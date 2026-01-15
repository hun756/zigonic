pub const math = @import("math.zig");

// GCD and LCM
pub const gcd = math.gcd;
pub const binaryGcd = math.binaryGcd;
pub const lcm = math.lcm;
pub const extendedGcd = math.extendedGcd;

// Prime operations
pub const isPrime = math.isPrime;
pub const sievePrimes = math.sievePrimes;
pub const segmentedSieve = math.segmentedSieve;
pub const primeFactors = math.primeFactors;

// Modular arithmetic
pub const modPow = math.modPow;
pub const modMul = math.modMul;
pub const modInverse = math.modInverse;
pub const chineseRemainder = math.chineseRemainder;

// Number theory
pub const eulerTotient = math.eulerTotient;
pub const mobiusFunction = math.mobiusFunction;
pub const isqrt = math.isqrt;
pub const intNthRoot = math.intNthRoot;
pub const isPerfectSquare = math.isPerfectSquare;
pub const isPerfectPower = math.isPerfectPower;

// Combinatorics
pub const fibonacci = math.fibonacci;
pub const binomial = math.binomial;
pub const catalan = math.catalan;

test {
    _ = math;
}
