pub const binary_search = @import("binary_search.zig");
pub const linear_search = @import("linear_search.zig");

pub const binarySearch = binary_search.binarySearch;
pub const binarySearchBy = binary_search.binarySearchBy;
pub const lowerBound = binary_search.lowerBound;
pub const lowerBoundBy = binary_search.lowerBoundBy;
pub const upperBound = binary_search.upperBound;
pub const upperBoundBy = binary_search.upperBoundBy;
pub const equalRange = binary_search.equalRange;
pub const contains = binary_search.contains;

pub const linearSearch = linear_search.linearSearch;
pub const linearSearchBy = linear_search.linearSearchBy;
pub const find = linear_search.find;
pub const findIf = linear_search.findIf;
pub const findLast = linear_search.findLast;

test {
    @import("std").testing.refAllDecls(@This());
}
