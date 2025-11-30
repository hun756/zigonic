pub const errors = @import("errors.zig");
pub const traits = @import("traits.zig");
pub const types = @import("types.zig");

pub const IteratorError = errors.IteratorError;
pub const AccumulateError = errors.AccumulateError;
pub const SearchError = errors.SearchError;
pub const MemoryError = errors.MemoryError;
pub const AlgorithmError = errors.AlgorithmError;

pub const Order = types.Order;
pub const Range = types.Range;
pub const Pair = types.Pair;
pub const Tuple = types.Tuple;
pub const BifurcateResult = types.BifurcateResult;
pub const SearchResult = types.SearchResult;

pub const isIterator = traits.isIterator;
pub const isComparable = traits.isComparable;
pub const isNumeric = traits.isNumeric;
pub const assertIterator = traits.assertIterator;
pub const assertComparable = traits.assertComparable;
pub const assertNumeric = traits.assertNumeric;

test {
    @import("std").testing.refAllDecls(@This());
}
