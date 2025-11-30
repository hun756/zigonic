const std = @import("std");
const core = @import("../core/mod.zig");

pub fn RangeIterator(comptime T: type) type {
    comptime core.assertNumeric(T);

    return struct {
        const Self = @This();

        start: T,
        end: T,
        step: T,
        current: T,

        pub fn init(start: T, end: T, step: T) Self {
            return .{
                .start = start,
                .end = end,
                .step = step,
                .current = start,
            };
        }

        pub fn until(n: T) Self {
            return init(0, n, 1);
        }

        pub fn from(start: T, end: T) Self {
            return init(start, end, 1);
        }

        pub fn next(self: *Self) ?T {
            if (self.step > 0) {
                if (self.current >= self.end) return null;
            } else {
                if (self.current <= self.end) return null;
            }

            const value = self.current;
            self.current += self.step;
            return value;
        }

        pub fn peek(self: *const Self) ?T {
            if (self.step > 0) {
                if (self.current >= self.end) return null;
            } else {
                if (self.current <= self.end) return null;
            }
            return self.current;
        }

        pub fn hasNext(self: *const Self) bool {
            if (self.step > 0) {
                return self.current < self.end;
            } else {
                return self.current > self.end;
            }
        }

        pub fn reset(self: *Self) void {
            self.current = self.start;
        }

        pub fn remaining(self: *const Self) usize {
            if (self.step > 0) {
                if (self.current >= self.end) return 0;
                const diff = self.end - self.current;
                return @intCast(@divFloor(diff + self.step - 1, self.step));
            } else {
                if (self.current <= self.end) return 0;
                const diff = self.current - self.end;
                const abs_step = if (self.step < 0) -self.step else self.step;
                return @intCast(@divFloor(diff + abs_step - 1, abs_step));
            }
        }

        pub fn skip(self: *Self, n: usize) *Self {
            var count: usize = 0;
            while (count < n and self.hasNext()) {
                _ = self.next();
                count += 1;
            }
            return self;
        }

        pub fn collect(self: *Self, allocator: std.mem.Allocator) ![]T {
            var list = std.ArrayListUnmanaged(T){};
            errdefer list.deinit(allocator);

            while (self.next()) |value| {
                try list.append(allocator, value);
            }

            return list.toOwnedSlice(allocator);
        }

        pub fn forEach(self: *Self, comptime f: fn (T) void) void {
            while (self.next()) |value| {
                f(value);
            }
        }

        pub fn fold(self: *Self, comptime Acc: type, initial: Acc, comptime f: fn (Acc, T) Acc) Acc {
            var acc = initial;
            while (self.next()) |value| {
                acc = f(acc, value);
            }
            return acc;
        }

        pub fn sum(self: *Self) T {
            return self.fold(T, 0, struct {
                fn add(acc: T, x: T) T {
                    return acc + x;
                }
            }.add);
        }
    };
}

pub fn range(comptime T: type, n: T) RangeIterator(T) {
    return RangeIterator(T).until(n);
}

pub fn rangeFrom(comptime T: type, start: T, end: T) RangeIterator(T) {
    return RangeIterator(T).from(start, end);
}

pub fn rangeStep(comptime T: type, start: T, end: T, step: T) RangeIterator(T) {
    return RangeIterator(T).init(start, end, step);
}

test "RangeIterator basic" {
    var r = RangeIterator(i32).init(0, 5, 1);

    try std.testing.expectEqual(@as(?i32, 0), r.next());
    try std.testing.expectEqual(@as(?i32, 1), r.next());
    try std.testing.expectEqual(@as(?i32, 2), r.next());
    try std.testing.expectEqual(@as(?i32, 3), r.next());
    try std.testing.expectEqual(@as(?i32, 4), r.next());
    try std.testing.expectEqual(@as(?i32, null), r.next());
}

test "RangeIterator with step" {
    var r = RangeIterator(i32).init(0, 10, 2);

    try std.testing.expectEqual(@as(?i32, 0), r.next());
    try std.testing.expectEqual(@as(?i32, 2), r.next());
    try std.testing.expectEqual(@as(?i32, 4), r.next());
    try std.testing.expectEqual(@as(?i32, 6), r.next());
    try std.testing.expectEqual(@as(?i32, 8), r.next());
    try std.testing.expectEqual(@as(?i32, null), r.next());
}

test "RangeIterator sum" {
    var r = RangeIterator(i32).init(1, 6, 1);
    try std.testing.expectEqual(@as(i32, 15), r.sum());
}

test "RangeIterator collect" {
    var r = RangeIterator(i32).init(0, 5, 1);
    const allocator = std.testing.allocator;
    const values = try r.collect(allocator);
    defer allocator.free(values);

    try std.testing.expectEqualSlices(i32, &[_]i32{ 0, 1, 2, 3, 4 }, values);
}

test "range convenience function" {
    var r = range(i32, 3);
    try std.testing.expectEqual(@as(?i32, 0), r.next());
    try std.testing.expectEqual(@as(?i32, 1), r.next());
    try std.testing.expectEqual(@as(?i32, 2), r.next());
    try std.testing.expectEqual(@as(?i32, null), r.next());
}
