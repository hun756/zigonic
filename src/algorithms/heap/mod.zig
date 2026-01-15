pub const heap = @import("heap.zig");

pub const makeHeap = heap.makeHeap;
pub const makeHeapBy = heap.makeHeapBy;
pub const pushHeap = heap.pushHeap;
pub const pushHeapBy = heap.pushHeapBy;
pub const popHeap = heap.popHeap;
pub const popHeapBy = heap.popHeapBy;
pub const sortHeap = heap.sortHeap;
pub const sortHeapBy = heap.sortHeapBy;
pub const isHeap = heap.isHeap;
pub const isHeapBy = heap.isHeapBy;
pub const isHeapUntil = heap.isHeapUntil;
pub const isHeapUntilBy = heap.isHeapUntilBy;

test {
    _ = heap;
}
