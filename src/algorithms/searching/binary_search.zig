const std = @import("std");
const Order = std.math.Order;

pub fn binarySearch(comptime T: type, slice: []const T, target: T) ?usize {
    return binarySearchBy(T, slice, target, defaultCompare(T));
}

pub fn binarySearchBy(
    comptime T: type,
    slice: []const T,
    target: T,
    comparator: *const fn (T, T) Order,
) ?usize {
    if (slice.len == 0) return null;

    var left: usize = 0;
    var right: usize = slice.len;

    while (left < right) {
        const mid = left + (right - left) / 2;
        const cmp = comparator(slice[mid], target);

        switch (cmp) {
            .eq => return mid,
            .lt => left = mid + 1,
            .gt => right = mid,
        }
    }

    return null;
}

pub fn lowerBound(comptime T: type, slice: []const T, target: T) usize {
    return lowerBoundBy(T, slice, target, defaultCompare(T));
}

pub fn lowerBoundBy(
    comptime T: type,
    slice: []const T,
    target: T,
    comparator: *const fn (T, T) Order,
) usize {
    var left: usize = 0;
    var right: usize = slice.len;

    while (left < right) {
        const mid = left + (right - left) / 2;
        if (comparator(slice[mid], target) == .lt) {
            left = mid + 1;
        } else {
            right = mid;
        }
    }

    return left;
}

pub fn upperBound(comptime T: type, slice: []const T, target: T) usize {
    return upperBoundBy(T, slice, target, defaultCompare(T));
}

pub fn upperBoundBy(
    comptime T: type,
    slice: []const T,
    target: T,
    comparator: *const fn (T, T) Order,
) usize {
    var left: usize = 0;
    var right: usize = slice.len;

    while (left < right) {
        const mid = left + (right - left) / 2;
        if (comparator(slice[mid], target) != .gt) {
            left = mid + 1;
        } else {
            right = mid;
        }
    }

    return left;
}

pub fn equalRange(comptime T: type, slice: []const T, target: T) struct { lower: usize, upper: usize } {
    return .{
        .lower = lowerBound(T, slice, target),
        .upper = upperBound(T, slice, target),
    };
}

pub fn contains(comptime T: type, slice: []const T, target: T) bool {
    return binarySearch(T, slice, target) != null;
}

fn defaultCompare(comptime T: type) *const fn (T, T) Order {
    return struct {
        fn cmp(a: T, b: T) Order {
            return std.math.order(a, b);
        }
    }.cmp;
}

test "binarySearch found" {
    const data = [_]i32{ 1, 3, 5, 7, 9, 11, 13 };
    try std.testing.expectEqual(@as(?usize, 3), binarySearch(i32, &data, 7));
}

test "binarySearch not found" {
    const data = [_]i32{ 1, 3, 5, 7, 9, 11, 13 };
    try std.testing.expectEqual(@as(?usize, null), binarySearch(i32, &data, 6));
}

test "binarySearch empty" {
    const data = [_]i32{};
    try std.testing.expectEqual(@as(?usize, null), binarySearch(i32, &data, 5));
}

test "lowerBound" {
    const data = [_]i32{ 1, 2, 2, 2, 3, 4, 5 };
    try std.testing.expectEqual(@as(usize, 1), lowerBound(i32, &data, 2));
}

test "upperBound" {
    const data = [_]i32{ 1, 2, 2, 2, 3, 4, 5 };
    try std.testing.expectEqual(@as(usize, 4), upperBound(i32, &data, 2));
}

test "equalRange" {
    const data = [_]i32{ 1, 2, 2, 2, 3, 4, 5 };
    const range = equalRange(i32, &data, 2);
    try std.testing.expectEqual(@as(usize, 1), range.lower);
    try std.testing.expectEqual(@as(usize, 4), range.upper);
}

test "contains" {
    const data = [_]i32{ 1, 3, 5, 7, 9 };
    try std.testing.expect(contains(i32, &data, 5));
    try std.testing.expect(!contains(i32, &data, 4));
}
