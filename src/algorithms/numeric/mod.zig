pub const numeric = @import("numeric.zig");

pub const iota = numeric.iota;
pub const partialSum = numeric.partialSum;
pub const adjacentDifference = numeric.adjacentDifference;
pub const innerProduct = numeric.innerProduct;
pub const gcd = numeric.gcd;
pub const lcm = numeric.lcm;
pub const reduce = numeric.reduce;
pub const exclusiveScan = numeric.exclusiveScan;
pub const inclusiveScan = numeric.inclusiveScan;
pub const transformReduce = numeric.transformReduce;
pub const transformExclusiveScan = numeric.transformExclusiveScan;
pub const transformInclusiveScan = numeric.transformInclusiveScan;
pub const midpoint = numeric.midpoint;

test {
    _ = numeric;
}
