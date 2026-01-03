const std = @import("std");
const Order = std.math.Order;

pub fn maxElement(comptime T: type, slice: []const T) ?*const T {
    return maxElementBy(T, slice, defaultCompare(T));
}

pub fn maxElementBy(
    comptime T: type,
    slice: []const T,
    comparator: *const fn (T, T) Order,
) ?*const T {
    if (slice.len == 0) return null;

    var max_idx: usize = 0;
    for (slice[1..], 1..) |item, i| {
        if (comparator(item, slice[max_idx]) == .gt) {
            max_idx = i;
        }
    }

    return &slice[max_idx];
}

pub fn minElement(comptime T: type, slice: []const T) ?*const T {
    return minElementBy(T, slice, defaultCompare(T));
}

pub fn minElementBy(
    comptime T: type,
    slice: []const T,
    comparator: *const fn (T, T) Order,
) ?*const T {
    if (slice.len == 0) return null;

    var min_idx: usize = 0;
    for (slice[1..], 1..) |item, i| {
        if (comparator(item, slice[min_idx]) == .lt) {
            min_idx = i;
        }
    }

    return &slice[min_idx];
}

pub const MinMaxResult = struct {
    min: usize,
    max: usize,
};

pub fn minMax(comptime T: type, slice: []const T) ?struct { min: *const T, max: *const T } {
    if (slice.len == 0) return null;
    const result = minMaxByIdx(T, slice, defaultCompare(T));
    return .{ .min = &slice[result.min], .max = &slice[result.max] };
}

pub fn minMaxByIdx(
    comptime T: type,
    slice: []const T,
    comparator: *const fn (T, T) Order,
) MinMaxResult {
    var min_idx: usize = 0;
    var max_idx: usize = 0;

    for (slice[1..], 1..) |item, i| {
        if (comparator(item, slice[min_idx]) == .lt) {
            min_idx = i;
        }
        if (comparator(item, slice[max_idx]) == .gt) {
            max_idx = i;
        }
    }

    return .{ .min = min_idx, .max = max_idx };
}

pub fn clamp(comptime T: type, value: T, min_val: T, max_val: T) T {
    if (std.math.order(value, min_val) == .lt) return min_val;
    if (std.math.order(value, max_val) == .gt) return max_val;
    return value;
}

pub fn min(comptime T: type, a: T, b: T) T {
    return if (std.math.order(a, b) == .lt) a else b;
}

pub fn max(comptime T: type, a: T, b: T) T {
    return if (std.math.order(a, b) == .gt) a else b;
}

pub fn minBy(comptime T: type, a: T, b: T, comparator: *const fn (T, T) Order) T {
    return if (comparator(a, b) == .lt) a else b;
}

pub fn maxBy(comptime T: type, a: T, b: T, comparator: *const fn (T, T) Order) T {
    return if (comparator(a, b) == .gt) a else b;
}

fn defaultCompare(comptime T: type) *const fn (T, T) Order {
    return struct {
        fn cmp(a: T, b: T) Order {
            return std.math.order(a, b);
        }
    }.cmp;
}

test "maxElement" {
    const data = [_]i32{ 3, 1, 4, 1, 5, 9, 2, 6 };
    const max_elem = maxElement(i32, &data).?;
    try std.testing.expectEqual(@as(i32, 9), max_elem.*);
}

test "minElement" {
    const data = [_]i32{ 3, 1, 4, 1, 5, 9, 2, 6 };
    const min_elem = minElement(i32, &data).?;
    try std.testing.expectEqual(@as(i32, 1), min_elem.*);
}

test "minMax" {
    const data = [_]i32{ 3, 1, 4, 1, 5, 9, 2, 6 };
    const result = minMax(i32, &data).?;
    try std.testing.expectEqual(@as(i32, 1), result.min.*);
    try std.testing.expectEqual(@as(i32, 9), result.max.*);
}

test "maxElement empty" {
    const data = [_]i32{};
    try std.testing.expectEqual(@as(?*const i32, null), maxElement(i32, &data));
}

test "clamp" {
    try std.testing.expectEqual(@as(i32, 5), clamp(i32, 3, 5, 10));
    try std.testing.expectEqual(@as(i32, 7), clamp(i32, 7, 5, 10));
    try std.testing.expectEqual(@as(i32, 10), clamp(i32, 15, 5, 10));
}

test "min and max values" {
    try std.testing.expectEqual(@as(i32, 3), min(i32, 3, 7));
    try std.testing.expectEqual(@as(i32, 7), max(i32, 3, 7));
}
