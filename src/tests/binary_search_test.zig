const std = @import("std");
const assert = std.debug.assert;
const binarySearch = @import("zigonic").binarySearch;

test "Binary Search" {
    var array = [_]i32{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };

    // Test with present values
    {
        assert((binarySearch(i32, &array, 1) orelse 0) == 0);
        assert((binarySearch(i32, &array, 5) orelse 0) == 4);
        assert((binarySearch(i32, &array, 10) orelse 0) == 9);
    }

    // Test with absent values
    {
        assert(binarySearch(i32, &array, 0) == null);
        assert(binarySearch(i32, &array, 11) == null);
        assert(binarySearch(i32, &array, -5) == null);
    }

    // Test with empty array
    {
        assert(binarySearch(i32, &[_]i32{}, 5) == null);
    }

    // Test with one element
    {
        assert((binarySearch(i32, &[_]i32{5}, 5) orelse 0) == 0);
        assert(binarySearch(i32, &[_]i32{5}, 4) == null);
    }
}
