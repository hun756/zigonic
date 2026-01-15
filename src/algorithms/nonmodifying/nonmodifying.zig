const std = @import("std");

pub fn findIfNot(comptime T: type, slice: []const T, predicate: fn (T) bool) ?usize {
    for (slice, 0..) |item, i| {
        if (!predicate(item)) return i;
    }
    return null;
}

pub fn findFirstOf(comptime T: type, haystack: []const T, needles: []const T) ?usize {
    for (haystack, 0..) |item, i| {
        for (needles) |needle| {
            if (item == needle) return i;
        }
    }
    return null;
}

pub fn findFirstOfBy(comptime T: type, haystack: []const T, needles: []const T, eq: fn (T, T) bool) ?usize {
    for (haystack, 0..) |item, i| {
        for (needles) |needle| {
            if (eq(item, needle)) return i;
        }
    }
    return null;
}

pub fn adjacentFind(comptime T: type, slice: []const T) ?usize {
    if (slice.len < 2) return null;
    for (0..slice.len - 1) |i| {
        if (slice[i] == slice[i + 1]) return i;
    }
    return null;
}

pub fn adjacentFindBy(comptime T: type, slice: []const T, predicate: fn (T, T) bool) ?usize {
    if (slice.len < 2) return null;
    for (0..slice.len - 1) |i| {
        if (predicate(slice[i], slice[i + 1])) return i;
    }
    return null;
}

pub const MismatchResult = struct {
    first: ?usize,
    second: ?usize,
};

pub fn mismatch(comptime T: type, a: []const T, b: []const T) MismatchResult {
    const len = @min(a.len, b.len);
    for (0..len) |i| {
        if (a[i] != b[i]) {
            return .{ .first = i, .second = i };
        }
    }
    if (a.len != b.len) {
        return .{ .first = len, .second = len };
    }
    return .{ .first = null, .second = null };
}

pub fn mismatchBy(comptime T: type, a: []const T, b: []const T, eq: fn (T, T) bool) MismatchResult {
    const len = @min(a.len, b.len);
    for (0..len) |i| {
        if (!eq(a[i], b[i])) {
            return .{ .first = i, .second = i };
        }
    }
    if (a.len != b.len) {
        return .{ .first = len, .second = len };
    }
    return .{ .first = null, .second = null };
}

pub fn equal(comptime T: type, a: []const T, b: []const T) bool {
    if (a.len != b.len) return false;
    for (a, b) |ai, bi| {
        if (ai != bi) return false;
    }
    return true;
}

pub fn equalBy(comptime T: type, a: []const T, b: []const T, eq: fn (T, T) bool) bool {
    if (a.len != b.len) return false;
    for (a, b) |ai, bi| {
        if (!eq(ai, bi)) return false;
    }
    return true;
}

pub fn search(comptime T: type, haystack: []const T, needle: []const T) ?usize {
    if (needle.len == 0) return 0;
    if (needle.len > haystack.len) return null;
    const limit = haystack.len - needle.len + 1;
    outer: for (0..limit) |i| {
        for (0..needle.len) |j| {
            if (haystack[i + j] != needle[j]) continue :outer;
        }
        return i;
    }
    return null;
}

pub fn searchBy(comptime T: type, haystack: []const T, needle: []const T, eq: fn (T, T) bool) ?usize {
    if (needle.len == 0) return 0;
    if (needle.len > haystack.len) return null;
    const limit = haystack.len - needle.len + 1;
    outer: for (0..limit) |i| {
        for (0..needle.len) |j| {
            if (!eq(haystack[i + j], needle[j])) continue :outer;
        }
        return i;
    }
    return null;
}

pub fn searchN(comptime T: type, slice: []const T, count: usize, value: T) ?usize {
    if (count == 0) return 0;
    if (count > slice.len) return null;
    const limit = slice.len - count + 1;
    outer: for (0..limit) |i| {
        for (0..count) |j| {
            if (slice[i + j] != value) continue :outer;
        }
        return i;
    }
    return null;
}

pub fn searchNBy(comptime T: type, slice: []const T, count: usize, predicate: fn (T) bool) ?usize {
    if (count == 0) return 0;
    if (count > slice.len) return null;
    const limit = slice.len - count + 1;
    outer: for (0..limit) |i| {
        for (0..count) |j| {
            if (!predicate(slice[i + j])) continue :outer;
        }
        return i;
    }
    return null;
}

pub fn findEnd(comptime T: type, haystack: []const T, needle: []const T) ?usize {
    if (needle.len == 0) return haystack.len;
    if (needle.len > haystack.len) return null;
    var result: ?usize = null;
    const limit = haystack.len - needle.len + 1;
    outer: for (0..limit) |i| {
        for (0..needle.len) |j| {
            if (haystack[i + j] != needle[j]) continue :outer;
        }
        result = i;
    }
    return result;
}

pub fn findEndBy(comptime T: type, haystack: []const T, needle: []const T, eq: fn (T, T) bool) ?usize {
    if (needle.len == 0) return haystack.len;
    if (needle.len > haystack.len) return null;
    var result: ?usize = null;
    const limit = haystack.len - needle.len + 1;
    outer: for (0..limit) |i| {
        for (0..needle.len) |j| {
            if (!eq(haystack[i + j], needle[j])) continue :outer;
        }
        result = i;
    }
    return result;
}

pub fn lexicographicalCompare(comptime T: type, a: []const T, b: []const T) std.math.Order {
    const len = @min(a.len, b.len);
    for (0..len) |i| {
        if (a[i] < b[i]) return .lt;
        if (a[i] > b[i]) return .gt;
    }
    if (a.len < b.len) return .lt;
    if (a.len > b.len) return .gt;
    return .eq;
}

pub fn lexicographicalCompareBy(comptime T: type, a: []const T, b: []const T, lessThan: fn (T, T) bool) std.math.Order {
    const len = @min(a.len, b.len);
    for (0..len) |i| {
        if (lessThan(a[i], b[i])) return .lt;
        if (lessThan(b[i], a[i])) return .gt;
    }
    if (a.len < b.len) return .lt;
    if (a.len > b.len) return .gt;
    return .eq;
}

pub fn forEach(comptime T: type, slice: []T, f: fn (*T) void) void {
    for (slice) |*item| {
        f(item);
    }
}

pub fn forEachN(comptime T: type, slice: []T, n: usize, f: fn (*T) void) []T {
    const len = @min(slice.len, n);
    for (slice[0..len]) |*item| {
        f(item);
    }
    return slice[0..len];
}

test "findIfNot" {
    const arr = [_]i32{ 2, 4, 6, 7, 8 };
    const isEven = struct {
        fn f(x: i32) bool {
            return @mod(x, 2) == 0;
        }
    }.f;
    try std.testing.expectEqual(@as(?usize, 3), findIfNot(i32, &arr, isEven));
}

test "findFirstOf" {
    const haystack = [_]i32{ 1, 2, 3, 4, 5 };
    const needles = [_]i32{ 7, 3, 9 };
    try std.testing.expectEqual(@as(?usize, 2), findFirstOf(i32, &haystack, &needles));
}

test "adjacentFind" {
    const arr = [_]i32{ 1, 2, 3, 3, 4 };
    try std.testing.expectEqual(@as(?usize, 2), adjacentFind(i32, &arr));
}

test "mismatch" {
    const a = [_]i32{ 1, 2, 3, 4, 5 };
    const b = [_]i32{ 1, 2, 9, 4, 5 };
    const result = mismatch(i32, &a, &b);
    try std.testing.expectEqual(@as(?usize, 2), result.first);
}

test "equal" {
    const a = [_]i32{ 1, 2, 3 };
    const b = [_]i32{ 1, 2, 3 };
    const c = [_]i32{ 1, 2, 4 };
    try std.testing.expect(equal(i32, &a, &b));
    try std.testing.expect(!equal(i32, &a, &c));
}

test "search" {
    const haystack = [_]i32{ 1, 2, 3, 4, 5, 6 };
    const needle = [_]i32{ 3, 4, 5 };
    try std.testing.expectEqual(@as(?usize, 2), search(i32, &haystack, &needle));
}

test "searchN" {
    const arr = [_]i32{ 1, 2, 2, 2, 3 };
    try std.testing.expectEqual(@as(?usize, 1), searchN(i32, &arr, 3, 2));
}

test "findEnd" {
    const haystack = [_]i32{ 1, 2, 1, 2, 1, 2 };
    const needle = [_]i32{ 1, 2 };
    try std.testing.expectEqual(@as(?usize, 4), findEnd(i32, &haystack, &needle));
}

test "lexicographicalCompare" {
    const a = [_]i32{ 1, 2, 3 };
    const b = [_]i32{ 1, 2, 4 };
    const c = [_]i32{ 1, 2, 3 };
    try std.testing.expectEqual(std.math.Order.lt, lexicographicalCompare(i32, &a, &b));
    try std.testing.expectEqual(std.math.Order.eq, lexicographicalCompare(i32, &a, &c));
}

test "forEach" {
    var arr = [_]i32{ 1, 2, 3 };
    const double = struct {
        fn f(x: *i32) void {
            x.* *= 2;
        }
    }.f;
    forEach(i32, &arr, double);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 2, 4, 6 }, &arr);
}
