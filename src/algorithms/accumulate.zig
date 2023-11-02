/// Accumulates values in a range by repeatedly applying a binary
/// operation. This allows you to reduce a range to a single value.
///
/// - `T` must be a compile time known type. This allows the fn to work
///   on any type that supports the binary operation.
///
/// - `BinaryOp` must be a compile time known function that takes two
///   parameters of type `T` and returns a `T`. This allows customizing
///   the accumulation operation.
///
/// - `range` is the slice to accumulate over.
///
/// - `initial` is the starting value to begin accumulation from.
///
/// Accumulates by looping over `range`, applying `BinaryOp` to each
/// element and the accumulator `acc`. Returns the final result.
///
/// Useful for sums, products, min/max, etc.
pub fn accumulate(comptime T: type, comptime BinaryOp: fn (T, T) T, range: []const T, initial: T) T {
    var acc = initial;
    for (range) |item| {
        acc = BinaryOp(acc, item);
    }
    return acc;
}
