const std = @import("std");

pub fn EnumerateIterator(comptime Inner: type) type {
    const ItemType = @typeInfo(@TypeOf(Inner.next)).@"fn".return_type.?;
    const T = @typeInfo(ItemType).optional.child;

    return struct {
        const Self = @This();

        pub const Item = struct {
            index: usize,
            value: T,
        };

        inner: Inner,
        index: usize,

        pub fn init(inner: Inner) Self {
            return .{
                .inner = inner,
                .index = 0,
            };
        }

        pub fn next(self: *Self) ?Item {
            if (self.inner.next()) |value| {
                const idx = self.index;
                self.index += 1;
                return .{ .index = idx, .value = value };
            }
            return null;
        }

        pub fn peek(self: *const Self) ?Item {
            if (self.inner.peek()) |value| {
                return .{ .index = self.index, .value = value };
            }
            return null;
        }

        pub fn hasNext(self: *const Self) bool {
            return self.inner.hasNext();
        }

        pub fn reset(self: *Self) void {
            self.inner.reset();
            self.index = 0;
        }
    };
}

pub fn enumerate(comptime Inner: type, inner: Inner) EnumerateIterator(Inner) {
    return EnumerateIterator(Inner).init(inner);
}

const SliceIterator = @import("slice_iterator.zig").SliceIterator;

test "EnumerateIterator basic" {
    const data = [_]i32{ 10, 20, 30 };
    var it = enumerate(SliceIterator(i32), SliceIterator(i32).init(&data));

    const first = it.next().?;
    try std.testing.expectEqual(@as(usize, 0), first.index);
    try std.testing.expectEqual(@as(i32, 10), first.value);

    const second = it.next().?;
    try std.testing.expectEqual(@as(usize, 1), second.index);
    try std.testing.expectEqual(@as(i32, 20), second.value);

    const third = it.next().?;
    try std.testing.expectEqual(@as(usize, 2), third.index);
    try std.testing.expectEqual(@as(i32, 30), third.value);

    try std.testing.expectEqual(@as(?EnumerateIterator(SliceIterator(i32)).Item, null), it.next());
}
