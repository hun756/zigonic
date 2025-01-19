const std = @import("std");
const math = std.math;

/// AccumulateError represents possible errors that can occur during accumulation
pub const AccumulateError = error{
    OperationOverflow,
};

/// Generic accumulate function that works with any iterator and operation
/// T: Type of elements to accumulate
/// Op: Type of the operation to perform (must be a function that takes two arguments of type T)
pub fn accumulate(
    comptime T: type,
    comptime Op: type,
    iterator: anytype,
    initial_value: T,
    operation: Op,
) AccumulateError!T {
    const op_info = @typeInfo(Op);
    if (op_info != .Fn or op_info.Fn.params.len != 2) {
        @compileError("Operation must be a function taking two parameters");
    }

    var result = initial_value;

    while (iterator.next()) |item| {
        result = operation(result, item) catch {
            return AccumulateError.OperationOverflow;
        };
    }

    return result;
}

/// Specialized accumulate for numeric types with addition
pub fn sum(
    comptime T: type,
    iterator: anytype,
    initial_value: T,
) AccumulateError!T {
    const add = struct {
        fn add(a: T, b: T) !T {
            return math.add(T, a, b);
        }
    }.add;

    return accumulate(T, @TypeOf(add), iterator, initial_value, add);
}

/// Specialized accumulate for numeric types with multiplication
pub fn product(
    comptime T: type,
    iterator: anytype,
    initial_value: T,
) AccumulateError!T {
    const multiply = struct {
        fn multiply(a: T, b: T) !T {
            return math.mul(T, a, b);
        }
    }.multiply;

    return accumulate(T, @TypeOf(multiply), iterator, initial_value, multiply);
}

// Generic slice iterator implementation
pub fn SliceIterator(comptime T: type) type {
    return struct {
        slice: []const T,
        index: usize,

        pub fn next(self: *@This()) ?T {
            if (self.index < self.slice.len) {
                const value = self.slice[self.index];
                self.index += 1;
                return value;
            }
            return null;
        }
    };
}
