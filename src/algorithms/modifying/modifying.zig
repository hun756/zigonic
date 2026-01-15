const std = @import("std");

pub fn copy(comptime T: type, source: []const T, dest: []T) []T {
    const len = @min(source.len, dest.len);
    @memcpy(dest[0..len], source[0..len]);
    return dest[0..len];
}

pub fn copyIf(comptime T: type, source: []const T, dest: []T, predicate: fn (T) bool) []T {
    var count: usize = 0;
    for (source) |item| {
        if (predicate(item)) {
            if (count >= dest.len) break;
            dest[count] = item;
            count += 1;
        }
    }
    return dest[0..count];
}

pub fn copyN(comptime T: type, source: []const T, n: usize, dest: []T) []T {
    const len = @min(@min(source.len, n), dest.len);
    @memcpy(dest[0..len], source[0..len]);
    return dest[0..len];
}

pub fn copyBackward(comptime T: type, source: []const T, dest: []T) []T {
    const len = @min(source.len, dest.len);
    var i: usize = len;
    while (i > 0) {
        i -= 1;
        dest[i] = source[i];
    }
    return dest[0..len];
}

pub fn fill(comptime T: type, slice: []T, value: T) void {
    for (slice) |*item| {
        item.* = value;
    }
}

pub fn fillN(comptime T: type, slice: []T, n: usize, value: T) []T {
    const len = @min(slice.len, n);
    for (slice[0..len]) |*item| {
        item.* = value;
    }
    return slice[0..len];
}

pub fn generate(comptime T: type, slice: []T, generator: fn () T) void {
    for (slice) |*item| {
        item.* = generator();
    }
}

pub fn generateN(comptime T: type, slice: []T, n: usize, generator: fn () T) []T {
    const len = @min(slice.len, n);
    for (slice[0..len]) |*item| {
        item.* = generator();
    }
    return slice[0..len];
}

pub fn transform(comptime T: type, comptime R: type, source: []const T, dest: []R, op: fn (T) R) []R {
    const len = @min(source.len, dest.len);
    for (0..len) |i| {
        dest[i] = op(source[i]);
    }
    return dest[0..len];
}

pub fn transformBinary(comptime T: type, comptime U: type, comptime R: type, a: []const T, b: []const U, dest: []R, op: fn (T, U) R) []R {
    const len = @min(@min(a.len, b.len), dest.len);
    for (0..len) |i| {
        dest[i] = op(a[i], b[i]);
    }
    return dest[0..len];
}

pub fn replace(comptime T: type, slice: []T, old_value: T, new_value: T) void {
    for (slice) |*item| {
        if (item.* == old_value) {
            item.* = new_value;
        }
    }
}

pub fn replaceIf(comptime T: type, slice: []T, predicate: fn (T) bool, new_value: T) void {
    for (slice) |*item| {
        if (predicate(item.*)) {
            item.* = new_value;
        }
    }
}

pub fn replaceCopy(comptime T: type, source: []const T, dest: []T, old_value: T, new_value: T) []T {
    const len = @min(source.len, dest.len);
    for (0..len) |i| {
        dest[i] = if (source[i] == old_value) new_value else source[i];
    }
    return dest[0..len];
}

pub fn replaceCopyIf(comptime T: type, source: []const T, dest: []T, predicate: fn (T) bool, new_value: T) []T {
    const len = @min(source.len, dest.len);
    for (0..len) |i| {
        dest[i] = if (predicate(source[i])) new_value else source[i];
    }
    return dest[0..len];
}

pub fn reverse(comptime T: type, slice: []T) void {
    if (slice.len <= 1) return;
    var left: usize = 0;
    var right: usize = slice.len - 1;
    while (left < right) {
        const temp = slice[left];
        slice[left] = slice[right];
        slice[right] = temp;
        left += 1;
        right -= 1;
    }
}

pub fn reverseCopy(comptime T: type, source: []const T, dest: []T) []T {
    const len = @min(source.len, dest.len);
    for (0..len) |i| {
        dest[i] = source[source.len - 1 - i];
    }
    return dest[0..len];
}

pub fn rotate(comptime T: type, slice: []T, middle: usize) void {
    if (slice.len == 0 or middle == 0 or middle >= slice.len) return;
    reverse(T, slice[0..middle]);
    reverse(T, slice[middle..]);
    reverse(T, slice);
}

pub fn rotateCopy(comptime T: type, source: []const T, middle: usize, dest: []T) []T {
    if (source.len == 0 or dest.len == 0) return dest[0..0];
    const m = @min(middle, source.len);
    const first_part = source[m..];
    const second_part = source[0..m];
    const first_len = @min(first_part.len, dest.len);
    @memcpy(dest[0..first_len], first_part[0..first_len]);
    if (first_len >= dest.len) return dest[0..dest.len];
    const second_len = @min(second_part.len, dest.len - first_len);
    @memcpy(dest[first_len..][0..second_len], second_part[0..second_len]);
    return dest[0 .. first_len + second_len];
}

pub fn shuffle(comptime T: type, slice: []T, rng: std.Random) void {
    if (slice.len <= 1) return;
    var i: usize = slice.len - 1;
    while (i > 0) : (i -= 1) {
        const j = rng.intRangeAtMost(usize, 0, i);
        const temp = slice[i];
        slice[i] = slice[j];
        slice[j] = temp;
    }
}

pub fn unique(comptime T: type, slice: []T) []T {
    if (slice.len <= 1) return slice;
    var write_idx: usize = 1;
    for (1..slice.len) |read_idx| {
        if (slice[read_idx] != slice[write_idx - 1]) {
            slice[write_idx] = slice[read_idx];
            write_idx += 1;
        }
    }
    return slice[0..write_idx];
}

pub fn uniqueBy(comptime T: type, slice: []T, eq: fn (T, T) bool) []T {
    if (slice.len <= 1) return slice;
    var write_idx: usize = 1;
    for (1..slice.len) |read_idx| {
        if (!eq(slice[read_idx], slice[write_idx - 1])) {
            slice[write_idx] = slice[read_idx];
            write_idx += 1;
        }
    }
    return slice[0..write_idx];
}

pub fn uniqueCopy(comptime T: type, source: []const T, dest: []T) []T {
    if (source.len == 0) return dest[0..0];
    dest[0] = source[0];
    var write_idx: usize = 1;
    for (1..source.len) |read_idx| {
        if (write_idx >= dest.len) break;
        if (source[read_idx] != source[read_idx - 1]) {
            dest[write_idx] = source[read_idx];
            write_idx += 1;
        }
    }
    return dest[0..write_idx];
}

pub fn remove(comptime T: type, slice: []T, value: T) []T {
    var write_idx: usize = 0;
    for (slice) |item| {
        if (item != value) {
            slice[write_idx] = item;
            write_idx += 1;
        }
    }
    return slice[0..write_idx];
}

pub fn removeIf(comptime T: type, slice: []T, predicate: fn (T) bool) []T {
    var write_idx: usize = 0;
    for (slice) |item| {
        if (!predicate(item)) {
            slice[write_idx] = item;
            write_idx += 1;
        }
    }
    return slice[0..write_idx];
}

pub fn removeCopy(comptime T: type, source: []const T, dest: []T, value: T) []T {
    var write_idx: usize = 0;
    for (source) |item| {
        if (write_idx >= dest.len) break;
        if (item != value) {
            dest[write_idx] = item;
            write_idx += 1;
        }
    }
    return dest[0..write_idx];
}

pub fn removeCopyIf(comptime T: type, source: []const T, dest: []T, predicate: fn (T) bool) []T {
    var write_idx: usize = 0;
    for (source) |item| {
        if (write_idx >= dest.len) break;
        if (!predicate(item)) {
            dest[write_idx] = item;
            write_idx += 1;
        }
    }
    return dest[0..write_idx];
}

pub fn swapRanges(comptime T: type, a: []T, b: []T) void {
    const len = @min(a.len, b.len);
    for (0..len) |i| {
        const temp = a[i];
        a[i] = b[i];
        b[i] = temp;
    }
}

pub fn shiftLeft(comptime T: type, slice: []T, n: usize) []T {
    if (n == 0) return slice;
    if (n >= slice.len) return slice[0..0];
    const remaining = slice.len - n;
    for (0..remaining) |i| {
        slice[i] = slice[i + n];
    }
    return slice[0..remaining];
}

pub fn shiftRight(comptime T: type, slice: []T, n: usize) []T {
    if (n == 0) return slice;
    if (n >= slice.len) return slice[0..0];
    var i: usize = slice.len;
    while (i > n) {
        i -= 1;
        slice[i] = slice[i - n];
    }
    return slice[n..];
}

pub fn sample(comptime T: type, source: []const T, dest: []T, rng: std.Random) []T {
    if (source.len == 0 or dest.len == 0) return dest[0..0];
    const count = @min(source.len, dest.len);

    for (0..count) |i| {
        dest[i] = source[i];
    }

    for (count..source.len) |i| {
        const j = rng.intRangeAtMost(usize, 0, i);
        if (j < count) {
            dest[j] = source[i];
        }
    }

    return dest[0..count];
}

test "copy" {
    const source = [_]i32{ 1, 2, 3, 4, 5 };
    var dest: [5]i32 = undefined;
    const result = copy(i32, &source, &dest);
    try std.testing.expectEqualSlices(i32, &source, result);
}

test "copyIf" {
    const source = [_]i32{ 1, 2, 3, 4, 5 };
    var dest: [5]i32 = undefined;
    const isEven = struct {
        fn f(x: i32) bool {
            return @mod(x, 2) == 0;
        }
    }.f;
    const result = copyIf(i32, &source, &dest, isEven);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 2, 4 }, result);
}

test "fill" {
    var arr: [5]i32 = undefined;
    fill(i32, &arr, 42);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 42, 42, 42, 42, 42 }, &arr);
}

test "generate" {
    var counter: i32 = 0;
    const gen = struct {
        var c: *i32 = undefined;
        fn init(ptr: *i32) void {
            c = ptr;
        }
        fn f() i32 {
            c.* += 1;
            return c.*;
        }
    };
    gen.init(&counter);
    var arr: [3]i32 = undefined;
    generate(i32, &arr, gen.f);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 1, 2, 3 }, &arr);
}

test "transform" {
    const source = [_]i32{ 1, 2, 3, 4 };
    var dest: [4]i32 = undefined;
    const double = struct {
        fn f(x: i32) i32 {
            return x * 2;
        }
    }.f;
    const result = transform(i32, i32, &source, &dest, double);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 2, 4, 6, 8 }, result);
}

test "replace" {
    var arr = [_]i32{ 1, 2, 3, 2, 5 };
    replace(i32, &arr, 2, 10);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 1, 10, 3, 10, 5 }, &arr);
}

test "reverse" {
    var arr = [_]i32{ 1, 2, 3, 4, 5 };
    reverse(i32, &arr);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 5, 4, 3, 2, 1 }, &arr);
}

test "rotate" {
    var arr = [_]i32{ 1, 2, 3, 4, 5 };
    rotate(i32, &arr, 2);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 3, 4, 5, 1, 2 }, &arr);
}

test "unique" {
    var arr = [_]i32{ 1, 1, 2, 2, 2, 3, 3, 4, 5, 5 };
    const result = unique(i32, &arr);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 1, 2, 3, 4, 5 }, result);
}

test "remove" {
    var arr = [_]i32{ 1, 2, 3, 2, 5 };
    const result = remove(i32, &arr, 2);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 1, 3, 5 }, result);
}

test "swapRanges" {
    var a = [_]i32{ 1, 2, 3 };
    var b = [_]i32{ 4, 5, 6 };
    swapRanges(i32, &a, &b);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 4, 5, 6 }, &a);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 1, 2, 3 }, &b);
}

test "rotateCopy" {
    const source = [_]i32{ 1, 2, 3, 4, 5 };
    var dest: [5]i32 = undefined;
    const result = rotateCopy(i32, &source, 2, &dest);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 3, 4, 5, 1, 2 }, result);
}

test "reverseCopy" {
    const source = [_]i32{ 1, 2, 3, 4, 5 };
    var dest: [5]i32 = undefined;
    const result = reverseCopy(i32, &source, &dest);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 5, 4, 3, 2, 1 }, result);
}
