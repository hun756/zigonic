const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn map(
    comptime T: type,
    comptime U: type,
    allocator: Allocator,
    slice: []const T,
    transform: *const fn (T) U,
) ![]U {
    const result = try allocator.alloc(U, slice.len);
    for (slice, 0..) |item, i| {
        result[i] = transform(item);
    }
    return result;
}

pub fn mapInPlace(
    comptime T: type,
    slice: []T,
    transform: *const fn (T) T,
) void {
    for (slice) |*item| {
        item.* = transform(item.*);
    }
}

pub fn filter(
    comptime T: type,
    allocator: Allocator,
    slice: []const T,
    predicate: *const fn (T) bool,
) ![]T {
    var list = std.ArrayListUnmanaged(T){};
    errdefer list.deinit(allocator);

    for (slice) |item| {
        if (predicate(item)) {
            try list.append(allocator, item);
        }
    }

    return list.toOwnedSlice(allocator);
}

pub fn filterMap(
    comptime T: type,
    comptime U: type,
    allocator: Allocator,
    slice: []const T,
    transform: *const fn (T) ?U,
) ![]U {
    var list = std.ArrayListUnmanaged(U){};
    errdefer list.deinit(allocator);

    for (slice) |item| {
        if (transform(item)) |value| {
            try list.append(allocator, value);
        }
    }

    return list.toOwnedSlice(allocator);
}

pub fn flatMap(
    comptime T: type,
    comptime U: type,
    allocator: Allocator,
    slice: []const T,
    transform: *const fn (Allocator, T) anyerror![]U,
) ![]U {
    var list = std.ArrayListUnmanaged(U){};
    errdefer list.deinit(allocator);

    for (slice) |item| {
        const inner = try transform(allocator, item);
        defer allocator.free(inner);
        try list.appendSlice(allocator, inner);
    }

    return list.toOwnedSlice(allocator);
}

test "map" {
    const allocator = std.testing.allocator;
    const data = [_]i32{ 1, 2, 3, 4, 5 };
    const double = struct {
        fn f(x: i32) i32 {
            return x * 2;
        }
    }.f;

    const result = try map(i32, i32, allocator, &data, double);
    defer allocator.free(result);

    try std.testing.expectEqualSlices(i32, &[_]i32{ 2, 4, 6, 8, 10 }, result);
}

test "filter" {
    const allocator = std.testing.allocator;
    const data = [_]i32{ 1, 2, 3, 4, 5, 6 };
    const isEven = struct {
        fn f(x: i32) bool {
            return @rem(x, 2) == 0;
        }
    }.f;

    const result = try filter(i32, allocator, &data, isEven);
    defer allocator.free(result);

    try std.testing.expectEqualSlices(i32, &[_]i32{ 2, 4, 6 }, result);
}

test "mapInPlace" {
    var data = [_]i32{ 1, 2, 3, 4, 5 };
    const double = struct {
        fn f(x: i32) i32 {
            return x * 2;
        }
    }.f;

    mapInPlace(i32, &data, double);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 2, 4, 6, 8, 10 }, &data);
}
