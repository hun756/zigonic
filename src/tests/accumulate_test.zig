const std = @import("std");
const accumulate = @import("zigonic").accumulate;

pub fn add(a: u32, b: u32) u32 {
    return a + b;
}

pub fn multiply(a: f32, b: f32) f32 {
    return a * b;
}

test "accumulate sum" {
    const numbers = [_]u32{ 1, 2, 3, 4, 5 };
    const result = accumulate(u32, add, numbers[0..], 0);
    try std.testing.expectEqual(result, 15);
}

test "accumulate product" {
    const numbers = [_]f32{ 1.0, 2.0, 3.0, 4.0, 5.0 };
    const result = accumulate(f32, multiply, numbers[0..], 1.0);
    try std.testing.expectEqual(result, 120.0);
}

test "accumulate empty range" {
    const numbers = [_]u32{};
    const result = accumulate(u32, add, numbers[0..], 0);
    try std.testing.expectEqual(result, 0);
}
