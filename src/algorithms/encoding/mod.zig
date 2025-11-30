pub const base64_mod = @import("base64.zig");
pub const hex_mod = @import("hex.zig");

pub const base64 = struct {
    pub const encode = base64_mod.encode;
    pub const decode = base64_mod.decode;
    pub const encodeToBuffer = base64_mod.encodeToBuffer;
    pub const decodeToBuffer = base64_mod.decodeToBuffer;
};

pub const hex = struct {
    pub const encode = hex_mod.encodeHex;
    pub const encodeUpper = hex_mod.encodeHexUpper;
    pub const decode = hex_mod.decodeHex;
};

test {
    @import("std").testing.refAllDecls(@This());
}
