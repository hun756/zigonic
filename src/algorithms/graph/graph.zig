const std = @import("std");

pub fn AdjacencyList(comptime T: type) type {
    return struct {
        const Self = @This();

        edges: std.ArrayList(std.ArrayList(Edge)),
        allocator: std.mem.Allocator,
        node_count: usize,

        pub const Edge = struct {
            to: usize,
            weight: T,
        };

        pub fn init(allocator: std.mem.Allocator, node_count: usize) !Self {
            var edges = std.ArrayList(std.ArrayList(Edge)).init(allocator);
            try edges.resize(node_count);
            for (edges.items) |*list| {
                list.* = std.ArrayList(Edge).init(allocator);
            }
            return Self{
                .edges = edges,
                .allocator = allocator,
                .node_count = node_count,
            };
        }

        pub fn deinit(self: *Self) void {
            for (self.edges.items) |*list| {
                list.deinit();
            }
            self.edges.deinit();
        }

        pub fn addEdge(self: *Self, from: usize, to: usize, weight: T) !void {
            try self.edges.items[from].append(.{ .to = to, .weight = weight });
        }

        pub fn addBidirectionalEdge(self: *Self, from: usize, to: usize, weight: T) !void {
            try self.addEdge(from, to, weight);
            try self.addEdge(to, from, weight);
        }

        pub fn getNeighbors(self: *const Self, node: usize) []const Edge {
            return self.edges.items[node].items;
        }
    };
}

pub fn bfs(
    comptime T: type,
    graph: *const AdjacencyList(T),
    start: usize,
    allocator: std.mem.Allocator,
) !struct { distances: []i64, parents: []?usize } {
    const n = graph.node_count;
    const distances = try allocator.alloc(i64, n);
    const parents = try allocator.alloc(?usize, n);
    errdefer allocator.free(distances);
    errdefer allocator.free(parents);

    @memset(distances, -1);
    @memset(parents, null);

    var queue = std.ArrayList(usize).init(allocator);
    defer queue.deinit();

    distances[start] = 0;
    try queue.append(start);

    var front: usize = 0;
    while (front < queue.items.len) {
        const current = queue.items[front];
        front += 1;

        for (graph.getNeighbors(current)) |edge| {
            if (distances[edge.to] == -1) {
                distances[edge.to] = distances[current] + 1;
                parents[edge.to] = current;
                try queue.append(edge.to);
            }
        }
    }

    return .{ .distances = distances, .parents = parents };
}

pub fn dfs(
    comptime T: type,
    graph: *const AdjacencyList(T),
    start: usize,
    allocator: std.mem.Allocator,
) !struct { discovery: []i32, finish: []i32, parents: []?usize } {
    const n = graph.node_count;
    const discovery = try allocator.alloc(i32, n);
    const finish = try allocator.alloc(i32, n);
    const parents = try allocator.alloc(?usize, n);
    errdefer allocator.free(discovery);
    errdefer allocator.free(finish);
    errdefer allocator.free(parents);

    @memset(discovery, -1);
    @memset(finish, -1);
    @memset(parents, null);

    var time: i32 = 0;
    var stack = std.ArrayList(struct { node: usize, state: enum { enter, exit } }).init(allocator);
    defer stack.deinit();

    try stack.append(.{ .node = start, .state = .enter });

    while (stack.items.len > 0) {
        const item = stack.pop();

        if (item.state == .enter) {
            if (discovery[item.node] != -1) continue;
            discovery[item.node] = time;
            time += 1;
            try stack.append(.{ .node = item.node, .state = .exit });

            const neighbors = graph.getNeighbors(item.node);
            var i = neighbors.len;
            while (i > 0) {
                i -= 1;
                const neighbor = neighbors[i].to;
                if (discovery[neighbor] == -1) {
                    parents[neighbor] = item.node;
                    try stack.append(.{ .node = neighbor, .state = .enter });
                }
            }
        } else {
            finish[item.node] = time;
            time += 1;
        }
    }

    return .{ .discovery = discovery, .finish = finish, .parents = parents };
}

pub fn dijkstra(
    comptime T: type,
    graph: *const AdjacencyList(T),
    start: usize,
    allocator: std.mem.Allocator,
) !struct { distances: []T, parents: []?usize } {
    const n = graph.node_count;
    const distances = try allocator.alloc(T, n);
    const parents = try allocator.alloc(?usize, n);
    errdefer allocator.free(distances);
    errdefer allocator.free(parents);

    @memset(distances, std.math.maxInt(T));
    @memset(parents, null);

    const PQItem = struct {
        distance: T,
        node: usize,

        fn lessThan(_: void, a: @This(), b: @This()) std.math.Order {
            return std.math.order(a.distance, b.distance);
        }
    };

    var pq = std.PriorityQueue(PQItem, void, PQItem.lessThan).init(allocator, {});
    defer pq.deinit();

    distances[start] = 0;
    try pq.add(.{ .distance = 0, .node = start });

    while (pq.count() > 0) {
        const current = pq.remove();

        if (current.distance > distances[current.node]) continue;

        for (graph.getNeighbors(current.node)) |edge| {
            const new_dist = distances[current.node] + edge.weight;
            if (new_dist < distances[edge.to]) {
                distances[edge.to] = new_dist;
                parents[edge.to] = current.node;
                try pq.add(.{ .distance = new_dist, .node = edge.to });
            }
        }
    }

    return .{ .distances = distances, .parents = parents };
}

pub fn bellmanFord(
    comptime T: type,
    graph: *const AdjacencyList(T),
    start: usize,
    allocator: std.mem.Allocator,
) !?struct { distances: []T, parents: []?usize } {
    const n = graph.node_count;
    const distances = try allocator.alloc(T, n);
    const parents = try allocator.alloc(?usize, n);
    errdefer allocator.free(distances);
    errdefer allocator.free(parents);

    @memset(distances, std.math.maxInt(T) / 2);
    @memset(parents, null);
    distances[start] = 0;

    for (0..n - 1) |_| {
        for (0..n) |u| {
            if (distances[u] == std.math.maxInt(T) / 2) continue;
            for (graph.getNeighbors(u)) |edge| {
                const new_dist = distances[u] + edge.weight;
                if (new_dist < distances[edge.to]) {
                    distances[edge.to] = new_dist;
                    parents[edge.to] = u;
                }
            }
        }
    }

    for (0..n) |u| {
        if (distances[u] == std.math.maxInt(T) / 2) continue;
        for (graph.getNeighbors(u)) |edge| {
            if (distances[u] + edge.weight < distances[edge.to]) {
                allocator.free(distances);
                allocator.free(parents);
                return null;
            }
        }
    }

    return .{ .distances = distances, .parents = parents };
}

pub fn topologicalSort(
    comptime T: type,
    graph: *const AdjacencyList(T),
    allocator: std.mem.Allocator,
) !?[]usize {
    const n = graph.node_count;
    const in_degree = try allocator.alloc(usize, n);
    defer allocator.free(in_degree);
    @memset(in_degree, 0);

    for (0..n) |u| {
        for (graph.getNeighbors(u)) |edge| {
            in_degree[edge.to] += 1;
        }
    }

    var queue = std.ArrayList(usize).init(allocator);
    defer queue.deinit();

    for (0..n) |i| {
        if (in_degree[i] == 0) {
            try queue.append(i);
        }
    }

    const result = try allocator.alloc(usize, n);
    errdefer allocator.free(result);
    var idx: usize = 0;

    var front: usize = 0;
    while (front < queue.items.len) {
        const u = queue.items[front];
        front += 1;
        result[idx] = u;
        idx += 1;

        for (graph.getNeighbors(u)) |edge| {
            in_degree[edge.to] -= 1;
            if (in_degree[edge.to] == 0) {
                try queue.append(edge.to);
            }
        }
    }

    if (idx != n) {
        allocator.free(result);
        return null; // Cycle detected
    }

    return result;
}

pub fn hasCycle(comptime T: type, graph: *const AdjacencyList(T), allocator: std.mem.Allocator) !bool {
    const n = graph.node_count;

    const Color = enum { white, gray, black };
    const colors = try allocator.alloc(Color, n);
    defer allocator.free(colors);
    @memset(colors, .white);

    var stack = std.ArrayList(struct { node: usize, neighbor_idx: usize }).init(allocator);
    defer stack.deinit();

    for (0..n) |start| {
        if (colors[start] != .white) continue;

        try stack.append(.{ .node = start, .neighbor_idx = 0 });
        colors[start] = .gray;

        while (stack.items.len > 0) {
            const current = &stack.items[stack.items.len - 1];
            const neighbors = graph.getNeighbors(current.node);

            if (current.neighbor_idx < neighbors.len) {
                const neighbor = neighbors[current.neighbor_idx].to;
                current.neighbor_idx += 1;

                if (colors[neighbor] == .gray) {
                    return true;
                } else if (colors[neighbor] == .white) {
                    colors[neighbor] = .gray;
                    try stack.append(.{ .node = neighbor, .neighbor_idx = 0 });
                }
            } else {
                colors[current.node] = .black;
                _ = stack.pop();
            }
        }
    }

    return false;
}

pub fn stronglyConnectedComponents(
    comptime T: type,
    graph: *const AdjacencyList(T),
    allocator: std.mem.Allocator,
) ![][]usize {
    const n = graph.node_count;

    const visited = try allocator.alloc(bool, n);
    defer allocator.free(visited);
    @memset(visited, false);

    var order = std.ArrayList(usize).init(allocator);
    defer order.deinit();

    for (0..n) |i| {
        if (!visited[i]) {
            try dfsOrder(T, graph, i, visited, &order);
        }
    }

    var transpose = try AdjacencyList(T).init(allocator, n);
    defer transpose.deinit();

    for (0..n) |u| {
        for (graph.getNeighbors(u)) |edge| {
            try transpose.addEdge(edge.to, u, edge.weight);
        }
    }

    @memset(visited, false);
    var components = std.ArrayList([]usize).init(allocator);
    errdefer {
        for (components.items) |comp| {
            allocator.free(comp);
        }
        components.deinit();
    }

    var i = order.items.len;
    while (i > 0) {
        i -= 1;
        const node = order.items[i];
        if (!visited[node]) {
            var component = std.ArrayList(usize).init(allocator);
            try dfsCollect(T, &transpose, node, visited, &component);
            try components.append(try component.toOwnedSlice());
        }
    }

    return components.toOwnedSlice();
}

fn dfsOrder(
    comptime T: type,
    graph: *const AdjacencyList(T),
    node: usize,
    visited: []bool,
    order: *std.ArrayList(usize),
) !void {
    visited[node] = true;
    for (graph.getNeighbors(node)) |edge| {
        if (!visited[edge.to]) {
            try dfsOrder(T, graph, edge.to, visited, order);
        }
    }
    try order.append(node);
}

fn dfsCollect(
    comptime T: type,
    graph: *AdjacencyList(T),
    node: usize,
    visited: []bool,
    component: *std.ArrayList(usize),
) !void {
    visited[node] = true;
    try component.append(node);
    for (graph.getNeighbors(node)) |edge| {
        if (!visited[edge.to]) {
            try dfsCollect(T, graph, edge.to, visited, component);
        }
    }
}

pub fn primMST(
    comptime T: type,
    graph: *const AdjacencyList(T),
    allocator: std.mem.Allocator,
) !struct { edges: []struct { from: usize, to: usize, weight: T }, total_weight: T } {
    const n = graph.node_count;
    if (n == 0) return .{ .edges = &[_]struct { from: usize, to: usize, weight: T }{}, .total_weight = 0 };

    const in_mst = try allocator.alloc(bool, n);
    defer allocator.free(in_mst);
    @memset(in_mst, false);

    const PQItem = struct {
        weight: T,
        node: usize,
        parent: ?usize,

        fn lessThan(_: void, a: @This(), b: @This()) std.math.Order {
            return std.math.order(a.weight, b.weight);
        }
    };

    var pq = std.PriorityQueue(PQItem, void, PQItem.lessThan).init(allocator, {});
    defer pq.deinit();

    var mst_edges = std.ArrayList(struct { from: usize, to: usize, weight: T }).init(allocator);
    errdefer mst_edges.deinit();

    var total_weight: T = 0;

    try pq.add(.{ .weight = 0, .node = 0, .parent = null });

    while (pq.count() > 0) {
        const current = pq.remove();

        if (in_mst[current.node]) continue;
        in_mst[current.node] = true;

        if (current.parent) |p| {
            try mst_edges.append(.{ .from = p, .to = current.node, .weight = current.weight });
            total_weight += current.weight;
        }

        for (graph.getNeighbors(current.node)) |edge| {
            if (!in_mst[edge.to]) {
                try pq.add(.{ .weight = edge.weight, .node = edge.to, .parent = current.node });
            }
        }
    }

    return .{ .edges = try mst_edges.toOwnedSlice(), .total_weight = total_weight };
}

test "bfs" {
    const allocator = std.testing.allocator;
    var graph = try AdjacencyList(i32).init(allocator, 5);
    defer graph.deinit();

    try graph.addBidirectionalEdge(0, 1, 1);
    try graph.addBidirectionalEdge(0, 2, 1);
    try graph.addBidirectionalEdge(1, 3, 1);
    try graph.addBidirectionalEdge(2, 4, 1);

    const result = try bfs(i32, &graph, 0, allocator);
    defer allocator.free(result.distances);
    defer allocator.free(result.parents);

    try std.testing.expectEqual(@as(i64, 0), result.distances[0]);
    try std.testing.expectEqual(@as(i64, 1), result.distances[1]);
    try std.testing.expectEqual(@as(i64, 2), result.distances[3]);
}

test "dijkstra" {
    const allocator = std.testing.allocator;
    var graph = try AdjacencyList(u32).init(allocator, 4);
    defer graph.deinit();

    try graph.addEdge(0, 1, 1);
    try graph.addEdge(0, 2, 4);
    try graph.addEdge(1, 2, 2);
    try graph.addEdge(2, 3, 1);

    const result = try dijkstra(u32, &graph, 0, allocator);
    defer allocator.free(result.distances);
    defer allocator.free(result.parents);

    try std.testing.expectEqual(@as(u32, 0), result.distances[0]);
    try std.testing.expectEqual(@as(u32, 1), result.distances[1]);
    try std.testing.expectEqual(@as(u32, 3), result.distances[2]);
    try std.testing.expectEqual(@as(u32, 4), result.distances[3]);
}

test "topologicalSort" {
    const allocator = std.testing.allocator;
    var graph = try AdjacencyList(i32).init(allocator, 4);
    defer graph.deinit();

    try graph.addEdge(0, 1, 1);
    try graph.addEdge(0, 2, 1);
    try graph.addEdge(1, 3, 1);
    try graph.addEdge(2, 3, 1);

    const result = try topologicalSort(i32, &graph, allocator);
    try std.testing.expect(result != null);
    defer allocator.free(result.?);

    var positions: [4]usize = undefined;
    for (result.?, 0..) |node, i| {
        positions[node] = i;
    }
    try std.testing.expect(positions[0] < positions[1]);
    try std.testing.expect(positions[0] < positions[2]);
    try std.testing.expect(positions[1] < positions[3]);
}

test "hasCycle" {
    const allocator = std.testing.allocator;

    var acyclic = try AdjacencyList(i32).init(allocator, 3);
    defer acyclic.deinit();
    try acyclic.addEdge(0, 1, 1);
    try acyclic.addEdge(1, 2, 1);
    try std.testing.expect(!try hasCycle(i32, &acyclic, allocator));

    var cyclic = try AdjacencyList(i32).init(allocator, 3);
    defer cyclic.deinit();
    try cyclic.addEdge(0, 1, 1);
    try cyclic.addEdge(1, 2, 1);
    try cyclic.addEdge(2, 0, 1);
    try std.testing.expect(try hasCycle(i32, &cyclic, allocator));
}
