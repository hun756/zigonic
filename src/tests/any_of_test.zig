const std = @import("std");
const zigonic = @import("zigonic");
const cmp = @import("functions/all_of_comparer.zig");

test "anyOf" {
    const mixed_arr = [_]i32{ 1, 3, 5, 7, 10 };
    const any_even = zigonic.anyOf(i32, cmp.isEven, &mixed_arr);
    try std.testing.expect(any_even);

    const odd_arr = [_]i32{ 1, 3, 5, 7, 9 };
    const all_even = zigonic.anyOf(i32, cmp.isEven, &odd_arr);
    try std.testing.expect(!all_even);

    const positive_arr = [_]i32{ 1, -2, -3, -4, -5 };
    const all_positive = zigonic.anyOf(i32, cmp.isPositive, &positive_arr);
    try std.testing.expect(all_positive);

    const all_negative = [_]i32{ -1, -2, -3, -4, -5 };
    const anyPositive = zigonic.anyOf(i32, cmp.isPositive, &all_negative);
    try std.testing.expect(!anyPositive);

    const empty_arr = [_]i32{};
    const any_even_empty = zigonic.anyOf(i32, cmp.isEven, &empty_arr);
    try std.testing.expect(!any_even_empty);

    const all_positive_empty = zigonic.allOf(i32, cmp.isPositive, &empty_arr);
    try std.testing.expect(all_positive_empty);

    const numbers = [_]i32{ 1, 2, 3, 4, 5 };
    try std.testing.expect(!zigonic.anyOf(i32, struct {
        fn foo(x: i32) bool {
            return x > 10;
        }
    }.foo, &numbers));
}
