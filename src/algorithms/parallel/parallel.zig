const std = @import("std");

pub const ParallelConfig = struct {
    min_parallel_size: usize = 10000,
    max_threads: ?usize = null,

    pub fn getThreadCount(self: ParallelConfig) usize {
        return self.max_threads orelse (std.Thread.getCpuCount() catch 4);
    }
};

pub const default_config = ParallelConfig{};

pub fn parallelFor(
    comptime T: type,
    slice: []T,
    config: ParallelConfig,
    comptime func: fn (*T) void,
) void {
    if (slice.len < config.min_parallel_size) {
        for (slice) |*item| {
            func(item);
        }
        return;
    }

    const thread_count = config.getThreadCount();
    const chunk_size = (slice.len + thread_count - 1) / thread_count;

    var threads: [64]std.Thread = undefined;
    var active_threads: usize = 0;

    var i: usize = 0;
    while (i < slice.len) : (i += chunk_size) {
        const end = @min(i + chunk_size, slice.len);
        const chunk = slice[i..end];

        threads[active_threads] = std.Thread.spawn(.{}, struct {
            fn work(c: []T) void {
                for (c) |*item| {
                    func(item);
                }
            }
        }.work, .{chunk}) catch {
            for (chunk) |*item| {
                func(item);
            }
            continue;
        };
        active_threads += 1;
    }

    for (threads[0..active_threads]) |t| {
        t.join();
    }
}

pub fn parallelForEach(
    comptime T: type,
    slice: []T,
    context: anytype,
    config: ParallelConfig,
    comptime func: fn (@TypeOf(context), *T) void,
) void {
    if (slice.len < config.min_parallel_size) {
        for (slice) |*item| {
            func(context, item);
        }
        return;
    }

    const thread_count = config.getThreadCount();
    const chunk_size = (slice.len + thread_count - 1) / thread_count;

    var threads: [64]std.Thread = undefined;
    var active_threads: usize = 0;

    const Context = @TypeOf(context);
    const Chunk = struct { data: []T, ctx: Context };

    var i: usize = 0;
    while (i < slice.len) : (i += chunk_size) {
        const end = @min(i + chunk_size, slice.len);

        threads[active_threads] = std.Thread.spawn(.{}, struct {
            fn work(chunk: Chunk) void {
                for (chunk.data) |*item| {
                    func(chunk.ctx, item);
                }
            }
        }.work, .{Chunk{ .data = slice[i..end], .ctx = context }}) catch {
            for (slice[i..end]) |*item| {
                func(context, item);
            }
            continue;
        };
        active_threads += 1;
    }

    for (threads[0..active_threads]) |t| {
        t.join();
    }
}

pub fn parallelReduce(
    comptime T: type,
    comptime R: type,
    slice: []const T,
    init: R,
    config: ParallelConfig,
    comptime reduce_fn: fn (R, T) R,
    comptime combine_fn: fn (R, R) R,
) R {
    if (slice.len < config.min_parallel_size) {
        var result = init;
        for (slice) |item| {
            result = reduce_fn(result, item);
        }
        return result;
    }

    const thread_count = config.getThreadCount();
    const chunk_size = (slice.len + thread_count - 1) / thread_count;

    var threads: [64]std.Thread = undefined;
    var results: [64]R = undefined;
    var active_threads: usize = 0;

    var i: usize = 0;
    while (i < slice.len) : (i += chunk_size) {
        const end = @min(i + chunk_size, slice.len);
        const chunk = slice[i..end];
        const idx = active_threads;

        threads[active_threads] = std.Thread.spawn(.{}, struct {
            fn work(c: []const T, initial: R, out: *R) void {
                var res = initial;
                for (c) |item| {
                    res = reduce_fn(res, item);
                }
                out.* = res;
            }
        }.work, .{ chunk, init, &results[idx] }) catch {
            var res = init;
            for (chunk) |item| {
                res = reduce_fn(res, item);
            }
            results[idx] = res;
            active_threads += 1;
            continue;
        };
        active_threads += 1;
    }

    for (threads[0..active_threads]) |t| {
        t.join();
    }

    var final_result = results[0];
    for (results[1..active_threads]) |r| {
        final_result = combine_fn(final_result, r);
    }

    return final_result;
}

pub fn parallelTransform(
    comptime T: type,
    comptime R: type,
    source: []const T,
    dest: []R,
    config: ParallelConfig,
    comptime transform_fn: fn (T) R,
) []R {
    const len = @min(source.len, dest.len);
    if (len < config.min_parallel_size) {
        for (0..len) |i| {
            dest[i] = transform_fn(source[i]);
        }
        return dest[0..len];
    }

    const thread_count = config.getThreadCount();
    const chunk_size = (len + thread_count - 1) / thread_count;

    var threads: [64]std.Thread = undefined;
    var active_threads: usize = 0;

    var i: usize = 0;
    while (i < len) : (i += chunk_size) {
        const start = i;
        const end = @min(i + chunk_size, len);

        threads[active_threads] = std.Thread.spawn(.{}, struct {
            fn work(src: []const T, dst: []R, s: usize, e: usize) void {
                for (s..e) |j| {
                    dst[j] = transform_fn(src[j]);
                }
            }
        }.work, .{ source, dest, start, end }) catch {
            for (start..end) |j| {
                dest[j] = transform_fn(source[j]);
            }
            continue;
        };
        active_threads += 1;
    }

    for (threads[0..active_threads]) |t| {
        t.join();
    }

    return dest[0..len];
}

fn merge(comptime T: type, left: []const T, right: []const T, dest: []T, comptime lessThan: fn (T, T) bool) void {
    var i: usize = 0;
    var j: usize = 0;
    var k: usize = 0;

    while (i < left.len and j < right.len) {
        if (lessThan(left[i], right[j])) {
            dest[k] = left[i];
            i += 1;
        } else {
            dest[k] = right[j];
            j += 1;
        }
        k += 1;
    }

    while (i < left.len) {
        dest[k] = left[i];
        i += 1;
        k += 1;
    }

    while (j < right.len) {
        dest[k] = right[j];
        j += 1;
        k += 1;
    }
}

fn sequentialSort(comptime T: type, slice: []T, comptime lessThan: fn (T, T) bool) void {
    if (slice.len <= 1) return;
    if (slice.len <= 32) {
        for (1..slice.len) |i| {
            const key = slice[i];
            var j: usize = i;
            while (j > 0 and lessThan(key, slice[j - 1])) {
                slice[j] = slice[j - 1];
                j -= 1;
            }
            slice[j] = key;
        }
        return;
    }

    const mid = slice.len / 2;
    sequentialSort(T, slice[0..mid], lessThan);
    sequentialSort(T, slice[mid..], lessThan);

    var temp: [4096]T = undefined;
    if (slice.len <= temp.len) {
        @memcpy(temp[0..slice.len], slice);
        merge(T, temp[0..mid], temp[mid..slice.len], slice, lessThan);
    }
}

pub fn parallelSort(
    comptime T: type,
    slice: []T,
    allocator: std.mem.Allocator,
    config: ParallelConfig,
    comptime lessThan: fn (T, T) bool,
) !void {
    if (slice.len < config.min_parallel_size) {
        sequentialSort(T, slice, lessThan);
        return;
    }

    const thread_count = config.getThreadCount();
    const chunk_size = (slice.len + thread_count - 1) / thread_count;

    var threads: [64]std.Thread = undefined;
    var active_threads: usize = 0;

    var i: usize = 0;
    while (i < slice.len) : (i += chunk_size) {
        const end = @min(i + chunk_size, slice.len);
        const chunk = slice[i..end];

        threads[active_threads] = std.Thread.spawn(.{}, struct {
            fn work(c: []T) void {
                sequentialSort(T, c, lessThan);
            }
        }.work, .{chunk}) catch {
            sequentialSort(T, chunk, lessThan);
            active_threads += 1;
            continue;
        };
        active_threads += 1;
    }

    for (threads[0..active_threads]) |t| {
        t.join();
    }

    const temp = try allocator.alloc(T, slice.len);
    defer allocator.free(temp);

    var width: usize = chunk_size;
    while (width < slice.len) : (width *= 2) {
        var j: usize = 0;
        while (j < slice.len) : (j += width * 2) {
            const left_end = @min(j + width, slice.len);
            const right_end = @min(j + width * 2, slice.len);

            merge(T, slice[j..left_end], slice[left_end..right_end], temp[j..right_end], lessThan);
        }
        @memcpy(slice, temp[0..slice.len]);
    }
}

pub fn parallelSortDefault(comptime T: type, slice: []T, allocator: std.mem.Allocator) !void {
    try parallelSort(T, slice, allocator, default_config, struct {
        fn lt(a: T, b: T) bool {
            return a < b;
        }
    }.lt);
}

pub fn parallelFind(
    comptime T: type,
    slice: []const T,
    value: T,
    config: ParallelConfig,
) ?usize {
    if (slice.len < config.min_parallel_size) {
        for (slice, 0..) |item, i| {
            if (item == value) return i;
        }
        return null;
    }

    const thread_count = config.getThreadCount();
    const chunk_size = (slice.len + thread_count - 1) / thread_count;

    var threads: [64]std.Thread = undefined;
    var results: [64]?usize = [_]?usize{null} ** 64;
    var active_threads: usize = 0;

    var i: usize = 0;
    while (i < slice.len) : (i += chunk_size) {
        const start = i;
        const end = @min(i + chunk_size, slice.len);
        const chunk = slice[start..end];
        const idx = active_threads;

        threads[active_threads] = std.Thread.spawn(.{}, struct {
            fn work(c: []const T, val: T, base: usize, out: *?usize) void {
                for (c, 0..) |item, j| {
                    if (item == val) {
                        out.* = base + j;
                        return;
                    }
                }
            }
        }.work, .{ chunk, value, start, &results[idx] }) catch {
            for (chunk, 0..) |item, j| {
                if (item == value) {
                    results[idx] = start + j;
                    break;
                }
            }
            active_threads += 1;
            continue;
        };
        active_threads += 1;
    }

    for (threads[0..active_threads]) |t| {
        t.join();
    }

    var min_idx: ?usize = null;
    for (results[0..active_threads]) |r| {
        if (r) |idx| {
            if (min_idx == null or idx < min_idx.?) {
                min_idx = idx;
            }
        }
    }

    return min_idx;
}

pub fn parallelCount(
    comptime T: type,
    slice: []const T,
    value: T,
    config: ParallelConfig,
) usize {
    if (slice.len < config.min_parallel_size) {
        var cnt: usize = 0;
        for (slice) |item| {
            if (item == value) cnt += 1;
        }
        return cnt;
    }

    const thread_count = config.getThreadCount();
    const chunk_size = (slice.len + thread_count - 1) / thread_count;

    var threads: [64]std.Thread = undefined;
    var counts: [64]usize = [_]usize{0} ** 64;
    var active_threads: usize = 0;

    var i: usize = 0;
    while (i < slice.len) : (i += chunk_size) {
        const end = @min(i + chunk_size, slice.len);
        const chunk = slice[i..end];
        const idx = active_threads;

        threads[active_threads] = std.Thread.spawn(.{}, struct {
            fn work(c: []const T, val: T, out: *usize) void {
                var cnt: usize = 0;
                for (c) |item| {
                    if (item == val) cnt += 1;
                }
                out.* = cnt;
            }
        }.work, .{ chunk, value, &counts[idx] }) catch {
            var cnt: usize = 0;
            for (chunk) |item| {
                if (item == value) cnt += 1;
            }
            counts[idx] = cnt;
            active_threads += 1;
            continue;
        };
        active_threads += 1;
    }

    for (threads[0..active_threads]) |t| {
        t.join();
    }

    var total: usize = 0;
    for (counts[0..active_threads]) |c| {
        total += c;
    }

    return total;
}

pub fn parallelCountIf(
    comptime T: type,
    slice: []const T,
    config: ParallelConfig,
    comptime predicate: fn (T) bool,
) usize {
    if (slice.len < config.min_parallel_size) {
        var cnt: usize = 0;
        for (slice) |item| {
            if (predicate(item)) cnt += 1;
        }
        return cnt;
    }

    const thread_count = config.getThreadCount();
    const chunk_size = (slice.len + thread_count - 1) / thread_count;

    var threads: [64]std.Thread = undefined;
    var counts: [64]usize = [_]usize{0} ** 64;
    var active_threads: usize = 0;

    var i: usize = 0;
    while (i < slice.len) : (i += chunk_size) {
        const end = @min(i + chunk_size, slice.len);
        const chunk = slice[i..end];
        const idx = active_threads;

        threads[active_threads] = std.Thread.spawn(.{}, struct {
            fn work(c: []const T, out: *usize) void {
                var cnt: usize = 0;
                for (c) |item| {
                    if (predicate(item)) cnt += 1;
                }
                out.* = cnt;
            }
        }.work, .{ chunk, &counts[idx] }) catch {
            var cnt: usize = 0;
            for (chunk) |item| {
                if (predicate(item)) cnt += 1;
            }
            counts[idx] = cnt;
            active_threads += 1;
            continue;
        };
        active_threads += 1;
    }

    for (threads[0..active_threads]) |t| {
        t.join();
    }

    var total: usize = 0;
    for (counts[0..active_threads]) |c| {
        total += c;
    }

    return total;
}

pub fn parallelAllOf(
    comptime T: type,
    slice: []const T,
    config: ParallelConfig,
    comptime predicate: fn (T) bool,
) bool {
    if (slice.len < config.min_parallel_size) {
        for (slice) |item| {
            if (!predicate(item)) return false;
        }
        return true;
    }

    const thread_count = config.getThreadCount();
    const chunk_size = (slice.len + thread_count - 1) / thread_count;

    var threads: [64]std.Thread = undefined;
    var results: [64]bool = [_]bool{true} ** 64;
    var active_threads: usize = 0;

    var i: usize = 0;
    while (i < slice.len) : (i += chunk_size) {
        const end = @min(i + chunk_size, slice.len);
        const chunk = slice[i..end];
        const idx = active_threads;

        threads[active_threads] = std.Thread.spawn(.{}, struct {
            fn work(c: []const T, out: *bool) void {
                for (c) |item| {
                    if (!predicate(item)) {
                        out.* = false;
                        return;
                    }
                }
            }
        }.work, .{ chunk, &results[idx] }) catch {
            for (chunk) |item| {
                if (!predicate(item)) {
                    results[idx] = false;
                    break;
                }
            }
            active_threads += 1;
            continue;
        };
        active_threads += 1;
    }

    for (threads[0..active_threads]) |t| {
        t.join();
    }

    for (results[0..active_threads]) |r| {
        if (!r) return false;
    }

    return true;
}

pub fn parallelAnyOf(
    comptime T: type,
    slice: []const T,
    config: ParallelConfig,
    comptime predicate: fn (T) bool,
) bool {
    if (slice.len < config.min_parallel_size) {
        for (slice) |item| {
            if (predicate(item)) return true;
        }
        return false;
    }

    const thread_count = config.getThreadCount();
    const chunk_size = (slice.len + thread_count - 1) / thread_count;

    var threads: [64]std.Thread = undefined;
    var results: [64]bool = [_]bool{false} ** 64;
    var active_threads: usize = 0;

    var i: usize = 0;
    while (i < slice.len) : (i += chunk_size) {
        const end = @min(i + chunk_size, slice.len);
        const chunk = slice[i..end];
        const idx = active_threads;

        threads[active_threads] = std.Thread.spawn(.{}, struct {
            fn work(c: []const T, out: *bool) void {
                for (c) |item| {
                    if (predicate(item)) {
                        out.* = true;
                        return;
                    }
                }
            }
        }.work, .{ chunk, &results[idx] }) catch {
            for (chunk) |item| {
                if (predicate(item)) {
                    results[idx] = true;
                    break;
                }
            }
            active_threads += 1;
            continue;
        };
        active_threads += 1;
    }

    for (threads[0..active_threads]) |t| {
        t.join();
    }

    for (results[0..active_threads]) |r| {
        if (r) return true;
    }

    return false;
}

pub fn parallelNoneOf(
    comptime T: type,
    slice: []const T,
    config: ParallelConfig,
    comptime predicate: fn (T) bool,
) bool {
    return !parallelAnyOf(T, slice, config, predicate);
}

pub fn parallelFill(
    comptime T: type,
    slice: []T,
    value: T,
    config: ParallelConfig,
) void {
    if (slice.len < config.min_parallel_size) {
        for (slice) |*item| {
            item.* = value;
        }
        return;
    }

    const thread_count = config.getThreadCount();
    const chunk_size = (slice.len + thread_count - 1) / thread_count;

    var threads: [64]std.Thread = undefined;
    var active_threads: usize = 0;

    var i: usize = 0;
    while (i < slice.len) : (i += chunk_size) {
        const end = @min(i + chunk_size, slice.len);
        const chunk = slice[i..end];

        threads[active_threads] = std.Thread.spawn(.{}, struct {
            fn work(c: []T, val: T) void {
                for (c) |*item| {
                    item.* = val;
                }
            }
        }.work, .{ chunk, value }) catch {
            for (chunk) |*item| {
                item.* = value;
            }
            continue;
        };
        active_threads += 1;
    }

    for (threads[0..active_threads]) |t| {
        t.join();
    }
}

pub fn parallelCopy(
    comptime T: type,
    source: []const T,
    dest: []T,
    config: ParallelConfig,
) []T {
    const len = @min(source.len, dest.len);
    if (len < config.min_parallel_size) {
        @memcpy(dest[0..len], source[0..len]);
        return dest[0..len];
    }

    const thread_count = config.getThreadCount();
    const chunk_size = (len + thread_count - 1) / thread_count;

    var threads: [64]std.Thread = undefined;
    var active_threads: usize = 0;

    var i: usize = 0;
    while (i < len) : (i += chunk_size) {
        const start = i;
        const end = @min(i + chunk_size, len);

        threads[active_threads] = std.Thread.spawn(.{}, struct {
            fn work(src: []const T, dst: []T, s: usize, e: usize) void {
                @memcpy(dst[s..e], src[s..e]);
            }
        }.work, .{ source, dest, start, end }) catch {
            @memcpy(dest[start..end], source[start..end]);
            continue;
        };
        active_threads += 1;
    }

    for (threads[0..active_threads]) |t| {
        t.join();
    }

    return dest[0..len];
}

test "parallelSort" {
    const allocator = std.testing.allocator;
    var arr = [_]i32{ 5, 2, 8, 1, 9, 3, 7, 4, 6, 0 };
    const config = ParallelConfig{ .min_parallel_size = 2 };

    try parallelSort(i32, &arr, allocator, config, struct {
        fn lt(a: i32, b: i32) bool {
            return a < b;
        }
    }.lt);

    try std.testing.expectEqualSlices(i32, &[_]i32{ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 }, &arr);
}

test "parallelFind" {
    const arr = [_]i32{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    const config = ParallelConfig{ .min_parallel_size = 2 };

    const result = parallelFind(i32, &arr, 7, config);
    try std.testing.expectEqual(@as(?usize, 6), result);
}

test "parallelCount" {
    const arr = [_]i32{ 1, 2, 2, 3, 2, 4, 2, 5 };
    const config = ParallelConfig{ .min_parallel_size = 2 };

    const result = parallelCount(i32, &arr, 2, config);
    try std.testing.expectEqual(@as(usize, 4), result);
}

test "parallelAllOf" {
    const arr = [_]i32{ 2, 4, 6, 8, 10 };
    const config = ParallelConfig{ .min_parallel_size = 2 };

    const isEven = struct {
        fn f(x: i32) bool {
            return @mod(x, 2) == 0;
        }
    }.f;

    try std.testing.expect(parallelAllOf(i32, &arr, config, isEven));
}

test "parallelFill" {
    var arr: [10]i32 = undefined;
    const config = ParallelConfig{ .min_parallel_size = 2 };

    parallelFill(i32, &arr, 42, config);

    for (arr) |item| {
        try std.testing.expectEqual(@as(i32, 42), item);
    }
}

test "parallelCopy" {
    const source = [_]i32{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    var dest: [10]i32 = undefined;
    const config = ParallelConfig{ .min_parallel_size = 2 };

    const result = parallelCopy(i32, &source, &dest, config);

    try std.testing.expectEqualSlices(i32, &source, result);
}

pub fn parallelMinElement(
    comptime T: type,
    slice: []const T,
    config: ParallelConfig,
    comptime lessThan: fn (T, T) bool,
) ?usize {
    if (slice.len == 0) return null;

    if (slice.len < config.min_parallel_size) {
        var min_idx: usize = 0;
        for (slice[1..], 1..) |item, i| {
            if (lessThan(item, slice[min_idx])) {
                min_idx = i;
            }
        }
        return min_idx;
    }

    const thread_count = config.getThreadCount();
    const chunk_size = (slice.len + thread_count - 1) / thread_count;

    var threads: [64]std.Thread = undefined;
    var results: [64]usize = undefined;
    var active_threads: usize = 0;

    var i: usize = 0;
    while (i < slice.len) : (i += chunk_size) {
        const start = i;
        const end = @min(i + chunk_size, slice.len);
        const chunk = slice[start..end];
        const idx = active_threads;

        threads[active_threads] = std.Thread.spawn(.{}, struct {
            fn work(c: []const T, base: usize, out: *usize) void {
                var min_idx: usize = 0;
                for (c[1..], 1..) |item, j| {
                    if (lessThan(item, c[min_idx])) {
                        min_idx = j;
                    }
                }
                out.* = base + min_idx;
            }
        }.work, .{ chunk, start, &results[idx] }) catch {
            var min_idx: usize = 0;
            for (chunk[1..], 1..) |item, j| {
                if (lessThan(item, chunk[min_idx])) {
                    min_idx = j;
                }
            }
            results[idx] = start + min_idx;
            active_threads += 1;
            continue;
        };
        active_threads += 1;
    }

    for (threads[0..active_threads]) |t| {
        t.join();
    }

    var global_min: usize = results[0];
    for (results[1..active_threads]) |r| {
        if (lessThan(slice[r], slice[global_min])) {
            global_min = r;
        }
    }

    return global_min;
}

pub fn parallelMaxElement(
    comptime T: type,
    slice: []const T,
    config: ParallelConfig,
    comptime greaterThan: fn (T, T) bool,
) ?usize {
    if (slice.len == 0) return null;

    if (slice.len < config.min_parallel_size) {
        var max_idx: usize = 0;
        for (slice[1..], 1..) |item, i| {
            if (greaterThan(item, slice[max_idx])) {
                max_idx = i;
            }
        }
        return max_idx;
    }

    const thread_count = config.getThreadCount();
    const chunk_size = (slice.len + thread_count - 1) / thread_count;

    var threads: [64]std.Thread = undefined;
    var results: [64]usize = undefined;
    var active_threads: usize = 0;

    var i: usize = 0;
    while (i < slice.len) : (i += chunk_size) {
        const start = i;
        const end = @min(i + chunk_size, slice.len);
        const chunk = slice[start..end];
        const idx = active_threads;

        threads[active_threads] = std.Thread.spawn(.{}, struct {
            fn work(c: []const T, base: usize, out: *usize) void {
                var max_idx: usize = 0;
                for (c[1..], 1..) |item, j| {
                    if (greaterThan(item, c[max_idx])) {
                        max_idx = j;
                    }
                }
                out.* = base + max_idx;
            }
        }.work, .{ chunk, start, &results[idx] }) catch {
            var max_idx: usize = 0;
            for (chunk[1..], 1..) |item, j| {
                if (greaterThan(item, chunk[max_idx])) {
                    max_idx = j;
                }
            }
            results[idx] = start + max_idx;
            active_threads += 1;
            continue;
        };
        active_threads += 1;
    }

    for (threads[0..active_threads]) |t| {
        t.join();
    }

    var global_max: usize = results[0];
    for (results[1..active_threads]) |r| {
        if (greaterThan(slice[r], slice[global_max])) {
            global_max = r;
        }
    }

    return global_max;
}

pub fn parallelReplace(
    comptime T: type,
    slice: []T,
    old_value: T,
    new_value: T,
    config: ParallelConfig,
) void {
    if (slice.len < config.min_parallel_size) {
        for (slice) |*item| {
            if (item.* == old_value) item.* = new_value;
        }
        return;
    }

    const thread_count = config.getThreadCount();
    const chunk_size = (slice.len + thread_count - 1) / thread_count;

    var threads: [64]std.Thread = undefined;
    var active_threads: usize = 0;

    var i: usize = 0;
    while (i < slice.len) : (i += chunk_size) {
        const end = @min(i + chunk_size, slice.len);
        const chunk = slice[i..end];

        threads[active_threads] = std.Thread.spawn(.{}, struct {
            fn work(c: []T, old: T, new: T) void {
                for (c) |*item| {
                    if (item.* == old) item.* = new;
                }
            }
        }.work, .{ chunk, old_value, new_value }) catch {
            for (chunk) |*item| {
                if (item.* == old_value) item.* = new_value;
            }
            continue;
        };
        active_threads += 1;
    }

    for (threads[0..active_threads]) |t| {
        t.join();
    }
}

pub fn parallelReplaceIf(
    comptime T: type,
    slice: []T,
    new_value: T,
    config: ParallelConfig,
    comptime predicate: fn (T) bool,
) void {
    if (slice.len < config.min_parallel_size) {
        for (slice) |*item| {
            if (predicate(item.*)) item.* = new_value;
        }
        return;
    }

    const thread_count = config.getThreadCount();
    const chunk_size = (slice.len + thread_count - 1) / thread_count;

    var threads: [64]std.Thread = undefined;
    var active_threads: usize = 0;

    var i: usize = 0;
    while (i < slice.len) : (i += chunk_size) {
        const end = @min(i + chunk_size, slice.len);
        const chunk = slice[i..end];

        threads[active_threads] = std.Thread.spawn(.{}, struct {
            fn work(c: []T, new: T) void {
                for (c) |*item| {
                    if (predicate(item.*)) item.* = new;
                }
            }
        }.work, .{ chunk, new_value }) catch {
            for (chunk) |*item| {
                if (predicate(item.*)) item.* = new_value;
            }
            continue;
        };
        active_threads += 1;
    }

    for (threads[0..active_threads]) |t| {
        t.join();
    }
}

pub fn parallelEqual(
    comptime T: type,
    slice1: []const T,
    slice2: []const T,
    config: ParallelConfig,
) bool {
    if (slice1.len != slice2.len) return false;
    if (slice1.len == 0) return true;

    if (slice1.len < config.min_parallel_size) {
        for (slice1, slice2) |a, b| {
            if (a != b) return false;
        }
        return true;
    }

    const thread_count = config.getThreadCount();
    const chunk_size = (slice1.len + thread_count - 1) / thread_count;

    var threads: [64]std.Thread = undefined;
    var results: [64]bool = [_]bool{true} ** 64;
    var active_threads: usize = 0;

    var i: usize = 0;
    while (i < slice1.len) : (i += chunk_size) {
        const start = i;
        const end = @min(i + chunk_size, slice1.len);
        const idx = active_threads;

        threads[active_threads] = std.Thread.spawn(.{}, struct {
            fn work(s1: []const T, s2: []const T, s: usize, e: usize, out: *bool) void {
                for (s..e) |j| {
                    if (s1[j] != s2[j]) {
                        out.* = false;
                        return;
                    }
                }
            }
        }.work, .{ slice1, slice2, start, end, &results[idx] }) catch {
            for (start..end) |j| {
                if (slice1[j] != slice2[j]) {
                    results[idx] = false;
                    break;
                }
            }
            active_threads += 1;
            continue;
        };
        active_threads += 1;
    }

    for (threads[0..active_threads]) |t| {
        t.join();
    }

    for (results[0..active_threads]) |r| {
        if (!r) return false;
    }

    return true;
}

pub fn parallelIota(
    comptime T: type,
    slice: []T,
    start_value: T,
    config: ParallelConfig,
) void {
    if (slice.len < config.min_parallel_size) {
        var val = start_value;
        for (slice) |*item| {
            item.* = val;
            val += 1;
        }
        return;
    }

    const thread_count = config.getThreadCount();
    const chunk_size = (slice.len + thread_count - 1) / thread_count;

    var threads: [64]std.Thread = undefined;
    var active_threads: usize = 0;

    var i: usize = 0;
    while (i < slice.len) : (i += chunk_size) {
        const start = i;
        const end = @min(i + chunk_size, slice.len);
        const chunk = slice[start..end];
        const base_val = start_value + @as(T, @intCast(start));

        threads[active_threads] = std.Thread.spawn(.{}, struct {
            fn work(c: []T, base: T) void {
                var val = base;
                for (c) |*item| {
                    item.* = val;
                    val += 1;
                }
            }
        }.work, .{ chunk, base_val }) catch {
            var val = base_val;
            for (chunk) |*item| {
                item.* = val;
                val += 1;
            }
            continue;
        };
        active_threads += 1;
    }

    for (threads[0..active_threads]) |t| {
        t.join();
    }
}

pub fn parallelAdjacentDifference(
    comptime T: type,
    source: []const T,
    dest: []T,
    config: ParallelConfig,
) []T {
    const len = @min(source.len, dest.len);
    if (len == 0) return dest[0..0];

    dest[0] = source[0];
    if (len == 1) return dest[0..1];

    if (len < config.min_parallel_size) {
        for (1..len) |i| {
            dest[i] = source[i] - source[i - 1];
        }
        return dest[0..len];
    }

    const thread_count = config.getThreadCount();
    const chunk_size = (len + thread_count - 1) / thread_count;

    var threads: [64]std.Thread = undefined;
    var active_threads: usize = 0;

    var i: usize = 1;
    while (i < len) : (i += chunk_size) {
        const start = i;
        const end = @min(i + chunk_size, len);

        threads[active_threads] = std.Thread.spawn(.{}, struct {
            fn work(src: []const T, dst: []T, s: usize, e: usize) void {
                for (s..e) |j| {
                    dst[j] = src[j] - src[j - 1];
                }
            }
        }.work, .{ source, dest, start, end }) catch {
            for (start..end) |j| {
                dest[j] = source[j] - source[j - 1];
            }
            continue;
        };
        active_threads += 1;
    }

    for (threads[0..active_threads]) |t| {
        t.join();
    }

    return dest[0..len];
}

pub fn parallelInnerProduct(
    comptime T: type,
    slice1: []const T,
    slice2: []const T,
    init: T,
    config: ParallelConfig,
) T {
    const len = @min(slice1.len, slice2.len);
    if (len == 0) return init;

    if (len < config.min_parallel_size) {
        var result = init;
        for (0..len) |i| {
            result += slice1[i] * slice2[i];
        }
        return result;
    }

    const thread_count = config.getThreadCount();
    const chunk_size = (len + thread_count - 1) / thread_count;

    var threads: [64]std.Thread = undefined;
    var results: [64]T = [_]T{0} ** 64;
    var active_threads: usize = 0;

    var i: usize = 0;
    while (i < len) : (i += chunk_size) {
        const start = i;
        const end = @min(i + chunk_size, len);
        const idx = active_threads;

        threads[active_threads] = std.Thread.spawn(.{}, struct {
            fn work(s1: []const T, s2: []const T, s: usize, e: usize, out: *T) void {
                var sum: T = 0;
                for (s..e) |j| {
                    sum += s1[j] * s2[j];
                }
                out.* = sum;
            }
        }.work, .{ slice1, slice2, start, end, &results[idx] }) catch {
            var sum: T = 0;
            for (start..end) |j| {
                sum += slice1[j] * slice2[j];
            }
            results[idx] = sum;
            active_threads += 1;
            continue;
        };
        active_threads += 1;
    }

    for (threads[0..active_threads]) |t| {
        t.join();
    }

    var total = init;
    for (results[0..active_threads]) |r| {
        total += r;
    }

    return total;
}

test "parallelMinElement" {
    const arr = [_]i32{ 5, 2, 8, 1, 9, 3, 7, 4, 6, 0 };
    const config = ParallelConfig{ .min_parallel_size = 2 };

    const result = parallelMinElement(i32, &arr, config, struct {
        fn lt(a: i32, b: i32) bool {
            return a < b;
        }
    }.lt);

    try std.testing.expectEqual(@as(?usize, 9), result);
}

test "parallelMaxElement" {
    const arr = [_]i32{ 5, 2, 8, 1, 9, 3, 7, 4, 6, 0 };
    const config = ParallelConfig{ .min_parallel_size = 2 };

    const result = parallelMaxElement(i32, &arr, config, struct {
        fn gt(a: i32, b: i32) bool {
            return a > b;
        }
    }.gt);

    try std.testing.expectEqual(@as(?usize, 4), result);
}

test "parallelReplace" {
    var arr = [_]i32{ 1, 2, 2, 3, 2, 4, 2, 5 };
    const config = ParallelConfig{ .min_parallel_size = 2 };

    parallelReplace(i32, &arr, 2, 99, config);

    try std.testing.expectEqualSlices(i32, &[_]i32{ 1, 99, 99, 3, 99, 4, 99, 5 }, &arr);
}

test "parallelEqual" {
    const arr1 = [_]i32{ 1, 2, 3, 4, 5 };
    const arr2 = [_]i32{ 1, 2, 3, 4, 5 };
    const arr3 = [_]i32{ 1, 2, 3, 4, 6 };
    const config = ParallelConfig{ .min_parallel_size = 2 };

    try std.testing.expect(parallelEqual(i32, &arr1, &arr2, config));
    try std.testing.expect(!parallelEqual(i32, &arr1, &arr3, config));
}

test "parallelIota" {
    var arr: [10]i32 = undefined;
    const config = ParallelConfig{ .min_parallel_size = 2 };

    parallelIota(i32, &arr, 5, config);

    try std.testing.expectEqualSlices(i32, &[_]i32{ 5, 6, 7, 8, 9, 10, 11, 12, 13, 14 }, &arr);
}

test "parallelInnerProduct" {
    const arr1 = [_]i32{ 1, 2, 3, 4, 5 };
    const arr2 = [_]i32{ 2, 3, 4, 5, 6 };
    const config = ParallelConfig{ .min_parallel_size = 2 };

    const result = parallelInnerProduct(i32, &arr1, &arr2, 0, config);

    try std.testing.expectEqual(@as(i32, 70), result);
}
