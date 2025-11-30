const std = @import("std");
const math = std.math;

pub const AccumulateError = error{
    Overflow,
    Underflow,
};

pub fn accumulate(
    comptime T: type,
    slice: []const T,
    initial: T,
    operation: *const fn (T, T) T,
) T {
    var result = initial;
    for (slice) |element| {
        result = operation(result, element);
    }
    return result;
}

pub fn accumulateChecked(
    comptime T: type,
    slice: []const T,
    initial: T,
    operation: *const fn (T, T) ?T,
) ?T {
    var result = initial;
    for (slice) |element| {
        result = operation(result, element) orelse return null;
    }
    return result;
}

pub fn sum(comptime T: type, slice: []const T) T {
    return accumulate(T, slice, 0, struct {
        fn add(a: T, b: T) T {
            return a + b;
        }
    }.add);
}

pub fn sumChecked(comptime T: type, slice: []const T) ?T {
    return accumulateChecked(T, slice, 0, struct {
        fn add(a: T, b: T) ?T {
            return math.add(T, a, b) catch null;
        }
    }.add);
}

pub fn product(comptime T: type, slice: []const T) T {
    return accumulate(T, slice, 1, struct {
        fn mul(a: T, b: T) T {
            return a * b;
        }
    }.mul);
}

pub fn productChecked(comptime T: type, slice: []const T) ?T {
    return accumulateChecked(T, slice, 1, struct {
        fn mul(a: T, b: T) ?T {
            return math.mul(T, a, b) catch null;
        }
    }.mul);
}

pub fn reduce(
    comptime T: type,
    comptime Acc: type,
    slice: []const T,
    initial: Acc,
    operation: *const fn (Acc, T) Acc,
) Acc {
    var result = initial;
    for (slice) |element| {
        result = operation(result, element);
    }
    return result;
}

test "accumulate basic" {
    const data = [_]i32{ 1, 2, 3, 4, 5 };
    const add = struct {
        fn f(a: i32, b: i32) i32 {
            return a + b;
        }
    }.f;
    try std.testing.expectEqual(@as(i32, 15), accumulate(i32, &data, 0, add));
}

test "sum" {
    const data = [_]i32{ 1, 2, 3, 4, 5 };
    try std.testing.expectEqual(@as(i32, 15), sum(i32, &data));
}

test "product" {
    const data = [_]i32{ 1, 2, 3, 4, 5 };
    try std.testing.expectEqual(@as(i32, 120), product(i32, &data));
}

test "sumChecked overflow" {
    const data = [_]i8{ 100, 100 };
    try std.testing.expectEqual(@as(?i8, null), sumChecked(i8, &data));
}

test "reduce different types" {
    const data = [_]i32{ 1, 2, 3, 4, 5 };
    const toStr = struct {
        fn f(acc: usize, _: i32) usize {
            return acc + 1;
        }
    }.f;
    try std.testing.expectEqual(@as(usize, 5), reduce(i32, usize, &data, 0, toStr));
}
