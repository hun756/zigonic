const std = @import("std");

pub const sort = @import("sort.zig");
pub const heap_sort = @import("heap_sort.zig");

pub const insertionSort = sort.insertionSort;
pub const insertionSortBy = sort.insertionSortBy;
pub const quickSort = sort.quickSort;
pub const quickSortBy = sort.quickSortBy;
pub const partialSort = sort.partialSort;
pub const partialSortBy = sort.partialSortBy;
pub const partialSortCopy = sort.partialSortCopy;
pub const partialSortCopyBy = sort.partialSortCopyBy;
pub const nthElement = sort.nthElement;
pub const nthElementBy = sort.nthElementBy;
pub const isSorted = sort.isSorted;
pub const isSortedBy = sort.isSortedBy;
pub const isSortedUntil = sort.isSortedUntil;
pub const isSortedUntilBy = sort.isSortedUntilBy;
pub const stableSort = sort.stableSort;
pub const stableSortBy = sort.stableSortBy;
pub const introSort = sort.sort;
pub const introSortBy = sort.sortBy;

pub const heapSort = heap_sort.heapSort;
pub const heapSortBy = heap_sort.heapSortBy;

test {
    std.testing.refAllDecls(@This());
}
