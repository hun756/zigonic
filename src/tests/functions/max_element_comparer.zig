const Vec2 = @import("../types/vec2.zig").Vec2;

pub fn intGreater(a: i32, b: i32) bool {
    return a > b;
}

pub fn floatGreater(a: f64, b: f64) bool {
    return a > b;
}

pub fn vecComparator(a: Vec2, b: Vec2) bool {
    return @max(a.x, a.y) > @max(b.x, b.y);
}
