# Zigonic

**Zigonic** is a comprehensive, production-ready algorithm library for Zig, featuring highly optimized implementations of algorithms and data structures from multiple programming paradigms.

## 🚀 Features

### Core Algorithm Categories
- **STL-style Algorithms** (~95% C++ STL coverage)
  - Predicates, searching, sorting, transforming
  - Set operations, heap operations, permutations
  - Modifying & non-modifying sequence operations
  
- **Parallel Algorithms**
  - Thread-pool based parallel execution
  - Parallel sorting, searching, reduction operations
  - Fine-grained control over parallelism

### Advanced Modules

#### 📐 Math & Number Theory
- GCD, LCM (Euclidean & Binary algorithms)
- Prime operations (Miller-Rabin, Sieve of Eratosthenes)
- Modular arithmetic (modPow, modInverse, Chinese Remainder)
- Number theory functions (Euler's totient, Möbius function)
- Combinatorics (Fibonacci, binomial, Catalan numbers)

#### 🌐 Graph Algorithms
- BFS, DFS traversals
- Shortest path (Dijkstra, Bellman-Ford)
- Topological sort, cycle detection
- Strongly connected components (Kosaraju)
- Minimum spanning tree (Prim's algorithm)

#### 📊 Data Structures
- **UnionFind** (Disjoint Set Union with path compression)
- **BloomFilter** (Space-efficient probabilistic set membership)
- **LRU Cache** (O(1) get/put operations)
- **Skip List** (O(log n) average operations)
- **Trie** (Prefix tree for string operations)

#### 🗜️ Compression Algorithms
- Run-Length Encoding (RLE)
- Delta encoding/decoding
- Variable-Length Quantity (VLQ)
- LZ77 compression
- Burrows-Wheeler Transform (BWT)
- Move-to-Front Transform (MTF)

#### 💾 Memory Utilities
- **Ring Buffer** (Lock-free circular buffer)
- **Object Pool** (Reusable object allocation)
- **Slab Allocator** (Fixed-size block allocation)
- **Bump Allocator** (Ultra-fast linear allocation)
- **Deque** (Double-ended queue)

#### ⏱️ Interval Algorithms
- Interval operations (merge, overlap, intersection)
- Interval Tree (O(log n) queries)
- Maximum non-overlapping intervals
- Minimum meeting rooms (interval partitioning)

#### ⚡ SIMD Optimizations
- SIMD-optimized sum, min, max
- SIMD dot product
- SIMD element-wise operations
- Cache-friendly block transpose

#### 🔤 String Algorithms
- Pattern matching (KMP, Boyer-Moore, Rabin-Karp)
- Edit distance (Levenshtein, Hamming)
- Longest common substring/subsequence
- String utilities (trim, split, join)

#### 🔢 Bitwise Operations
- Bit counting (popcount, clz, ctz)
- Bit manipulation (set, clear, toggle, extract)
- Power operations (isPowerOfTwo, nextPowerOfTwo)
- Rotation, reversal, Gray code

#### 🔐 Hashing & Checksums
- Hash functions (FNV-1a, DJB2, MurmurHash3, xxHash32)
- Checksums (CRC32, CRC16, Adler32, Fletcher)
- Utilities (hashCombine, hashSlice)

#### 🎯 Functional Programming
- Function composition (compose, pipe)
- Higher-order functions (zipWith, scanLeft/Right)
- List operations (takeWhile, dropWhile, chunks, windows)
- Transformations (flatten, transpose, groupBy)

## 📦 Installation

Add to your `build.zig.zon`:

```zig
.{
    .name = "your-project",
    .version = "0.1.0",
    .dependencies = .{
        .zigonic = .{
            .url = "https://github.com/hun756/zigonic/archive/<commit-hash>.tar.gz",
        },
    },
}
```

## 🔧 Usage Examples

### Basic Algorithms
```zig
const zigonic = @import("zigonic");

// Searching
const arr = [_]i32{ 1, 2, 3, 4, 5 };
const result = zigonic.binarySearch(i32, &arr, 3);

// Sorting
var data = [_]i32{ 5, 2, 8, 1, 9 };
zigonic.sort(i32, &data);

// Accumulation
const sum = zigonic.sum(i32, &arr);
```

### Math & Number Theory
```zig
// Prime checking (Miller-Rabin)
const is_prime = zigonic.isPrime(104729);

// GCD & LCM
const g = zigonic.gcd(u32, 48, 18);
const l = zigonic.lcm(u32, 12, 18);

// Modular arithmetic
const result = zigonic.modPow(4, 13, 497);

// Fibonacci (O(log n))
const fib = zigonic.fibonacci(50);
```

### Graph Algorithms
```zig
const allocator = std.heap.page_allocator;
var graph = try zigonic.AdjacencyList(u32).init(allocator, 5);
defer graph.deinit();

try graph.addEdge(0, 1, 10);
try graph.addEdge(1, 2, 5);

const result = try zigonic.dijkstra(u32, &graph, 0, allocator);
defer allocator.free(result.distances);
defer allocator.free(result.parents);
```

### Data Structures
```zig
// LRU Cache
var cache = zigonic.LRUCache(u32, []const u8).init(allocator, 100);
defer cache.deinit();

try cache.put(1, "value1");
const value = cache.get(1);

// Bloom Filter
var bloom = try zigonic.BloomFilter(5).init(allocator, 1000, 0.01);
defer bloom.deinit();

bloom.add("hello");
const might_contain = bloom.mightContain("hello");
```

### SIMD Operations
```zig
var data = [_]f32{ 1.0, 2.0, 3.0, 4.0 };
const sum = zigonic.simdSum(f32, &data);
const min = zigonic.simdMin(f32, &data);
const max = zigonic.simdMax(f32, &data);
```

### Compression
```zig
const original = "AAABBBCCCC";
const encoded = try zigonic.rleEncode(allocator, original);
defer allocator.free(encoded);

const decoded = try zigonic.rleDecode(allocator, encoded);
defer allocator.free(decoded);
```

## 🎯 Performance

Zigonic is designed with performance as a top priority:
- **SIMD optimizations** for numerical operations
- **Cache-friendly** algorithms and data structures
- **Lock-free** implementations where applicable
- **Zero-cost abstractions** leveraging Zig's compile-time features
- **Minimal allocations** with careful memory management

## 📊 Test Coverage

**273+ passing tests** covering all major modules and algorithms.

## 🛠️ Requirements

- Zig 0.14.1 or newer

## 📖 Documentation

See [API Documentation](docs/api.md) for detailed API reference.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

Inspired by algorithms from:
- C++ STL
- Rust standard library
- Python standard library
- Haskell Prelude
- Various computer science textbooks and papers

---

**Note**: Some advanced features (BWT, ObjectPool) are under active development and may have known limitations.
