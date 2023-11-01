/// Performs a binary search to find the index of a target value in a sorted array.
///
/// This uses a divide and conquer algorithm that repeatedly splits the search interval
/// in half until the target is found. This allows for O(log n) search time on average.
///
/// The array must be sorted in ascending order or the result is undefined.
///
/// - `T` - The array element type. Must be a type that supports `==` comparison.
/// - `array` - The array to search. Should be sorted ascending.
/// - `target` - The value to search for.
///
/// Returns the index of the target in the array if found, else null.
///
/// Time complexity: O(log n) average, O(n) worst case.
/// Space complexity: O(1).
///
/// Example:
/// ```
/// const arr = [_]i32{1, 3, 7, 9, 12};
/// const idx = binarySearch(i32, arr, 7); // idx = 2
/// ```
pub fn binarySearch(comptime T: type, array: []const T, target: T) ?usize {
    var low: usize = 0;
    var high: usize = array.len;

    while (low < high) {
        const mid = low + (high - low) / 2;
        const midValue = array[mid];

        if (midValue == target) {
            return mid;
        } else if (midValue < target) {
            low = mid + 1;
        } else {
            high = mid;
        }
    }

    return null;
}
