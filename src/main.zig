const std = @import("std");
const zigonic = @import("zigonic");

const print = std.debug.print;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    print("\n=== Zigonic Library Examples ===\n\n", .{});

    {
        print("1. Iterator Operations\n", .{});
        const numbers = [_]i32{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
        var it = zigonic.SliceIterator(i32).init(&numbers);

        print("   Sum: {d}\n", .{it.sum()});

        it.reset();
        const evens = try it.filter(allocator, struct {
            fn f(x: i32) bool {
                return @rem(x, 2) == 0;
            }
        }.f);
        defer allocator.free(evens);

        print("   Even numbers: ", .{});
        for (evens) |n| {
            print("{d} ", .{n});
        }
        print("\n\n", .{});
    }

    {
        print("2. Predicate Functions\n", .{});
        const data = [_]i32{ 2, 4, 6, 8, 10 };
        const isEven = struct {
            fn f(x: i32) bool {
                return @rem(x, 2) == 0;
            }
        }.f;

        print("   All even: {any}\n", .{zigonic.allOf(i32, &data, isEven)});
        print("   Any even: {any}\n", .{zigonic.anyOf(i32, &data, isEven)});
        print("\n", .{});
    }

    {
        print("3. Binary Search\n", .{});
        const sorted = [_]i32{ 1, 3, 5, 7, 9, 11, 13, 15 };

        if (zigonic.binarySearch(i32, &sorted, 7)) |idx| {
            print("   Found 7 at index: {d}\n", .{idx});
        }

        print("   Contains 9: {any}\n", .{zigonic.contains(i32, &sorted, 9)});
        print("   Contains 10: {any}\n", .{zigonic.contains(i32, &sorted, 10)});
        print("\n", .{});
    }

    {
        print("4. Min/Max Operations\n", .{});
        const values = [_]i32{ 3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5 };

        if (zigonic.minMax(i32, &values)) |result| {
            print("   Min: {d}, Max: {d}\n", .{ result.min.*, result.max.* });
        }

        print("   Clamp 15 to [0,10]: {d}\n", .{zigonic.clamp(i32, 15, 0, 10)});
        print("\n", .{});
    }

    {
        print("5. Accumulate/Reduce\n", .{});
        const nums = [_]i32{ 1, 2, 3, 4, 5 };

        print("   Sum: {d}\n", .{zigonic.sum(i32, &nums)});
        print("   Product: {d}\n", .{zigonic.product(i32, &nums)});
        print("\n", .{});
    }

    {
        print("6. Bifurcate/Partition\n", .{});
        const mixed = [_]i32{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
        const isEven = struct {
            fn f(x: i32) bool {
                return @rem(x, 2) == 0;
            }
        }.f;

        var result = try zigonic.bifurcate(i32, allocator, &mixed, isEven);
        defer result.deinit();

        print("   Evens: ", .{});
        for (result.matching) |n| {
            print("{d} ", .{n});
        }
        print("\n   Odds: ", .{});
        for (result.non_matching) |n| {
            print("{d} ", .{n});
        }
        print("\n\n", .{});
    }

    {
        print("7. Range Iterator\n", .{});
        var r = zigonic.range(i32, 10);
        print("   Range sum 0-9: {d}\n", .{r.sum()});
        print("\n", .{});
    }

    {
        print("8. Encoding\n", .{});
        const message = "Hello, Zigonic!";

        const b64 = try zigonic.base64.encode(allocator, message);
        defer allocator.free(b64);
        print("   Base64: {s}\n", .{b64});

        const hexed = try zigonic.hex.encode(allocator, message);
        defer allocator.free(hexed);
        print("   Hex: {s}\n", .{hexed});
        print("\n", .{});
    }

    print("=== All examples completed ===\n", .{});
}
