const std = @import("std");

pub fn Interval(comptime T: type) type {
    return struct {
        start: T,
        end: T,

        pub fn init(start: T, end: T) @This() {
            return .{ .start = start, .end = end };
        }

        pub fn contains(self: @This(), point: T) bool {
            return point >= self.start and point <= self.end;
        }

        pub fn overlaps(self: @This(), other: @This()) bool {
            return self.start <= other.end and other.start <= self.end;
        }

        pub fn merge(self: @This(), other: @This()) ?@This() {
            if (!self.overlaps(other) and self.end + 1 != other.start and other.end + 1 != self.start) {
                return null;
            }
            return .{
                .start = @min(self.start, other.start),
                .end = @max(self.end, other.end),
            };
        }

        pub fn intersect(self: @This(), other: @This()) ?@This() {
            if (!self.overlaps(other)) return null;
            return .{
                .start = @max(self.start, other.start),
                .end = @min(self.end, other.end),
            };
        }

        pub fn length(self: @This()) T {
            return self.end - self.start;
        }

        fn lessThan(_: void, a: @This(), b: @This()) bool {
            if (a.start != b.start) return a.start < b.start;
            return a.end < b.end;
        }
    };
}

pub fn mergeIntervals(comptime T: type, allocator: std.mem.Allocator, intervals: []const Interval(T)) ![]Interval(T) {
    if (intervals.len == 0) return &[_]Interval(T){};
    if (intervals.len == 1) {
        const result = try allocator.alloc(Interval(T), 1);
        result[0] = intervals[0];
        return result;
    }

    const sorted = try allocator.alloc(Interval(T), intervals.len);
    defer allocator.free(sorted);
    @memcpy(sorted, intervals);
    std.mem.sort(Interval(T), sorted, {}, Interval(T).lessThan);

    var result = std.ArrayList(Interval(T)).init(allocator);
    errdefer result.deinit();

    try result.append(sorted[0]);

    for (sorted[1..]) |interval| {
        const last = &result.items[result.items.len - 1];
        if (last.overlaps(interval) or last.end + 1 == interval.start) {
            last.end = @max(last.end, interval.end);
        } else {
            try result.append(interval);
        }
    }

    return result.toOwnedSlice();
}

pub fn findOverlapping(comptime T: type, allocator: std.mem.Allocator, intervals: []const Interval(T), query: Interval(T)) ![]Interval(T) {
    var result = std.ArrayList(Interval(T)).init(allocator);
    errdefer result.deinit();

    for (intervals) |interval| {
        if (interval.overlaps(query)) {
            try result.append(interval);
        }
    }

    return result.toOwnedSlice();
}

pub fn IntervalTree(comptime T: type) type {
    return struct {
        const Self = @This();
        const Int = Interval(T);

        const Node = struct {
            interval: Int,
            max_end: T,
            left: ?*Node,
            right: ?*Node,
        };

        root: ?*Node,
        allocator: std.mem.Allocator,
        size: usize,

        pub fn init(allocator: std.mem.Allocator) Self {
            return Self{
                .root = null,
                .allocator = allocator,
                .size = 0,
            };
        }

        pub fn deinit(self: *Self) void {
            self.freeNode(self.root);
        }

        fn freeNode(self: *Self, node: ?*Node) void {
            if (node) |n| {
                self.freeNode(n.left);
                self.freeNode(n.right);
                self.allocator.destroy(n);
            }
        }

        pub fn insert(self: *Self, interval: Int) !void {
            self.root = try self.insertNode(self.root, interval);
            self.size += 1;
        }

        fn insertNode(self: *Self, node: ?*Node, interval: Int) !*Node {
            if (node == null) {
                const new_node = try self.allocator.create(Node);
                new_node.* = .{
                    .interval = interval,
                    .max_end = interval.end,
                    .left = null,
                    .right = null,
                };
                return new_node;
            }

            const n = node.?;
            n.max_end = @max(n.max_end, interval.end);

            if (interval.start < n.interval.start) {
                n.left = try self.insertNode(n.left, interval);
            } else {
                n.right = try self.insertNode(n.right, interval);
            }

            return n;
        }

        pub fn queryOverlapping(self: *Self, allocator: std.mem.Allocator, query: Int) ![]Int {
            var result = std.ArrayList(Int).init(allocator);
            errdefer result.deinit();
            try self.queryNode(self.root, query, &result);
            return result.toOwnedSlice();
        }

        fn queryNode(self: *Self, node: ?*Node, query: Int, result: *std.ArrayList(Int)) !void {
            if (node == null) return;

            const n = node.?;

            if (n.interval.overlaps(query)) {
                try result.append(n.interval);
            }

            if (n.left != null and n.left.?.max_end >= query.start) {
                try self.queryNode(n.left, query, result);
            }

            if (n.right != null and n.interval.start <= query.end) {
                try self.queryNode(n.right, query, result);
            }
        }

        pub fn queryPoint(self: *Self, allocator: std.mem.Allocator, point: T) ![]Int {
            return self.queryOverlapping(allocator, Int.init(point, point));
        }

        pub fn len(self: *const Self) usize {
            return self.size;
        }
    };
}

pub fn maxNonOverlapping(comptime T: type, allocator: std.mem.Allocator, intervals: []const Interval(T)) ![]Interval(T) {
    if (intervals.len == 0) return &[_]Interval(T){};

    const sorted = try allocator.alloc(Interval(T), intervals.len);
    defer allocator.free(sorted);
    @memcpy(sorted, intervals);

    const EndTimeLessThan = struct {
        fn lessThan(_: void, a: Interval(T), b: Interval(T)) bool {
            return a.end < b.end;
        }
    };

    std.mem.sort(Interval(T), sorted, {}, EndTimeLessThan.lessThan);

    var result = std.ArrayList(Interval(T)).init(allocator);
    errdefer result.deinit();

    var last_end: T = 0;

    for (sorted) |interval| {
        if (interval.start >= last_end or result.items.len == 0) {
            try result.append(interval);
            last_end = interval.end;
        }
    }

    return result.toOwnedSlice();
}

pub fn minMeetingRooms(comptime T: type, intervals: []const Interval(T)) usize {
    if (intervals.len == 0) return 0;

    const Event = struct {
        time: T,
        is_start: bool,

        fn lessThan(_: void, a: @This(), b: @This()) bool {
            if (a.time != b.time) return a.time < b.time;
            return !a.is_start and b.is_start;
        }
    };

    var events: [256]Event = undefined;
    var event_count: usize = 0;

    for (intervals) |interval| {
        if (event_count + 2 > 256) break;
        events[event_count] = .{ .time = interval.start, .is_start = true };
        event_count += 1;
        events[event_count] = .{ .time = interval.end, .is_start = false };
        event_count += 1;
    }

    std.mem.sort(Event, events[0..event_count], {}, Event.lessThan);

    var current_rooms: usize = 0;
    var max_rooms: usize = 0;

    for (events[0..event_count]) |event| {
        if (event.is_start) {
            current_rooms += 1;
            max_rooms = @max(max_rooms, current_rooms);
        } else {
            current_rooms -= 1;
        }
    }

    return max_rooms;
}

pub fn insertInterval(comptime T: type, allocator: std.mem.Allocator, intervals: []const Interval(T), new_interval: Interval(T)) ![]Interval(T) {
    var result = std.ArrayList(Interval(T)).init(allocator);
    errdefer result.deinit();

    var merged = new_interval;
    var inserted = false;

    for (intervals) |interval| {
        if (interval.end < merged.start) {
            try result.append(interval);
        } else if (interval.start > merged.end) {
            if (!inserted) {
                try result.append(merged);
                inserted = true;
            }
            try result.append(interval);
        } else {
            merged.start = @min(merged.start, interval.start);
            merged.end = @max(merged.end, interval.end);
        }
    }

    if (!inserted) {
        try result.append(merged);
    }

    return result.toOwnedSlice();
}

pub fn totalCoverage(comptime T: type, allocator: std.mem.Allocator, intervals: []const Interval(T)) !T {
    const merged = try mergeIntervals(T, allocator, intervals);
    defer allocator.free(merged);

    var total: T = 0;
    for (merged) |interval| {
        total += interval.end - interval.start;
    }
    return total;
}

test "Interval basic operations" {
    const interval1 = Interval(i32).init(1, 5);
    const interval2 = Interval(i32).init(3, 8);
    const interval3 = Interval(i32).init(10, 15);

    try std.testing.expect(interval1.overlaps(interval2));
    try std.testing.expect(!interval1.overlaps(interval3));
    try std.testing.expect(interval1.contains(3));
    try std.testing.expect(!interval1.contains(6));

    const merged = interval1.merge(interval2);
    try std.testing.expect(merged != null);
    try std.testing.expectEqual(@as(i32, 1), merged.?.start);
    try std.testing.expectEqual(@as(i32, 8), merged.?.end);
}

test "mergeIntervals" {
    const allocator = std.testing.allocator;

    const intervals = [_]Interval(i32){
        Interval(i32).init(1, 3),
        Interval(i32).init(2, 6),
        Interval(i32).init(8, 10),
        Interval(i32).init(15, 18),
    };

    const merged = try mergeIntervals(i32, allocator, &intervals);
    defer allocator.free(merged);

    try std.testing.expectEqual(@as(usize, 3), merged.len);
    try std.testing.expectEqual(@as(i32, 1), merged[0].start);
    try std.testing.expectEqual(@as(i32, 6), merged[0].end);
}

test "IntervalTree" {
    const allocator = std.testing.allocator;
    var tree = IntervalTree(i32).init(allocator);
    defer tree.deinit();

    try tree.insert(Interval(i32).init(15, 20));
    try tree.insert(Interval(i32).init(10, 30));
    try tree.insert(Interval(i32).init(5, 20));
    try tree.insert(Interval(i32).init(12, 15));

    const overlapping = try tree.queryOverlapping(allocator, Interval(i32).init(14, 16));
    defer allocator.free(overlapping);

    try std.testing.expect(overlapping.len >= 2);
}

test "maxNonOverlapping" {
    const allocator = std.testing.allocator;

    const intervals = [_]Interval(i32){
        Interval(i32).init(0, 6),
        Interval(i32).init(1, 4),
        Interval(i32).init(5, 7),
        Interval(i32).init(8, 9),
    };

    const result = try maxNonOverlapping(i32, allocator, &intervals);
    defer allocator.free(result);

    try std.testing.expect(result.len >= 2);
}

test "minMeetingRooms" {
    const intervals = [_]Interval(i32){
        Interval(i32).init(0, 30),
        Interval(i32).init(5, 10),
        Interval(i32).init(15, 20),
    };

    const rooms = minMeetingRooms(i32, &intervals);
    try std.testing.expectEqual(@as(usize, 2), rooms);
}

test "insertInterval" {
    const allocator = std.testing.allocator;

    const intervals = [_]Interval(i32){
        Interval(i32).init(1, 3),
        Interval(i32).init(6, 9),
    };

    const result = try insertInterval(i32, allocator, &intervals, Interval(i32).init(2, 5));
    defer allocator.free(result);

    try std.testing.expectEqual(@as(usize, 2), result.len);
    try std.testing.expectEqual(@as(i32, 1), result[0].start);
    try std.testing.expectEqual(@as(i32, 5), result[0].end);
}
