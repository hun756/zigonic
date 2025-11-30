pub const accumulate_mod = @import("accumulate.zig");
pub const bifurcate_mod = @import("bifurcate.zig");
pub const map_filter_mod = @import("map_filter.zig");

pub const accumulate = accumulate_mod.accumulate;
pub const accumulateChecked = accumulate_mod.accumulateChecked;
pub const sum = accumulate_mod.sum;
pub const sumChecked = accumulate_mod.sumChecked;
pub const product = accumulate_mod.product;
pub const productChecked = accumulate_mod.productChecked;
pub const reduce = accumulate_mod.reduce;

pub const bifurcate = bifurcate_mod.bifurcate;
pub const bifurcateWithContext = bifurcate_mod.bifurcateWithContext;
pub const partition = bifurcate_mod.partition;
pub const BifurcateResult = bifurcate_mod.BifurcateResult;

pub const map = map_filter_mod.map;
pub const mapInPlace = map_filter_mod.mapInPlace;
pub const filter = map_filter_mod.filter;
pub const filterMap = map_filter_mod.filterMap;
pub const flatMap = map_filter_mod.flatMap;

test {
    @import("std").testing.refAllDecls(@This());
}
