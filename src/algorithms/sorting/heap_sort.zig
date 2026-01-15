const std = @import("std");

fn defaultLessThan(comptime T: type) fn (T, T) bool {
    return struct {
        fn f(a: T, b: T) bool {
            return a < b;
        }
    }.f;
}

pub fn heapSort(comptime T: type, slice: []T) void {
    heapSortBy(T, slice, defaultLessThan(T));
}

pub fn heapSortBy(comptime T: type, slice: []T, lessThan: fn (T, T) bool) void {
    if (slice.len <= 1) return;

    var i: usize = slice.len / 2;
    while (i > 0) {
        i -= 1;
        siftDown(T, slice, i, slice.len, lessThan);
    }

    var end: usize = slice.len;
    while (end > 1) {
        end -= 1;
        const temp = slice[0];
        slice[0] = slice[end];
        slice[end] = temp;
        siftDown(T, slice, 0, end, lessThan);
    }
}

fn siftDown(comptime T: type, slice: []T, start: usize, end: usize, lessThan: fn (T, T) bool) void {
    var root = start;
    while (true) {
        const left = 2 * root + 1;
        if (left >= end) break;
        var largest = root;
        if (lessThan(slice[largest], slice[left])) {
            largest = left;
        }
        const right = left + 1;
        if (right < end and lessThan(slice[largest], slice[right])) {
            largest = right;
        }
        if (largest == root) break;
        const temp = slice[root];
        slice[root] = slice[largest];
        slice[largest] = temp;
        root = largest;
    }
}

test "heapSort" {
    var arr = [_]i32{ 5, 2, 8, 1, 9, 3, 7, 4, 6 };
    heapSort(i32, &arr);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, &arr);
}

test "heapSortBy descending" {
    var arr = [_]i32{ 5, 2, 8, 1, 9 };
    const greaterThan = struct {
        fn f(a: i32, b: i32) bool {
            return a > b;
        }
    }.f;
    heapSortBy(i32, &arr, greaterThan);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 9, 8, 5, 2, 1 }, &arr);
}
