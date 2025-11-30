const std = @import("std");

pub fn isIterator(comptime T: type) bool {
    const info = @typeInfo(T);
    if (info != .@"struct") return false;

    if (!@hasDecl(T, "next")) return false;

    const next_info = @typeInfo(@TypeOf(@field(T, "next")));
    if (next_info != .@"fn") return false;

    const return_type = next_info.@"fn".return_type orelse return false;
    return @typeInfo(return_type) == .optional;
}

pub fn isBidirectionalIterator(comptime T: type) bool {
    if (!isIterator(T)) return false;
    return @hasDecl(T, "prev");
}

pub fn isRandomAccessIterator(comptime T: type) bool {
    if (!isBidirectionalIterator(T)) return false;
    return @hasDecl(T, "get") and @hasDecl(T, "len");
}

pub fn isComparable(comptime T: type) bool {
    const info = @typeInfo(T);
    return switch (info) {
        .int, .float, .comptime_int, .comptime_float => true,
        .@"enum" => true,
        .pointer => |ptr| ptr.size == .one or ptr.size == .slice,
        .@"struct" => @hasDecl(T, "cmp") or @hasDecl(T, "lessThan"),
        else => false,
    };
}

pub fn isNumeric(comptime T: type) bool {
    const info = @typeInfo(T);
    return switch (info) {
        .int, .float, .comptime_int, .comptime_float => true,
        else => false,
    };
}

pub fn isInteger(comptime T: type) bool {
    return @typeInfo(T) == .int or @typeInfo(T) == .comptime_int;
}

pub fn isFloat(comptime T: type) bool {
    return @typeInfo(T) == .float or @typeInfo(T) == .comptime_float;
}

pub fn isSigned(comptime T: type) bool {
    const info = @typeInfo(T);
    return switch (info) {
        .int => |i| i.signedness == .signed,
        .comptime_int => true,
        .float, .comptime_float => true,
        else => false,
    };
}

pub fn ElementType(comptime T: type) type {
    const info = @typeInfo(T);
    return switch (info) {
        .pointer => |ptr| ptr.child,
        .array => |arr| arr.child,
        else => @compileError("Expected slice or array type, got " ++ @typeName(T)),
    };
}

pub fn isPredicate(comptime F: type, comptime T: type) bool {
    const info = @typeInfo(F);
    if (info != .@"fn") return false;

    const fn_info = info.@"fn";
    if (fn_info.params.len != 1) return false;
    if (fn_info.params[0].type != T) return false;

    const return_type = fn_info.return_type orelse return false;
    return return_type == bool;
}

pub fn isBinaryPredicate(comptime F: type, comptime T: type) bool {
    const info = @typeInfo(F);
    if (info != .@"fn") return false;

    const fn_info = info.@"fn";
    if (fn_info.params.len != 2) return false;
    if (fn_info.params[0].type != T) return false;
    if (fn_info.params[1].type != T) return false;

    const return_type = fn_info.return_type orelse return false;
    return return_type == bool;
}

pub fn isComparator(comptime F: type, comptime T: type) bool {
    const info = @typeInfo(F);
    if (info != .@"fn") return false;

    const fn_info = info.@"fn";
    if (fn_info.params.len != 2) return false;
    if (fn_info.params[0].type != T) return false;
    if (fn_info.params[1].type != T) return false;

    const return_type = fn_info.return_type orelse return false;
    return return_type == std.math.Order;
}

pub fn assertIterator(comptime T: type) void {
    if (!isIterator(T)) {
        @compileError("Type '" ++ @typeName(T) ++ "' does not implement Iterator interface. " ++
            "An Iterator must have a 'next() ?ItemType' method.");
    }
}

pub fn assertComparable(comptime T: type) void {
    if (!isComparable(T)) {
        @compileError("Type '" ++ @typeName(T) ++ "' is not comparable. " ++
            "Implement 'cmp' or 'lessThan' method for custom types.");
    }
}

pub fn assertNumeric(comptime T: type) void {
    if (!isNumeric(T)) {
        @compileError("Type '" ++ @typeName(T) ++ "' is not a numeric type.");
    }
}

test "isNumeric" {
    try std.testing.expect(isNumeric(i32));
    try std.testing.expect(isNumeric(f64));
    try std.testing.expect(isNumeric(u8));
    try std.testing.expect(!isNumeric([]u8));
    try std.testing.expect(!isNumeric(bool));
}

test "isComparable" {
    try std.testing.expect(isComparable(i32));
    try std.testing.expect(isComparable(f64));

    const ComparableStruct = struct {
        value: i32,
        pub fn cmp(_: @This(), _: @This()) std.math.Order {
            return .eq;
        }
    };
    try std.testing.expect(isComparable(ComparableStruct));
}

test "ElementType" {
    try std.testing.expect(ElementType([]const u8) == u8);
    try std.testing.expect(ElementType([5]i32) == i32);
}
