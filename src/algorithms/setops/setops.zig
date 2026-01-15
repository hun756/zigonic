const std = @import("std");

fn defaultLessThan(comptime T: type) fn (T, T) bool {
    return struct {
        fn f(a: T, b: T) bool {
            return a < b;
        }
    }.f;
}

pub fn merge(comptime T: type, a: []const T, b: []const T, dest: []T) []T {
    return mergeBy(T, a, b, dest, defaultLessThan(T));
}

pub fn mergeBy(comptime T: type, a: []const T, b: []const T, dest: []T, lessThan: fn (T, T) bool) []T {
    var i: usize = 0;
    var j: usize = 0;
    var k: usize = 0;
    while (i < a.len and j < b.len and k < dest.len) {
        if (lessThan(a[i], b[j])) {
            dest[k] = a[i];
            i += 1;
        } else {
            dest[k] = b[j];
            j += 1;
        }
        k += 1;
    }
    while (i < a.len and k < dest.len) {
        dest[k] = a[i];
        i += 1;
        k += 1;
    }
    while (j < b.len and k < dest.len) {
        dest[k] = b[j];
        j += 1;
        k += 1;
    }
    return dest[0..k];
}

pub fn inplaceMerge(comptime T: type, slice: []T, middle: usize, allocator: std.mem.Allocator) !void {
    return inplaceMergeBy(T, slice, middle, allocator, defaultLessThan(T));
}

pub fn inplaceMergeBy(comptime T: type, slice: []T, middle: usize, allocator: std.mem.Allocator, lessThan: fn (T, T) bool) !void {
    if (slice.len == 0 or middle == 0 or middle >= slice.len) return;
    const left = slice[0..middle];
    const right = slice[middle..];
    const temp = try allocator.alloc(T, left.len);
    defer allocator.free(temp);
    @memcpy(temp, left);
    var i: usize = 0;
    var j: usize = 0;
    var k: usize = 0;
    while (i < temp.len and j < right.len) {
        if (lessThan(temp[i], right[j])) {
            slice[k] = temp[i];
            i += 1;
        } else {
            slice[k] = right[j];
            j += 1;
        }
        k += 1;
    }
    while (i < temp.len) {
        slice[k] = temp[i];
        i += 1;
        k += 1;
    }
}

pub fn setUnion(comptime T: type, a: []const T, b: []const T, dest: []T) []T {
    return setUnionBy(T, a, b, dest, defaultLessThan(T));
}

pub fn setUnionBy(comptime T: type, a: []const T, b: []const T, dest: []T, lessThan: fn (T, T) bool) []T {
    var i: usize = 0;
    var j: usize = 0;
    var k: usize = 0;
    while (i < a.len and j < b.len and k < dest.len) {
        if (lessThan(a[i], b[j])) {
            dest[k] = a[i];
            i += 1;
            k += 1;
        } else if (lessThan(b[j], a[i])) {
            dest[k] = b[j];
            j += 1;
            k += 1;
        } else {
            dest[k] = a[i];
            i += 1;
            j += 1;
            k += 1;
        }
    }
    while (i < a.len and k < dest.len) {
        dest[k] = a[i];
        i += 1;
        k += 1;
    }
    while (j < b.len and k < dest.len) {
        dest[k] = b[j];
        j += 1;
        k += 1;
    }
    return dest[0..k];
}

pub fn setIntersection(comptime T: type, a: []const T, b: []const T, dest: []T) []T {
    return setIntersectionBy(T, a, b, dest, defaultLessThan(T));
}

pub fn setIntersectionBy(comptime T: type, a: []const T, b: []const T, dest: []T, lessThan: fn (T, T) bool) []T {
    var i: usize = 0;
    var j: usize = 0;
    var k: usize = 0;
    while (i < a.len and j < b.len and k < dest.len) {
        if (lessThan(a[i], b[j])) {
            i += 1;
        } else if (lessThan(b[j], a[i])) {
            j += 1;
        } else {
            dest[k] = a[i];
            i += 1;
            j += 1;
            k += 1;
        }
    }
    return dest[0..k];
}

pub fn setDifference(comptime T: type, a: []const T, b: []const T, dest: []T) []T {
    return setDifferenceBy(T, a, b, dest, defaultLessThan(T));
}

pub fn setDifferenceBy(comptime T: type, a: []const T, b: []const T, dest: []T, lessThan: fn (T, T) bool) []T {
    var i: usize = 0;
    var j: usize = 0;
    var k: usize = 0;
    while (i < a.len and k < dest.len) {
        if (j >= b.len) {
            dest[k] = a[i];
            i += 1;
            k += 1;
        } else if (lessThan(a[i], b[j])) {
            dest[k] = a[i];
            i += 1;
            k += 1;
        } else if (lessThan(b[j], a[i])) {
            j += 1;
        } else {
            i += 1;
            j += 1;
        }
    }
    return dest[0..k];
}

pub fn setSymmetricDifference(comptime T: type, a: []const T, b: []const T, dest: []T) []T {
    return setSymmetricDifferenceBy(T, a, b, dest, defaultLessThan(T));
}

pub fn setSymmetricDifferenceBy(comptime T: type, a: []const T, b: []const T, dest: []T, lessThan: fn (T, T) bool) []T {
    var i: usize = 0;
    var j: usize = 0;
    var k: usize = 0;
    while (i < a.len and j < b.len and k < dest.len) {
        if (lessThan(a[i], b[j])) {
            dest[k] = a[i];
            i += 1;
            k += 1;
        } else if (lessThan(b[j], a[i])) {
            dest[k] = b[j];
            j += 1;
            k += 1;
        } else {
            i += 1;
            j += 1;
        }
    }
    while (i < a.len and k < dest.len) {
        dest[k] = a[i];
        i += 1;
        k += 1;
    }
    while (j < b.len and k < dest.len) {
        dest[k] = b[j];
        j += 1;
        k += 1;
    }
    return dest[0..k];
}

pub fn includes(comptime T: type, a: []const T, b: []const T) bool {
    return includesBy(T, a, b, defaultLessThan(T));
}

pub fn includesBy(comptime T: type, a: []const T, b: []const T, lessThan: fn (T, T) bool) bool {
    var i: usize = 0;
    var j: usize = 0;
    while (j < b.len) {
        if (i >= a.len) return false;
        if (lessThan(b[j], a[i])) return false;
        if (!lessThan(a[i], b[j])) {
            j += 1;
        }
        i += 1;
    }
    return true;
}

test "merge" {
    const a = [_]i32{ 1, 3, 5, 7 };
    const b = [_]i32{ 2, 4, 6, 8 };
    var dest: [8]i32 = undefined;
    const result = merge(i32, &a, &b, &dest);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 1, 2, 3, 4, 5, 6, 7, 8 }, result);
}

test "inplaceMerge" {
    var arr = [_]i32{ 1, 3, 5, 2, 4, 6 };
    try inplaceMerge(i32, &arr, 3, std.testing.allocator);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 1, 2, 3, 4, 5, 6 }, &arr);
}

test "setUnion" {
    const a = [_]i32{ 1, 2, 3, 5 };
    const b = [_]i32{ 2, 3, 4, 6 };
    var dest: [8]i32 = undefined;
    const result = setUnion(i32, &a, &b, &dest);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 1, 2, 3, 4, 5, 6 }, result);
}

test "setIntersection" {
    const a = [_]i32{ 1, 2, 3, 5 };
    const b = [_]i32{ 2, 3, 4, 6 };
    var dest: [4]i32 = undefined;
    const result = setIntersection(i32, &a, &b, &dest);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 2, 3 }, result);
}

test "setDifference" {
    const a = [_]i32{ 1, 2, 3, 5 };
    const b = [_]i32{ 2, 3, 4, 6 };
    var dest: [4]i32 = undefined;
    const result = setDifference(i32, &a, &b, &dest);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 1, 5 }, result);
}

test "setSymmetricDifference" {
    const a = [_]i32{ 1, 2, 3, 5 };
    const b = [_]i32{ 2, 3, 4, 6 };
    var dest: [8]i32 = undefined;
    const result = setSymmetricDifference(i32, &a, &b, &dest);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 1, 4, 5, 6 }, result);
}

test "includes" {
    const a = [_]i32{ 1, 2, 3, 4, 5, 6 };
    const b = [_]i32{ 2, 4, 6 };
    const c = [_]i32{ 2, 7 };
    try std.testing.expect(includes(i32, &a, &b));
    try std.testing.expect(!includes(i32, &a, &c));
}
