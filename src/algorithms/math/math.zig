const std = @import("std");

pub fn gcd(a: anytype, b: @TypeOf(a)) @TypeOf(a) {
    const T = @TypeOf(a);
    var x: T = if (a < 0) @intCast(-@as(i64, a)) else a;
    var y: T = if (b < 0) @intCast(-@as(i64, b)) else b;

    while (y != 0) {
        const temp = y;
        y = x % y;
        x = temp;
    }
    return x;
}

pub fn binaryGcd(a: anytype, b: @TypeOf(a)) @TypeOf(a) {
    if (a == 0) return b;
    if (b == 0) return a;

    var x = a;
    var y = b;

    const shift = @ctz(x | y);
    x >>= @intCast(@ctz(x));

    while (y != 0) {
        y >>= @intCast(@ctz(y));
        if (x > y) {
            const temp = x;
            x = y;
            y = temp;
        }
        y -= x;
    }

    return x << @intCast(shift);
}

pub fn lcm(a: anytype, b: @TypeOf(a)) @TypeOf(a) {
    if (a == 0 or b == 0) return 0;
    return @divExact(a, gcd(a, b)) * b;
}

pub fn extendedGcd(a: i64, b: i64) struct { gcd: i64, x: i64, y: i64 } {
    if (b == 0) return .{ .gcd = a, .x = 1, .y = 0 };

    const result = extendedGcd(b, @mod(a, b));
    return .{
        .gcd = result.gcd,
        .x = result.y,
        .y = result.x - @divFloor(a, b) * result.y,
    };
}

pub fn isPrime(n: u64) bool {
    if (n < 2) return false;
    if (n == 2 or n == 3) return true;
    if (n % 2 == 0) return false;

    var d = n - 1;
    var r: u32 = 0;
    while (d % 2 == 0) {
        d /= 2;
        r += 1;
    }

    const witnesses = [_]u64{ 2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37 };

    for (witnesses) |a| {
        if (a >= n) continue;
        if (!millerRabinWitness(a, d, r, n)) return false;
    }
    return true;
}

fn millerRabinWitness(a: u64, d: u64, r: u32, n: u64) bool {
    var x = modPow(a, d, n);
    if (x == 1 or x == n - 1) return true;

    var i: u32 = 0;
    while (i < r - 1) : (i += 1) {
        x = modMul(x, x, n);
        if (x == n - 1) return true;
    }
    return false;
}

pub fn sievePrimes(allocator: std.mem.Allocator, limit: usize) ![]u32 {
    if (limit < 2) return &[_]u32{};

    const sieve = try allocator.alloc(bool, limit + 1);
    defer allocator.free(sieve);

    @memset(sieve, true);
    sieve[0] = false;
    sieve[1] = false;

    var i: usize = 2;
    while (i * i <= limit) : (i += 1) {
        if (sieve[i]) {
            var j = i * i;
            while (j <= limit) : (j += i) {
                sieve[j] = false;
            }
        }
    }

    var count: usize = 0;
    for (sieve) |is_prime| {
        if (is_prime) count += 1;
    }

    const primes = try allocator.alloc(u32, count);
    var idx: usize = 0;
    for (sieve, 0..) |is_prime, num| {
        if (is_prime) {
            primes[idx] = @intCast(num);
            idx += 1;
        }
    }

    return primes;
}

pub fn segmentedSieve(allocator: std.mem.Allocator, low: u64, high: u64) ![]u64 {
    if (high < 2 or low > high) return &[_]u64{};

    const limit = std.math.sqrt(high) + 1;
    const base_primes = try sievePrimes(allocator, @intCast(limit));
    defer allocator.free(base_primes);

    const range = high - low + 1;
    const is_prime = try allocator.alloc(bool, @intCast(range));
    defer allocator.free(is_prime);
    @memset(is_prime, true);

    for (base_primes) |p| {
        var start = ((low + p - 1) / p) * p;
        if (start == p) start += p;
        if (start < low) start = low;

        var j = start;
        while (j <= high) : (j += p) {
            is_prime[@intCast(j - low)] = false;
        }
    }

    if (low <= 1) {
        if (low == 0) is_prime[0] = false;
        if (low <= 1 and high >= 1) is_prime[@intCast(1 - low)] = false;
    }

    var count: usize = 0;
    for (is_prime) |ip| {
        if (ip) count += 1;
    }

    const primes = try allocator.alloc(u64, count);
    var idx: usize = 0;
    for (is_prime, 0..) |ip, i| {
        if (ip) {
            primes[idx] = low + i;
            idx += 1;
        }
    }

    return primes;
}

pub const PrimeFactor = struct { prime: u64, exponent: u32 };

pub fn primeFactors(allocator: std.mem.Allocator, n: u64) ![]PrimeFactor {
    var result = std.ArrayList(PrimeFactor).init(allocator);
    errdefer result.deinit();

    var num = n;
    if (num <= 1) return result.toOwnedSlice();

    if (num % 2 == 0) {
        var exp: u32 = 0;
        while (num % 2 == 0) {
            num /= 2;
            exp += 1;
        }
        try result.append(.{ .prime = 2, .exponent = exp });
    }

    var i: u64 = 3;
    while (i * i <= num) : (i += 2) {
        if (num % i == 0) {
            var exp: u32 = 0;
            while (num % i == 0) {
                num /= i;
                exp += 1;
            }
            try result.append(.{ .prime = i, .exponent = exp });
        }
    }

    if (num > 1) {
        try result.append(.{ .prime = num, .exponent = 1 });
    }

    return result.toOwnedSlice();
}

pub fn modPow(base: u64, exp: u64, m: u64) u64 {
    if (m == 1) return 0;

    var result: u64 = 1;
    var b = base % m;
    var e = exp;

    while (e > 0) {
        if (e & 1 == 1) {
            result = modMul(result, b, m);
        }
        e >>= 1;
        b = modMul(b, b, m);
    }

    return result;
}

pub fn modMul(a: u64, b: u64, m: u64) u64 {
    return @intCast(@as(u128, a) * @as(u128, b) % @as(u128, m));
}

pub fn modInverse(a: i64, m: i64) ?i64 {
    const result = extendedGcd(a, m);
    if (result.gcd != 1) return null;
    return @mod(result.x, m);
}

pub fn chineseRemainder(remainders: []const i64, moduli: []const i64) ?i64 {
    if (remainders.len != moduli.len or remainders.len == 0) return null;

    var result: i64 = remainders[0];
    var lcm_val: i64 = moduli[0];

    for (1..remainders.len) |i| {
        const ext = extendedGcd(lcm_val, moduli[i]);
        if (@mod(remainders[i] - result, ext.gcd) != 0) return null;

        result = result + lcm_val * @divExact(remainders[i] - result, ext.gcd) * ext.x;
        lcm_val = @divExact(lcm_val, ext.gcd) * moduli[i];
        result = @mod(result, lcm_val);
    }

    return result;
}

pub fn eulerTotient(n: u64) u64 {
    if (n == 0) return 0;
    if (n == 1) return 1;

    var result = n;
    var num = n;

    var i: u64 = 2;
    while (i * i <= num) {
        if (num % i == 0) {
            while (num % i == 0) {
                num /= i;
            }
            result -= result / i;
        }
        i += 1;
    }

    if (num > 1) {
        result -= result / num;
    }

    return result;
}

pub fn mobiusFunction(n: u64) i8 {
    if (n == 1) return 1;

    var num = n;
    var prime_count: i8 = 0;

    var i: u64 = 2;
    while (i * i <= num) {
        if (num % i == 0) {
            num /= i;
            if (num % i == 0) return 0;
            prime_count += 1;
        }
        i += 1;
    }

    if (num > 1) prime_count += 1;

    return if (@rem(prime_count, 2) == 0) 1 else -1;
}

pub fn isqrt(n: u64) u64 {
    if (n == 0) return 0;

    var x = n;
    var y = (x + 1) / 2;

    while (y < x) {
        x = y;
        y = (x + n / x) / 2;
    }

    return x;
}

pub fn intNthRoot(n: u64, k: u32) u64 {
    if (n == 0 or k == 0) return 0;
    if (k == 1) return n;

    var low: u64 = 1;
    var high: u64 = n;

    while (low < high) {
        const mid = low + (high - low + 1) / 2;
        var power: u64 = 1;
        var overflow = false;

        for (0..k) |_| {
            if (power > n / mid) {
                overflow = true;
                break;
            }
            power *= mid;
        }

        if (overflow or power > n) {
            high = mid - 1;
        } else {
            low = mid;
        }
    }

    return low;
}

pub fn isPerfectSquare(n: u64) bool {
    if (n == 0) return true;
    const root = isqrt(n);
    return root * root == n;
}

pub fn isPerfectPower(n: u64) bool {
    if (n <= 1) return false;

    var b: u32 = 2;
    while (b <= 63) : (b += 1) {
        const a = intNthRoot(n, b);
        var power: u64 = 1;
        for (0..b) |_| {
            power *= a;
        }
        if (power == n) return true;
        b += 1;
    }

    return false;
}

pub fn fibonacci(n: u64) u64 {
    if (n == 0) return 0;
    if (n <= 2) return 1;

    var matrix = [2][2]u64{ [_]u64{ 1, 1 }, [_]u64{ 1, 0 } };
    var result = [2][2]u64{ [_]u64{ 1, 0 }, [_]u64{ 0, 1 } };
    var exp = n - 1;

    while (exp > 0) {
        if (exp & 1 == 1) {
            result = matrixMul(result, matrix);
        }
        matrix = matrixMul(matrix, matrix);
        exp >>= 1;
    }

    return result[0][0];
}

fn matrixMul(a: [2][2]u64, b: [2][2]u64) [2][2]u64 {
    return [2][2]u64{
        [_]u64{
            a[0][0] *% b[0][0] +% a[0][1] *% b[1][0],
            a[0][0] *% b[0][1] +% a[0][1] *% b[1][1],
        },
        [_]u64{
            a[1][0] *% b[0][0] +% a[1][1] *% b[1][0],
            a[1][0] *% b[0][1] +% a[1][1] *% b[1][1],
        },
    };
}

pub fn binomial(n: u64, k: u64) u64 {
    if (k > n) return 0;
    if (k == 0 or k == n) return 1;

    var kk = k;
    if (kk > n - kk) kk = n - kk;

    var result: u64 = 1;
    for (0..kk) |i| {
        result = result * (n - i) / (i + 1);
    }

    return result;
}

pub fn catalan(n: u64) u64 {
    return binomial(2 * n, n) / (n + 1);
}

test "gcd" {
    try std.testing.expectEqual(@as(u32, 6), gcd(@as(u32, 48), @as(u32, 18)));
    try std.testing.expectEqual(@as(u32, 1), gcd(@as(u32, 17), @as(u32, 13)));
    try std.testing.expectEqual(@as(u32, 12), binaryGcd(@as(u32, 48), @as(u32, 180)));
}

test "lcm" {
    try std.testing.expectEqual(@as(u32, 36), lcm(@as(u32, 12), @as(u32, 18)));
    try std.testing.expectEqual(@as(u32, 60), lcm(@as(u32, 15), @as(u32, 20)));
}

test "extendedGcd" {
    const result = extendedGcd(35, 15);
    try std.testing.expectEqual(@as(i64, 5), result.gcd);
    try std.testing.expectEqual(@as(i64, 5), 35 * result.x + 15 * result.y);
}

test "isPrime" {
    try std.testing.expect(isPrime(2));
    try std.testing.expect(isPrime(17));
    try std.testing.expect(isPrime(104729));
    try std.testing.expect(!isPrime(1));
    try std.testing.expect(!isPrime(100));
}

test "sievePrimes" {
    const allocator = std.testing.allocator;
    const primes = try sievePrimes(allocator, 30);
    defer allocator.free(primes);

    try std.testing.expectEqualSlices(u32, &[_]u32{ 2, 3, 5, 7, 11, 13, 17, 19, 23, 29 }, primes);
}

test "modPow" {
    try std.testing.expectEqual(@as(u64, 445), modPow(4, 13, 497));
    try std.testing.expectEqual(@as(u64, 1), modPow(2, 10, 1023));
}

test "modInverse" {
    try std.testing.expectEqual(@as(?i64, 4), modInverse(3, 11));
    try std.testing.expectEqual(@as(?i64, null), modInverse(2, 4));
}

test "eulerTotient" {
    try std.testing.expectEqual(@as(u64, 4), eulerTotient(10));
    try std.testing.expectEqual(@as(u64, 6), eulerTotient(9));
    try std.testing.expectEqual(@as(u64, 40), eulerTotient(100));
}

test "isqrt" {
    try std.testing.expectEqual(@as(u64, 3), isqrt(10));
    try std.testing.expectEqual(@as(u64, 10), isqrt(100));
    try std.testing.expectEqual(@as(u64, 31), isqrt(1000));
}

test "fibonacci" {
    try std.testing.expectEqual(@as(u64, 0), fibonacci(0));
    try std.testing.expectEqual(@as(u64, 1), fibonacci(1));
    try std.testing.expectEqual(@as(u64, 55), fibonacci(10));
    try std.testing.expectEqual(@as(u64, 6765), fibonacci(20));
}

test "binomial" {
    try std.testing.expectEqual(@as(u64, 10), binomial(5, 2));
    try std.testing.expectEqual(@as(u64, 252), binomial(10, 5));
}

test "catalan" {
    try std.testing.expectEqual(@as(u64, 1), catalan(0));
    try std.testing.expectEqual(@as(u64, 1), catalan(1));
    try std.testing.expectEqual(@as(u64, 42), catalan(5));
}
