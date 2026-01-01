const std = @import("std");

pub fn popcount(comptime T: type, value: T) u16 {
    return @popCount(value);
}

pub fn countTrailingZeros(comptime T: type, value: T) u16 {
    if (value == 0) return @bitSizeOf(T);
    return @ctz(value);
}

pub fn countLeadingZeros(comptime T: type, value: T) u16 {
    if (value == 0) return @bitSizeOf(T);
    return @clz(value);
}

pub fn isPowerOfTwo(comptime T: type, value: T) bool {
    return value != 0 and (value & (value - 1)) == 0;
}

pub fn nextPowerOfTwo(comptime T: type, value: T) T {
    if (value == 0) return 1;
    if (isPowerOfTwo(T, value)) return value;

    var v = value;
    v -= 1;
    inline for ([_]u8{ 1, 2, 4, 8, 16, 32 }) |shift| {
        if (shift < @bitSizeOf(T)) {
            v |= v >> @intCast(shift);
        }
    }
    return v + 1;
}

pub fn reverseBits(comptime T: type, value: T) T {
    return @bitReverse(value);
}

pub fn rotateLeft(comptime T: type, value: T, shift: u16) T {
    return std.math.rotl(T, value, shift);
}

pub fn rotateRight(comptime T: type, value: T, shift: u16) T {
    return std.math.rotr(T, value, shift);
}

pub fn getBit(comptime T: type, value: T, position: u16) bool {
    return (value & (@as(T, 1) << @intCast(position))) != 0;
}

pub fn setBit(comptime T: type, value: T, position: u16) T {
    return value | (@as(T, 1) << @intCast(position));
}

pub fn clearBit(comptime T: type, value: T, position: u16) T {
    return value & ~(@as(T, 1) << @intCast(position));
}

pub fn toggleBit(comptime T: type, value: T, position: u16) T {
    return value ^ (@as(T, 1) << @intCast(position));
}

pub fn extractBits(comptime T: type, value: T, start: u16, length: u16) T {
    const mask = (@as(T, 1) << @intCast(length)) - 1;
    return (value >> @intCast(start)) & mask;
}

pub fn setBits(comptime T: type, value: T, start: u16, length: u16, bits: T) T {
    const mask = ((@as(T, 1) << @intCast(length)) - 1) << @intCast(start);
    return (value & ~mask) | ((bits << @intCast(start)) & mask);
}

pub fn parity(comptime T: type, value: T) u1 {
    return @as(u1, @intCast(@popCount(value) & 1));
}

pub fn swapBits(comptime T: type, value: T, pos1: u16, pos2: u16) T {
    const bit1 = (value >> @intCast(pos1)) & 1;
    const bit2 = (value >> @intCast(pos2)) & 1;

    if (bit1 == bit2) return value;

    const mask = (@as(T, 1) << @intCast(pos1)) | (@as(T, 1) << @intCast(pos2));
    return value ^ mask;
}

pub fn grayCode(comptime T: type, value: T) T {
    return value ^ (value >> 1);
}

pub fn inverseGrayCode(comptime T: type, gray: T) T {
    var result = gray;
    inline for ([_]u8{ 1, 2, 4, 8, 16, 32 }) |shift| {
        if (shift < @bitSizeOf(T)) {
            result ^= result >> @intCast(shift);
        }
    }
    return result;
}

pub fn hammingWeight(comptime T: type, value: T) u16 {
    return @popCount(value);
}

pub fn hammingDistanceBits(comptime T: type, a: T, b: T) u16 {
    return @popCount(a ^ b);
}

pub fn findFirstSet(comptime T: type, value: T) ?u16 {
    if (value == 0) return null;
    return @ctz(value);
}

pub fn findLastSet(comptime T: type, value: T) ?u16 {
    if (value == 0) return null;
    return @bitSizeOf(T) - @clz(value) - 1;
}

pub fn isolateRightmostBit(comptime T: type, value: T) T {
    return value & (~value +% 1);
}

pub fn clearRightmostBit(comptime T: type, value: T) T {
    return value & (value -% 1);
}

pub fn isEven(comptime T: type, value: T) bool {
    return (value & 1) == 0;
}

pub fn isOdd(comptime T: type, value: T) bool {
    return (value & 1) != 0;
}

pub fn multiplyByPowerOfTwo(comptime T: type, value: T, power: u16) T {
    return value << @intCast(power);
}

pub fn divideByPowerOfTwo(comptime T: type, value: T, power: u16) T {
    return value >> @intCast(power);
}

pub fn byteSwap(comptime T: type, value: T) T {
    return @byteSwap(value);
}

pub fn bitReverse8(value: u8) u8 {
    var v = value;
    v = ((v & 0xF0) >> 4) | ((v & 0x0F) << 4);
    v = ((v & 0xCC) >> 2) | ((v & 0x33) << 2);
    v = ((v & 0xAA) >> 1) | ((v & 0x55) << 1);
    return v;
}

pub fn bitReverse16(value: u16) u16 {
    const low = bitReverse8(@truncate(value));
    const high = bitReverse8(@truncate(value >> 8));
    return (@as(u16, low) << 8) | high;
}

pub fn bitReverse32(value: u32) u32 {
    const low = bitReverse16(@truncate(value));
    const high = bitReverse16(@truncate(value >> 16));
    return (@as(u32, low) << 16) | high;
}

pub fn rightPropagate(comptime T: type, value: T) T {
    var v = value;
    inline for ([_]u8{ 1, 2, 4, 8, 16, 32 }) |shift| {
        if (shift < @bitSizeOf(T)) {
            v |= v >> @intCast(shift);
        }
    }
    return v;
}

pub fn leftPropagate(comptime T: type, value: T) T {
    var v = value;
    inline for ([_]u8{ 1, 2, 4, 8, 16, 32 }) |shift| {
        if (shift < @bitSizeOf(T)) {
            v |= v << @intCast(shift);
        }
    }
    return v;
}

pub fn bitsRequired(comptime T: type, value: T) u16 {
    if (value == 0) return 0;
    return @bitSizeOf(T) - @clz(value);
}

pub fn saturatingAdd(comptime T: type, a: T, b: T) T {
    return a +| b;
}

pub fn saturatingSub(comptime T: type, a: T, b: T) T {
    return a -| b;
}

test "popcount" {
    try std.testing.expectEqual(@as(u16, 3), popcount(u8, 0b10110000));
    try std.testing.expectEqual(@as(u16, 4), popcount(u16, 0b0000111100000000));
}

test "countTrailingZeros" {
    try std.testing.expectEqual(@as(u16, 4), countTrailingZeros(u8, 0b10110000));
    try std.testing.expectEqual(@as(u16, 0), countTrailingZeros(u8, 0b10110001));
}

test "countLeadingZeros" {
    try std.testing.expectEqual(@as(u16, 4), countLeadingZeros(u8, 0b00001111));
    try std.testing.expectEqual(@as(u16, 0), countLeadingZeros(u8, 0b11111111));
}

test "isPowerOfTwo" {
    try std.testing.expect(isPowerOfTwo(u32, 8));
    try std.testing.expect(isPowerOfTwo(u32, 16));
    try std.testing.expect(!isPowerOfTwo(u32, 12));
}

test "nextPowerOfTwo" {
    try std.testing.expectEqual(@as(u32, 8), nextPowerOfTwo(u32, 5));
    try std.testing.expectEqual(@as(u32, 16), nextPowerOfTwo(u32, 9));
    try std.testing.expectEqual(@as(u32, 8), nextPowerOfTwo(u32, 8));
}

test "reverseBits" {
    try std.testing.expectEqual(@as(u8, 0b00001111), reverseBits(u8, 0b11110000));
}

test "rotateLeft and rotateRight" {
    try std.testing.expectEqual(@as(u8, 0b11000110), rotateLeft(u8, 0b10110001, 2));
    try std.testing.expectEqual(@as(u8, 0b01101100), rotateRight(u8, 0b10110001, 2));
}

test "getBit" {
    try std.testing.expect(getBit(u8, 0b10110000, 5));
    try std.testing.expect(!getBit(u8, 0b10110000, 6));
}

test "setBit and clearBit" {
    try std.testing.expectEqual(@as(u8, 0b10110100), setBit(u8, 0b10110000, 2));
    try std.testing.expectEqual(@as(u8, 0b10010000), clearBit(u8, 0b10110000, 5));
}

test "toggleBit" {
    try std.testing.expectEqual(@as(u8, 0b10110100), toggleBit(u8, 0b10110000, 2));
    try std.testing.expectEqual(@as(u8, 0b10010000), toggleBit(u8, 0b10110000, 5));
}

test "extractBits" {
    try std.testing.expectEqual(@as(u8, 0b1101), extractBits(u8, 0b10110100, 2, 4));
}

test "parity" {
    try std.testing.expectEqual(@as(u1, 1), parity(u8, 0b10110000));
    try std.testing.expectEqual(@as(u1, 0), parity(u8, 0b10110001));
}

test "grayCode and inverseGrayCode" {
    const value: u8 = 5;
    const gray = grayCode(u8, value);
    const inverse = inverseGrayCode(u8, gray);
    try std.testing.expectEqual(value, inverse);
}

test "hammingDistanceBits" {
    try std.testing.expectEqual(@as(u16, 2), hammingDistanceBits(u8, 0b10110000, 0b10010100));
}

test "findFirstSet and findLastSet" {
    try std.testing.expectEqual(@as(?u16, 4), findFirstSet(u8, 0b10110000));
    try std.testing.expectEqual(@as(?u16, 7), findLastSet(u8, 0b10110000));
}

test "isolateRightmostBit" {
    try std.testing.expectEqual(@as(u8, 0b00010000), isolateRightmostBit(u8, 0b10110000));
}

test "clearRightmostBit" {
    try std.testing.expectEqual(@as(u8, 0b10100000), clearRightmostBit(u8, 0b10110000));
}

test "byteSwap" {
    try std.testing.expectEqual(@as(u16, 0x3412), byteSwap(u16, 0x1234));
    try std.testing.expectEqual(@as(u32, 0x78563412), byteSwap(u32, 0x12345678));
}

test "bitReverse" {
    try std.testing.expectEqual(@as(u8, 0x0F), bitReverse8(0xF0));
    try std.testing.expectEqual(@as(u16, 0x2C48), bitReverse16(0x1234));
}

test "bitsRequired" {
    try std.testing.expectEqual(@as(u16, 4), bitsRequired(u32, 15));
    try std.testing.expectEqual(@as(u16, 5), bitsRequired(u32, 16));
}
