const std = @import("std");

pub fn UnionFind(comptime T: type) type {
    return struct {
        const Self = @This();

        parent: []T,
        rank: []u32,
        size: []T,
        components: usize,
        allocator: std.mem.Allocator,

        pub fn init(allocator: std.mem.Allocator, n: usize) !Self {
            const parent = try allocator.alloc(T, n);
            const rank = try allocator.alloc(u32, n);
            const size = try allocator.alloc(T, n);

            for (0..n) |i| {
                parent[i] = @intCast(i);
                rank[i] = 0;
                size[i] = 1;
            }

            return Self{
                .parent = parent,
                .rank = rank,
                .size = size,
                .components = n,
                .allocator = allocator,
            };
        }

        pub fn deinit(self: *Self) void {
            self.allocator.free(self.parent);
            self.allocator.free(self.rank);
            self.allocator.free(self.size);
        }

        pub fn find(self: *Self, x: T) T {
            const idx: usize = @intCast(x);
            if (self.parent[idx] != x) {
                self.parent[idx] = self.find(self.parent[idx]);
            }
            return self.parent[idx];
        }

        pub fn unite(self: *Self, x: T, y: T) bool {
            var root_x = self.find(x);
            var root_y = self.find(y);

            if (root_x == root_y) return false;

            const rx: usize = @intCast(root_x);
            const ry: usize = @intCast(root_y);

            if (self.rank[rx] < self.rank[ry]) {
                const temp = root_x;
                root_x = root_y;
                root_y = temp;
            }

            const new_rx: usize = @intCast(root_x);
            const new_ry: usize = @intCast(root_y);

            self.parent[new_ry] = root_x;
            self.size[new_rx] += self.size[new_ry];

            if (self.rank[new_rx] == self.rank[new_ry]) {
                self.rank[new_rx] += 1;
            }

            self.components -= 1;
            return true;
        }

        pub fn connected(self: *Self, x: T, y: T) bool {
            return self.find(x) == self.find(y);
        }

        pub fn getSize(self: *Self, x: T) T {
            const root: usize = @intCast(self.find(x));
            return self.size[root];
        }

        pub fn getComponentCount(self: *const Self) usize {
            return self.components;
        }
    };
}

pub fn BloomFilter(comptime num_hashes: u32) type {
    return struct {
        const Self = @This();

        bits: []u8,
        bit_count: usize,
        allocator: std.mem.Allocator,
        item_count: usize,

        pub fn init(allocator: std.mem.Allocator, expected_items: usize, false_positive_rate: f64) !Self {
            const n: f64 = @floatFromInt(expected_items);
            const ln2 = @log(2.0);
            const m = @ceil(-n * @log(false_positive_rate) / (ln2 * ln2));
            const bit_count: usize = @intFromFloat(m);

            const byte_count = (bit_count + 7) / 8;
            const bits = try allocator.alloc(u8, byte_count);
            @memset(bits, 0);

            return Self{
                .bits = bits,
                .bit_count = bit_count,
                .allocator = allocator,
                .item_count = 0,
            };
        }

        pub fn deinit(self: *Self) void {
            self.allocator.free(self.bits);
        }

        fn getHashIndices(self: *const Self, data: []const u8) [num_hashes]usize {
            var indices: [num_hashes]usize = undefined;

            const h1 = std.hash.Fnv1a_64.hash(data);
            const h2 = std.hash.Murmur2_64.hash(data);

            for (0..num_hashes) |i| {
                const combined = h1 +% @as(u64, @intCast(i)) *% h2;
                indices[i] = @intCast(combined % self.bit_count);
            }

            return indices;
        }

        pub fn add(self: *Self, data: []const u8) void {
            const indices = self.getHashIndices(data);
            for (indices) |idx| {
                self.bits[idx / 8] |= @as(u8, 1) << @intCast(idx % 8);
            }
            self.item_count += 1;
        }

        pub fn mightContain(self: *const Self, data: []const u8) bool {
            const indices = self.getHashIndices(data);
            for (indices) |idx| {
                if (self.bits[idx / 8] & (@as(u8, 1) << @intCast(idx % 8)) == 0) {
                    return false;
                }
            }
            return true;
        }

        pub fn clear(self: *Self) void {
            @memset(self.bits, 0);
            self.item_count = 0;
        }

        pub fn estimatedFalsePositiveRate(self: *const Self) f64 {
            const m: f64 = @floatFromInt(self.bit_count);
            const n: f64 = @floatFromInt(self.item_count);
            const k: f64 = @floatFromInt(num_hashes);
            return std.math.pow(f64, 1.0 - std.math.exp(-k * n / m), k);
        }
    };
}

pub fn LRUCache(comptime K: type, comptime V: type) type {
    return struct {
        const Self = @This();

        const Node = struct {
            key: K,
            value: V,
            prev: ?*Node,
            next: ?*Node,
        };

        map: std.AutoHashMap(K, *Node),
        head: ?*Node,
        tail: ?*Node,
        capacity: usize,
        allocator: std.mem.Allocator,
        node_pool: std.heap.MemoryPool(Node),

        pub fn init(allocator: std.mem.Allocator, capacity: usize) Self {
            return Self{
                .map = std.AutoHashMap(K, *Node).init(allocator),
                .head = null,
                .tail = null,
                .capacity = capacity,
                .allocator = allocator,
                .node_pool = std.heap.MemoryPool(Node).init(allocator),
            };
        }

        pub fn deinit(self: *Self) void {
            self.map.deinit();
            self.node_pool.deinit();
        }

        fn removeNode(self: *Self, node: *Node) void {
            if (node.prev) |prev| {
                prev.next = node.next;
            } else {
                self.head = node.next;
            }

            if (node.next) |next| {
                next.prev = node.prev;
            } else {
                self.tail = node.prev;
            }
        }

        fn addToFront(self: *Self, node: *Node) void {
            node.next = self.head;
            node.prev = null;

            if (self.head) |head| {
                head.prev = node;
            }
            self.head = node;

            if (self.tail == null) {
                self.tail = node;
            }
        }

        fn moveToFront(self: *Self, node: *Node) void {
            self.removeNode(node);
            self.addToFront(node);
        }

        pub fn get(self: *Self, key: K) ?V {
            if (self.map.get(key)) |node| {
                self.moveToFront(node);
                return node.value;
            }
            return null;
        }

        pub fn put(self: *Self, key: K, value: V) !void {
            if (self.map.get(key)) |node| {
                node.value = value;
                self.moveToFront(node);
                return;
            }

            if (self.map.count() >= self.capacity) {
                if (self.tail) |lru| {
                    _ = self.map.remove(lru.key);
                    self.removeNode(lru);
                    self.node_pool.destroy(lru);
                }
            }

            const node = try self.node_pool.create();
            node.* = .{ .key = key, .value = value, .prev = null, .next = null };
            self.addToFront(node);
            try self.map.put(key, node);
        }

        pub fn contains(self: *const Self, key: K) bool {
            return self.map.contains(key);
        }

        pub fn size(self: *const Self) usize {
            return self.map.count();
        }

        pub fn clear(self: *Self) void {
            self.map.clearAndFree();
            self.head = null;
            self.tail = null;
            self.node_pool.deinit();
            self.node_pool = std.heap.MemoryPool(Node).init(self.allocator);
        }
    };
}

pub fn SkipList(comptime K: type, comptime V: type) type {
    return struct {
        const Self = @This();
        const MAX_LEVEL = 16;

        const Node = struct {
            key: K,
            value: V,
            forward: [MAX_LEVEL]?*Node,

            fn init(key: K, value: V) Node {
                return Node{
                    .key = key,
                    .value = value,
                    .forward = [_]?*Node{null} ** MAX_LEVEL,
                };
            }
        };

        head: *Node,
        level: usize,
        length: usize,
        allocator: std.mem.Allocator,
        prng: std.Random.DefaultPrng,

        pub fn init(allocator: std.mem.Allocator) !Self {
            const head = try allocator.create(Node);
            head.* = Node.init(undefined, undefined);
            @memset(&head.forward, null);

            return Self{
                .head = head,
                .level = 0,
                .length = 0,
                .allocator = allocator,
                .prng = std.Random.DefaultPrng.init(@intCast(std.time.timestamp())),
            };
        }

        pub fn deinit(self: *Self) void {
            var current = self.head;
            while (current.forward[0]) |next| {
                self.allocator.destroy(current);
                current = next;
            }
            self.allocator.destroy(current);
        }

        fn randomLevel(self: *Self) usize {
            var lvl: usize = 0;
            const random = self.prng.random();
            while (lvl < MAX_LEVEL - 1 and random.boolean()) {
                lvl += 1;
            }
            return lvl;
        }

        pub fn insert(self: *Self, key: K, value: V) !void {
            var update: [MAX_LEVEL]?*Node = [_]?*Node{null} ** MAX_LEVEL;
            var current = self.head;

            var i = self.level;
            while (true) : (i -= 1) {
                while (current.forward[i]) |next| {
                    if (next.key >= key) break;
                    current = next;
                }
                update[i] = current;
                if (i == 0) break;
            }

            const next = current.forward[0];
            if (next != null and next.?.key == key) {
                next.?.value = value;
                return;
            }

            const lvl = self.randomLevel();
            if (lvl > self.level) {
                for (self.level + 1..lvl + 1) |j| {
                    update[j] = self.head;
                }
                self.level = lvl;
            }

            const new_node = try self.allocator.create(Node);
            new_node.* = Node.init(key, value);

            for (0..lvl + 1) |j| {
                new_node.forward[j] = update[j].?.forward[j];
                update[j].?.forward[j] = new_node;
            }

            self.length += 1;
        }

        pub fn get(self: *Self, key: K) ?V {
            var current = self.head;

            var i = self.level;
            while (true) : (i -= 1) {
                while (current.forward[i]) |next| {
                    if (next.key >= key) break;
                    current = next;
                }
                if (i == 0) break;
            }

            if (current.forward[0]) |next| {
                if (next.key == key) {
                    return next.value;
                }
            }
            return null;
        }

        pub fn remove(self: *Self, key: K) bool {
            var update: [MAX_LEVEL]?*Node = [_]?*Node{null} ** MAX_LEVEL;
            var current = self.head;

            var i = self.level;
            while (true) : (i -= 1) {
                while (current.forward[i]) |next| {
                    if (next.key >= key) break;
                    current = next;
                }
                update[i] = current;
                if (i == 0) break;
            }

            const target = current.forward[0];
            if (target == null or target.?.key != key) {
                return false;
            }

            for (0..self.level + 1) |j| {
                if (update[j].?.forward[j] != target) break;
                update[j].?.forward[j] = target.?.forward[j];
            }

            self.allocator.destroy(target.?);

            while (self.level > 0 and self.head.forward[self.level] == null) {
                self.level -= 1;
            }

            self.length -= 1;
            return true;
        }

        pub fn len(self: *const Self) usize {
            return self.length;
        }
    };
}

pub fn Trie(comptime V: type) type {
    return struct {
        const Self = @This();
        const ALPHABET_SIZE = 256;

        const Node = struct {
            children: [ALPHABET_SIZE]?*Node,
            value: ?V,
            is_end: bool,

            fn init() Node {
                return Node{
                    .children = [_]?*Node{null} ** ALPHABET_SIZE,
                    .value = null,
                    .is_end = false,
                };
            }
        };

        root: *Node,
        allocator: std.mem.Allocator,
        size: usize,

        pub fn init(allocator: std.mem.Allocator) !Self {
            const root = try allocator.create(Node);
            root.* = Node.init();
            return Self{
                .root = root,
                .allocator = allocator,
                .size = 0,
            };
        }

        pub fn deinit(self: *Self) void {
            self.freeNode(self.root);
        }

        fn freeNode(self: *Self, node: *Node) void {
            for (node.children) |child| {
                if (child) |c| {
                    self.freeNode(c);
                }
            }
            self.allocator.destroy(node);
        }

        pub fn insert(self: *Self, key: []const u8, value: V) !void {
            var current = self.root;

            for (key) |c| {
                if (current.children[c] == null) {
                    const new_node = try self.allocator.create(Node);
                    new_node.* = Node.init();
                    current.children[c] = new_node;
                }
                current = current.children[c].?;
            }

            if (!current.is_end) {
                self.size += 1;
            }
            current.is_end = true;
            current.value = value;
        }

        pub fn get(self: *const Self, key: []const u8) ?V {
            var current = self.root;

            for (key) |c| {
                if (current.children[c] == null) {
                    return null;
                }
                current = current.children[c].?;
            }

            if (current.is_end) {
                return current.value;
            }
            return null;
        }

        pub fn contains(self: *const Self, key: []const u8) bool {
            return self.get(key) != null;
        }

        pub fn startsWith(self: *const Self, prefix: []const u8) bool {
            var current = self.root;

            for (prefix) |c| {
                if (current.children[c] == null) {
                    return false;
                }
                current = current.children[c].?;
            }

            return true;
        }

        pub fn len(self: *const Self) usize {
            return self.size;
        }
    };
}

// ============================================================================
// Tests
// ============================================================================

test "UnionFind" {
    const allocator = std.testing.allocator;
    var uf = try UnionFind(u32).init(allocator, 10);
    defer uf.deinit();

    try std.testing.expect(!uf.connected(0, 1));
    _ = uf.unite(0, 1);
    try std.testing.expect(uf.connected(0, 1));

    _ = uf.unite(2, 3);
    _ = uf.unite(0, 2);
    try std.testing.expect(uf.connected(1, 3));

    try std.testing.expectEqual(@as(u32, 4), uf.getSize(0));
}

test "BloomFilter" {
    const allocator = std.testing.allocator;
    var bloom = try BloomFilter(5).init(allocator, 1000, 0.01);
    defer bloom.deinit();

    bloom.add("hello");
    bloom.add("world");

    try std.testing.expect(bloom.mightContain("hello"));
    try std.testing.expect(bloom.mightContain("world"));
}

test "LRUCache" {
    const allocator = std.testing.allocator;
    var cache = LRUCache(u32, []const u8).init(allocator, 3);
    defer cache.deinit();

    try cache.put(1, "one");
    try cache.put(2, "two");
    try cache.put(3, "three");

    try std.testing.expectEqualStrings("one", cache.get(1).?);

    try cache.put(4, "four"); // Should evict 2

    try std.testing.expect(cache.get(2) == null);
    try std.testing.expect(cache.get(3) != null);
}

test "Trie" {
    const allocator = std.testing.allocator;
    var trie = try Trie(u32).init(allocator);
    defer trie.deinit();

    try trie.insert("hello", 1);
    try trie.insert("help", 2);
    try trie.insert("world", 3);

    try std.testing.expectEqual(@as(?u32, 1), trie.get("hello"));
    try std.testing.expectEqual(@as(?u32, 2), trie.get("help"));
    try std.testing.expect(trie.startsWith("hel"));
    try std.testing.expect(!trie.startsWith("xyz"));
}
