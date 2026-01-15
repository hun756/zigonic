const std = @import("std");

pub fn identity(comptime T: type) fn (T) T {
    return struct {
        fn f(x: T) T {
            return x;
        }
    }.f;
}

pub fn constant(comptime T: type, value: T) fn (anytype) T {
    _ = value;
    return struct {
        fn f(_: anytype) T {
            return @as(T, undefined);
        }
    }.f;
}

pub fn compose(
    comptime A: type,
    comptime B: type,
    comptime C: type,
    comptime f: fn (B) C,
    comptime g: fn (A) B,
) fn (A) C {
    return struct {
        fn composed(x: A) C {
            return f(g(x));
        }
    }.composed;
}

pub fn pipe(
    comptime A: type,
    comptime B: type,
    comptime C: type,
    comptime f: fn (A) B,
    comptime g: fn (B) C,
) fn (A) C {
    return struct {
        fn piped(x: A) C {
            return g(f(x));
        }
    }.piped;
}

pub fn flip(
    comptime A: type,
    comptime B: type,
    comptime R: type,
    comptime f: fn (A, B) R,
) fn (B, A) R {
    return struct {
        fn flipped(b: B, a: A) R {
            return f(a, b);
        }
    }.flipped;
}

pub fn negate(comptime T: type, comptime pred: fn (T) bool) fn (T) bool {
    return struct {
        fn negated(x: T) bool {
            return !pred(x);
        }
    }.negated;
}

pub fn conjunct(
    comptime T: type,
    comptime pred1: fn (T) bool,
    comptime pred2: fn (T) bool,
) fn (T) bool {
    return struct {
        fn conjuncted(x: T) bool {
            return pred1(x) and pred2(x);
        }
    }.conjuncted;
}

pub fn disjunct(
    comptime T: type,
    comptime pred1: fn (T) bool,
    comptime pred2: fn (T) bool,
) fn (T) bool {
    return struct {
        fn disjuncted(x: T) bool {
            return pred1(x) or pred2(x);
        }
    }.disjuncted;
}

pub fn applyN(
    comptime T: type,
    comptime f: fn (T) T,
    n: usize,
    initial: T,
) T {
    var result = initial;
    for (0..n) |_| {
        result = f(result);
    }
    return result;
}

pub fn iterate(
    comptime T: type,
    comptime f: fn (T) T,
    initial: T,
    dest: []T,
) void {
    if (dest.len == 0) return;
    dest[0] = initial;
    var current = initial;
    for (1..dest.len) |i| {
        current = f(current);
        dest[i] = current;
    }
}

pub fn unfold(
    comptime S: type,
    comptime T: type,
    comptime f: fn (S) ?struct { value: T, next: S },
    initial: S,
    dest: []T,
) usize {
    var state = initial;
    var i: usize = 0;
    while (i < dest.len) {
        if (f(state)) |result| {
            dest[i] = result.value;
            state = result.next;
            i += 1;
        } else {
            break;
        }
    }
    return i;
}

pub fn zipWith(
    comptime A: type,
    comptime B: type,
    comptime R: type,
    slice1: []const A,
    slice2: []const B,
    dest: []R,
    comptime f: fn (A, B) R,
) []R {
    const len = @min(@min(slice1.len, slice2.len), dest.len);
    for (0..len) |i| {
        dest[i] = f(slice1[i], slice2[i]);
    }
    return dest[0..len];
}

pub fn scanLeft(
    comptime T: type,
    comptime R: type,
    slice: []const T,
    initial: R,
    dest: []R,
    comptime f: fn (R, T) R,
) []R {
    if (dest.len == 0) return dest[0..0];

    dest[0] = initial;
    var acc = initial;
    const len = @min(slice.len, dest.len - 1);

    for (0..len) |i| {
        acc = f(acc, slice[i]);
        dest[i + 1] = acc;
    }

    return dest[0 .. len + 1];
}

pub fn scanRight(
    comptime T: type,
    comptime R: type,
    slice: []const T,
    initial: R,
    dest: []R,
    comptime f: fn (T, R) R,
) []R {
    if (slice.len == 0 or dest.len == 0) {
        if (dest.len > 0) dest[0] = initial;
        return dest[0..@min(1, dest.len)];
    }

    const len = @min(slice.len, dest.len - 1);
    dest[len] = initial;
    var acc = initial;

    var i: usize = len;
    while (i > 0) {
        i -= 1;
        acc = f(slice[i], acc);
        dest[i] = acc;
    }

    return dest[0 .. len + 1];
}

pub fn takeWhile(
    comptime T: type,
    slice: []const T,
    comptime pred: fn (T) bool,
) []const T {
    for (slice, 0..) |item, i| {
        if (!pred(item)) return slice[0..i];
    }
    return slice;
}

pub fn dropWhile(
    comptime T: type,
    slice: []const T,
    comptime pred: fn (T) bool,
) []const T {
    for (slice, 0..) |item, i| {
        if (!pred(item)) return slice[i..];
    }
    return slice[slice.len..];
}

pub fn span(
    comptime T: type,
    slice: []const T,
    comptime pred: fn (T) bool,
) struct { taken: []const T, dropped: []const T } {
    for (slice, 0..) |item, i| {
        if (!pred(item)) {
            return .{ .taken = slice[0..i], .dropped = slice[i..] };
        }
    }
    return .{ .taken = slice, .dropped = slice[slice.len..] };
}

pub fn groupBy(
    comptime T: type,
    slice: []const T,
    comptime eq: fn (T, T) bool,
    allocator: std.mem.Allocator,
) !std.ArrayList([]const T) {
    var groups = std.ArrayList([]const T).init(allocator);
    errdefer groups.deinit();

    if (slice.len == 0) return groups;

    var start: usize = 0;
    for (slice[1..], 1..) |item, i| {
        if (!eq(slice[i - 1], item)) {
            try groups.append(slice[start..i]);
            start = i;
        }
    }
    try groups.append(slice[start..]);

    return groups;
}

pub fn intersperse(
    comptime T: type,
    slice: []const T,
    separator: T,
    dest: []T,
) []T {
    if (slice.len == 0) return dest[0..0];

    const result_len = slice.len * 2 - 1;
    if (dest.len < result_len) return dest[0..0];

    var j: usize = 0;
    for (slice, 0..) |item, i| {
        dest[j] = item;
        j += 1;
        if (i < slice.len - 1) {
            dest[j] = separator;
            j += 1;
        }
    }

    return dest[0..result_len];
}

pub fn intercalate(
    comptime T: type,
    slices: []const []const T,
    separator: []const T,
    dest: []T,
) []T {
    if (slices.len == 0) return dest[0..0];

    var total_len: usize = 0;
    for (slices) |s| {
        total_len += s.len;
    }
    total_len += separator.len * (slices.len - 1);

    if (dest.len < total_len) return dest[0..0];

    var pos: usize = 0;
    for (slices, 0..) |s, i| {
        @memcpy(dest[pos .. pos + s.len], s);
        pos += s.len;
        if (i < slices.len - 1) {
            @memcpy(dest[pos .. pos + separator.len], separator);
            pos += separator.len;
        }
    }

    return dest[0..total_len];
}

pub fn chunks(
    comptime T: type,
    slice: []const T,
    chunk_size: usize,
    allocator: std.mem.Allocator,
) !std.ArrayList([]const T) {
    var result = std.ArrayList([]const T).init(allocator);
    errdefer result.deinit();

    if (chunk_size == 0) return result;

    var i: usize = 0;
    while (i < slice.len) {
        const end = @min(i + chunk_size, slice.len);
        try result.append(slice[i..end]);
        i = end;
    }

    return result;
}

pub fn windows(
    comptime T: type,
    slice: []const T,
    window_size: usize,
    allocator: std.mem.Allocator,
) !std.ArrayList([]const T) {
    var result = std.ArrayList([]const T).init(allocator);
    errdefer result.deinit();

    if (window_size == 0 or window_size > slice.len) return result;

    for (0..slice.len - window_size + 1) |i| {
        try result.append(slice[i .. i + window_size]);
    }

    return result;
}

pub fn flatten(
    comptime T: type,
    slices: []const []const T,
    dest: []T,
) []T {
    var total_len: usize = 0;
    for (slices) |s| {
        total_len += s.len;
    }

    if (dest.len < total_len) return dest[0..0];

    var pos: usize = 0;
    for (slices) |s| {
        @memcpy(dest[pos .. pos + s.len], s);
        pos += s.len;
    }

    return dest[0..total_len];
}

pub fn transpose(
    comptime T: type,
    matrix: []const []const T,
    allocator: std.mem.Allocator,
) !std.ArrayList(std.ArrayList(T)) {
    var result = std.ArrayList(std.ArrayList(T)).init(allocator);
    errdefer {
        for (result.items) |*row| {
            row.deinit();
        }
        result.deinit();
    }

    if (matrix.len == 0) return result;

    var min_cols: usize = matrix[0].len;
    for (matrix) |row| {
        min_cols = @min(min_cols, row.len);
    }

    for (0..min_cols) |col| {
        var new_row = std.ArrayList(T).init(allocator);
        errdefer new_row.deinit();

        for (matrix) |row| {
            try new_row.append(row[col]);
        }
        try result.append(new_row);
    }

    return result;
}

test "compose" {
    const double = struct {
        fn f(x: i32) i32 {
            return x * 2;
        }
    }.f;

    const addOne = struct {
        fn f(x: i32) i32 {
            return x + 1;
        }
    }.f;

    const composed = compose(i32, i32, i32, double, addOne);
    try std.testing.expectEqual(@as(i32, 10), composed(4));
}

test "pipe" {
    const double = struct {
        fn f(x: i32) i32 {
            return x * 2;
        }
    }.f;

    const addOne = struct {
        fn f(x: i32) i32 {
            return x + 1;
        }
    }.f;

    const piped = pipe(i32, i32, i32, addOne, double);
    try std.testing.expectEqual(@as(i32, 10), piped(4));
}

test "negate" {
    const isPositive = struct {
        fn f(x: i32) bool {
            return x > 0;
        }
    }.f;

    const isNotPositive = negate(i32, isPositive);
    try std.testing.expect(!isNotPositive(5));
    try std.testing.expect(isNotPositive(-1));
}

test "conjunct" {
    const isPositive = struct {
        fn f(x: i32) bool {
            return x > 0;
        }
    }.f;

    const isSmall = struct {
        fn f(x: i32) bool {
            return x < 10;
        }
    }.f;

    const isSmallPositive = conjunct(i32, isPositive, isSmall);
    try std.testing.expect(isSmallPositive(5));
    try std.testing.expect(!isSmallPositive(-1));
    try std.testing.expect(!isSmallPositive(15));
}

test "applyN" {
    const double = struct {
        fn f(x: i32) i32 {
            return x * 2;
        }
    }.f;

    try std.testing.expectEqual(@as(i32, 16), applyN(i32, double, 4, 1));
}

test "iterate" {
    const double = struct {
        fn f(x: i32) i32 {
            return x * 2;
        }
    }.f;

    var dest: [5]i32 = undefined;
    iterate(i32, double, 1, &dest);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 1, 2, 4, 8, 16 }, &dest);
}

test "zipWith" {
    const arr1 = [_]i32{ 1, 2, 3, 4 };
    const arr2 = [_]i32{ 10, 20, 30, 40 };
    var dest: [4]i32 = undefined;

    const add = struct {
        fn f(a: i32, b: i32) i32 {
            return a + b;
        }
    }.f;

    const result = zipWith(i32, i32, i32, &arr1, &arr2, &dest, add);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 11, 22, 33, 44 }, result);
}

test "takeWhile" {
    const arr = [_]i32{ 1, 2, 3, 4, 5, 1, 2 };
    const isSmall = struct {
        fn f(x: i32) bool {
            return x < 4;
        }
    }.f;

    const result = takeWhile(i32, &arr, isSmall);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 1, 2, 3 }, result);
}

test "dropWhile" {
    const arr = [_]i32{ 1, 2, 3, 4, 5, 1, 2 };
    const isSmall = struct {
        fn f(x: i32) bool {
            return x < 4;
        }
    }.f;

    const result = dropWhile(i32, &arr, isSmall);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 4, 5, 1, 2 }, result);
}

test "span" {
    const arr = [_]i32{ 1, 2, 3, 4, 5, 1, 2 };
    const isSmall = struct {
        fn f(x: i32) bool {
            return x < 4;
        }
    }.f;

    const result = span(i32, &arr, isSmall);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 1, 2, 3 }, result.taken);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 4, 5, 1, 2 }, result.dropped);
}

test "groupBy" {
    const allocator = std.testing.allocator;
    const arr = [_]i32{ 1, 1, 2, 2, 2, 3, 1, 1 };

    const eq = struct {
        fn f(a: i32, b: i32) bool {
            return a == b;
        }
    }.f;

    var groups = try groupBy(i32, &arr, eq, allocator);
    defer groups.deinit();

    try std.testing.expectEqual(@as(usize, 4), groups.items.len);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 1, 1 }, groups.items[0]);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 2, 2, 2 }, groups.items[1]);
}

test "intersperse" {
    const arr = [_]i32{ 1, 2, 3 };
    var dest: [5]i32 = undefined;

    const result = intersperse(i32, &arr, 0, &dest);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 1, 0, 2, 0, 3 }, result);
}

test "chunks" {
    const allocator = std.testing.allocator;
    const arr = [_]i32{ 1, 2, 3, 4, 5 };

    var result = try chunks(i32, &arr, 2, allocator);
    defer result.deinit();

    try std.testing.expectEqual(@as(usize, 3), result.items.len);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 1, 2 }, result.items[0]);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 3, 4 }, result.items[1]);
    try std.testing.expectEqualSlices(i32, &[_]i32{5}, result.items[2]);
}

test "windows" {
    const allocator = std.testing.allocator;
    const arr = [_]i32{ 1, 2, 3, 4, 5 };

    var result = try windows(i32, &arr, 3, allocator);
    defer result.deinit();

    try std.testing.expectEqual(@as(usize, 3), result.items.len);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 1, 2, 3 }, result.items[0]);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 2, 3, 4 }, result.items[1]);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 3, 4, 5 }, result.items[2]);
}

test "flatten" {
    const slices = [_][]const i32{
        &[_]i32{ 1, 2 },
        &[_]i32{ 3, 4, 5 },
        &[_]i32{6},
    };
    var dest: [6]i32 = undefined;

    const result = flatten(i32, &slices, &dest);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 1, 2, 3, 4, 5, 6 }, result);
}
