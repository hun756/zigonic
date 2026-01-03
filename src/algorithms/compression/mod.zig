pub const compression = @import("compression.zig");

pub const rleEncode = compression.rleEncode;
pub const rleDecode = compression.rleDecode;
pub const deltaEncode = compression.deltaEncode;
pub const deltaDecode = compression.deltaDecode;
pub const vlqEncode = compression.vlqEncode;
pub const vlqDecode = compression.vlqDecode;
pub const LZ77Token = compression.LZ77Token;
pub const lz77Compress = compression.lz77Compress;
pub const lz77Decompress = compression.lz77Decompress;
pub const bwtTransform = compression.bwtTransform;
pub const bwtInverse = compression.bwtInverse;
pub const mtfEncode = compression.mtfEncode;
pub const mtfDecode = compression.mtfDecode;

test {
    _ = compression;
}
