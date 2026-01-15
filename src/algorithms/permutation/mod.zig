pub const permutation = @import("permutation.zig");

pub const nextPermutation = permutation.nextPermutation;
pub const nextPermutationBy = permutation.nextPermutationBy;
pub const prevPermutation = permutation.prevPermutation;
pub const prevPermutationBy = permutation.prevPermutationBy;
pub const isPermutation = permutation.isPermutation;
pub const isPermutationBy = permutation.isPermutationBy;

test {
    _ = permutation;
}
