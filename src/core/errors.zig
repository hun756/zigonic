const std = @import("std");

pub const IteratorError = error{
    AllocatorRequired,
    EmptyIterator,
    InvalidRange,
    Exhausted,
};

pub const AccumulateError = error{
    Overflow,
    Underflow,
    DivisionByZero,
};

pub const SearchError = error{
    UnsortedInput,
    InvalidBounds,
};

pub const MemoryError = error{
    OutOfMemory,
    BufferTooSmall,
};

pub const AlgorithmError = IteratorError || AccumulateError || SearchError || MemoryError;

pub const ErrorContext = struct {
    message: []const u8,
    source_location: ?std.builtin.SourceLocation,

    pub fn init(message: []const u8, src: ?std.builtin.SourceLocation) ErrorContext {
        return .{
            .message = message,
            .source_location = src,
        };
    }

    pub fn format(
        self: ErrorContext,
        comptime _: []const u8,
        _: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        if (self.source_location) |loc| {
            try writer.print("{s}:{d}:{d}: {s}", .{
                loc.file,
                loc.line,
                loc.column,
                self.message,
            });
        } else {
            try writer.print("{s}", .{self.message});
        }
    }
};

test "ErrorContext formatting" {
    const ctx = ErrorContext.init("test error", @src());
    var buf: [1024]u8 = undefined;
    const result = std.fmt.bufPrint(&buf, "{any}", .{ctx}) catch unreachable;
    try std.testing.expect(result.len > 0);
}
