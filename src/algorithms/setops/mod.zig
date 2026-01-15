pub const setops = @import("setops.zig");

pub const merge = setops.merge;
pub const mergeBy = setops.mergeBy;
pub const inplaceMerge = setops.inplaceMerge;
pub const inplaceMergeBy = setops.inplaceMergeBy;
pub const setUnion = setops.setUnion;
pub const setUnionBy = setops.setUnionBy;
pub const setIntersection = setops.setIntersection;
pub const setIntersectionBy = setops.setIntersectionBy;
pub const setDifference = setops.setDifference;
pub const setDifferenceBy = setops.setDifferenceBy;
pub const setSymmetricDifference = setops.setSymmetricDifference;
pub const setSymmetricDifferenceBy = setops.setSymmetricDifferenceBy;
pub const includes = setops.includes;
pub const includesBy = setops.includesBy;

test {
    _ = setops;
}
