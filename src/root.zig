const std = @import("std");

pub const core = @import("core/mod.zig");
pub const algorithms = @import("algorithms/mod.zig");
pub const iterators = @import("iterators/mod.zig");

pub const IteratorError = core.IteratorError;
pub const AccumulateError = core.AccumulateError;
pub const SearchError = core.SearchError;
pub const MemoryError = core.MemoryError;
pub const Order = core.Order;
pub const Range = core.Range;
pub const Pair = core.Pair;
pub const Tuple = core.Tuple;
pub const BifurcateResult = core.BifurcateResult;
pub const SearchResult = core.SearchResult;

pub const isIterator = core.isIterator;
pub const isComparable = core.isComparable;
pub const isNumeric = core.isNumeric;

pub const SliceIterator = iterators.SliceIterator;
pub const RangeIterator = iterators.RangeIterator;
pub const EnumerateIterator = iterators.EnumerateIterator;
pub const iter = iterators.iter;
pub const range = iterators.range;
pub const rangeFrom = iterators.rangeFrom;
pub const enumerate = iterators.enumerate;

pub const allOf = algorithms.allOf;
pub const anyOf = algorithms.anyOf;
pub const noneOf = algorithms.noneOf;
pub const countIf = algorithms.countIf;
pub const count = algorithms.count;

pub const binarySearch = algorithms.binarySearch;
pub const lowerBound = algorithms.lowerBound;
pub const upperBound = algorithms.upperBound;
pub const equalRange = algorithms.equalRange;
pub const contains = algorithms.contains;
pub const linearSearch = algorithms.linearSearch;
pub const find = algorithms.find;
pub const findIf = algorithms.findIf;

pub const accumulate = algorithms.accumulate;
pub const sum = algorithms.sum;
pub const product = algorithms.product;
pub const reduce = algorithms.reduce;
pub const bifurcate = algorithms.bifurcate;
pub const partition = algorithms.partition;
pub const map = algorithms.map;
pub const filter = algorithms.filter;

pub const maxElement = algorithms.maxElement;
pub const minElement = algorithms.minElement;
pub const minMax = algorithms.minMax;
pub const clamp = algorithms.clamp;

pub const base64 = algorithms.base64;
pub const hex = algorithms.hex;

test {
    std.testing.refAllDecls(@This());
}
