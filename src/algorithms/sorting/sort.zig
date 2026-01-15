const std = @import("std");

pub fn insertionSort(comptime T: type, slice: []T) void {
    insertionSortBy(T, slice, defaultLessThan(T));
}

pub fn insertionSortBy(comptime T: type, slice: []T, comptime lessThan: fn (T, T) bool) void {
    if (slice.len <= 1) return;

    for (1..slice.len) |i| {
        const key = slice[i];
        var j: usize = i;

        while (j > 0 and lessThan(key, slice[j - 1])) {
            slice[j] = slice[j - 1];
            j -= 1;
        }
        slice[j] = key;
    }
}

pub fn quickSort(comptime T: type, slice: []T) void {
    quickSortBy(T, slice, defaultLessThan(T));
}

pub fn quickSortBy(comptime T: type, slice: []T, comptime lessThan: fn (T, T) bool) void {
    if (slice.len <= 1) return;

    quickSortImpl(T, slice, 0, slice.len - 1, lessThan);
}

fn quickSortImpl(comptime T: type, slice: []T, left: usize, right: usize, comptime lessThan: fn (T, T) bool) void {
    const INSERTION_THRESHOLD = 16;

    if (left >= right) return;

    const len = right - left + 1;
    if (len <= INSERTION_THRESHOLD) {
        insertionSortByRange(T, slice, left, right + 1, lessThan);
        return;
    }

    const pivot_idx = partition(T, slice, left, right, lessThan);

    if (pivot_idx > left) {
        quickSortImpl(T, slice, left, pivot_idx - 1, lessThan);
    }
    if (pivot_idx < right) {
        quickSortImpl(T, slice, pivot_idx + 1, right, lessThan);
    }
}

fn insertionSortByRange(comptime T: type, slice: []T, start: usize, end: usize, comptime lessThan: fn (T, T) bool) void {
    for (start + 1..end) |i| {
        const key = slice[i];
        var j: usize = i;

        while (j > start and lessThan(key, slice[j - 1])) {
            slice[j] = slice[j - 1];
            j -= 1;
        }
        slice[j] = key;
    }
}

fn partition(comptime T: type, slice: []T, left: usize, right: usize, comptime lessThan: fn (T, T) bool) usize {
    const mid = left + (right - left) / 2;

    if (lessThan(slice[mid], slice[left])) std.mem.swap(T, &slice[left], &slice[mid]);
    if (lessThan(slice[right], slice[left])) std.mem.swap(T, &slice[left], &slice[right]);
    if (lessThan(slice[right], slice[mid])) std.mem.swap(T, &slice[mid], &slice[right]);

    std.mem.swap(T, &slice[mid], &slice[right - 1]);
    const pivot = slice[right - 1];

    var i = left;
    var j = right - 1;

    while (true) {
        i += 1;
        while (lessThan(slice[i], pivot)) : (i += 1) {}

        j -= 1;
        while (lessThan(pivot, slice[j])) : (j -= 1) {}

        if (i >= j) break;
        std.mem.swap(T, &slice[i], &slice[j]);
    }

    std.mem.swap(T, &slice[i], &slice[right - 1]);
    return i;
}

pub fn partialSort(comptime T: type, slice: []T, n: usize) void {
    partialSortBy(T, slice, n, defaultLessThan(T));
}

pub fn partialSortBy(comptime T: type, slice: []T, n: usize, comptime lessThan: fn (T, T) bool) void {
    if (n == 0 or slice.len <= 1) return;
    const actual_n = @min(n, slice.len);

    for (0..actual_n) |i| {
        var min_idx = i;
        for (i + 1..slice.len) |j| {
            if (lessThan(slice[j], slice[min_idx])) {
                min_idx = j;
            }
        }
        if (min_idx != i) {
            std.mem.swap(T, &slice[i], &slice[min_idx]);
        }
    }
}

pub fn partialSortCopy(comptime T: type, source: []const T, dest: []T) []T {
    return partialSortCopyBy(T, source, dest, defaultLessThan(T));
}

pub fn partialSortCopyBy(comptime T: type, source: []const T, dest: []T, comptime lessThan: fn (T, T) bool) []T {
    if (source.len == 0 or dest.len == 0) return dest[0..0];

    const result_len = @min(source.len, dest.len);

    for (0..result_len) |i| {
        dest[i] = source[i];
    }

    heapifyRange(T, dest[0..result_len], greaterThan(T, lessThan));

    for (result_len..source.len) |i| {
        if (lessThan(source[i], dest[0])) {
            dest[0] = source[i];
            siftDownSlice(T, dest[0..result_len], 0, greaterThan(T, lessThan));
        }
    }

    var end = result_len;
    while (end > 1) {
        end -= 1;
        std.mem.swap(T, &dest[0], &dest[end]);
        siftDownSlice(T, dest[0..end], 0, greaterThan(T, lessThan));
    }

    return dest[0..result_len];
}

pub fn nthElement(comptime T: type, slice: []T, n: usize) void {
    nthElementBy(T, slice, n, defaultLessThan(T));
}

pub fn nthElementBy(comptime T: type, slice: []T, n: usize, comptime lessThan: fn (T, T) bool) void {
    if (n >= slice.len or slice.len <= 1) return;

    var left: usize = 0;
    var right: usize = slice.len - 1;

    while (left < right) {
        const pivot_idx = partitionNth(T, slice, left, right, lessThan);

        if (pivot_idx == n) {
            return;
        } else if (pivot_idx < n) {
            left = pivot_idx + 1;
        } else {
            right = pivot_idx - 1;
        }
    }
}

fn partitionNth(comptime T: type, slice: []T, left: usize, right: usize, comptime lessThan: fn (T, T) bool) usize {
    const mid = left + (right - left) / 2;
    std.mem.swap(T, &slice[mid], &slice[right]);

    const pivot = slice[right];
    var i = left;

    for (left..right) |j| {
        if (lessThan(slice[j], pivot)) {
            std.mem.swap(T, &slice[i], &slice[j]);
            i += 1;
        }
    }
    std.mem.swap(T, &slice[i], &slice[right]);
    return i;
}

pub fn isSorted(comptime T: type, slice: []const T) bool {
    return isSortedBy(T, slice, defaultLessThan(T));
}

pub fn isSortedBy(comptime T: type, slice: []const T, comptime lessThan: fn (T, T) bool) bool {
    if (slice.len <= 1) return true;

    for (0..slice.len - 1) |i| {
        if (lessThan(slice[i + 1], slice[i])) return false;
    }
    return true;
}

pub fn isSortedUntil(comptime T: type, slice: []const T) usize {
    return isSortedUntilBy(T, slice, defaultLessThan(T));
}

pub fn isSortedUntilBy(comptime T: type, slice: []const T, comptime lessThan: fn (T, T) bool) usize {
    if (slice.len <= 1) return slice.len;

    for (0..slice.len - 1) |i| {
        if (lessThan(slice[i + 1], slice[i])) return i + 1;
    }
    return slice.len;
}

pub fn stableSort(comptime T: type, slice: []T, allocator: std.mem.Allocator) !void {
    try stableSortBy(T, slice, allocator, defaultLessThan(T));
}

pub fn stableSortBy(comptime T: type, slice: []T, allocator: std.mem.Allocator, comptime lessThan: fn (T, T) bool) !void {
    if (slice.len <= 1) return;

    const buffer = try allocator.alloc(T, slice.len);
    defer allocator.free(buffer);

    mergeSort(T, slice, buffer, lessThan);
}

fn mergeSort(comptime T: type, slice: []T, buffer: []T, comptime lessThan: fn (T, T) bool) void {
    if (slice.len <= 1) return;

    const mid = slice.len / 2;

    mergeSort(T, slice[0..mid], buffer[0..mid], lessThan);
    mergeSort(T, slice[mid..], buffer[mid..], lessThan);
    merge(T, slice, mid, buffer, lessThan);
}

fn merge(comptime T: type, slice: []T, mid: usize, buffer: []T, comptime lessThan: fn (T, T) bool) void {
    @memcpy(buffer[0..slice.len], slice);

    var i: usize = 0;
    var j: usize = mid;
    var k: usize = 0;

    while (i < mid and j < slice.len) {
        if (lessThan(buffer[j], buffer[i])) {
            slice[k] = buffer[j];
            j += 1;
        } else {
            slice[k] = buffer[i];
            i += 1;
        }
        k += 1;
    }

    while (i < mid) {
        slice[k] = buffer[i];
        i += 1;
        k += 1;
    }

    while (j < slice.len) {
        slice[k] = buffer[j];
        j += 1;
        k += 1;
    }
}

pub fn sort(comptime T: type, slice: []T) void {
    sortBy(T, slice, defaultLessThan(T));
}

pub fn sortBy(comptime T: type, slice: []T, comptime lessThan: fn (T, T) bool) void {
    if (slice.len <= 16) {
        insertionSortBy(T, slice, lessThan);
    } else {
        introSort(T, slice, lessThan);
    }
}

fn introSort(comptime T: type, slice: []T, comptime lessThan: fn (T, T) bool) void {
    const max_depth = 2 * log2Floor(slice.len);
    introSortImpl(T, slice, 0, slice.len, max_depth, lessThan);
}

fn introSortImpl(comptime T: type, slice: []T, left: usize, right: usize, depth: usize, comptime lessThan: fn (T, T) bool) void {
    if (right <= left) return;

    const len = right - left;
    if (len <= 16) {
        insertionSortByRange(T, slice, left, right, lessThan);
        return;
    }

    if (depth == 0) {
        heapSortRange(T, slice, left, right, lessThan);
        return;
    }

    const pivot_idx = partition(T, slice, left, right - 1, lessThan);
    introSortImpl(T, slice, left, pivot_idx, depth - 1, lessThan);
    introSortImpl(T, slice, pivot_idx + 1, right, depth - 1, lessThan);
}

fn heapSortRange(comptime T: type, slice: []T, left: usize, right: usize, comptime lessThan: fn (T, T) bool) void {
    const sub = slice[left..right];

    var i = sub.len / 2;
    while (i > 0) {
        i -= 1;
        siftDownRange(T, sub, i, sub.len, lessThan);
    }

    var end = sub.len;
    while (end > 1) {
        end -= 1;
        std.mem.swap(T, &sub[0], &sub[end]);
        siftDownRange(T, sub, 0, end, lessThan);
    }
}

fn siftDownRange(comptime T: type, slice: []T, start: usize, end: usize, comptime lessThan: fn (T, T) bool) void {
    var root = start;

    while (true) {
        var largest = root;
        const left_child = 2 * root + 1;
        const right_child = 2 * root + 2;

        if (left_child < end and lessThan(slice[largest], slice[left_child])) {
            largest = left_child;
        }
        if (right_child < end and lessThan(slice[largest], slice[right_child])) {
            largest = right_child;
        }

        if (largest == root) break;

        std.mem.swap(T, &slice[root], &slice[largest]);
        root = largest;
    }
}

fn log2Floor(n: usize) usize {
    if (n == 0) return 0;
    var result: usize = 0;
    var val = n;
    while (val > 1) {
        val >>= 1;
        result += 1;
    }
    return result;
}

fn defaultLessThan(comptime T: type) fn (T, T) bool {
    return struct {
        fn lessThan(a: T, b: T) bool {
            return a < b;
        }
    }.lessThan;
}

fn greaterThan(comptime T: type, comptime lessThan: fn (T, T) bool) fn (T, T) bool {
    return struct {
        fn gt(a: T, b: T) bool {
            return lessThan(b, a);
        }
    }.gt;
}

fn heapify(comptime T: type, slice: []T, comptime lessThan: fn (T, T) bool) void {
    if (slice.len <= 1) return;

    var i = slice.len / 2;
    while (i > 0) {
        i -= 1;
        siftDown(T, slice, i, lessThan);
    }
}

fn heapifyRange(comptime T: type, slice: []T, comptime lessThan: fn (T, T) bool) void {
    if (slice.len <= 1) return;

    var i = slice.len / 2;
    while (i > 0) {
        i -= 1;
        siftDownSlice(T, slice, i, lessThan);
    }
}

fn siftDown(comptime T: type, slice: []T, start: usize, comptime lessThan: fn (T, T) bool) void {
    var root = start;
    const len = slice.len;

    while (true) {
        var largest = root;
        const left_child = 2 * root + 1;
        const right_child = 2 * root + 2;

        if (left_child < len and lessThan(slice[largest], slice[left_child])) {
            largest = left_child;
        }
        if (right_child < len and lessThan(slice[largest], slice[right_child])) {
            largest = right_child;
        }

        if (largest == root) break;

        std.mem.swap(T, &slice[root], &slice[largest]);
        root = largest;
    }
}

fn siftDownSlice(comptime T: type, slice: []T, start: usize, comptime lessThan: fn (T, T) bool) void {
    var root = start;
    const len = slice.len;

    while (true) {
        var largest = root;
        const left_child = 2 * root + 1;
        const right_child = 2 * root + 2;

        if (left_child < len and lessThan(slice[largest], slice[left_child])) {
            largest = left_child;
        }
        if (right_child < len and lessThan(slice[largest], slice[right_child])) {
            largest = right_child;
        }

        if (largest == root) break;

        std.mem.swap(T, &slice[root], &slice[largest]);
        root = largest;
    }
}

test "insertionSort" {
    var data = [_]i32{ 5, 2, 8, 1, 9, 3, 7, 4, 6 };
    insertionSort(i32, &data);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, &data);
}

test "quickSort" {
    var data = [_]i32{ 5, 2, 8, 1, 9, 3, 7, 4, 6 };
    quickSort(i32, &data);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, &data);
}

test "quickSort large array" {
    var data: [100]i32 = undefined;
    for (0..100) |i| {
        data[i] = @intCast(99 - i);
    }
    quickSort(i32, &data);

    for (0..100) |i| {
        try std.testing.expectEqual(@as(i32, @intCast(i)), data[i]);
    }
}

test "partialSort" {
    var data = [_]i32{ 9, 7, 5, 3, 1, 8, 6, 4, 2, 0 };
    partialSort(i32, &data, 3);

    try std.testing.expectEqual(@as(i32, 0), data[0]);
    try std.testing.expectEqual(@as(i32, 1), data[1]);
    try std.testing.expectEqual(@as(i32, 2), data[2]);
}

test "nthElement" {
    var data = [_]i32{ 5, 2, 8, 1, 9, 3, 7, 4, 6 };
    nthElement(i32, &data, 4);

    try std.testing.expectEqual(@as(i32, 5), data[4]);

    for (data[0..4]) |x| {
        try std.testing.expect(x <= 5);
    }
    for (data[5..]) |x| {
        try std.testing.expect(x >= 5);
    }
}

test "isSorted" {
    const sorted = [_]i32{ 1, 2, 3, 4, 5 };
    const unsorted = [_]i32{ 1, 3, 2, 4, 5 };

    try std.testing.expect(isSorted(i32, &sorted));
    try std.testing.expect(!isSorted(i32, &unsorted));
}

test "isSortedUntil" {
    const data = [_]i32{ 1, 2, 3, 5, 4, 6 };
    try std.testing.expectEqual(@as(usize, 4), isSortedUntil(i32, &data));
}

test "stableSort" {
    const allocator = std.testing.allocator;
    var data = [_]i32{ 5, 2, 8, 1, 9, 3, 7, 4, 6 };
    try stableSort(i32, &data, allocator);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, &data);
}

test "sort (introsort)" {
    var data = [_]i32{ 5, 2, 8, 1, 9, 3, 7, 4, 6, 10, 15, 12, 11, 14, 13, 16, 17, 18, 19, 20 };
    sort(i32, &data);
    for (0..data.len - 1) |i| {
        try std.testing.expect(data[i] <= data[i + 1]);
    }
}
