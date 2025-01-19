const std = @import("std");
const zigonic = @import("zigonic");
const expect = std.testing.expect;
const expectEqualSlices = std.testing.expectEqualSlices;

fn isEven(item: i32) bool {
    return @mod(item, 2) == 0;
}

fn isPositive(item: f64) bool {
    return item > 0;
}

test "bifurcateBy with integers" {
    var items = [_]i32{ 1, 2, 3, 4, 5 };
    const result = try zigonic.bifurcateBy(i32, items[0..], isEven);

    // Check that the bifurcation is correct
    try expectEqualSlices(i32, result[0], &[_]i32{ 2, 4 }); // even numbers
    try expectEqualSlices(i32, result[1], &[_]i32{ 1, 3, 5 }); // odd numbers
}

test "bifurcateBy with empty array" {
    const items: []f64 = &[_]f64{};
    const result = try zigonic.bifurcateBy(f64, items, isPositive);

    // Check that function can handle empty arrays
    try expectEqualSlices(f64, result[0], &[_]f64{});
    try expectEqualSlices(f64, result[1], &[_]f64{});
}
