pub const parallel = @import("parallel.zig");

pub const ParallelConfig = parallel.ParallelConfig;
pub const default_config = parallel.default_config;

pub const parallelFor = parallel.parallelFor;
pub const parallelForEach = parallel.parallelForEach;
pub const parallelReduce = parallel.parallelReduce;
pub const parallelTransform = parallel.parallelTransform;
pub const parallelSort = parallel.parallelSort;
pub const parallelSortDefault = parallel.parallelSortDefault;
pub const parallelFind = parallel.parallelFind;
pub const parallelCount = parallel.parallelCount;
pub const parallelCountIf = parallel.parallelCountIf;
pub const parallelAllOf = parallel.parallelAllOf;
pub const parallelAnyOf = parallel.parallelAnyOf;
pub const parallelNoneOf = parallel.parallelNoneOf;
pub const parallelFill = parallel.parallelFill;
pub const parallelCopy = parallel.parallelCopy;
pub const parallelMinElement = parallel.parallelMinElement;
pub const parallelMaxElement = parallel.parallelMaxElement;
pub const parallelReplace = parallel.parallelReplace;
pub const parallelReplaceIf = parallel.parallelReplaceIf;
pub const parallelEqual = parallel.parallelEqual;
pub const parallelIota = parallel.parallelIota;
pub const parallelAdjacentDifference = parallel.parallelAdjacentDifference;
pub const parallelInnerProduct = parallel.parallelInnerProduct;
