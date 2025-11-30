pub const predicates = @import("predicates/mod.zig");
pub const searching = @import("searching/mod.zig");
pub const transforming = @import("transforming/mod.zig");
pub const comparison = @import("comparison/mod.zig");
pub const encoding = @import("encoding/mod.zig");

pub const allOf = predicates.allOf;
pub const allOfComptime = predicates.allOfComptime;
pub const anyOf = predicates.anyOf;
pub const anyOfComptime = predicates.anyOfComptime;
pub const noneOf = predicates.noneOf;
pub const countIf = predicates.countIf;
pub const count = predicates.count;

pub const binarySearch = searching.binarySearch;
pub const binarySearchBy = searching.binarySearchBy;
pub const lowerBound = searching.lowerBound;
pub const upperBound = searching.upperBound;
pub const equalRange = searching.equalRange;
pub const contains = searching.contains;
pub const linearSearch = searching.linearSearch;
pub const find = searching.find;
pub const findIf = searching.findIf;

pub const accumulate = transforming.accumulate;
pub const sum = transforming.sum;
pub const sumChecked = transforming.sumChecked;
pub const product = transforming.product;
pub const reduce = transforming.reduce;
pub const bifurcate = transforming.bifurcate;
pub const partition = transforming.partition;
pub const map = transforming.map;
pub const filter = transforming.filter;
pub const filterMap = transforming.filterMap;

pub const maxElement = comparison.maxElement;
pub const maxElementBy = comparison.maxElementBy;
pub const minElement = comparison.minElement;
pub const minElementBy = comparison.minElementBy;
pub const minMax = comparison.minMax;
pub const clamp = comparison.clamp;

pub const base64 = encoding.base64;
pub const hex = encoding.hex;

test {
    @import("std").testing.refAllDecls(@This());
}
