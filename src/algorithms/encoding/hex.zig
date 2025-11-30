const std = @import("std");
const Allocator = std.mem.Allocator;

const hex_chars = "0123456789abcdef";
const hex_chars_upper = "0123456789ABCDEF";

pub fn encodeHex(allocator: Allocator, data: []const u8) ![]u8 {
    const result = try allocator.alloc(u8, data.len * 2);
    for (data, 0..) |byte, i| {
        result[i * 2] = hex_chars[byte >> 4];
        result[i * 2 + 1] = hex_chars[byte & 0x0F];
    }
    return result;
}

pub fn encodeHexUpper(allocator: Allocator, data: []const u8) ![]u8 {
    const result = try allocator.alloc(u8, data.len * 2);
    for (data, 0..) |byte, i| {
        result[i * 2] = hex_chars_upper[byte >> 4];
        result[i * 2 + 1] = hex_chars_upper[byte & 0x0F];
    }
    return result;
}

pub fn decodeHex(allocator: Allocator, hex: []const u8) ![]u8 {
    if (hex.len % 2 != 0) return error.InvalidHexLength;

    const result = try allocator.alloc(u8, hex.len / 2);
    errdefer allocator.free(result);

    var i: usize = 0;
    while (i < hex.len) : (i += 2) {
        const high = try hexCharToValue(hex[i]);
        const low = try hexCharToValue(hex[i + 1]);
        result[i / 2] = @as(u8, high << 4) | low;
    }

    return result;
}

fn hexCharToValue(c: u8) !u8 {
    return switch (c) {
        '0'...'9' => c - '0',
        'a'...'f' => c - 'a' + 10,
        'A'...'F' => c - 'A' + 10,
        else => error.InvalidHexChar,
    };
}

test "encodeHex" {
    const allocator = std.testing.allocator;
    const result = try encodeHex(allocator, "Hello");
    defer allocator.free(result);
    try std.testing.expectEqualStrings("48656c6c6f", result);
}

test "decodeHex" {
    const allocator = std.testing.allocator;
    const result = try decodeHex(allocator, "48656c6c6f");
    defer allocator.free(result);
    try std.testing.expectEqualStrings("Hello", result);
}

test "hex roundtrip" {
    const allocator = std.testing.allocator;
    const original = "Test Data 123";

    const encoded = try encodeHex(allocator, original);
    defer allocator.free(encoded);

    const decoded = try decodeHex(allocator, encoded);
    defer allocator.free(decoded);

    try std.testing.expectEqualStrings(original, decoded);
}
