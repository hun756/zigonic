const std = @import("std");
const algorithms = @import("algorithms.zig");

fn isEven(val: i32) bool {
    return @mod(val, 2) == 0;
}

fn isPositive(val: i32) bool {
    return val > 0;
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
