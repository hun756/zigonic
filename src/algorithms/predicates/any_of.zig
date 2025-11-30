const std = @import("std");

pub fn anyOf(comptime T: type, slice: []const T, predicate: *const fn (T) bool) bool {
    for (slice) |element| {
        if (predicate(element)) return true;
    }
    return false;
}

pub fn anyOfComptime(comptime T: type, comptime predicate: fn (T) bool, comptime slice: []const T) bool {
    inline for (slice) |element| {
        if (predicate(element)) return true;
    }
    return false;
}

pub fn anyOfWithContext(
    comptime T: type,
    comptime Context: type,
    slice: []const T,
    context: Context,
    predicate: *const fn (T, Context) bool,
) bool {
    for (slice) |element| {
        if (predicate(element, context)) return true;
    }
    return false;
}

pub fn noneOf(comptime T: type, slice: []const T, predicate: *const fn (T) bool) bool {
    return !anyOf(T, slice, predicate);
}

test "anyOf basic" {
    const data = [_]i32{ 1, 3, 5, 6, 9 };
    const isEven = struct {
        fn f(x: i32) bool {
            return @rem(x, 2) == 0;
        }
    }.f;
    try std.testing.expect(anyOf(i32, &data, isEven));
}

test "anyOf none match" {
    const data = [_]i32{ 1, 3, 5, 7, 9 };
    const isEven = struct {
        fn f(x: i32) bool {
            return @rem(x, 2) == 0;
        }
    }.f;
    try std.testing.expect(!anyOf(i32, &data, isEven));
}

test "anyOf empty slice" {
    const data = [_]i32{};
    const isEven = struct {
        fn f(x: i32) bool {
            return @rem(x, 2) == 0;
        }
    }.f;
    try std.testing.expect(!anyOf(i32, &data, isEven));
}

test "noneOf" {
    const data = [_]i32{ 1, 3, 5, 7, 9 };
    const isEven = struct {
        fn f(x: i32) bool {
            return @rem(x, 2) == 0;
        }
    }.f;
    try std.testing.expect(noneOf(i32, &data, isEven));
}
