pub const partitioning = @import("partitioning.zig");

pub const isPartitioned = partitioning.isPartitioned;
pub const partition = partitioning.partition;
pub const partitionCopy = partitioning.partitionCopy;
pub const stablePartition = partitioning.stablePartition;
pub const partitionPoint = partitioning.partitionPoint;

test {
    _ = partitioning;
}
