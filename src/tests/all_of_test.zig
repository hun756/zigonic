const std = @import("std");
const zigonic = @import("zigonic");
const cmp = @import("functions/all_of_comparer.zig");

test "allOf" {
    const even_arr = [_]i32{ 2, 4, 6, 8, 10 };
    const all_even = zigonic.allOf(i32, cmp.isEven, &even_arr);
    try std.testing.expect(all_even);

    const mixed_arr = [_]i32{ 2, 3, 6, 8, 10 };
    const all_even_mixed = zigonic.allOf(i32, cmp.isEven, &mixed_arr);
    try std.testing.expect(!all_even_mixed);

    const positive_arr = [_]i32{ 1, 2, 3, 4, 5 };
    const all_positive = zigonic.allOf(i32, cmp.isPositive, &positive_arr);
    try std.testing.expect(all_positive);

    const mixed_positive_negative_arr = [_]i32{ -1, 2, -3, 4, 5 };
    const all_positive_mixed = zigonic.allOf(i32, cmp.isPositive, &mixed_positive_negative_arr);
    try std.testing.expect(!all_positive_mixed);

    const empty_arr = [_]i32{};
    const all_even_empty = zigonic.allOf(i32, cmp.isEven, &empty_arr);
    try std.testing.expect(all_even_empty);

    const all_positive_empty = zigonic.allOf(i32, cmp.isPositive, &empty_arr);
    try std.testing.expect(all_positive_empty);

    const numbers = [_]i32{ 1, 2, 3, 4, 5 };

    try std.testing.expect(zigonic.allOf(i32, struct {
        fn foo(x: i32) bool {
            return x > 0;
        }
    }.foo, &numbers));

    try std.testing.expect(!zigonic.allOf(i32, struct {
        fn foo(x: i32) bool {
            return x > 10;
        }
    }.foo, &numbers));
}
