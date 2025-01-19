const algorithms = struct {
    pub const allOf = @import("algorithms/all_of.zig").allOf;
    pub const anyOf = @import("algorithms/any_of.zig").anyOf;
    pub const maxElement = @import("algorithms/max_element.zig").maxElement;
    pub const binarySearch = @import("algorithms/binary_search.zig").binarySearch;
    pub const accumulate = @import("algorithms/accumulate.zig");
    pub const bifurcateBy = @import("algorithms/bifurcate_by.zig").bifurcateBy;
    pub const btoa = @import("algorithms/btoa.zig").btoa;
};

pub usingnamespace algorithms;
