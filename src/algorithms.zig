/// Returns true if the given predicate returns true for every element in
/// the given slice.
///
/// This functions loops through the given slice and calls the predicate
/// function on each element. If the predicate returns false for any element,
/// this function immediately returns false. It only returns true if the
/// predicate returns true for all elements in the slice.
///
/// Parameters:
///     comptime T = The element type of the slice
///     pred = The predicate function to call on each element
///     comptime slice = The slice to loop over
///
/// Returns:
///     bool = True if pred returns true for all elements in slice. False
///            if pred returns false for any element.
///
/// Examples:
///
///     const std = @import("std");
///     const assert = std.debug.assert;
///
///     pub fn isEven(num: i32) bool {
///         return @mod(num, 2) == 0;
///     }
///
///     test "allOf" {
///         const numbers = [_]i32{ 2, 4, 6, 8, 10 };
///         assert(allOf(i32, isEven, numbers[0..]));
///     }
///
pub fn allOf(comptime T: type, pred: fn (T) bool, comptime slice: []const T) bool {
    inline for (slice) |element| {
        if (!@call(.always_inline, pred, .{element})) return false;
    }
    return true;
}

// pub fn allOf(comptime T: type, pred: fn (T) bool, slice: []const T) bool {
//     var i: usize = 0;
//     while (i < slice.len) : (i += 1) {
//         if (!pred(slice[i])) {
//             return false;
//         }
//     }
//     return true;
// }

/// Finds the maximum element in a slice according to the provided comparator
/// function.
///
/// The comparator function should take two values of type `T` and return `true`
/// if the first element is greater than the second.
///
/// Params:
///     comptime T = The element type.
///     comptime comparator = The comparator function.
///     slice = The slice to search.
///
/// Returns:
///     A pointer to the maximum element, or `null` if `slice` is empty.
///
/// Note:
///     The function does not return an error union but an optional pointer (`?*const T`)
///     to handle the case where `slice` is empty. Hence, it returns `null` when the slice
///     is empty, indicating that there's no maximum element to be found.
///
/// Usage Example:
///
///     const std = @import("std");
///     const algorithms = @import("algorithms.zig");
///
///     fn intComparator(a: i32, b: i32) bool {
///         return a > b;
///     }
///
///     pub fn main() !void {
///         var items = [_]i32{ 3, 5, 2, 7, 4 };
///         const max = algorithms.maxElement(i32, intComparator, items[0..]);
///
///         if (max) |m| {
///             std.debug.print("The maximum element is: {}\n", .{m.*});
///         } else {
///             std.debug.print("The slice is empty, no maximum element.\n", .{});
///         }
///     }
///
pub fn maxElement(comptime T: type, comptime comparator: fn (a: T, b: T) bool, slice: []const T) ?*const T {
    if (slice.len == 0) return null;

    var maxIndex: usize = 0;
    for (slice, 0..) |item, i| {
        if (i == 0) continue;
        if (comparator(item, slice[maxIndex])) {
            maxIndex = i;
        }
    }

    return &slice[maxIndex];
}
