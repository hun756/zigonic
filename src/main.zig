const std = @import("std");
const zigonic = @import("zigonic");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const stdout = std.io.getStdOut().writer();

    try stdout.print("\n=== Zigonic Library Examples ===\n\n", .{});

    {
        try stdout.print("1. Iterator Operations\n", .{});
        const numbers = [_]i32{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
        var it = zigonic.SliceIterator(i32).init(&numbers);

        try stdout.print("   Sum: {}\n", .{it.sum()});

        it.reset();
        const evens = try it.filter(allocator, struct {
            fn f(x: i32) bool {
                return @rem(x, 2) == 0;
            }
        }.f);
        defer allocator.free(evens);

        try stdout.print("   Even numbers: ", .{});
        for (evens) |n| {
            try stdout.print("{} ", .{n});
        }
        try stdout.print("\n\n", .{});
    }

    {
        try stdout.print("2. Predicate Functions\n", .{});
        const data = [_]i32{ 2, 4, 6, 8, 10 };
        const isEven = struct {
            fn f(x: i32) bool {
                return @rem(x, 2) == 0;
            }
        }.f;

        try stdout.print("   All even: {}\n", .{zigonic.allOf(i32, &data, isEven)});
        try stdout.print("   Any even: {}\n", .{zigonic.anyOf(i32, &data, isEven)});
        try stdout.print("\n", .{});
    }

    {
        try stdout.print("3. Binary Search\n", .{});
        const sorted = [_]i32{ 1, 3, 5, 7, 9, 11, 13, 15 };

        if (zigonic.binarySearch(i32, &sorted, 7)) |idx| {
            try stdout.print("   Found 7 at index: {}\n", .{idx});
        }

        try stdout.print("   Contains 9: {}\n", .{zigonic.contains(i32, &sorted, 9)});
        try stdout.print("   Contains 10: {}\n", .{zigonic.contains(i32, &sorted, 10)});
        try stdout.print("\n", .{});
    }

    {
        try stdout.print("4. Min/Max Operations\n", .{});
        const values = [_]i32{ 3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5 };

        if (zigonic.minMax(i32, &values)) |result| {
            try stdout.print("   Min: {}, Max: {}\n", .{ result.min.*, result.max.* });
        }

        try stdout.print("   Clamp 15 to [0,10]: {}\n", .{zigonic.clamp(i32, 15, 0, 10)});
        try stdout.print("\n", .{});
    }

    {
        try stdout.print("5. Accumulate/Reduce\n", .{});
        const nums = [_]i32{ 1, 2, 3, 4, 5 };

        try stdout.print("   Sum: {}\n", .{zigonic.sum(i32, &nums)});
        try stdout.print("   Product: {}\n", .{zigonic.product(i32, &nums)});
        try stdout.print("\n", .{});
    }

    {
        try stdout.print("6. Bifurcate/Partition\n", .{});
        const mixed = [_]i32{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
        const isEven = struct {
            fn f(x: i32) bool {
                return @rem(x, 2) == 0;
            }
        }.f;

        var result = try zigonic.bifurcate(i32, allocator, &mixed, isEven);
        defer result.deinit();

        try stdout.print("   Evens: ", .{});
        for (result.matching) |n| {
            try stdout.print("{} ", .{n});
        }
        try stdout.print("\n   Odds: ", .{});
        for (result.non_matching) |n| {
            try stdout.print("{} ", .{n});
        }
        try stdout.print("\n\n", .{});
    }

    {
        try stdout.print("7. Range Iterator\n", .{});
        var r = zigonic.range(i32, 10);
        try stdout.print("   Range sum 0-9: {}\n", .{r.sum()});
        try stdout.print("\n", .{});
    }

    {
        try stdout.print("8. Encoding\n", .{});
        const message = "Hello, Zigonic!";

        const b64 = try zigonic.base64.encode(allocator, message);
        defer allocator.free(b64);
        try stdout.print("   Base64: {s}\n", .{b64});

        const hexed = try zigonic.hex.encode(allocator, message);
        defer allocator.free(hexed);
        try stdout.print("   Hex: {s}\n", .{hexed});
        try stdout.print("\n", .{});
    }

    try stdout.print("=== All examples completed ===\n", .{});
}
