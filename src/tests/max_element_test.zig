const std = @import("std");
const zigonic = @import("zigonic");
const cmp = @import("functions/max_element_comparer.zig");
const Vec2 = @import("types/vec2.zig").Vec2;

test "maxElement returns the maximum integer" {
    var items = [_]i32{ 3, 5, 2, 7, 4 };
    const max = zigonic.maxElement(i32, cmp.intGreater, items[0..]);

    if (max) |m| {
        try std.testing.expect(m.* == 7);
    } else {
        unreachable; // fail if max is null
    }
}

test "maxElement works with f64" {
    var items = [_]f64{ 1.3, 5.6, 2.8, 9.2, 4.1 };
    const max = zigonic.maxElement(f64, cmp.floatGreater, items[0..]);

    try std.testing.expect(max.?.* == 9.2);
}

test "maxElement handles empty slice" {
    var empty: [0]i32 = undefined;
    const max = zigonic.maxElement(i32, cmp.intGreater, empty[0..]);
    try std.testing.expectEqual(@as(?*const i32, null), max);
}

test "maxElement works with structs" {
    var items = [_]Vec2{
        Vec2{ .x = 1, .y = 2 },
        Vec2{ .x = 5, .y = -3 },
        //...
    };

    const max = zigonic.maxElement(Vec2, @import("functions/max_element_comparer.zig").vecComparator, items[0..]);

    try std.testing.expectEqual(Vec2{ .x = 5, .y = -3 }, max.?.*);
}
