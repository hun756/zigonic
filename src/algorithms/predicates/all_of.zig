const std = @import("std");

pub fn allOf(comptime T: type, slice: []const T, predicate: *const fn (T) bool) bool {
    for (slice) |element| {
        if (!predicate(element)) return false;
    }
    return true;
}

pub fn allOfComptime(comptime T: type, comptime predicate: fn (T) bool, comptime slice: []const T) bool {
    inline for (slice) |element| {
        if (!predicate(element)) return false;
    }
    return true;
}

pub fn allOfWithContext(
    comptime T: type,
    comptime Context: type,
    slice: []const T,
    context: Context,
    predicate: *const fn (T, Context) bool,
) bool {
    for (slice) |element| {
        if (!predicate(element, context)) return false;
    }
    return true;
}

test "allOf basic" {
    const data = [_]i32{ 2, 4, 6, 8, 10 };
    const isEven = struct {
        fn f(x: i32) bool {
            return @rem(x, 2) == 0;
        }
    }.f;
    try std.testing.expect(allOf(i32, &data, isEven));
}

test "allOf with odd number" {
    const data = [_]i32{ 2, 3, 6, 8, 10 };
    const isEven = struct {
        fn f(x: i32) bool {
            return @rem(x, 2) == 0;
        }
    }.f;
    try std.testing.expect(!allOf(i32, &data, isEven));
}

test "allOf empty slice" {
    const data = [_]i32{};
    const isEven = struct {
        fn f(x: i32) bool {
            return @rem(x, 2) == 0;
        }
    }.f;
    try std.testing.expect(allOf(i32, &data, isEven));
}
