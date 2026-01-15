const std = @import("std");

pub fn kmpSearch(text: []const u8, pattern: []const u8, allocator: std.mem.Allocator) !std.ArrayList(usize) {
    var matches = std.ArrayList(usize).init(allocator);
    errdefer matches.deinit();

    if (pattern.len == 0 or pattern.len > text.len) return matches;

    const lps = try computeLPSArray(pattern, allocator);
    defer allocator.free(lps);

    var i: usize = 0;
    var j: usize = 0;

    while (i < text.len) {
        if (pattern[j] == text[i]) {
            i += 1;
            j += 1;
        }

        if (j == pattern.len) {
            try matches.append(i - j);
            j = lps[j - 1];
        } else if (i < text.len and pattern[j] != text[i]) {
            if (j != 0) {
                j = lps[j - 1];
            } else {
                i += 1;
            }
        }
    }

    return matches;
}

fn computeLPSArray(pattern: []const u8, allocator: std.mem.Allocator) ![]usize {
    const lps = try allocator.alloc(usize, pattern.len);
    errdefer allocator.free(lps);

    lps[0] = 0;
    var len: usize = 0;
    var i: usize = 1;

    while (i < pattern.len) {
        if (pattern[i] == pattern[len]) {
            len += 1;
            lps[i] = len;
            i += 1;
        } else {
            if (len != 0) {
                len = lps[len - 1];
            } else {
                lps[i] = 0;
                i += 1;
            }
        }
    }

    return lps;
}

pub fn boyerMooreSearch(text: []const u8, pattern: []const u8, allocator: std.mem.Allocator) !std.ArrayList(usize) {
    var matches = std.ArrayList(usize).init(allocator);
    errdefer matches.deinit();

    if (pattern.len == 0 or pattern.len > text.len) return matches;

    const bad_char = try buildBadCharTable(pattern, allocator);
    defer allocator.free(bad_char);

    var s: usize = 0;
    while (s <= text.len - pattern.len) {
        var j: isize = @as(isize, @intCast(pattern.len)) - 1;

        while (j >= 0 and pattern[@intCast(j)] == text[s + @as(usize, @intCast(j))]) {
            j -= 1;
        }

        if (j < 0) {
            try matches.append(s);
            s += if (s + pattern.len < text.len) pattern.len - bad_char[text[s + pattern.len]] else 1;
        } else {
            const char_idx = text[s + @as(usize, @intCast(j))];
            const shift = @max(1, @as(isize, @intCast(j)) - @as(isize, @intCast(bad_char[char_idx])));
            s += @intCast(shift);
        }
    }

    return matches;
}

fn buildBadCharTable(pattern: []const u8, allocator: std.mem.Allocator) ![]usize {
    const table = try allocator.alloc(usize, 256);
    @memset(table, 0);

    for (pattern, 0..) |char, i| {
        table[char] = i;
    }

    return table;
}

pub fn rabinKarpSearch(text: []const u8, pattern: []const u8, allocator: std.mem.Allocator) !std.ArrayList(usize) {
    var matches = std.ArrayList(usize).init(allocator);
    errdefer matches.deinit();

    if (pattern.len == 0 or pattern.len > text.len) return matches;

    const d: u64 = 256;
    const q: u64 = 101;
    var p_hash: u64 = 0;
    var t_hash: u64 = 0;
    var h: u64 = 1;

    for (0..pattern.len - 1) |_| {
        h = (h * d) % q;
    }

    for (0..pattern.len) |i| {
        p_hash = (d * p_hash + pattern[i]) % q;
        t_hash = (d * t_hash + text[i]) % q;
    }

    for (0..text.len - pattern.len + 1) |i| {
        if (p_hash == t_hash) {
            var match = true;
            for (0..pattern.len) |j| {
                if (text[i + j] != pattern[j]) {
                    match = false;
                    break;
                }
            }
            if (match) try matches.append(i);
        }

        if (i < text.len - pattern.len) {
            t_hash = (d * (t_hash + q - (text[i] * h) % q) + text[i + pattern.len]) % q;
        }
    }

    return matches;
}

pub fn levenshteinDistance(s1: []const u8, s2: []const u8, allocator: std.mem.Allocator) !usize {
    if (s1.len == 0) return s2.len;
    if (s2.len == 0) return s1.len;

    const rows = s1.len + 1;
    const cols = s2.len + 1;
    const matrix = try allocator.alloc(usize, rows * cols);
    defer allocator.free(matrix);

    for (0..rows) |i| {
        matrix[i * cols] = i;
    }
    for (0..cols) |j| {
        matrix[j] = j;
    }

    for (1..rows) |i| {
        for (1..cols) |j| {
            const cost: usize = if (s1[i - 1] == s2[j - 1]) 0 else 1;
            const deletion = matrix[(i - 1) * cols + j] + 1;
            const insertion = matrix[i * cols + (j - 1)] + 1;
            const substitution = matrix[(i - 1) * cols + (j - 1)] + cost;
            matrix[i * cols + j] = @min(@min(deletion, insertion), substitution);
        }
    }

    return matrix[(rows - 1) * cols + (cols - 1)];
}

pub fn longestCommonSubstring(s1: []const u8, s2: []const u8, allocator: std.mem.Allocator) !struct { start: usize, length: usize } {
    if (s1.len == 0 or s2.len == 0) return .{ .start = 0, .length = 0 };

    const rows = s1.len + 1;
    const cols = s2.len + 1;
    const matrix = try allocator.alloc(usize, rows * cols);
    defer allocator.free(matrix);

    @memset(matrix, 0);

    var max_len: usize = 0;
    var end_pos: usize = 0;

    for (1..rows) |i| {
        for (1..cols) |j| {
            if (s1[i - 1] == s2[j - 1]) {
                matrix[i * cols + j] = matrix[(i - 1) * cols + (j - 1)] + 1;
                if (matrix[i * cols + j] > max_len) {
                    max_len = matrix[i * cols + j];
                    end_pos = i;
                }
            }
        }
    }

    return .{ .start = end_pos - max_len, .length = max_len };
}

pub fn longestCommonSubsequence(s1: []const u8, s2: []const u8, allocator: std.mem.Allocator) !usize {
    if (s1.len == 0 or s2.len == 0) return 0;

    const rows = s1.len + 1;
    const cols = s2.len + 1;
    const matrix = try allocator.alloc(usize, rows * cols);
    defer allocator.free(matrix);

    @memset(matrix, 0);

    for (1..rows) |i| {
        for (1..cols) |j| {
            if (s1[i - 1] == s2[j - 1]) {
                matrix[i * cols + j] = matrix[(i - 1) * cols + (j - 1)] + 1;
            } else {
                matrix[i * cols + j] = @max(matrix[(i - 1) * cols + j], matrix[i * cols + (j - 1)]);
            }
        }
    }

    return matrix[(rows - 1) * cols + (cols - 1)];
}

pub fn isPalindrome(s: []const u8) bool {
    if (s.len <= 1) return true;
    var left: usize = 0;
    var right: usize = s.len - 1;
    while (left < right) {
        if (s[left] != s[right]) return false;
        left += 1;
        right -= 1;
    }
    return true;
}

pub fn reverseString(s: []u8) void {
    if (s.len <= 1) return;
    var left: usize = 0;
    var right: usize = s.len - 1;
    while (left < right) {
        const temp = s[left];
        s[left] = s[right];
        s[right] = temp;
        left += 1;
        right -= 1;
    }
}

pub fn countSubstrings(text: []const u8, substring: []const u8) usize {
    if (substring.len == 0 or substring.len > text.len) return 0;
    var count: usize = 0;
    var i: usize = 0;
    while (i <= text.len - substring.len) {
        if (std.mem.eql(u8, text[i .. i + substring.len], substring)) {
            count += 1;
            i += substring.len;
        } else {
            i += 1;
        }
    }
    return count;
}

pub fn hammingDistance(s1: []const u8, s2: []const u8) !usize {
    if (s1.len != s2.len) return error.UnequalLength;
    var distance: usize = 0;
    for (s1, s2) |c1, c2| {
        if (c1 != c2) distance += 1;
    }
    return distance;
}

pub fn trim(s: []const u8) []const u8 {
    if (s.len == 0) return s;
    var start: usize = 0;
    var end: usize = s.len;

    while (start < end and std.ascii.isWhitespace(s[start])) {
        start += 1;
    }
    while (end > start and std.ascii.isWhitespace(s[end - 1])) {
        end -= 1;
    }
    return s[start..end];
}

pub fn trimLeft(s: []const u8) []const u8 {
    if (s.len == 0) return s;
    var start: usize = 0;
    while (start < s.len and std.ascii.isWhitespace(s[start])) {
        start += 1;
    }
    return s[start..];
}

pub fn trimRight(s: []const u8) []const u8 {
    if (s.len == 0) return s;
    var end: usize = s.len;
    while (end > 0 and std.ascii.isWhitespace(s[end - 1])) {
        end -= 1;
    }
    return s[0..end];
}

pub fn split(s: []const u8, delimiter: u8, allocator: std.mem.Allocator) !std.ArrayList([]const u8) {
    var result = std.ArrayList([]const u8).init(allocator);
    errdefer result.deinit();

    var start: usize = 0;
    for (s, 0..) |c, i| {
        if (c == delimiter) {
            try result.append(s[start..i]);
            start = i + 1;
        }
    }
    try result.append(s[start..]);

    return result;
}

pub fn join(slices: []const []const u8, separator: []const u8, allocator: std.mem.Allocator) ![]u8 {
    if (slices.len == 0) return try allocator.alloc(u8, 0);

    var total_len: usize = 0;
    for (slices) |slice| {
        total_len += slice.len;
    }
    total_len += separator.len * (slices.len - 1);

    const result = try allocator.alloc(u8, total_len);
    var pos: usize = 0;

    for (slices, 0..) |slice, i| {
        @memcpy(result[pos .. pos + slice.len], slice);
        pos += slice.len;
        if (i < slices.len - 1) {
            @memcpy(result[pos .. pos + separator.len], separator);
            pos += separator.len;
        }
    }

    return result;
}

pub fn startsWith(s: []const u8, prefix: []const u8) bool {
    if (prefix.len > s.len) return false;
    return std.mem.eql(u8, s[0..prefix.len], prefix);
}

pub fn endsWith(s: []const u8, suffix: []const u8) bool {
    if (suffix.len > s.len) return false;
    return std.mem.eql(u8, s[s.len - suffix.len ..], suffix);
}

pub fn contains(s: []const u8, substring: []const u8) bool {
    if (substring.len > s.len) return false;
    var i: usize = 0;
    while (i <= s.len - substring.len) : (i += 1) {
        if (std.mem.eql(u8, s[i .. i + substring.len], substring)) return true;
    }
    return false;
}

pub fn replace(s: []const u8, old: []const u8, new: []const u8, allocator: std.mem.Allocator) ![]u8 {
    if (old.len == 0) return try allocator.dupe(u8, s);

    var count: usize = 0;
    var i: usize = 0;
    while (i <= s.len - old.len) {
        if (std.mem.eql(u8, s[i .. i + old.len], old)) {
            count += 1;
            i += old.len;
        } else {
            i += 1;
        }
    }

    if (count == 0) return try allocator.dupe(u8, s);

    const new_len = s.len + count * new.len - count * old.len;
    const result = try allocator.alloc(u8, new_len);

    var src_pos: usize = 0;
    var dst_pos: usize = 0;

    while (src_pos < s.len) {
        if (src_pos <= s.len - old.len and std.mem.eql(u8, s[src_pos .. src_pos + old.len], old)) {
            @memcpy(result[dst_pos .. dst_pos + new.len], new);
            src_pos += old.len;
            dst_pos += new.len;
        } else {
            result[dst_pos] = s[src_pos];
            src_pos += 1;
            dst_pos += 1;
        }
    }

    return result;
}

test "kmpSearch" {
    const allocator = std.testing.allocator;
    const text = "ABABDABACDABABCABAB";
    const pattern = "ABABCABAB";

    var matches = try kmpSearch(text, pattern, allocator);
    defer matches.deinit();

    try std.testing.expectEqual(@as(usize, 1), matches.items.len);
    try std.testing.expectEqual(@as(usize, 10), matches.items[0]);
}

test "boyerMooreSearch" {
    const allocator = std.testing.allocator;
    const text = "HERE IS A SIMPLE EXAMPLE";
    const pattern = "EXAMPLE";

    var matches = try boyerMooreSearch(text, pattern, allocator);
    defer matches.deinit();

    try std.testing.expectEqual(@as(usize, 1), matches.items.len);
    try std.testing.expectEqual(@as(usize, 17), matches.items[0]);
}

test "levenshteinDistance" {
    const allocator = std.testing.allocator;

    const dist1 = try levenshteinDistance("kitten", "sitting", allocator);
    try std.testing.expectEqual(@as(usize, 3), dist1);

    const dist2 = try levenshteinDistance("saturday", "sunday", allocator);
    try std.testing.expectEqual(@as(usize, 3), dist2);
}

test "longestCommonSubstring" {
    const allocator = std.testing.allocator;

    const result = try longestCommonSubstring("OldSite:GeeksforGeeks.org", "NewSite:GeeksQuiz.com", allocator);
    try std.testing.expectEqual(@as(usize, 10), result.length);
}

test "longestCommonSubsequence" {
    const allocator = std.testing.allocator;

    const lcs = try longestCommonSubsequence("AGGTAB", "GXTXAYB", allocator);
    try std.testing.expectEqual(@as(usize, 4), lcs);
}

test "isPalindrome" {
    try std.testing.expect(isPalindrome("racecar"));
    try std.testing.expect(isPalindrome("a"));
    try std.testing.expect(!isPalindrome("hello"));
}

test "reverseString" {
    var s1 = [_]u8{ 'h', 'e', 'l', 'l', 'o' };
    reverseString(&s1);
    try std.testing.expectEqualStrings("olleh", &s1);
}

test "countSubstrings" {
    try std.testing.expectEqual(@as(usize, 2), countSubstrings("aaaa", "aa"));
    try std.testing.expectEqual(@as(usize, 3), countSubstrings("abcabcabc", "abc"));
}

test "hammingDistance" {
    const dist = try hammingDistance("karolin", "kathrin");
    try std.testing.expectEqual(@as(usize, 3), dist);
}

test "trim" {
    try std.testing.expectEqualStrings("hello", trim("  hello  "));
    try std.testing.expectEqualStrings("world", trim("\t\nworld\n\t"));
}

test "split" {
    const allocator = std.testing.allocator;
    var parts = try split("a,b,c,d", ',', allocator);
    defer parts.deinit();

    try std.testing.expectEqual(@as(usize, 4), parts.items.len);
    try std.testing.expectEqualStrings("a", parts.items[0]);
    try std.testing.expectEqualStrings("d", parts.items[3]);
}

test "join" {
    const allocator = std.testing.allocator;
    const parts = [_][]const u8{ "hello", "world", "zig" };
    const result = try join(&parts, " ", allocator);
    defer allocator.free(result);

    try std.testing.expectEqualStrings("hello world zig", result);
}

test "startsWith and endsWith" {
    try std.testing.expect(startsWith("hello world", "hello"));
    try std.testing.expect(!startsWith("hello world", "world"));
    try std.testing.expect(endsWith("hello world", "world"));
    try std.testing.expect(!endsWith("hello world", "hello"));
}

test "contains" {
    try std.testing.expect(contains("hello world", "lo wo"));
    try std.testing.expect(!contains("hello world", "xyz"));
}

test "replace" {
    const allocator = std.testing.allocator;
    const result = try replace("hello world hello", "hello", "hi", allocator);
    defer allocator.free(result);

    try std.testing.expectEqualStrings("hi world hi", result);
}
