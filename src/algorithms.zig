/// Determines if all elements of a slice satisfy a given predicate.
///
/// This function iterates over each element of the provided slice and
/// applies the specified predicate function to determine if all elements
/// satisfy the condition defined by the predicate.
///
/// ## Parameters:
///  - `T`: The type of the elements within the slice. This is a comptime parameter.
///  - `pred`: A predicate function that takes an element of type `T` and returns a boolean.
///            It should return `true` if the element satisfies the condition, and `false` otherwise.
///  - `slice`: A slice containing elements of type `T`.
///
/// ## Returns:
///  - `true` if all elements in the slice satisfy the predicate.
///  - `false` if any element in the slice does not satisfy the predicate.
///
/// ## Example:
/// ```zig
/// const std = @import("std");
/// const assert = std.debug.assert;
///
/// pub fn isEven(num: i32) bool {
///     return @mod(num, 2) == 0;
/// }
///
/// test "allOf" {
///     const numbers = [_]i32{ 2, 4, 6, 8, 10 };
///     assert(allOf(i32, isEven, numbers[0..]));
/// }
/// ```
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
