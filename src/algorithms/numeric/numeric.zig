const std = @import("std");

pub fn iota(comptime T: type, slice: []T, start: T) void {
    var value = start;
    for (slice) |*item| {
        item.* = value;
        value += 1;
    }
}

pub fn partialSum(comptime T: type, input: []const T, output: []T) []T {
    if (input.len == 0) return output[0..0];
    const len = @min(input.len, output.len);
    output[0] = input[0];
    for (1..len) |i| {
        output[i] = output[i - 1] + input[i];
    }
    return output[0..len];
}

pub fn partialSumBy(comptime T: type, input: []const T, output: []T, op: fn (T, T) T) []T {
    if (input.len == 0) return output[0..0];
    const len = @min(input.len, output.len);
    output[0] = input[0];
    for (1..len) |i| {
        output[i] = op(output[i - 1], input[i]);
    }
    return output[0..len];
}

pub fn adjacentDifference(comptime T: type, input: []const T, output: []T) []T {
    if (input.len == 0) return output[0..0];
    const len = @min(input.len, output.len);
    output[0] = input[0];
    for (1..len) |i| {
        output[i] = input[i] - input[i - 1];
    }
    return output[0..len];
}

pub fn adjacentDifferenceBy(comptime T: type, input: []const T, output: []T, op: fn (T, T) T) []T {
    if (input.len == 0) return output[0..0];
    const len = @min(input.len, output.len);
    output[0] = input[0];
    for (1..len) |i| {
        output[i] = op(input[i], input[i - 1]);
    }
    return output[0..len];
}

pub fn innerProduct(comptime T: type, a: []const T, b: []const T, init: T) T {
    const len = @min(a.len, b.len);
    var result = init;
    for (0..len) |i| {
        result += a[i] * b[i];
    }
    return result;
}

pub fn innerProductBy(comptime T: type, comptime R: type, a: []const T, b: []const T, init: R, sum_op: fn (R, R) R, prod_op: fn (T, T) R) R {
    const len = @min(a.len, b.len);
    var result = init;
    for (0..len) |i| {
        result = sum_op(result, prod_op(a[i], b[i]));
    }
    return result;
}

pub fn gcd(comptime T: type, a: T, b: T) T {
    var x = if (a < 0) -a else a;
    var y = if (b < 0) -b else b;
    while (y != 0) {
        const temp = y;
        y = @mod(x, y);
        x = temp;
    }
    return x;
}

pub fn lcm(comptime T: type, a: T, b: T) T {
    if (a == 0 or b == 0) return 0;
    const abs_a = if (a < 0) -a else a;
    const abs_b = if (b < 0) -b else b;
    return @divExact(abs_a, gcd(T, a, b)) * abs_b;
}

pub fn reduce(comptime T: type, slice: []const T, init: T) T {
    var result = init;
    for (slice) |item| {
        result += item;
    }
    return result;
}

pub fn reduceBy(comptime T: type, slice: []const T, init: T, op: fn (T, T) T) T {
    var result = init;
    for (slice) |item| {
        result = op(result, item);
    }
    return result;
}

pub fn exclusiveScan(comptime T: type, input: []const T, output: []T, init: T) []T {
    if (input.len == 0) return output[0..0];
    const len = @min(input.len, output.len);
    output[0] = init;
    for (1..len) |i| {
        output[i] = output[i - 1] + input[i - 1];
    }
    return output[0..len];
}

pub fn exclusiveScanBy(comptime T: type, input: []const T, output: []T, init: T, op: fn (T, T) T) []T {
    if (input.len == 0) return output[0..0];
    const len = @min(input.len, output.len);
    output[0] = init;
    for (1..len) |i| {
        output[i] = op(output[i - 1], input[i - 1]);
    }
    return output[0..len];
}

pub fn inclusiveScan(comptime T: type, input: []const T, output: []T) []T {
    return partialSum(T, input, output);
}

pub fn inclusiveScanBy(comptime T: type, input: []const T, output: []T, op: fn (T, T) T) []T {
    return partialSumBy(T, input, output, op);
}

pub fn transformReduce(comptime T: type, comptime R: type, slice: []const T, init: R, reduce_op: fn (R, R) R, transform_op: fn (T) R) R {
    var result = init;
    for (slice) |item| {
        result = reduce_op(result, transform_op(item));
    }
    return result;
}

test "iota" {
    var arr: [5]i32 = undefined;
    iota(i32, &arr, 1);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 1, 2, 3, 4, 5 }, &arr);
}

test "iota starting from zero" {
    var arr: [4]i32 = undefined;
    iota(i32, &arr, 0);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 0, 1, 2, 3 }, &arr);
}

test "partialSum" {
    const input = [_]i32{ 1, 2, 3, 4, 5 };
    var output: [5]i32 = undefined;
    const result = partialSum(i32, &input, &output);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 1, 3, 6, 10, 15 }, result);
}

test "adjacentDifference" {
    const input = [_]i32{ 1, 3, 6, 10, 15 };
    var output: [5]i32 = undefined;
    const result = adjacentDifference(i32, &input, &output);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 1, 2, 3, 4, 5 }, result);
}

test "innerProduct" {
    const a = [_]i32{ 1, 2, 3 };
    const b = [_]i32{ 4, 5, 6 };
    const result = innerProduct(i32, &a, &b, 0);
    try std.testing.expectEqual(@as(i32, 32), result);
}

test "gcd" {
    try std.testing.expectEqual(@as(i32, 6), gcd(i32, 12, 18));
    try std.testing.expectEqual(@as(i32, 1), gcd(i32, 17, 23));
    try std.testing.expectEqual(@as(i32, 5), gcd(i32, 0, 5));
    try std.testing.expectEqual(@as(i32, 5), gcd(i32, 5, 0));
}

test "lcm" {
    try std.testing.expectEqual(@as(i32, 36), lcm(i32, 12, 18));
    try std.testing.expectEqual(@as(i32, 391), lcm(i32, 17, 23));
    try std.testing.expectEqual(@as(i32, 0), lcm(i32, 0, 5));
}

test "reduce" {
    const arr = [_]i32{ 1, 2, 3, 4, 5 };
    try std.testing.expectEqual(@as(i32, 15), reduce(i32, &arr, 0));
}

test "exclusiveScan" {
    const input = [_]i32{ 1, 2, 3, 4, 5 };
    var output: [5]i32 = undefined;
    const result = exclusiveScan(i32, &input, &output, 0);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 0, 1, 3, 6, 10 }, result);
}

test "inclusiveScan" {
    const input = [_]i32{ 1, 2, 3, 4, 5 };
    var output: [5]i32 = undefined;
    const result = inclusiveScan(i32, &input, &output);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 1, 3, 6, 10, 15 }, result);
}

test "transformReduce" {
    const arr = [_]i32{ 1, 2, 3, 4 };
    const square = struct {
        fn f(x: i32) i32 {
            return x * x;
        }
    }.f;
    const add = struct {
        fn f(a: i32, b: i32) i32 {
            return a + b;
        }
    }.f;
    const result = transformReduce(i32, i32, &arr, 0, add, square);
    try std.testing.expectEqual(@as(i32, 30), result);
}

pub fn transformExclusiveScan(comptime T: type, comptime R: type, input: []const T, output: []R, init: R, binary_op: fn (R, R) R, unary_op: fn (T) R) []R {
    if (input.len == 0) return output[0..0];
    const len = @min(input.len, output.len);
    output[0] = init;
    for (1..len) |i| {
        output[i] = binary_op(output[i - 1], unary_op(input[i - 1]));
    }
    return output[0..len];
}

pub fn transformInclusiveScan(comptime T: type, comptime R: type, input: []const T, output: []R, binary_op: fn (R, R) R, unary_op: fn (T) R) []R {
    if (input.len == 0) return output[0..0];
    const len = @min(input.len, output.len);
    output[0] = unary_op(input[0]);
    for (1..len) |i| {
        output[i] = binary_op(output[i - 1], unary_op(input[i]));
    }
    return output[0..len];
}

pub fn midpoint(comptime T: type, a: T, b: T) T {
    if (@typeInfo(T) == .int) {
        return a + @divTrunc(b - a, 2);
    } else {
        return (a + b) / 2;
    }
}

test "transformExclusiveScan" {
    const input = [_]i32{ 1, 2, 3, 4 };
    var output: [4]i32 = undefined;
    const double = struct {
        fn f(x: i32) i32 {
            return x * 2;
        }
    }.f;
    const add = struct {
        fn f(a: i32, b: i32) i32 {
            return a + b;
        }
    }.f;
    const result = transformExclusiveScan(i32, i32, &input, &output, 0, add, double);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 0, 2, 6, 12 }, result);
}

test "transformInclusiveScan" {
    const input = [_]i32{ 1, 2, 3, 4 };
    var output: [4]i32 = undefined;
    const double = struct {
        fn f(x: i32) i32 {
            return x * 2;
        }
    }.f;
    const add = struct {
        fn f(a: i32, b: i32) i32 {
            return a + b;
        }
    }.f;
    const result = transformInclusiveScan(i32, i32, &input, &output, add, double);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 2, 6, 12, 20 }, result);
}

test "midpoint" {
    try std.testing.expectEqual(@as(i32, 5), midpoint(i32, 3, 7));
    try std.testing.expectEqual(@as(i32, 5), midpoint(i32, 4, 7));
}
