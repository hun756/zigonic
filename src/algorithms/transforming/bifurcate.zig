const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn BifurcateResult(comptime T: type) type {
    return struct {
        const Self = @This();

        matching: []T,
        non_matching: []T,
        allocator: Allocator,

        pub fn deinit(self: *Self) void {
            self.allocator.free(self.matching);
            self.allocator.free(self.non_matching);
            self.* = undefined;
        }
    };
}

pub fn bifurcate(
    comptime T: type,
    allocator: Allocator,
    slice: []const T,
    predicate: *const fn (T) bool,
) !BifurcateResult(T) {
    var matching = std.ArrayListUnmanaged(T){};
    errdefer matching.deinit(allocator);
    var non_matching = std.ArrayListUnmanaged(T){};
    errdefer non_matching.deinit(allocator);

    for (slice) |item| {
        if (predicate(item)) {
            try matching.append(allocator, item);
        } else {
            try non_matching.append(allocator, item);
        }
    }

    return .{
        .matching = try matching.toOwnedSlice(allocator),
        .non_matching = try non_matching.toOwnedSlice(allocator),
        .allocator = allocator,
    };
}

pub fn bifurcateWithContext(
    comptime T: type,
    comptime Context: type,
    allocator: Allocator,
    slice: []const T,
    context: Context,
    predicate: *const fn (T, Context) bool,
) !BifurcateResult(T) {
    var matching = std.ArrayListUnmanaged(T){};
    errdefer matching.deinit(allocator);
    var non_matching = std.ArrayListUnmanaged(T){};
    errdefer non_matching.deinit(allocator);

    for (slice) |item| {
        if (predicate(item, context)) {
            try matching.append(allocator, item);
        } else {
            try non_matching.append(allocator, item);
        }
    }

    return .{
        .matching = try matching.toOwnedSlice(allocator),
        .non_matching = try non_matching.toOwnedSlice(allocator),
        .allocator = allocator,
    };
}

pub fn partition(
    comptime T: type,
    slice: []T,
    predicate: *const fn (T) bool,
) usize {
    var i: usize = 0;
    var j: usize = slice.len;

    while (i < j) {
        while (i < j and predicate(slice[i])) : (i += 1) {}
        while (i < j and !predicate(slice[j - 1])) : (j -= 1) {}

        if (i < j) {
            j -= 1;
            const temp = slice[i];
            slice[i] = slice[j];
            slice[j] = temp;
            i += 1;
        }
    }

    return i;
}

test "bifurcate" {
    const allocator = std.testing.allocator;
    const data = [_]i32{ 1, 2, 3, 4, 5, 6 };
    const isEven = struct {
        fn f(x: i32) bool {
            return @rem(x, 2) == 0;
        }
    }.f;

    var result = try bifurcate(i32, allocator, &data, isEven);
    defer result.deinit();

    try std.testing.expectEqualSlices(i32, &[_]i32{ 2, 4, 6 }, result.matching);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 1, 3, 5 }, result.non_matching);
}

test "partition in place" {
    var data = [_]i32{ 1, 2, 3, 4, 5, 6 };
    const isEven = struct {
        fn f(x: i32) bool {
            return @rem(x, 2) == 0;
        }
    }.f;

    const pivot = partition(i32, &data, isEven);
    try std.testing.expectEqual(@as(usize, 3), pivot);

    for (data[0..pivot]) |x| {
        try std.testing.expect(@rem(x, 2) == 0);
    }
    for (data[pivot..]) |x| {
        try std.testing.expect(@rem(x, 2) != 0);
    }
}
