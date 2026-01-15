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
pub const min = algorithms.min;
pub const max = algorithms.max;

pub const base64 = algorithms.base64;
pub const hex = algorithms.hex;

pub const insertionSort = algorithms.insertionSort;
pub const quickSort = algorithms.quickSort;
pub const heapSort = algorithms.heapSort;
pub const partialSort = algorithms.partialSort;
pub const partialSortCopy = algorithms.partialSortCopy;
pub const nthElement = algorithms.nthElement;
pub const isSorted = algorithms.isSorted;
pub const isSortedUntil = algorithms.isSortedUntil;
pub const stableSort = algorithms.stableSort;
pub const sort = algorithms.sort;

pub const iota = algorithms.iota;
pub const partialSum = algorithms.partialSum;
pub const adjacentDifference = algorithms.adjacentDifference;
pub const innerProduct = algorithms.innerProduct;
pub const gcd = algorithms.gcd;
pub const lcm = algorithms.lcm;
pub const exclusiveScan = algorithms.exclusiveScan;
pub const inclusiveScan = algorithms.inclusiveScan;
pub const transformReduce = algorithms.transformReduce;
pub const transformExclusiveScan = algorithms.transformExclusiveScan;
pub const transformInclusiveScan = algorithms.transformInclusiveScan;
pub const midpoint = algorithms.midpoint;

pub const copy = algorithms.copy;
pub const copyIf = algorithms.copyIf;
pub const fill = algorithms.fill;
pub const generate = algorithms.generate;
pub const transform = algorithms.transform;
pub const replace = algorithms.replace;
pub const replaceIf = algorithms.replaceIf;
pub const reverse = algorithms.reverse;
pub const reverseCopy = algorithms.reverseCopy;
pub const rotate = algorithms.rotate;
pub const rotateCopy = algorithms.rotateCopy;
pub const shuffle = algorithms.shuffle;
pub const unique = algorithms.unique;
pub const remove = algorithms.remove;
pub const removeIf = algorithms.removeIf;
pub const swapRanges = algorithms.swapRanges;
pub const shiftLeft = algorithms.shiftLeft;
pub const shiftRight = algorithms.shiftRight;
pub const sample = algorithms.sample;

pub const findIfNot = algorithms.findIfNot;
pub const findFirstOf = algorithms.findFirstOf;
pub const adjacentFind = algorithms.adjacentFind;
pub const mismatch = algorithms.mismatch;
pub const equal = algorithms.equal;
pub const search = algorithms.search;
pub const searchN = algorithms.searchN;
pub const findEnd = algorithms.findEnd;
pub const lexicographicalCompare = algorithms.lexicographicalCompare;
pub const forEach = algorithms.forEach;

pub const merge = algorithms.merge;
pub const inplaceMerge = algorithms.inplaceMerge;
pub const setUnion = algorithms.setUnion;
pub const setIntersection = algorithms.setIntersection;
pub const setDifference = algorithms.setDifference;
pub const setSymmetricDifference = algorithms.setSymmetricDifference;
pub const includes = algorithms.includes;

pub const makeHeap = algorithms.makeHeap;
pub const pushHeap = algorithms.pushHeap;
pub const popHeap = algorithms.popHeap;
pub const sortHeap = algorithms.sortHeap;
pub const isHeap = algorithms.isHeap;
pub const isHeapUntil = algorithms.isHeapUntil;

pub const nextPermutation = algorithms.nextPermutation;
pub const prevPermutation = algorithms.prevPermutation;
pub const isPermutation = algorithms.isPermutation;

pub const isPartitioned = algorithms.isPartitioned;
pub const partitionAlgo = algorithms.partitionAlgo;
pub const partitionCopy = algorithms.partitionCopy;
pub const stablePartition = algorithms.stablePartition;
pub const partitionPoint = algorithms.partitionPoint;

pub const ParallelConfig = algorithms.ParallelConfig;
pub const parallelFor = algorithms.parallelFor;
pub const parallelForEach = algorithms.parallelForEach;
pub const parallelReduce = algorithms.parallelReduce;
pub const parallelTransform = algorithms.parallelTransform;
pub const parallelSort = algorithms.parallelSort;
pub const parallelSortDefault = algorithms.parallelSortDefault;
pub const parallelFind = algorithms.parallelFind;
pub const parallelCount = algorithms.parallelCount;
pub const parallelCountIf = algorithms.parallelCountIf;
pub const parallelAllOf = algorithms.parallelAllOf;
pub const parallelAnyOf = algorithms.parallelAnyOf;
pub const parallelNoneOf = algorithms.parallelNoneOf;
pub const parallelFill = algorithms.parallelFill;
pub const parallelCopy = algorithms.parallelCopy;
pub const parallelMinElement = algorithms.parallelMinElement;
pub const parallelMaxElement = algorithms.parallelMaxElement;
pub const parallelReplace = algorithms.parallelReplace;
pub const parallelReplaceIf = algorithms.parallelReplaceIf;
pub const parallelEqual = algorithms.parallelEqual;
pub const parallelIota = algorithms.parallelIota;
pub const parallelAdjacentDifference = algorithms.parallelAdjacentDifference;
pub const parallelInnerProduct = algorithms.parallelInnerProduct;

pub const kmpSearch = algorithms.kmpSearch;
pub const boyerMooreSearch = algorithms.boyerMooreSearch;
pub const rabinKarpSearch = algorithms.rabinKarpSearch;
pub const levenshteinDistance = algorithms.levenshteinDistance;
pub const longestCommonSubstring = algorithms.longestCommonSubstring;
pub const longestCommonSubsequence = algorithms.longestCommonSubsequence;
pub const isPalindrome = algorithms.isPalindrome;
pub const reverseString = algorithms.reverseString;
pub const countSubstrings = algorithms.countSubstrings;
pub const hammingDistance = algorithms.hammingDistance;
pub const trim = algorithms.trim;
pub const trimLeft = algorithms.trimLeft;
pub const trimRight = algorithms.trimRight;
pub const split = algorithms.split;
pub const strJoin = algorithms.strJoin;
pub const startsWith = algorithms.startsWith;
pub const endsWith = algorithms.endsWith;

pub const popcount = algorithms.popcount;
pub const countTrailingZeros = algorithms.countTrailingZeros;
pub const countLeadingZeros = algorithms.countLeadingZeros;
pub const isPowerOfTwo = algorithms.isPowerOfTwo;
pub const nextPowerOfTwo = algorithms.nextPowerOfTwo;
pub const reverseBits = algorithms.reverseBits;
pub const rotateLeft = algorithms.rotateLeft;
pub const rotateRight = algorithms.rotateRight;
pub const getBit = algorithms.getBit;
pub const setBit = algorithms.setBit;
pub const clearBit = algorithms.clearBit;
pub const toggleBit = algorithms.toggleBit;
pub const extractBits = algorithms.extractBits;
pub const grayCode = algorithms.grayCode;
pub const inverseGrayCode = algorithms.inverseGrayCode;
pub const hammingWeight = algorithms.hammingWeight;
pub const byteSwap = algorithms.byteSwap;
pub const bitsRequired = algorithms.bitsRequired;

pub const compose = algorithms.compose;
pub const pipe = algorithms.pipe;
pub const applyN = algorithms.applyN;
pub const zipWith = algorithms.zipWith;
pub const scanLeft = algorithms.scanLeft;
pub const scanRight = algorithms.scanRight;
pub const takeWhile = algorithms.takeWhile;
pub const dropWhile = algorithms.dropWhile;
pub const groupBy = algorithms.groupBy;
pub const intersperse = algorithms.intersperse;
pub const chunks = algorithms.chunks;
pub const transpose = algorithms.transpose;

pub const fnv1a32 = algorithms.fnv1a32;
pub const fnv1a64 = algorithms.fnv1a64;
pub const djb2 = algorithms.djb2;
pub const murmur3_32 = algorithms.murmur3_32;
pub const xxHash32 = algorithms.xxHash32;
pub const adler32 = algorithms.adler32;
pub const crc32 = algorithms.crc32;
pub const crc16 = algorithms.crc16;
pub const fletcher16 = algorithms.fletcher16;
pub const fletcher32 = algorithms.fletcher32;
pub const hashCombine = algorithms.hashCombine;

// Math & Number Theory
pub const mathGcd = algorithms.mathGcd;
pub const mathLcm = algorithms.mathLcm;
pub const isPrime = algorithms.isPrime;
pub const modPow = algorithms.modPow;
pub const fibonacci = algorithms.fibonacci;
pub const binomial = algorithms.binomial;

// Graph Algorithms
pub const AdjacencyList = algorithms.AdjacencyList;
pub const bfs = algorithms.bfs;
pub const dfs = algorithms.dfs;
pub const dijkstra = algorithms.dijkstra;

// Data Structures
pub const UnionFind = algorithms.UnionFind;
pub const BloomFilter = algorithms.BloomFilter;
pub const LRUCache = algorithms.LRUCache;
pub const Trie = algorithms.Trie;

// Compression
pub const rleEncode = algorithms.rleEncode;
pub const rleDecode = algorithms.rleDecode;
pub const deltaEncode = algorithms.deltaEncode;
pub const deltaDecode = algorithms.deltaDecode;

// Memory Utilities
pub const RingBuffer = algorithms.RingBuffer;
pub const Deque = algorithms.Deque;
pub const BumpAllocator = algorithms.BumpAllocator;

// Intervals
pub const Interval = algorithms.Interval;
pub const mergeIntervals = algorithms.mergeIntervals;
pub const IntervalTree = algorithms.IntervalTree;

// SIMD Operations
pub const simdSum = algorithms.simdSum;
pub const simdMin = algorithms.simdMin;
pub const simdMax = algorithms.simdMax;
pub const simdDotProduct = algorithms.simdDotProduct;

test {
    std.testing.refAllDecls(@This());
}
