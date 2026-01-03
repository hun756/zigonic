pub const minmax = @import("minmax.zig");

pub const maxElement = minmax.maxElement;
pub const maxElementBy = minmax.maxElementBy;
pub const minElement = minmax.minElement;
pub const minElementBy = minmax.minElementBy;
pub const minMax = minmax.minMax;
pub const minMaxByIdx = minmax.minMaxByIdx;
pub const clamp = minmax.clamp;
pub const min = minmax.min;
pub const max = minmax.max;
pub const minBy = minmax.minBy;
pub const maxBy = minmax.maxBy;

test {
    @import("std").testing.refAllDecls(@This());
}
