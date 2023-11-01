const std = @import("std");
const algorithms = @import("algorithms.zig");

const f64_9p2 = 9.2;

fn isEven(val: i32) bool {
    return @mod(val, 2) == 0;
}

fn isPositive(val: i32) bool {
    return val > 0;
}

fn compare(a: i32, b: i32) bool {
    return a > b;
}

fn intGreater(a: i32, b: i32) bool {
    return a > b;
}

fn floatGreater(a: f64, b: f64) bool {
    return a > b;
}

pub fn main() !void {}

test "allOf" {
    const even_arr = [_]i32{ 2, 4, 6, 8, 10 };
    const all_even = algorithms.allOf(i32, isEven, &even_arr);
    try std.testing.expect(all_even);

    const mixed_arr = [_]i32{ 2, 3, 6, 8, 10 };
    const all_even_mixed = algorithms.allOf(i32, isEven, &mixed_arr);
    try std.testing.expect(!all_even_mixed);

    const positive_arr = [_]i32{ 1, 2, 3, 4, 5 };
    const all_positive = algorithms.allOf(i32, isPositive, &positive_arr);
    try std.testing.expect(all_positive);

    const mixed_positive_negative_arr = [_]i32{ -1, 2, -3, 4, 5 };
    const all_positive_mixed = algorithms.allOf(i32, isPositive, &mixed_positive_negative_arr);
    try std.testing.expect(!all_positive_mixed);

    const empty_arr = [_]i32{};
    const all_even_empty = algorithms.allOf(i32, isEven, &empty_arr);
    try std.testing.expect(all_even_empty);

    const all_positive_empty = algorithms.allOf(i32, isPositive, &empty_arr);
    try std.testing.expect(all_positive_empty);

    const numbers = [_]i32{ 1, 2, 3, 4, 5 };

    try std.testing.expect(algorithms.allOf(i32, struct {
        fn foo(x: i32) bool {
            return x > 0;
        }
    }.foo, &numbers));

    try std.testing.expect(!algorithms.allOf(i32, struct {
        fn foo(x: i32) bool {
            return x > 10;
        }
    }.foo, &numbers));
}

test "maxElement returns the maximum integer" {
    var items = [_]i32{ 3, 5, 2, 7, 4 };
    const max = algorithms.maxElement(i32, intGreater, items[0..]);

    if (max) |m| {
        try std.testing.expect(m.* == 7);
    } else {
        unreachable; // fail if max is null
    }
}

test "maxElement works with f64" {
    var items = [_]f64{ 1.3, 5.6, 2.8, 9.2, 4.1 };
    const max = algorithms.maxElement(f64, floatGreater, items[0..]);

    try std.testing.expect(max.?.* == 9.2);
}

fn vecComparator(a: Vec2, b: Vec2) bool {
    return @max(a.x, a.y) > @max(b.x, b.y);
}

const Vec2 = struct {
    x: f32,
    y: f32,
};

test "maxElement works with structs" {
    var items = [_]Vec2{
        Vec2{ .x = 1, .y = 2 },
        Vec2{ .x = 5, .y = -3 },
        //...
    };

    const max = algorithms.maxElement(Vec2, vecComparator, items[0..]);

    try std.testing.expectEqual(Vec2{ .x = 5, .y = -3 }, max.?.*);
}

test "maxElement handles empty slice" {
    var empty: [0]i32 = undefined;
    const max = algorithms.maxElement(i32, intGreater, empty[0..]);

    try std.testing.expectEqual(@as(?*const i32, null), max);
}
