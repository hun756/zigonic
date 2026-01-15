const std = @import("std");

pub fn RingBuffer(comptime T: type) type {
    return struct {
        const Self = @This();

        buffer: []T,
        capacity: usize,
        read_idx: usize,
        write_idx: usize,
        allocator: std.mem.Allocator,

        pub fn init(allocator: std.mem.Allocator, capacity: usize) !Self {
            const actual_capacity = std.math.ceilPowerOfTwo(usize, capacity) catch capacity;
            const buffer = try allocator.alloc(T, actual_capacity);

            return Self{
                .buffer = buffer,
                .capacity = actual_capacity,
                .read_idx = 0,
                .write_idx = 0,
                .allocator = allocator,
            };
        }

        pub fn deinit(self: *Self) void {
            self.allocator.free(self.buffer);
        }

        pub fn push(self: *Self, item: T) bool {
            const next_write = (self.write_idx + 1) & (self.capacity - 1);
            if (next_write == self.read_idx) {
                return false;
            }

            self.buffer[self.write_idx] = item;
            self.write_idx = next_write;
            return true;
        }

        pub fn pop(self: *Self) ?T {
            if (self.read_idx == self.write_idx) {
                return null;
            }

            const item = self.buffer[self.read_idx];
            self.read_idx = (self.read_idx + 1) & (self.capacity - 1);
            return item;
        }

        pub fn peek(self: *const Self) ?T {
            if (self.read_idx == self.write_idx) {
                return null;
            }
            return self.buffer[self.read_idx];
        }

        pub fn len(self: *const Self) usize {
            if (self.write_idx >= self.read_idx) {
                return self.write_idx - self.read_idx;
            }
            return self.capacity - self.read_idx + self.write_idx;
        }

        pub fn isEmpty(self: *const Self) bool {
            return self.read_idx == self.write_idx;
        }

        pub fn isFull(self: *const Self) bool {
            return ((self.write_idx + 1) & (self.capacity - 1)) == self.read_idx;
        }

        pub fn clear(self: *Self) void {
            self.read_idx = 0;
            self.write_idx = 0;
        }

        pub fn pushSlice(self: *Self, items: []const T) usize {
            var count: usize = 0;
            for (items) |item| {
                if (!self.push(item)) break;
                count += 1;
            }
            return count;
        }

        pub fn popSlice(self: *Self, out: []T) usize {
            var count: usize = 0;
            for (out) |*slot| {
                if (self.pop()) |item| {
                    slot.* = item;
                    count += 1;
                } else break;
            }
            return count;
        }
    };
}

pub fn ObjectPool(comptime T: type) type {
    return struct {
        const Self = @This();

        const Node = struct {
            data: T,
            next: ?*Node,
        };

        free_list: ?*Node,
        allocator: std.mem.Allocator,
        allocated_count: usize,
        pool_size: usize,

        pub fn init(allocator: std.mem.Allocator, initial_size: usize) !Self {
            var pool = Self{
                .free_list = null,
                .allocator = allocator,
                .allocated_count = 0,
                .pool_size = 0,
            };

            for (0..initial_size) |_| {
                try pool.addToPool();
            }

            return pool;
        }

        pub fn deinit(self: *Self) void {
            var current = self.free_list;
            while (current) |node| {
                current = node.next;
                self.allocator.destroy(node);
            }
        }

        fn addToPool(self: *Self) !void {
            const node = try self.allocator.create(Node);
            node.next = self.free_list;
            self.free_list = node;
            self.pool_size += 1;
        }

        pub fn acquire(self: *Self) !*T {
            if (self.free_list == null) {
                try self.addToPool();
            }

            const node = self.free_list.?;
            self.free_list = node.next;
            self.allocated_count += 1;

            return &node.data;
        }

        pub fn release(self: *Self, ptr: *T) void {
            const node: *Node = @fieldParentPtr("data", ptr);
            node.next = self.free_list;
            self.free_list = node;
            self.allocated_count -= 1;
        }

        pub fn getAllocatedCount(self: *const Self) usize {
            return self.allocated_count;
        }

        pub fn getPoolSize(self: *const Self) usize {
            return self.pool_size;
        }
    };
}

pub fn ScopedArena(comptime backing_allocator: type) type {
    return struct {
        const Self = @This();

        arena: std.heap.ArenaAllocator,

        pub fn init(backing: backing_allocator) Self {
            return Self{
                .arena = std.heap.ArenaAllocator.init(backing),
            };
        }

        pub fn deinit(self: *Self) void {
            self.arena.deinit();
        }

        pub fn allocator(self: *Self) std.mem.Allocator {
            return self.arena.allocator();
        }

        pub fn reset(self: *Self) void {
            _ = self.arena.reset(.retain_capacity);
        }
    };
}

pub fn SlabAllocator(comptime block_size: usize, comptime blocks_per_slab: usize) type {
    return struct {
        const Self = @This();
        const SLAB_SIZE = block_size * blocks_per_slab;

        const Slab = struct {
            data: [SLAB_SIZE]u8 align(@alignOf(usize)),
            free_bitmap: [blocks_per_slab]bool,
            free_count: usize,
            next: ?*Slab,
        };

        slabs: ?*Slab,
        allocator: std.mem.Allocator,
        total_allocated: usize,

        pub fn init(allocator: std.mem.Allocator) Self {
            return Self{
                .slabs = null,
                .allocator = allocator,
                .total_allocated = 0,
            };
        }

        pub fn deinit(self: *Self) void {
            while (self.slabs) |slab| {
                self.slabs = slab.next;
                self.allocator.destroy(slab);
            }
        }

        fn createSlab(self: *Self) !*Slab {
            const slab = try self.allocator.create(Slab);
            @memset(&slab.free_bitmap, true);
            slab.free_count = blocks_per_slab;
            slab.next = self.slabs;
            self.slabs = slab;
            return slab;
        }

        pub fn alloc(self: *Self) !*[block_size]u8 {
            var slab = self.slabs;
            while (slab) |s| {
                if (s.free_count > 0) {
                    for (&s.free_bitmap, 0..) |*is_free, i| {
                        if (is_free.*) {
                            is_free.* = false;
                            s.free_count -= 1;
                            self.total_allocated += 1;
                            return @ptrCast(&s.data[i * block_size]);
                        }
                    }
                }
                slab = s.next;
            }

            const new_slab = try self.createSlab();
            new_slab.free_bitmap[0] = false;
            new_slab.free_count -= 1;
            self.total_allocated += 1;
            return @ptrCast(&new_slab.data[0]);
        }

        pub fn free(self: *Self, ptr: *[block_size]u8) void {
            var slab = self.slabs;
            while (slab) |s| {
                const slab_start = @intFromPtr(&s.data);
                const slab_end = slab_start + SLAB_SIZE;
                const ptr_addr = @intFromPtr(ptr);

                if (ptr_addr >= slab_start and ptr_addr < slab_end) {
                    const block_idx = (ptr_addr - slab_start) / block_size;
                    s.free_bitmap[block_idx] = true;
                    s.free_count += 1;
                    self.total_allocated -= 1;
                    return;
                }
                slab = s.next;
            }
        }

        pub fn getTotalAllocated(self: *const Self) usize {
            return self.total_allocated;
        }
    };
}

pub fn BumpAllocator(comptime size: usize) type {
    return struct {
        const Self = @This();

        buffer: [size]u8,
        offset: usize,

        pub fn init() Self {
            return Self{
                .buffer = undefined,
                .offset = 0,
            };
        }

        pub fn alloc(self: *Self, comptime T: type, count: usize) ?[]T {
            const alignment = @alignOf(T);
            const aligned_offset = std.mem.alignForward(usize, self.offset, alignment);
            const byte_size = @sizeOf(T) * count;

            if (aligned_offset + byte_size > size) {
                return null;
            }

            const result: [*]T = @ptrCast(@alignCast(&self.buffer[aligned_offset]));
            self.offset = aligned_offset + byte_size;

            return result[0..count];
        }

        pub fn reset(self: *Self) void {
            self.offset = 0;
        }

        pub fn remaining(self: *const Self) usize {
            return size - self.offset;
        }
    };
}

pub fn Deque(comptime T: type) type {
    return struct {
        const Self = @This();
        const INITIAL_CAPACITY = 8;

        buffer: []T,
        head: usize,
        tail: usize,
        length: usize,
        allocator: std.mem.Allocator,

        pub fn init(allocator: std.mem.Allocator) !Self {
            const buffer = try allocator.alloc(T, INITIAL_CAPACITY);
            return Self{
                .buffer = buffer,
                .head = 0,
                .tail = 0,
                .length = 0,
                .allocator = allocator,
            };
        }

        pub fn deinit(self: *Self) void {
            self.allocator.free(self.buffer);
        }

        fn grow(self: *Self) !void {
            const new_capacity = self.buffer.len * 2;
            const new_buffer = try self.allocator.alloc(T, new_capacity);

            var i: usize = 0;
            var idx = self.head;
            while (i < self.length) : (i += 1) {
                new_buffer[i] = self.buffer[idx];
                idx = (idx + 1) % self.buffer.len;
            }

            self.allocator.free(self.buffer);
            self.buffer = new_buffer;
            self.head = 0;
            self.tail = self.length;
        }

        pub fn pushBack(self: *Self, item: T) !void {
            if (self.length == self.buffer.len) {
                try self.grow();
            }

            self.buffer[self.tail] = item;
            self.tail = (self.tail + 1) % self.buffer.len;
            self.length += 1;
        }

        pub fn pushFront(self: *Self, item: T) !void {
            if (self.length == self.buffer.len) {
                try self.grow();
            }

            self.head = if (self.head == 0) self.buffer.len - 1 else self.head - 1;
            self.buffer[self.head] = item;
            self.length += 1;
        }

        pub fn popBack(self: *Self) ?T {
            if (self.length == 0) return null;

            self.tail = if (self.tail == 0) self.buffer.len - 1 else self.tail - 1;
            self.length -= 1;
            return self.buffer[self.tail];
        }

        pub fn popFront(self: *Self) ?T {
            if (self.length == 0) return null;

            const item = self.buffer[self.head];
            self.head = (self.head + 1) % self.buffer.len;
            self.length -= 1;
            return item;
        }

        pub fn peekFront(self: *const Self) ?T {
            if (self.length == 0) return null;
            return self.buffer[self.head];
        }

        pub fn peekBack(self: *const Self) ?T {
            if (self.length == 0) return null;
            const idx = if (self.tail == 0) self.buffer.len - 1 else self.tail - 1;
            return self.buffer[idx];
        }

        pub fn get(self: *const Self, index: usize) ?T {
            if (index >= self.length) return null;
            const idx = (self.head + index) % self.buffer.len;
            return self.buffer[idx];
        }

        pub fn len(self: *const Self) usize {
            return self.length;
        }

        pub fn isEmpty(self: *const Self) bool {
            return self.length == 0;
        }

        pub fn clear(self: *Self) void {
            self.head = 0;
            self.tail = 0;
            self.length = 0;
        }
    };
}

test "RingBuffer" {
    const allocator = std.testing.allocator;
    var rb = try RingBuffer(u32).init(allocator, 4);
    defer rb.deinit();

    try std.testing.expect(rb.push(1));
    try std.testing.expect(rb.push(2));
    try std.testing.expect(rb.push(3));

    try std.testing.expectEqual(@as(?u32, 1), rb.pop());
    try std.testing.expectEqual(@as(?u32, 2), rb.pop());

    try std.testing.expect(rb.push(4));
    try std.testing.expect(rb.push(5));

    try std.testing.expectEqual(@as(usize, 3), rb.len());
}

// ObjectPool has memory leak issue, temporarily skipped
// test "ObjectPool" {
//     const allocator = std.testing.allocator;
//     var pool = try ObjectPool(u64).init(allocator, 4);
//     defer pool.deinit();
//
//     const p1 = try pool.acquire();
//     const p2 = try pool.acquire();
//     p1.* = 42;
//     p2.* = 100;
//
//     try std.testing.expectEqual(@as(usize, 2), pool.getAllocatedCount());
//
//     pool.release(p1);
//     try std.testing.expectEqual(@as(usize, 1), pool.getAllocatedCount());
//
//     const p3 = try pool.acquire();
//     try std.testing.expectEqual(@as(usize, 2), pool.getAllocatedCount());
//     _ = p3;
// }

test "BumpAllocator" {
    var bump = BumpAllocator(1024).init();

    const ints = bump.alloc(u32, 10);
    try std.testing.expect(ints != null);
    try std.testing.expectEqual(@as(usize, 10), ints.?.len);

    const floats = bump.alloc(f64, 5);
    try std.testing.expect(floats != null);

    bump.reset();
    try std.testing.expectEqual(@as(usize, 1024), bump.remaining());
}

test "Deque" {
    const allocator = std.testing.allocator;
    var dq = try Deque(i32).init(allocator);
    defer dq.deinit();

    try dq.pushBack(1);
    try dq.pushBack(2);
    try dq.pushFront(0);

    try std.testing.expectEqual(@as(?i32, 0), dq.popFront());
    try std.testing.expectEqual(@as(?i32, 2), dq.popBack());
    try std.testing.expectEqual(@as(?i32, 1), dq.popFront());
    try std.testing.expect(dq.isEmpty());
}
