const std = @import("std");

pub fn simdFill(comptime T: type, dest: []T, value: T) void {
    const VectorSize = 256 / @bitSizeOf(T);

    if (@typeInfo(T) == .int or @typeInfo(T) == .float) {
        if (comptime VectorSize > 1 and @sizeOf(T) * VectorSize <= 32) {
            const Vec = @Vector(VectorSize, T);
            const vec_value: Vec = @splat(value);

            var i: usize = 0;
            const vec_count = dest.len / VectorSize;

            while (i < vec_count) : (i += 1) {
                const ptr: *Vec = @ptrCast(@alignCast(dest.ptr + i * VectorSize));
                ptr.* = vec_value;
            }

            const remainder_start = vec_count * VectorSize;
            for (dest[remainder_start..]) |*item| {
                item.* = value;
            }
            return;
        }
    }

    @memset(dest, value);
}

pub fn simdSum(comptime T: type, data: []const T) T {
    const VectorSize = 256 / @bitSizeOf(T);

    if (@typeInfo(T) == .int or @typeInfo(T) == .float) {
        if (comptime VectorSize > 1 and @sizeOf(T) * VectorSize <= 32) {
            const Vec = @Vector(VectorSize, T);
            var vec_sum: Vec = @splat(@as(T, 0));

            var i: usize = 0;
            const vec_count = data.len / VectorSize;

            while (i < vec_count) : (i += 1) {
                const ptr: *const Vec = @ptrCast(@alignCast(data.ptr + i * VectorSize));
                vec_sum += ptr.*;
            }

            var sum = @reduce(.Add, vec_sum);

            const remainder_start = vec_count * VectorSize;
            for (data[remainder_start..]) |item| {
                sum += item;
            }

            return sum;
        }
    }

    var sum: T = 0;
    for (data) |item| {
        sum += item;
    }
    return sum;
}

pub fn simdDotProduct(comptime T: type, a: []const T, b: []const T) T {
    const len = @min(a.len, b.len);
    const VectorSize = 256 / @bitSizeOf(T);

    if (@typeInfo(T) == .int or @typeInfo(T) == .float) {
        if (comptime VectorSize > 1 and @sizeOf(T) * VectorSize <= 32) {
            const Vec = @Vector(VectorSize, T);
            var vec_sum: Vec = @splat(@as(T, 0));

            var i: usize = 0;
            const vec_count = len / VectorSize;

            while (i < vec_count) : (i += 1) {
                const ptr_a: *const Vec = @ptrCast(@alignCast(a.ptr + i * VectorSize));
                const ptr_b: *const Vec = @ptrCast(@alignCast(b.ptr + i * VectorSize));
                vec_sum += ptr_a.* * ptr_b.*;
            }

            var result = @reduce(.Add, vec_sum);

            const remainder_start = vec_count * VectorSize;
            for (remainder_start..len) |idx| {
                result += a[idx] * b[idx];
            }

            return result;
        }
    }

    var result: T = 0;
    for (0..len) |i| {
        result += a[i] * b[i];
    }
    return result;
}

pub fn simdMin(comptime T: type, data: []const T) ?T {
    if (data.len == 0) return null;

    const VectorSize = 256 / @bitSizeOf(T);

    if (@typeInfo(T) == .int or @typeInfo(T) == .float) {
        if (comptime VectorSize > 1 and @sizeOf(T) * VectorSize <= 32) {
            const Vec = @Vector(VectorSize, T);
            var vec_min: Vec = @splat(data[0]);

            var i: usize = 0;
            const vec_count = data.len / VectorSize;

            while (i < vec_count) : (i += 1) {
                const ptr: *const Vec = @ptrCast(@alignCast(data.ptr + i * VectorSize));
                vec_min = @min(vec_min, ptr.*);
            }

            var result = @reduce(.Min, vec_min);

            const remainder_start = vec_count * VectorSize;
            for (data[remainder_start..]) |item| {
                result = @min(result, item);
            }

            return result;
        }
    }

    var min_val = data[0];
    for (data[1..]) |item| {
        if (item < min_val) min_val = item;
    }
    return min_val;
}

pub fn simdMax(comptime T: type, data: []const T) ?T {
    if (data.len == 0) return null;

    const VectorSize = 256 / @bitSizeOf(T);

    if (@typeInfo(T) == .int or @typeInfo(T) == .float) {
        if (comptime VectorSize > 1 and @sizeOf(T) * VectorSize <= 32) {
            const Vec = @Vector(VectorSize, T);
            var vec_max: Vec = @splat(data[0]);

            var i: usize = 0;
            const vec_count = data.len / VectorSize;

            while (i < vec_count) : (i += 1) {
                const ptr: *const Vec = @ptrCast(@alignCast(data.ptr + i * VectorSize));
                vec_max = @max(vec_max, ptr.*);
            }

            var result = @reduce(.Max, vec_max);

            const remainder_start = vec_count * VectorSize;
            for (data[remainder_start..]) |item| {
                result = @max(result, item);
            }

            return result;
        }
    }

    var max_val = data[0];
    for (data[1..]) |item| {
        if (item > max_val) max_val = item;
    }
    return max_val;
}

pub fn simdEqual(comptime T: type, a: []const T, b: []const T) bool {
    if (a.len != b.len) return false;

    const VectorSize = 256 / @bitSizeOf(T);

    if (@typeInfo(T) == .int) {
        if (comptime VectorSize > 1 and @sizeOf(T) * VectorSize <= 32) {
            const Vec = @Vector(VectorSize, T);

            var i: usize = 0;
            const vec_count = a.len / VectorSize;

            while (i < vec_count) : (i += 1) {
                const ptr_a: *const Vec = @ptrCast(@alignCast(a.ptr + i * VectorSize));
                const ptr_b: *const Vec = @ptrCast(@alignCast(b.ptr + i * VectorSize));
                if (!@reduce(.And, ptr_a.* == ptr_b.*)) return false;
            }

            const remainder_start = vec_count * VectorSize;
            for (remainder_start..a.len) |idx| {
                if (a[idx] != b[idx]) return false;
            }

            return true;
        }
    }

    return std.mem.eql(T, a, b);
}

pub fn simdContains(data: []const u8, needle: u8) bool {
    const VectorSize = 32;
    const Vec = @Vector(VectorSize, u8);
    const needle_vec: Vec = @splat(needle);

    var i: usize = 0;
    const vec_count = data.len / VectorSize;

    while (i < vec_count) : (i += 1) {
        const ptr: *const Vec = @ptrCast(@alignCast(data.ptr + i * VectorSize));
        if (@reduce(.Or, ptr.* == needle_vec)) return true;
    }

    const remainder_start = vec_count * VectorSize;
    for (data[remainder_start..]) |byte| {
        if (byte == needle) return true;
    }

    return false;
}

pub fn simdAdd(comptime T: type, dest: []T, a: []const T, b: []const T) void {
    const len = @min(@min(dest.len, a.len), b.len);
    const VectorSize = 256 / @bitSizeOf(T);

    if (@typeInfo(T) == .int or @typeInfo(T) == .float) {
        if (comptime VectorSize > 1 and @sizeOf(T) * VectorSize <= 32) {
            const Vec = @Vector(VectorSize, T);

            var i: usize = 0;
            const vec_count = len / VectorSize;

            while (i < vec_count) : (i += 1) {
                const ptr_a: *const Vec = @ptrCast(@alignCast(a.ptr + i * VectorSize));
                const ptr_b: *const Vec = @ptrCast(@alignCast(b.ptr + i * VectorSize));
                const ptr_dest: *Vec = @ptrCast(@alignCast(dest.ptr + i * VectorSize));
                ptr_dest.* = ptr_a.* + ptr_b.*;
            }

            const remainder_start = vec_count * VectorSize;
            for (remainder_start..len) |idx| {
                dest[idx] = a[idx] + b[idx];
            }
            return;
        }
    }

    for (0..len) |i| {
        dest[i] = a[i] + b[i];
    }
}

pub fn simdMul(comptime T: type, dest: []T, a: []const T, b: []const T) void {
    const len = @min(@min(dest.len, a.len), b.len);
    const VectorSize = 256 / @bitSizeOf(T);

    if (@typeInfo(T) == .int or @typeInfo(T) == .float) {
        if (comptime VectorSize > 1 and @sizeOf(T) * VectorSize <= 32) {
            const Vec = @Vector(VectorSize, T);

            var i: usize = 0;
            const vec_count = len / VectorSize;

            while (i < vec_count) : (i += 1) {
                const ptr_a: *const Vec = @ptrCast(@alignCast(a.ptr + i * VectorSize));
                const ptr_b: *const Vec = @ptrCast(@alignCast(b.ptr + i * VectorSize));
                const ptr_dest: *Vec = @ptrCast(@alignCast(dest.ptr + i * VectorSize));
                ptr_dest.* = ptr_a.* * ptr_b.*;
            }

            const remainder_start = vec_count * VectorSize;
            for (remainder_start..len) |idx| {
                dest[idx] = a[idx] * b[idx];
            }
            return;
        }
    }

    for (0..len) |i| {
        dest[i] = a[i] * b[i];
    }
}

pub fn blockTranspose(
    comptime T: type,
    dest: []T,
    src: []const T,
    rows: usize,
    cols: usize,
    block_size: usize,
) void {
    var i: usize = 0;
    while (i < rows) : (i += block_size) {
        var j: usize = 0;
        while (j < cols) : (j += block_size) {
            const i_end = @min(i + block_size, rows);
            const j_end = @min(j + block_size, cols);

            var ii = i;
            while (ii < i_end) : (ii += 1) {
                var jj = j;
                while (jj < j_end) : (jj += 1) {
                    dest[jj * rows + ii] = src[ii * cols + jj];
                }
            }
        }
    }
}

test "simdSum" {
    var data align(32) = [_]i32{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    const sum = simdSum(i32, &data);
    try std.testing.expectEqual(@as(i32, 55), sum);
}

test "simdMin and simdMax" {
    var data align(32) = [_]i32{ 5, 2, 8, 1, 9, 3, 7, 4, 6, 10 };
    try std.testing.expectEqual(@as(?i32, 1), simdMin(i32, &data));
    try std.testing.expectEqual(@as(?i32, 10), simdMax(i32, &data));
}

test "simdDotProduct" {
    var a align(32) = [_]f32{ 1.0, 2.0, 3.0, 4.0 };
    var b align(32) = [_]f32{ 5.0, 6.0, 7.0, 8.0 };
    const result = simdDotProduct(f32, &a, &b);
    try std.testing.expectEqual(@as(f32, 70.0), result);
}

test "simdEqual" {
    var a align(32) = [_]i32{ 1, 2, 3, 4, 5 };
    var b align(32) = [_]i32{ 1, 2, 3, 4, 5 };
    var c align(32) = [_]i32{ 1, 2, 3, 4, 6 };

    try std.testing.expect(simdEqual(i32, &a, &b));
    try std.testing.expect(!simdEqual(i32, &a, &c));
}

test "simdContains" {
    const data = "Hello, World!";
    try std.testing.expect(simdContains(data, 'W'));
    try std.testing.expect(!simdContains(data, 'z'));
}

test "simdAdd" {
    var dest align(32) = [_]i32{0} ** 5;
    var a align(32) = [_]i32{ 1, 2, 3, 4, 5 };
    var b align(32) = [_]i32{ 10, 20, 30, 40, 50 };

    simdAdd(i32, &dest, &a, &b);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 11, 22, 33, 44, 55 }, &dest);
}
