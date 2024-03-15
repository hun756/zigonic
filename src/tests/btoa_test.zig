const std = @import("std");
const zigonic = @import("zigonic");

test "btoa test" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var allocator = gpa.allocator();

    const input = "foobar";
    const expected = "Zm9vYmFy";

    const encoded = try zigonic.btoa(&allocator, input);
    defer allocator.free(encoded);

    try std.testing.expectEqualStrings(expected, encoded);
}
