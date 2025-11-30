const std = @import("std");

pub fn countIf(comptime T: type, slice: []const T, predicate: *const fn (T) bool) usize {
    var result: usize = 0;
    for (slice) |element| {
        if (predicate(element)) result += 1;
    }
    return result;
}

pub fn countIfNot(comptime T: type, slice: []const T, predicate: *const fn (T) bool) usize {
    return slice.len - countIf(T, slice, predicate);
}

pub fn count(comptime T: type, slice: []const T, value: T) usize {
    var result: usize = 0;
    for (slice) |element| {
        if (element == value) result += 1;
    }
    return result;
}

test "countIf" {
    const data = [_]i32{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    const isEven = struct {
        fn f(x: i32) bool {
            return @rem(x, 2) == 0;
        }
    }.f;
    try std.testing.expectEqual(@as(usize, 5), countIf(i32, &data, isEven));
}

test "count value" {
    const data = [_]i32{ 1, 2, 2, 3, 2, 4, 2 };
    try std.testing.expectEqual(@as(usize, 4), count(i32, &data, 2));
}
