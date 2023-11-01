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
