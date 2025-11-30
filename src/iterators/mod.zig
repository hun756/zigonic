pub const slice_iterator = @import("slice_iterator.zig");
pub const range_iterator = @import("range_iterator.zig");
pub const enumerate_iterator = @import("enumerate_iterator.zig");

pub const SliceIterator = slice_iterator.SliceIterator;
pub const RangeIterator = range_iterator.RangeIterator;
pub const EnumerateIterator = enumerate_iterator.EnumerateIterator;

pub const iter = slice_iterator.iter;
pub const iterArray = slice_iterator.iterArray;
pub const range = range_iterator.range;
pub const rangeFrom = range_iterator.rangeFrom;
pub const rangeStep = range_iterator.rangeStep;
pub const enumerate = enumerate_iterator.enumerate;

test {
    @import("std").testing.refAllDecls(@This());
}
