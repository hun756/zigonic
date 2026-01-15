pub const intervals = @import("intervals.zig");

pub const Interval = intervals.Interval;
pub const IntervalTree = intervals.IntervalTree;
pub const mergeIntervals = intervals.mergeIntervals;
pub const findOverlapping = intervals.findOverlapping;
pub const maxNonOverlapping = intervals.maxNonOverlapping;
pub const minMeetingRooms = intervals.minMeetingRooms;
pub const insertInterval = intervals.insertInterval;
pub const totalCoverage = intervals.totalCoverage;

test {
    _ = intervals;
}
