const std = @import("std");

fn defaultLessThan(comptime T: type) fn (T, T) bool {
    return struct {
        fn f(a: T, b: T) bool {
            return a < b;
        }
    }.f;
}

pub fn nextPermutation(comptime T: type, slice: []T) bool {
    return nextPermutationBy(T, slice, defaultLessThan(T));
}

pub fn nextPermutationBy(comptime T: type, slice: []T, lessThan: fn (T, T) bool) bool {
    if (slice.len < 2) return false;
    var i: usize = slice.len - 1;
    while (i > 0 and !lessThan(slice[i - 1], slice[i])) {
        i -= 1;
    }
    if (i == 0) {
        reverse(T, slice);
        return false;
    }
    var j: usize = slice.len - 1;
    while (!lessThan(slice[i - 1], slice[j])) {
        j -= 1;
    }
    swap(T, slice, i - 1, j);
    reverse(T, slice[i..]);
    return true;
}

pub fn prevPermutation(comptime T: type, slice: []T) bool {
    return prevPermutationBy(T, slice, defaultLessThan(T));
}

pub fn prevPermutationBy(comptime T: type, slice: []T, lessThan: fn (T, T) bool) bool {
    if (slice.len < 2) return false;
    var i: usize = slice.len - 1;
    while (i > 0 and !lessThan(slice[i], slice[i - 1])) {
        i -= 1;
    }
    if (i == 0) {
        reverse(T, slice);
        return false;
    }
    var j: usize = slice.len - 1;
    while (!lessThan(slice[j], slice[i - 1])) {
        j -= 1;
    }
    swap(T, slice, i - 1, j);
    reverse(T, slice[i..]);
    return true;
}

fn swap(comptime T: type, slice: []T, i: usize, j: usize) void {
    const temp = slice[i];
    slice[i] = slice[j];
    slice[j] = temp;
}

fn reverse(comptime T: type, slice: []T) void {
    if (slice.len <= 1) return;
    var left: usize = 0;
    var right: usize = slice.len - 1;
    while (left < right) {
        swap(T, slice, left, right);
        left += 1;
        right -= 1;
    }
}

pub fn isPermutation(comptime T: type, a: []const T, b: []const T, allocator: std.mem.Allocator) !bool {
    return isPermutationBy(T, a, b, allocator, struct {
        fn eq(x: T, y: T) bool {
            return x == y;
        }
    }.eq);
}

pub fn isPermutationBy(comptime T: type, a: []const T, b: []const T, allocator: std.mem.Allocator, eq: fn (T, T) bool) !bool {
    if (a.len != b.len) return false;
    if (a.len == 0) return true;
    const used = try allocator.alloc(bool, b.len);
    defer allocator.free(used);
    @memset(used, false);
    for (a) |ai| {
        var found = false;
        for (b, 0..) |bi, j| {
            if (!used[j] and eq(ai, bi)) {
                used[j] = true;
                found = true;
                break;
            }
        }
        if (!found) return false;
    }
    return true;
}

test "nextPermutation" {
    var arr = [_]i32{ 1, 2, 3 };
    try std.testing.expect(nextPermutation(i32, &arr));
    try std.testing.expectEqualSlices(i32, &[_]i32{ 1, 3, 2 }, &arr);
    try std.testing.expect(nextPermutation(i32, &arr));
    try std.testing.expectEqualSlices(i32, &[_]i32{ 2, 1, 3 }, &arr);
}

test "nextPermutation wraps" {
    var arr = [_]i32{ 3, 2, 1 };
    try std.testing.expect(!nextPermutation(i32, &arr));
    try std.testing.expectEqualSlices(i32, &[_]i32{ 1, 2, 3 }, &arr);
}

test "prevPermutation" {
    var arr = [_]i32{ 1, 3, 2 };
    try std.testing.expect(prevPermutation(i32, &arr));
    try std.testing.expectEqualSlices(i32, &[_]i32{ 1, 2, 3 }, &arr);
}

test "prevPermutation wraps" {
    var arr = [_]i32{ 1, 2, 3 };
    try std.testing.expect(!prevPermutation(i32, &arr));
    try std.testing.expectEqualSlices(i32, &[_]i32{ 3, 2, 1 }, &arr);
}

test "isPermutation" {
    const a = [_]i32{ 1, 2, 3 };
    const b = [_]i32{ 3, 1, 2 };
    const c = [_]i32{ 1, 2, 4 };
    try std.testing.expect(try isPermutation(i32, &a, &b, std.testing.allocator));
    try std.testing.expect(!try isPermutation(i32, &a, &c, std.testing.allocator));
}
