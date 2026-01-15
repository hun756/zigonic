const std = @import("std");

pub fn fnv1a32(data: []const u8) u32 {
    const FNV_OFFSET_BASIS: u32 = 2166136261;
    const FNV_PRIME: u32 = 16777619;

    var hash: u32 = FNV_OFFSET_BASIS;
    for (data) |byte| {
        hash ^= byte;
        hash *%= FNV_PRIME;
    }
    return hash;
}

pub fn fnv1a64(data: []const u8) u64 {
    const FNV_OFFSET_BASIS: u64 = 14695981039346656037;
    const FNV_PRIME: u64 = 1099511628211;

    var hash: u64 = FNV_OFFSET_BASIS;
    for (data) |byte| {
        hash ^= byte;
        hash *%= FNV_PRIME;
    }
    return hash;
}

pub fn fnv1_32(data: []const u8) u32 {
    const FNV_OFFSET_BASIS: u32 = 2166136261;
    const FNV_PRIME: u32 = 16777619;

    var hash: u32 = FNV_OFFSET_BASIS;
    for (data) |byte| {
        hash *%= FNV_PRIME;
        hash ^= byte;
    }
    return hash;
}

pub fn fnv1_64(data: []const u8) u64 {
    const FNV_OFFSET_BASIS: u64 = 14695981039346656037;
    const FNV_PRIME: u64 = 1099511628211;

    var hash: u64 = FNV_OFFSET_BASIS;
    for (data) |byte| {
        hash *%= FNV_PRIME;
        hash ^= byte;
    }
    return hash;
}

pub fn djb2(data: []const u8) u32 {
    var hash: u32 = 5381;
    for (data) |byte| {
        hash = ((hash << 5) +% hash) +% byte;
    }
    return hash;
}

pub fn sdbm(data: []const u8) u32 {
    var hash: u32 = 0;
    for (data) |byte| {
        hash = byte +% (hash << 6) +% (hash << 16) -% hash;
    }
    return hash;
}

pub fn jenkinsOneAtATime(data: []const u8) u32 {
    var hash: u32 = 0;
    for (data) |byte| {
        hash +%= byte;
        hash +%= hash << 10;
        hash ^= hash >> 6;
    }
    hash +%= hash << 3;
    hash ^= hash >> 11;
    hash +%= hash << 15;
    return hash;
}

pub fn murmur3_32(data: []const u8, seed: u32) u32 {
    const c1: u32 = 0xcc9e2d51;
    const c2: u32 = 0x1b873593;
    const r1: u5 = 15;
    const r2: u5 = 13;
    const m: u32 = 5;
    const n: u32 = 0xe6546b64;

    var hash: u32 = seed;
    const nblocks = data.len / 4;

    var i: usize = 0;
    while (i < nblocks) : (i += 1) {
        var k: u32 = @as(u32, data[i * 4]) |
            (@as(u32, data[i * 4 + 1]) << 8) |
            (@as(u32, data[i * 4 + 2]) << 16) |
            (@as(u32, data[i * 4 + 3]) << 24);

        k *%= c1;
        k = std.math.rotl(u32, k, r1);
        k *%= c2;

        hash ^= k;
        hash = std.math.rotl(u32, hash, r2);
        hash = hash *% m +% n;
    }

    const tail = data[nblocks * 4 ..];
    var k1: u32 = 0;

    switch (tail.len) {
        3 => {
            k1 ^= @as(u32, tail[2]) << 16;
            k1 ^= @as(u32, tail[1]) << 8;
            k1 ^= @as(u32, tail[0]);
            k1 *%= c1;
            k1 = std.math.rotl(u32, k1, r1);
            k1 *%= c2;
            hash ^= k1;
        },
        2 => {
            k1 ^= @as(u32, tail[1]) << 8;
            k1 ^= @as(u32, tail[0]);
            k1 *%= c1;
            k1 = std.math.rotl(u32, k1, r1);
            k1 *%= c2;
            hash ^= k1;
        },
        1 => {
            k1 ^= @as(u32, tail[0]);
            k1 *%= c1;
            k1 = std.math.rotl(u32, k1, r1);
            k1 *%= c2;
            hash ^= k1;
        },
        else => {},
    }

    hash ^= @as(u32, @intCast(data.len));
    hash ^= hash >> 16;
    hash *%= 0x85ebca6b;
    hash ^= hash >> 13;
    hash *%= 0xc2b2ae35;
    hash ^= hash >> 16;

    return hash;
}

pub fn xxHash32(data: []const u8, seed: u32) u32 {
    const PRIME32_1: u32 = 0x9E3779B1;
    const PRIME32_2: u32 = 0x85EBCA77;
    const PRIME32_3: u32 = 0xC2B2AE3D;
    const PRIME32_4: u32 = 0x27D4EB2F;
    const PRIME32_5: u32 = 0x165667B1;

    var hash: u32 = undefined;
    var p: usize = 0;

    if (data.len >= 16) {
        var v1 = seed +% PRIME32_1 +% PRIME32_2;
        var v2 = seed +% PRIME32_2;
        var v3 = seed;
        var v4 = seed -% PRIME32_1;

        while (p + 16 <= data.len) {
            inline for (0..4) |i| {
                const offset = p + i * 4;
                const lane_data = @as(u32, data[offset]) |
                    (@as(u32, data[offset + 1]) << 8) |
                    (@as(u32, data[offset + 2]) << 16) |
                    (@as(u32, data[offset + 3]) << 24);

                const v = switch (i) {
                    0 => &v1,
                    1 => &v2,
                    2 => &v3,
                    3 => &v4,
                    else => unreachable,
                };
                v.* +%= lane_data *% PRIME32_2;
                v.* = std.math.rotl(u32, v.*, 13);
                v.* *%= PRIME32_1;
            }
            p += 16;
        }

        hash = std.math.rotl(u32, v1, 1) +%
            std.math.rotl(u32, v2, 7) +%
            std.math.rotl(u32, v3, 12) +%
            std.math.rotl(u32, v4, 18);
    } else {
        hash = seed +% PRIME32_5;
    }

    hash +%= @as(u32, @intCast(data.len));

    while (p + 4 <= data.len) {
        const k = @as(u32, data[p]) |
            (@as(u32, data[p + 1]) << 8) |
            (@as(u32, data[p + 2]) << 16) |
            (@as(u32, data[p + 3]) << 24);
        hash +%= k *% PRIME32_3;
        hash = std.math.rotl(u32, hash, 17) *% PRIME32_4;
        p += 4;
    }

    while (p < data.len) {
        hash +%= data[p] *% PRIME32_5;
        hash = std.math.rotl(u32, hash, 11) *% PRIME32_1;
        p += 1;
    }

    hash ^= hash >> 15;
    hash *%= PRIME32_2;
    hash ^= hash >> 13;
    hash *%= PRIME32_3;
    hash ^= hash >> 16;

    return hash;
}

pub fn adler32(data: []const u8) u32 {
    const MOD_ADLER: u32 = 65521;
    var a: u32 = 1;
    var b: u32 = 0;

    for (data) |byte| {
        a = (a + byte) % MOD_ADLER;
        b = (b + a) % MOD_ADLER;
    }

    return (b << 16) | a;
}

const CRC32_TABLE: [256]u32 = blk: {
    @setEvalBranchQuota(3000);
    var table: [256]u32 = undefined;
    for (0..256) |i| {
        var crc: u32 = @intCast(i);
        for (0..8) |_| {
            if (crc & 1 == 1) {
                crc = (crc >> 1) ^ 0xEDB88320;
            } else {
                crc = crc >> 1;
            }
        }
        table[i] = crc;
    }
    break :blk table;
};

pub fn crc32(data: []const u8) u32 {
    var crc: u32 = 0xFFFFFFFF;
    for (data) |byte| {
        crc = CRC32_TABLE[(crc ^ byte) & 0xFF] ^ (crc >> 8);
    }
    return ~crc;
}

pub fn crc32WithInit(data: []const u8, init: u32) u32 {
    var crc: u32 = ~init;
    for (data) |byte| {
        crc = CRC32_TABLE[(crc ^ byte) & 0xFF] ^ (crc >> 8);
    }
    return ~crc;
}

const CRC16_TABLE: [256]u16 = blk: {
    @setEvalBranchQuota(3000);
    var table: [256]u16 = undefined;
    for (0..256) |i| {
        var crc: u16 = @intCast(i);
        for (0..8) |_| {
            if (crc & 1 == 1) {
                crc = (crc >> 1) ^ 0xA001;
            } else {
                crc = crc >> 1;
            }
        }
        table[i] = crc;
    }
    break :blk table;
};

pub fn crc16(data: []const u8) u16 {
    var crc: u16 = 0xFFFF;
    for (data) |byte| {
        crc = CRC16_TABLE[(crc ^ byte) & 0xFF] ^ (crc >> 8);
    }
    return crc;
}

pub fn pearsonHash(data: []const u8) u8 {
    const T: [256]u8 = .{
        98,  6,   85,  150, 36,  23,  112, 164, 135, 207, 169, 5,   26,  64,  165, 219,
        61,  20,  68,  89,  130, 63,  52,  102, 24,  229, 132, 245, 80,  216, 195, 115,
        90,  168, 156, 203, 177, 120, 2,   190, 188, 7,   100, 185, 174, 243, 162, 10,
        237, 18,  253, 225, 8,   208, 172, 244, 255, 126, 101, 79,  145, 235, 228, 121,
        123, 251, 67,  250, 161, 0,   107, 97,  241, 111, 181, 82,  249, 33,  69,  55,
        59,  153, 29,  9,   213, 167, 84,  93,  30,  46,  94,  75,  151, 114, 73,  222,
        197, 96,  210, 45,  16,  227, 248, 202, 51,  152, 252, 125, 81,  206, 215, 186,
        39,  158, 178, 187, 131, 136, 1,   49,  50,  17,  141, 91,  47,  129, 60,  99,
        154, 35,  86,  171, 105, 34,  38,  200, 147, 58,  77,  118, 173, 246, 76,  254,
        133, 232, 196, 144, 198, 124, 53,  4,   108, 74,  223, 234, 134, 230, 157, 139,
        189, 205, 199, 128, 176, 19,  211, 236, 127, 192, 231, 70,  233, 88,  146, 44,
        183, 201, 22,  83,  13,  214, 116, 109, 159, 32,  95,  226, 140, 220, 57,  12,
        221, 31,  209, 182, 143, 92,  149, 184, 148, 62,  113, 65,  37,  27,  106, 166,
        3,   14,  204, 72,  21,  41,  56,  66,  28,  193, 40,  217, 25,  54,  179, 117,
        238, 87,  240, 155, 180, 170, 242, 212, 191, 163, 78,  218, 137, 194, 175, 110,
        43,  119, 224, 71,  122, 142, 42,  160, 104, 48,  247, 103, 15,  11,  138, 239,
    };

    var hash: u8 = 0;
    for (data) |byte| {
        hash = T[hash ^ byte];
    }
    return hash;
}

pub fn fletcher16(data: []const u8) u16 {
    var sum1: u16 = 0;
    var sum2: u16 = 0;

    for (data) |byte| {
        sum1 = (sum1 + byte) % 255;
        sum2 = (sum2 + sum1) % 255;
    }

    return (sum2 << 8) | sum1;
}

pub fn fletcher32(data: []const u8) u32 {
    var sum1: u32 = 0;
    var sum2: u32 = 0;

    var i: usize = 0;
    while (i < data.len) {
        const word: u16 = if (i + 1 < data.len)
            @as(u16, data[i]) | (@as(u16, data[i + 1]) << 8)
        else
            @as(u16, data[i]);

        sum1 = (sum1 + word) % 65535;
        sum2 = (sum2 + sum1) % 65535;
        i += 2;
    }

    return (sum2 << 16) | sum1;
}

pub fn checksum8Xor(data: []const u8) u8 {
    var result: u8 = 0;
    for (data) |byte| {
        result ^= byte;
    }
    return result;
}

pub fn checksum8Sum(data: []const u8) u8 {
    var result: u8 = 0;
    for (data) |byte| {
        result +%= byte;
    }
    return result;
}

pub fn checksum16(data: []const u8) u16 {
    var sum: u32 = 0;
    var i: usize = 0;

    while (i + 1 < data.len) {
        sum += @as(u16, data[i]) | (@as(u16, data[i + 1]) << 8);
        i += 2;
    }

    if (i < data.len) {
        sum += data[i];
    }

    while (sum >> 16 != 0) {
        sum = (sum & 0xFFFF) + (sum >> 16);
    }

    return @truncate(~sum);
}

pub fn internetChecksum(data: []const u8) u16 {
    return checksum16(data);
}

pub fn hashCombine(seed: u64, hash: u64) u64 {
    return seed ^ (hash +% 0x9e3779b9 +% (seed << 6) +% (seed >> 2));
}

pub fn hashSlice(comptime T: type, slice: []const T) u64 {
    var hash: u64 = 0;
    for (slice) |item| {
        const item_hash = switch (@typeInfo(T)) {
            .int => @as(u64, @bitCast(@as(i64, item))),
            .float => @as(u64, @bitCast(item)),
            else => @as(u64, @intCast(@intFromPtr(&item))),
        };
        hash = hashCombine(hash, item_hash);
    }
    return hash;
}

test "fnv1a32" {
    try std.testing.expectEqual(@as(u32, 0x811c9dc5), fnv1a32(""));
    try std.testing.expectEqual(@as(u32, 0xe40c292c), fnv1a32("a"));
    try std.testing.expectEqual(@as(u32, 0xbf9cf968), fnv1a32("foobar"));
}

test "fnv1a64" {
    try std.testing.expectEqual(@as(u64, 0xcbf29ce484222325), fnv1a64(""));
    try std.testing.expectEqual(@as(u64, 0xaf63dc4c8601ec8c), fnv1a64("a"));
}

test "djb2" {
    const hash1 = djb2("hello");
    const hash2 = djb2("world");
    try std.testing.expect(hash1 != hash2);
}

test "jenkinsOneAtATime" {
    const hash1 = jenkinsOneAtATime("hello");
    const hash2 = jenkinsOneAtATime("world");
    try std.testing.expect(hash1 != hash2);
}

test "murmur3_32" {
    const hash = murmur3_32("hello", 0);
    try std.testing.expect(hash != 0);
}

test "xxHash32" {
    const hash = xxHash32("hello world", 0);
    try std.testing.expect(hash != 0);
}

test "adler32" {
    try std.testing.expectEqual(@as(u32, 0x11E60398), adler32("Wikipedia"));
}

test "crc32" {
    try std.testing.expectEqual(@as(u32, 0xCBF43926), crc32("123456789"));
}

test "crc16" {
    const result = crc16("123456789");
    try std.testing.expect(result != 0);
}

test "pearsonHash" {
    const hash1 = pearsonHash("hello");
    const hash2 = pearsonHash("world");
    try std.testing.expect(hash1 != hash2);
}

test "fletcher16" {
    const result = fletcher16("abcde");
    try std.testing.expect(result != 0);
}

test "fletcher32" {
    const result = fletcher32("abcdefgh");
    try std.testing.expect(result != 0);
}

test "checksum8" {
    const data = [_]u8{ 0x01, 0x02, 0x03, 0x04 };
    try std.testing.expectEqual(@as(u8, 0x04), checksum8Xor(&data));
    try std.testing.expectEqual(@as(u8, 0x0A), checksum8Sum(&data));
}

test "hashCombine" {
    const h1 = hashCombine(0, 42);
    const h2 = hashCombine(h1, 43);
    try std.testing.expect(h1 != h2);
}
