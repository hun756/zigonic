const std = @import("std");

fn defaultLessThan(comptime T: type) fn (T, T) bool {
    return struct {
        fn f(a: T, b: T) bool {
            return a < b;
        }
    }.f;
}

pub fn makeHeap(comptime T: type, slice: []T) void {
    makeHeapBy(T, slice, defaultLessThan(T));
}

pub fn makeHeapBy(comptime T: type, slice: []T, lessThan: fn (T, T) bool) void {
    if (slice.len <= 1) return;
    var i: usize = slice.len / 2;
    while (i > 0) {
        i -= 1;
        siftDown(T, slice, i, slice.len, lessThan);
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

fn siftUp(comptime T: type, slice: []T, index: usize, lessThan: fn (T, T) bool) void {
    var i = index;
    while (i > 0) {
        const parent = (i - 1) / 2;
        if (!lessThan(slice[parent], slice[i])) break;
        const temp = slice[i];
        slice[i] = slice[parent];
        slice[parent] = temp;
        i = parent;
    }
}

pub fn pushHeap(comptime T: type, slice: []T) void {
    pushHeapBy(T, slice, defaultLessThan(T));
}

pub fn pushHeapBy(comptime T: type, slice: []T, lessThan: fn (T, T) bool) void {
    if (slice.len <= 1) return;
    siftUp(T, slice, slice.len - 1, lessThan);
}

pub fn popHeap(comptime T: type, slice: []T) void {
    popHeapBy(T, slice, defaultLessThan(T));
}

pub fn popHeapBy(comptime T: type, slice: []T, lessThan: fn (T, T) bool) void {
    if (slice.len <= 1) return;
    const temp = slice[0];
    slice[0] = slice[slice.len - 1];
    slice[slice.len - 1] = temp;
    siftDown(T, slice, 0, slice.len - 1, lessThan);
}

pub fn sortHeap(comptime T: type, slice: []T) void {
    sortHeapBy(T, slice, defaultLessThan(T));
}

pub fn sortHeapBy(comptime T: type, slice: []T, lessThan: fn (T, T) bool) void {
    var end = slice.len;
    while (end > 1) {
        popHeapBy(T, slice[0..end], lessThan);
        end -= 1;
    }
}

pub fn isHeap(comptime T: type, slice: []const T) bool {
    return isHeapBy(T, slice, defaultLessThan(T));
}

pub fn isHeapBy(comptime T: type, slice: []const T, lessThan: fn (T, T) bool) bool {
    return isHeapUntilBy(T, slice, lessThan) == slice.len;
}

pub fn isHeapUntil(comptime T: type, slice: []const T) usize {
    return isHeapUntilBy(T, slice, defaultLessThan(T));
}

pub fn isHeapUntilBy(comptime T: type, slice: []const T, lessThan: fn (T, T) bool) usize {
    if (slice.len <= 1) return slice.len;
    for (1..slice.len) |i| {
        const parent = (i - 1) / 2;
        if (lessThan(slice[parent], slice[i])) {
            return i;
        }
    }
    return slice.len;
}

test "makeHeap" {
    var arr = [_]i32{ 3, 1, 4, 1, 5, 9, 2, 6 };
    makeHeap(i32, &arr);
    try std.testing.expect(isHeap(i32, &arr));
}

test "pushHeap" {
    var arr = [_]i32{ 9, 6, 5, 1, 4, 3, 2, 0 };
    arr[arr.len - 1] = 7;
    pushHeap(i32, &arr);
    try std.testing.expect(isHeap(i32, &arr));
}

test "popHeap" {
    var arr = [_]i32{ 9, 6, 5, 1, 4, 3, 2 };
    popHeap(i32, &arr);
    try std.testing.expectEqual(@as(i32, 9), arr[arr.len - 1]);
    try std.testing.expect(isHeap(i32, arr[0 .. arr.len - 1]));
}

test "sortHeap" {
    var arr = [_]i32{ 9, 6, 5, 1, 4, 3, 2 };
    sortHeap(i32, &arr);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 1, 2, 3, 4, 5, 6, 9 }, &arr);
}

test "isHeap" {
    const valid = [_]i32{ 9, 6, 5, 1, 4, 3, 2 };
    const invalid = [_]i32{ 1, 2, 3, 4, 5, 6, 9 };
    try std.testing.expect(isHeap(i32, &valid));
    try std.testing.expect(!isHeap(i32, &invalid));
}

test "isHeapUntil" {
    const arr = [_]i32{ 9, 6, 5, 1, 4, 3, 10 };
    const until = isHeapUntil(i32, &arr);
    try std.testing.expectEqual(@as(usize, 6), until);
}
