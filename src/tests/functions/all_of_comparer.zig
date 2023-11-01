pub fn isEven(val: i32) bool {
    return @mod(val, 2) == 0;
}

pub fn isPositive(val: i32) bool {
    return val > 0;
}
