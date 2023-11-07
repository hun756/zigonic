const std = @import("std");

/// Splits a slice into two based on a condition.
///
/// This function takes a slice and separates its elements into two groups.
/// One group contains elements that meet a certain condition, and the
/// other contains those that don't. To store these groups, we create two
/// dynamic arrays (ArrayLists), which live on the heap and are managed by
/// the page allocator.
///
/// We use a predicate function, which you provide, that checks each element
/// to see if it meets your specified condition, returning true or false.
///
/// If everything goes right, you'll get a pair of slices: one slice for elements
/// that passed the test, and another for those that didn't. These slices are yours;
/// they point to the allocated ArrayList storage that actually holds the elements.
///
/// If we run into trouble (like running out of memory while trying to grow the
/// ArrayLists), we'll return an error instead.
///
/// Regardless of success or failure, we clean up the ArrayLists before wrapping up.
///
/// Arguments:
///     comptime T: What kind of things are we dealing with in the slice?
///     items: The collection of items you want to split.
///     predicate: A function that decides if an item should be in the first or second group.
///
/// Returns:
///     A pair of slices, each of type `T`, if successful.
///     An error, specifically if we couldn't allocate memory for the groups.
pub fn bifurcateBy(comptime T: type, items: []const T, predicate: fn (T) bool) ![2][]T {
    var trueItems = std.ArrayList(T).init(std.heap.page_allocator);
    var falseItems = std.ArrayList(T).init(std.heap.page_allocator);
    defer {
        trueItems.deinit();
        falseItems.deinit();
    }

    for (items) |item| {
        if (predicate(item)) {
            try trueItems.append(item);
        } else {
            try falseItems.append(item);
        }
    }

    return .{ try trueItems.toOwnedSlice(), try falseItems.toOwnedSlice() };
}
