const std = @import("std");
const core = @import("../core/mod.zig");
const Allocator = std.mem.Allocator;

pub fn SliceIterator(comptime T: type) type {
    return struct {
        const Self = @This();

        slice: []const T,
        index: usize,

        pub fn init(data: []const T) Self {
            return .{
                .slice = data,
                .index = 0,
            };
        }

        pub fn fromArray(comptime N: usize, array: *const [N]T) Self {
            return init(array[0..]);
        }

        pub fn next(self: *Self) ?T {
            if (self.index >= self.slice.len) return null;
            const value = self.slice[self.index];
            self.index += 1;
            return value;
        }

        pub fn peek(self: *const Self) ?T {
            if (self.index >= self.slice.len) return null;
            return self.slice[self.index];
        }

        pub fn prev(self: *Self) ?T {
            if (self.index == 0) return null;
            self.index -= 1;
            return self.slice[self.index];
        }

        pub inline fn hasNext(self: *const Self) bool {
            return self.index < self.slice.len;
        }

        pub inline fn remaining(self: *const Self) usize {
            return self.slice.len - self.index;
        }

        pub fn reset(self: *Self) void {
            self.index = 0;
        }

        pub fn get(self: *const Self, index: usize) ?T {
            if (index >= self.slice.len) return null;
            return self.slice[index];
        }

        pub fn getRelative(self: *const Self, offset: usize) ?T {
            const abs_index = self.index + offset;
            if (abs_index >= self.slice.len) return null;
            return self.slice[abs_index];
        }

        pub fn getPtr(self: *const Self, index: usize) ?*const T {
            if (index >= self.slice.len) return null;
            return &self.slice[index];
        }

        pub inline fn len(self: *const Self) usize {
            return self.slice.len;
        }

        pub inline fn isEmpty(self: *const Self) bool {
            return self.slice.len == 0;
        }

        pub inline fn position(self: *const Self) usize {
            return self.index;
        }

        pub fn rest(self: *const Self) []const T {
            return self.slice[self.index..];
        }

        pub fn slice(self: *const Self, start: usize, end: usize) Self {
            const actual_start = @min(start, self.slice.len);
            const actual_end = @min(end, self.slice.len);
            return Self{
                .slice = self.slice[actual_start..actual_end],
                .index = 0,
            };
        }

        pub fn skip(self: *Self, n: usize) *Self {
            self.index = @min(self.index + n, self.slice.len);
            return self;
        }

        pub fn take(self: *Self, n: usize) []const T {
            const available = self.remaining();
            const take_count = @min(n, available);
            const result = self.slice[self.index .. self.index + take_count];
            self.index += take_count;
            return result;
        }

        pub fn forEach(self: *Self, comptime f: fn (T) void) void {
            while (self.next()) |item| {
                f(item);
            }
        }

        pub fn fold(self: *Self, comptime Acc: type, initial: Acc, comptime f: fn (Acc, T) Acc) Acc {
            var acc = initial;
            while (self.next()) |item| {
                acc = f(acc, item);
            }
            return acc;
        }

        pub fn tryFold(
            self: *Self,
            comptime Acc: type,
            initial: Acc,
            comptime f: fn (Acc, T) anyerror!Acc,
        ) !Acc {
            var acc = initial;
            while (self.next()) |item| {
                acc = try f(acc, item);
            }
            return acc;
        }

        pub fn any(self: *Self, comptime pred: fn (T) bool) bool {
            while (self.next()) |item| {
                if (pred(item)) return true;
            }
            return false;
        }

        pub fn all(self: *Self, comptime pred: fn (T) bool) bool {
            while (self.next()) |item| {
                if (!pred(item)) return false;
            }
            return true;
        }

        pub fn none(self: *Self, comptime pred: fn (T) bool) bool {
            return !self.any(pred);
        }

        pub fn find(self: *Self, comptime pred: fn (T) bool) ?T {
            while (self.next()) |item| {
                if (pred(item)) return item;
            }
            return null;
        }

        pub fn findIndex(self: *Self, comptime pred: fn (T) bool) ?usize {
            const start = self.index;
            while (self.next()) |item| {
                if (pred(item)) return self.index - 1 - start;
            }
            return null;
        }

        pub fn count(self: *Self, comptime pred: fn (T) bool) usize {
            var c: usize = 0;
            while (self.next()) |item| {
                if (pred(item)) c += 1;
            }
            return c;
        }

        pub fn countAll(self: *Self) usize {
            const c = self.remaining();
            self.index = self.slice.len;
            return c;
        }

        pub fn collect(self: *Self, allocator: Allocator) ![]T {
            const rem = self.remaining();
            if (rem == 0) return &[_]T{};

            const result = try allocator.alloc(T, rem);
            @memcpy(result, self.slice[self.index..]);
            self.index = self.slice.len;
            return result;
        }

        pub fn filter(self: *Self, allocator: Allocator, comptime pred: fn (T) bool) ![]T {
            var list = std.ArrayList(T).init(allocator);
            errdefer list.deinit();

            while (self.next()) |item| {
                if (pred(item)) {
                    try list.append(item);
                }
            }

            return list.toOwnedSlice();
        }

        pub fn map(
            self: *Self,
            comptime U: type,
            allocator: Allocator,
            comptime f: fn (T) U,
        ) ![]U {
            const rem = self.remaining();
            if (rem == 0) return &[_]U{};

            const result = try allocator.alloc(U, rem);
            var i: usize = 0;
            while (self.next()) |item| {
                result[i] = f(item);
                i += 1;
            }
            return result;
        }

        pub fn partition(
            self: *Self,
            allocator: Allocator,
            comptime pred: fn (T) bool,
        ) !core.BifurcateResult(T) {
            var matching = std.ArrayList(T).init(allocator);
            errdefer matching.deinit();
            var non_matching = std.ArrayList(T).init(allocator);
            errdefer non_matching.deinit();

            while (self.next()) |item| {
                if (pred(item)) {
                    try matching.append(item);
                } else {
                    try non_matching.append(item);
                }
            }

            return .{
                .matching = try matching.toOwnedSlice(),
                .non_matching = try non_matching.toOwnedSlice(),
                .allocator = allocator,
            };
        }

        pub fn sum(self: *Self) T {
            comptime core.assertNumeric(T);
            return self.fold(T, 0, struct {
                fn add(acc: T, x: T) T {
                    return acc + x;
                }
            }.add);
        }

        pub fn product(self: *Self) T {
            comptime core.assertNumeric(T);
            return self.fold(T, 1, struct {
                fn mul(acc: T, x: T) T {
                    return acc * x;
                }
            }.mul);
        }

        pub fn min(self: *Self) ?T {
            comptime core.assertComparable(T);
            var result: ?T = self.next();
            while (self.next()) |item| {
                if (result) |r| {
                    if (std.math.order(item, r) == .lt) {
                        result = item;
                    }
                }
            }
            return result;
        }

        pub fn max(self: *Self) ?T {
            comptime core.assertComparable(T);
            var result: ?T = self.next();
            while (self.next()) |item| {
                if (result) |r| {
                    if (std.math.order(item, r) == .gt) {
                        result = item;
                    }
                }
            }
            return result;
        }
    };
}

pub fn iter(comptime T: type, slice: []const T) SliceIterator(T) {
    return SliceIterator(T).init(slice);
}

pub fn iterArray(comptime T: type, comptime N: usize, array: *const [N]T) SliceIterator(T) {
    return SliceIterator(T).fromArray(N, array);
}

test "SliceIterator basic iteration" {
    const data = [_]i32{ 1, 2, 3, 4, 5 };
    var it = SliceIterator(i32).init(&data);

    try std.testing.expectEqual(@as(?i32, 1), it.next());
    try std.testing.expectEqual(@as(?i32, 2), it.next());
    try std.testing.expectEqual(@as(?i32, 3), it.peek());
    try std.testing.expectEqual(@as(?i32, 3), it.next());
    try std.testing.expectEqual(@as(usize, 2), it.remaining());
}

test "SliceIterator fold" {
    const data = [_]i32{ 1, 2, 3, 4, 5 };
    var it = SliceIterator(i32).init(&data);

    const sum = it.fold(i32, 0, struct {
        fn add(acc: i32, x: i32) i32 {
            return acc + x;
        }
    }.add);

    try std.testing.expectEqual(@as(i32, 15), sum);
}

test "SliceIterator filter" {
    const data = [_]i32{ 1, 2, 3, 4, 5, 6 };
    var it = SliceIterator(i32).init(&data);

    const allocator = std.testing.allocator;
    const evens = try it.filter(allocator, struct {
        fn isEven(x: i32) bool {
            return @rem(x, 2) == 0;
        }
    }.isEven);
    defer allocator.free(evens);

    try std.testing.expectEqualSlices(i32, &[_]i32{ 2, 4, 6 }, evens);
}

test "SliceIterator sum" {
    const data = [_]i32{ 1, 2, 3, 4, 5 };
    var it = SliceIterator(i32).init(&data);
    try std.testing.expectEqual(@as(i32, 15), it.sum());
}

test "SliceIterator min/max" {
    const data = [_]i32{ 3, 1, 4, 1, 5, 9, 2, 6 };

    var it1 = SliceIterator(i32).init(&data);
    try std.testing.expectEqual(@as(?i32, 1), it1.min());

    var it2 = SliceIterator(i32).init(&data);
    try std.testing.expectEqual(@as(?i32, 9), it2.max());
}

test "SliceIterator skip and take" {
    const data = [_]i32{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    var it = SliceIterator(i32).init(&data);

    _ = it.skip(3);
    const taken = it.take(4);

    try std.testing.expectEqualSlices(i32, &[_]i32{ 4, 5, 6, 7 }, taken);
}

test "SliceIterator partition" {
    const data = [_]i32{ 1, 2, 3, 4, 5, 6 };
    var it = SliceIterator(i32).init(&data);

    const allocator = std.testing.allocator;
    var result = try it.partition(allocator, struct {
        fn isEven(x: i32) bool {
            return @rem(x, 2) == 0;
        }
    }.isEven);
    defer result.deinit();

    try std.testing.expectEqualSlices(i32, &[_]i32{ 2, 4, 6 }, result.matching);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 1, 3, 5 }, result.non_matching);
}
