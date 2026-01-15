const std = @import("std");

pub fn isPartitioned(comptime T: type, slice: []const T, predicate: fn (T) bool) bool {
    var seen_false = false;
    for (slice) |item| {
        if (predicate(item)) {
            if (seen_false) return false;
        } else {
            seen_false = true;
        }
    }
    return true;
}

pub fn partition(comptime T: type, slice: []T, predicate: fn (T) bool) usize {
    var i: usize = 0;
    for (0..slice.len) |j| {
        if (predicate(slice[j])) {
            std.mem.swap(T, &slice[i], &slice[j]);
            i += 1;
        }
    }
    return i;
}

pub const PartitionCopyResult = struct {
    true_count: usize,
    false_count: usize,
};

pub fn partitionCopy(comptime T: type, source: []const T, out_true: []T, out_false: []T, predicate: fn (T) bool) PartitionCopyResult {
    var true_idx: usize = 0;
    var false_idx: usize = 0;
    for (source) |item| {
        if (predicate(item)) {
            if (true_idx < out_true.len) {
                out_true[true_idx] = item;
                true_idx += 1;
            }
        } else {
            if (false_idx < out_false.len) {
                out_false[false_idx] = item;
                false_idx += 1;
            }
        }
    }
    return .{ .true_count = true_idx, .false_count = false_idx };
}

pub fn stablePartition(comptime T: type, slice: []T, allocator: std.mem.Allocator, predicate: fn (T) bool) !usize {
    if (slice.len == 0) return 0;

    const buffer = try allocator.alloc(T, slice.len);
    defer allocator.free(buffer);

    var true_idx: usize = 0;
    var false_idx: usize = 0;

    for (slice) |item| {
        if (predicate(item)) {
            buffer[true_idx] = item;
            true_idx += 1;
        }
    }

    for (slice) |item| {
        if (!predicate(item)) {
            buffer[true_idx + false_idx] = item;
            false_idx += 1;
        }
    }

    @memcpy(slice, buffer);
    return true_idx;
}

pub fn partitionPoint(comptime T: type, slice: []const T, predicate: fn (T) bool) usize {
    var low: usize = 0;
    var high: usize = slice.len;
    while (low < high) {
        const mid = low + (high - low) / 2;
        if (predicate(slice[mid])) {
            low = mid + 1;
        } else {
            high = mid;
        }
    }
    return low;
}

test "isPartitioned" {
    const isEven = struct {
        fn f(x: i32) bool {
            return @mod(x, 2) == 0;
        }
    }.f;
    const partitioned = [_]i32{ 2, 4, 6, 1, 3, 5 };
    const not_partitioned = [_]i32{ 2, 1, 4, 3, 6, 5 };
    try std.testing.expect(isPartitioned(i32, &partitioned, isEven));
    try std.testing.expect(!isPartitioned(i32, &not_partitioned, isEven));
}

test "partition" {
    var arr = [_]i32{ 1, 2, 3, 4, 5, 6, 7, 8 };
    const isEven = struct {
        fn f(x: i32) bool {
            return @mod(x, 2) == 0;
        }
    }.f;
    const pivot = partition(i32, &arr, isEven);
    try std.testing.expectEqual(@as(usize, 4), pivot);
    for (arr[0..pivot]) |x| {
        try std.testing.expect(@mod(x, 2) == 0);
    }
    for (arr[pivot..]) |x| {
        try std.testing.expect(@mod(x, 2) != 0);
    }
}

test "partitionCopy" {
    const source = [_]i32{ 1, 2, 3, 4, 5, 6 };
    var evens: [6]i32 = undefined;
    var odds: [6]i32 = undefined;
    const isEven = struct {
        fn f(x: i32) bool {
            return @mod(x, 2) == 0;
        }
    }.f;
    const result = partitionCopy(i32, &source, &evens, &odds, isEven);
    try std.testing.expectEqual(@as(usize, 3), result.true_count);
    try std.testing.expectEqual(@as(usize, 3), result.false_count);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 2, 4, 6 }, evens[0..result.true_count]);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 1, 3, 5 }, odds[0..result.false_count]);
}

test "stablePartition" {
    var arr = [_]i32{ 1, 2, 3, 4, 5, 6 };
    const isEven = struct {
        fn f(x: i32) bool {
            return @mod(x, 2) == 0;
        }
    }.f;
    const pivot = try stablePartition(i32, &arr, std.testing.allocator, isEven);
    try std.testing.expectEqual(@as(usize, 3), pivot);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 2, 4, 6 }, arr[0..pivot]);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 1, 3, 5 }, arr[pivot..]);
}

test "partitionPoint" {
    const arr = [_]i32{ 2, 4, 6, 1, 3, 5 };
    const isEven = struct {
        fn f(x: i32) bool {
            return @mod(x, 2) == 0;
        }
    }.f;
    const point = partitionPoint(i32, &arr, isEven);
    try std.testing.expectEqual(@as(usize, 3), point);
}
