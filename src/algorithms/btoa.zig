const std = @import("std");
const Allocator = std.mem.Allocator;
const base64 = std.base64.standard;

pub fn btoa(allocator: *std.mem.Allocator, str: []const u8) ![]u8 {
    var buffer = try allocator.alloc(u8, base64.Encoder.calcSize(str.len));
    _ = base64.Encoder.encode(buffer, str);
    return buffer;
}
