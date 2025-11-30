const std = @import("std");
const Allocator = std.mem.Allocator;
const base64 = std.base64.standard;

pub fn encode(allocator: Allocator, data: []const u8) ![]u8 {
    const size = base64.Encoder.calcSize(data.len);
    const buffer = try allocator.alloc(u8, size);
    _ = base64.Encoder.encode(buffer, data);
    return buffer;
}

pub fn decode(allocator: Allocator, encoded: []const u8) ![]u8 {
    const size = try base64.Decoder.calcSizeForSlice(encoded);
    const buffer = try allocator.alloc(u8, size);
    try base64.Decoder.decode(buffer, encoded);
    return buffer;
}

pub fn encodeToBuffer(dest: []u8, source: []const u8) ![]u8 {
    const size = base64.Encoder.calcSize(source.len);
    if (dest.len < size) return error.BufferTooSmall;
    _ = base64.Encoder.encode(dest[0..size], source);
    return dest[0..size];
}

pub fn decodeToBuffer(dest: []u8, source: []const u8) ![]u8 {
    const size = try base64.Decoder.calcSizeForSlice(source);
    if (dest.len < size) return error.BufferTooSmall;
    try base64.Decoder.decode(dest[0..size], source);
    return dest[0..size];
}

test "encode" {
    const allocator = std.testing.allocator;
    const result = try encode(allocator, "Hello, World!");
    defer allocator.free(result);
    try std.testing.expectEqualStrings("SGVsbG8sIFdvcmxkIQ==", result);
}

test "decode" {
    const allocator = std.testing.allocator;
    const result = try decode(allocator, "SGVsbG8sIFdvcmxkIQ==");
    defer allocator.free(result);
    try std.testing.expectEqualStrings("Hello, World!", result);
}

test "roundtrip" {
    const allocator = std.testing.allocator;
    const original = "The quick brown fox jumps over the lazy dog";

    const encoded = try encode(allocator, original);
    defer allocator.free(encoded);

    const decoded = try decode(allocator, encoded);
    defer allocator.free(decoded);

    try std.testing.expectEqualStrings(original, decoded);
}
