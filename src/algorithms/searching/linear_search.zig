const std = @import("std");

pub fn linearSearch(comptime T: type, slice: []const T, target: T) ?usize {
    for (slice, 0..) |element, i| {
        if (element == target) return i;
    }
    return null;
}

pub fn linearSearchBy(
    comptime T: type,
    slice: []const T,
    predicate: *const fn (T) bool,
) ?usize {
    for (slice, 0..) |element, i| {
        if (predicate(element)) return i;
    }
    return null;
}

pub fn find(comptime T: type, slice: []const T, target: T) ?*const T {
    for (slice) |*element| {
        if (element.* == target) return element;
    }
    return null;
}

pub fn findIf(comptime T: type, slice: []const T, predicate: *const fn (T) bool) ?*const T {
    for (slice) |*element| {
        if (predicate(element.*)) return element;
    }
    return null;
}

pub fn findLast(comptime T: type, slice: []const T, target: T) ?usize {
    var i: usize = slice.len;
    while (i > 0) {
        i -= 1;
        if (slice[i] == target) return i;
    }
    return null;
}

test "linearSearch found" {
    const data = [_]i32{ 5, 3, 8, 1, 9 };
    try std.testing.expectEqual(@as(?usize, 2), linearSearch(i32, &data, 8));
}

test "linearSearch not found" {
    const data = [_]i32{ 5, 3, 8, 1, 9 };
    try std.testing.expectEqual(@as(?usize, null), linearSearch(i32, &data, 7));
}

test "findLast" {
    const data = [_]i32{ 1, 2, 3, 2, 4, 2 };
    try std.testing.expectEqual(@as(?usize, 5), findLast(i32, &data, 2));
}
