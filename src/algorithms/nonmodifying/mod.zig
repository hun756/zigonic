pub const nonmodifying = @import("nonmodifying.zig");

pub const findIfNot = nonmodifying.findIfNot;
pub const findFirstOf = nonmodifying.findFirstOf;
pub const adjacentFind = nonmodifying.adjacentFind;
pub const adjacentFindBy = nonmodifying.adjacentFindBy;
pub const mismatch = nonmodifying.mismatch;
pub const mismatchBy = nonmodifying.mismatchBy;
pub const equal = nonmodifying.equal;
pub const equalBy = nonmodifying.equalBy;
pub const search = nonmodifying.search;
pub const searchN = nonmodifying.searchN;
pub const findEnd = nonmodifying.findEnd;
pub const lexicographicalCompare = nonmodifying.lexicographicalCompare;
pub const forEach = nonmodifying.forEach;
pub const forEachN = nonmodifying.forEachN;

test {
    _ = nonmodifying;
}
