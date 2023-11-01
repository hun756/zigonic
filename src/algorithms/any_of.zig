/// Tests whether any element in the given slice satisfies the predicate.
///
/// This function iterates through the given slice and calls the predicate 
/// function on each element. If the predicate returns true for any of the
/// elements, this function returns true. Otherwise, it returns false.
///
/// The predicate function accepts a single parameter of the slice element
/// type and returns a bool indicating whether the element matches the 
/// predicate.
///
/// Parameters:
///     comptime T = The element type of the slice
///     pred = The predicate function to test each element against
///     comptime slice = The slice to iterate over
///
/// Returns: 
///     true if any element satisfies the predicate
///     false if no elements satisfy the predicate
///
pub fn anyOf(comptime T: type, pred: fn (T) bool, comptime slice: []const T) bool {
    inline for (slice) |element| {
        if (@call(.always_inline, pred, .{element})) return true;
    }
    return false;
}
