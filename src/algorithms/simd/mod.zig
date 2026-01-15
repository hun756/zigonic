pub const simd = @import("simd.zig");

pub const simdFill = simd.simdFill;
pub const simdSum = simd.simdSum;
pub const simdDotProduct = simd.simdDotProduct;
pub const simdMin = simd.simdMin;
pub const simdMax = simd.simdMax;
pub const simdEqual = simd.simdEqual;
pub const simdContains = simd.simdContains;
pub const simdAdd = simd.simdAdd;
pub const simdMul = simd.simdMul;
pub const blockTranspose = simd.blockTranspose;

test {
    _ = simd;
}
