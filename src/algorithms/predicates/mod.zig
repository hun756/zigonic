pub const all_of = @import("all_of.zig");
pub const any_of = @import("any_of.zig");
pub const count_mod = @import("count.zig");

pub const allOf = all_of.allOf;
pub const allOfComptime = all_of.allOfComptime;
pub const allOfWithContext = all_of.allOfWithContext;

pub const anyOf = any_of.anyOf;
pub const anyOfComptime = any_of.anyOfComptime;
pub const anyOfWithContext = any_of.anyOfWithContext;
pub const noneOf = any_of.noneOf;

pub const countIf = count_mod.countIf;
pub const countIfNot = count_mod.countIfNot;
pub const count = count_mod.count;

test {
    @import("std").testing.refAllDecls(@This());
}
