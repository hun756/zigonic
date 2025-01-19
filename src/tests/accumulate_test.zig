const std = @import("std");
const zigonic = @import("zigonic");
const _accumulate = zigonic.accumulate;
const accumulate = _accumulate.accumulate;
const SliceIterator = _accumulate.SliceIterator;
const sum = _accumulate.sum;
const product = _accumulate.product;
const math = std.math;
const testing = std.testing;

test "accumulate basic addition" {
    const numbers = [_]i32{ 1, 2, 3, 4, 5 };
    var iterator = SliceIterator(i32){ .slice = &numbers, .index = 0 };
    const add = struct {
        fn add(a: i32, b: i32) !i32 {
            return math.add(i32, a, b);
        }
    }.add;

    const result = try accumulate(i32, @TypeOf(add), &iterator, 0, add);
    try testing.expectEqual(result, 15);
}

test "accumulate with custom operation" {
    const numbers = [_]i32{ 1, 2, 3, 4, 5 };
    var iterator = SliceIterator(i32){ .slice = &numbers, .index = 0 };
    const max = struct {
        fn max(a: i32, b: i32) !i32 {
            return if (a > b) a else b;
        }
    }.max;

    const result = try accumulate(i32, @TypeOf(max), &iterator, 0, max);
    try testing.expectEqual(result, 5);
}

test "sum specialized function" {
    const numbers = [_]i32{ 1, 2, 3, 4, 5 };
    var iterator = SliceIterator(i32){ .slice = &numbers, .index = 0 };
    const result = try sum(i32, &iterator, 0);
    try testing.expectEqual(result, 15);
}

test "product specialized function" {
    const numbers = [_]i32{ 1, 2, 3, 4, 5 };
    var iterator = SliceIterator(i32){ .slice = &numbers, .index = 0 };
    const result = try product(i32, &iterator, 1);
    try testing.expectEqual(result, 120);
}
