const std = @import("std");

pub const Order = std.math.Order;

pub fn Range(comptime T: type) type {
    return struct {
        const Self = @This();

        start: T,
        end: T,

        pub fn init(start: T, end: T) Self {
            return .{ .start = start, .end = end };
        }

        pub fn isEmpty(self: Self) bool {
            return self.start >= self.end;
        }

        pub fn len(self: Self) T {
            if (self.isEmpty()) return 0;
            return self.end - self.start;
        }

        pub fn contains(self: Self, value: T) bool {
            return value >= self.start and value < self.end;
        }

        pub fn intersect(self: Self, other: Self) ?Self {
            const new_start = @max(self.start, other.start);
            const new_end = @min(self.end, other.end);
            if (new_start >= new_end) return null;
            return Self.init(new_start, new_end);
        }
    };
}

pub fn Pair(comptime T: type) type {
    return struct {
        first: T,
        second: T,

        pub fn init(first: T, second: T) @This() {
            return .{ .first = first, .second = second };
        }
    };
}

pub fn Tuple(comptime T1: type, comptime T2: type) type {
    return struct {
        first: T1,
        second: T2,

        pub fn init(first: T1, second: T2) @This() {
            return .{ .first = first, .second = second };
        }
    };
}

pub fn Maybe(comptime T: type, comptime E: type) type {
    return union(enum) {
        some: T,
        none: E,

        pub fn just(value: T) @This() {
            return .{ .some = value };
        }

        pub fn nothing(reason: E) @This() {
            return .{ .none = reason };
        }

        pub fn unwrap(self: @This()) ?T {
            return switch (self) {
                .some => |v| v,
                .none => null,
            };
        }

        pub fn unwrapOr(self: @This(), default: T) T {
            return switch (self) {
                .some => |v| v,
                .none => default,
            };
        }
    };
}

pub fn BifurcateResult(comptime T: type) type {
    return struct {
        const Self = @This();

        matching: []T,
        non_matching: []T,
        allocator: std.mem.Allocator,

        pub fn deinit(self: *Self) void {
            self.allocator.free(self.matching);
            self.allocator.free(self.non_matching);
            self.* = undefined;
        }
    };
}

pub fn SearchResult(comptime T: type) type {
    return struct {
        index: ?usize,
        element: ?*const T,

        pub fn found(index: usize, element: *const T) @This() {
            return .{ .index = index, .element = element };
        }

        pub fn notFound() @This() {
            return .{ .index = null, .element = null };
        }

        pub fn isFound(self: @This()) bool {
            return self.index != null;
        }
    };
}

pub fn CompareFn(comptime T: type) type {
    return *const fn (T, T) Order;
}

pub fn PredicateFn(comptime T: type) type {
    return *const fn (T) bool;
}

pub fn BinaryPredicateFn(comptime T: type) type {
    return *const fn (T, T) bool;
}

pub fn TransformFn(comptime T: type, comptime U: type) type {
    return *const fn (T) U;
}

pub fn ReduceFn(comptime T: type, comptime Acc: type) type {
    return *const fn (Acc, T) Acc;
}

pub fn defaultCompare(comptime T: type) fn (T, T) Order {
    return struct {
        fn compare(a: T, b: T) Order {
            return std.math.order(a, b);
        }
    }.compare;
}

pub fn defaultCompareDesc(comptime T: type) fn (T, T) Order {
    return struct {
        fn compare(a: T, b: T) Order {
            return std.math.order(b, a);
        }
    }.compare;
}

test "Range operations" {
    const range = Range(usize).init(5, 10);
    try std.testing.expect(!range.isEmpty());
    try std.testing.expectEqual(@as(usize, 5), range.len());
    try std.testing.expect(range.contains(7));
    try std.testing.expect(!range.contains(10));
    try std.testing.expect(!range.contains(4));
}

test "Range intersection" {
    const r1 = Range(usize).init(0, 10);
    const r2 = Range(usize).init(5, 15);
    const intersection = r1.intersect(r2).?;
    try std.testing.expectEqual(@as(usize, 5), intersection.start);
    try std.testing.expectEqual(@as(usize, 10), intersection.end);
}

test "Pair and Tuple" {
    const pair = Pair(i32).init(1, 2);
    try std.testing.expectEqual(@as(i32, 1), pair.first);
    try std.testing.expectEqual(@as(i32, 2), pair.second);

    const tuple = Tuple(i32, []const u8).init(42, "hello");
    try std.testing.expectEqual(@as(i32, 42), tuple.first);
    try std.testing.expectEqualStrings("hello", tuple.second);
}

test "defaultCompare" {
    const cmp = defaultCompare(i32);
    try std.testing.expectEqual(Order.lt, cmp(1, 2));
    try std.testing.expectEqual(Order.eq, cmp(2, 2));
    try std.testing.expectEqual(Order.gt, cmp(3, 2));
}
