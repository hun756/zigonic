pub const modifying = @import("modifying.zig");

pub const copy = modifying.copy;
pub const copyIf = modifying.copyIf;
pub const copyN = modifying.copyN;
pub const copyBackward = modifying.copyBackward;
pub const fill = modifying.fill;
pub const fillN = modifying.fillN;
pub const generate = modifying.generate;
pub const generateN = modifying.generateN;
pub const transform = modifying.transform;
pub const transformBinary = modifying.transformBinary;
pub const replace = modifying.replace;
pub const replaceIf = modifying.replaceIf;
pub const replaceCopy = modifying.replaceCopy;
pub const replaceCopyIf = modifying.replaceCopyIf;
pub const reverse = modifying.reverse;
pub const reverseCopy = modifying.reverseCopy;
pub const rotate = modifying.rotate;
pub const rotateCopy = modifying.rotateCopy;
pub const shuffle = modifying.shuffle;
pub const unique = modifying.unique;
pub const uniqueCopy = modifying.uniqueCopy;
pub const remove = modifying.remove;
pub const removeIf = modifying.removeIf;
pub const removeCopy = modifying.removeCopy;
pub const removeCopyIf = modifying.removeCopyIf;
pub const swapRanges = modifying.swapRanges;
pub const shiftLeft = modifying.shiftLeft;
pub const shiftRight = modifying.shiftRight;
pub const sample = modifying.sample;

test {
    _ = modifying;
}
