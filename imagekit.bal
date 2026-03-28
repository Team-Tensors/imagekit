// Copyright (c) 2026, Vishwa Jayawickrama.
// Apache License 2.0

import ballerina/file;
import ballerina/io;

// ── Public types ─────────────────────────────────────────────────────

# Metadata describing an image file.
public type ImageInfo record {|
    # Width in pixels.
    int width;
    # Height in pixels.
    int height;
    # Format identifier (e.g. `"PNG"`, `"JPEG"`, `"BMP"`).
    string format;
    # File size in bytes.
    int fileSize;
|};

# Per-file result from `cropDirectory`.
public type CropResult record {|
    # Absolute path to the file.
    string fileName;
    # Whether the file was skipped without being processed.
    boolean skipped;
    # Human-readable reason for skipping; `()` when not skipped.
    string? skipReason;
    # Width before cropping in pixels.
    int widthBefore;
    # Height before cropping in pixels.
    int heightBefore;
    # Width after cropping in pixels (0 when skipped).
    int widthAfter;
    # Height after cropping in pixels (0 when skipped).
    int heightAfter;
|};

# Aggregate summary returned by `cropDirectory`.
public type CropSummary record {|
    # Number of files successfully processed.
    int processed;
    # Number of files skipped.
    int skipped;
    # Percentage of total pixels removed across all processed files.
    float pixelReductionPct;
    # Per-file results in the order they were processed.
    CropResult[] results;
|};

// ── Default crop margins ──────────────────────────────────────────────

# Default pixels removed from the top edge (no crop).
public const int DEFAULT_TOP    = 0;
# Default pixels removed from the bottom edge (no crop).
public const int DEFAULT_BOTTOM = 0;
# Default pixels removed from the left edge (no crop).
public const int DEFAULT_LEFT   = 0;
# Default pixels removed from the right edge (no crop).
public const int DEFAULT_RIGHT  = 0;

// ── Info ─────────────────────────────────────────────────────────────

# Returns metadata (dimensions, format, file size) for an image file.
#
# + filePath - path to the image file
# + return   - `ImageInfo` on success, `error` on failure
public isolated function getInfo(string filePath) returns ImageInfo|error {
    string raw = getImageInfo(filePath);
    if raw.startsWith("ERROR:") {
        return error(raw.substring(6));
    }
    string[] parts = re`,`.split(raw);
    if parts.length() < 4 {
        return error("Unexpected info format: " + raw);
    }
    return {
        width:    check int:fromString(parts[0]),
        height:   check int:fromString(parts[1]),
        format:   parts[2],
        fileSize: check int:fromString(parts[3])
    };
}

// ── Crop ─────────────────────────────────────────────────────────────

# Crops a single image file in-place by removing the specified number of pixels
# from each edge. All margins default to 0 (no crop).
#
# + filePath - path to the image file
# + top      - pixels to remove from the top edge
# + bottom   - pixels to remove from the bottom edge
# + left     - pixels to remove from the left edge
# + right    - pixels to remove from the right edge
# + return   - `error` on failure, `()` on success
public isolated function crop(
        string filePath,
        int top    = DEFAULT_TOP,
        int bottom = DEFAULT_BOTTOM,
        int left   = DEFAULT_LEFT,
        int right  = DEFAULT_RIGHT) returns error? {
    string result = cropImageNative(filePath, top, bottom, left, right);
    if result != "" {
        return error("Crop failed: " + result);
    }
}

# Crops all PNG files in a directory in-place.
# Files ending in `.orig.png` (backups) are automatically excluded.
# All margins default to 0; pass explicit values to crop each edge.
#
# + dirPath  - path to the directory containing PNG images
# + top      - pixels to remove from the top edge
# + bottom   - pixels to remove from the bottom edge
# + left     - pixels to remove from the left edge
# + right    - pixels to remove from the right edge
# + dryRun   - when `true`, log what would happen without writing any files
# + backup   - when `true`, copy each original to `<name>.orig.png` before cropping
# + return   - `CropSummary` on success, `error` if the directory cannot be read
public isolated function cropDirectory(
        string dirPath,
        int     top    = DEFAULT_TOP,
        int     bottom = DEFAULT_BOTTOM,
        int     left   = DEFAULT_LEFT,
        int     right  = DEFAULT_RIGHT,
        boolean dryRun = false,
        boolean backup = false) returns CropSummary|error {

    file:MetaData[] entries = check file:readDir(dirPath);
    string[] pngs = entries
        .filter(e => e.absPath.endsWith(".png") && !e.absPath.endsWith(".orig.png"))
        .map(e => e.absPath);

    CropResult[] results   = [];
    int          processed = 0;
    int          skipped   = 0;
    int          pixBefore = 0;
    int          pixAfter  = 0;

    foreach string pngPath in pngs {
        string dimStr = getImageDimensions(pngPath);
        if dimStr.startsWith("ERROR:") {
            string reason = dimStr.substring(6);
            io:println("[SKIP] " + pngPath + " — " + reason);
            skipped += 1;
            results.push({
                fileName: pngPath, skipped: true, skipReason: reason,
                widthBefore: 0, heightBefore: 0, widthAfter: 0, heightAfter: 0
            });
            continue;
        }

        [int, int] [w, h] = check parseDimensions(dimStr);
        int x2 = w - right;
        int y2 = h - bottom;

        if left >= x2 || top >= y2 {
            string reason = "margins exceed image size (" + w.toString() + "x" + h.toString() + ")";
            io:println("[SKIP] " + pngPath + " — " + reason);
            skipped += 1;
            results.push({
                fileName: pngPath, skipped: true, skipReason: reason,
                widthBefore: w, heightBefore: h, widthAfter: 0, heightAfter: 0
            });
            continue;
        }

        int nw = x2 - left;
        int nh = y2 - top;
        pixBefore += w * h;
        pixAfter  += nw * nh;

        if dryRun {
            io:println("[DRY-RUN] " + pngPath + ": " + w.toString() + "x" + h.toString()
                + " → " + nw.toString() + "x" + nh.toString());
            processed += 1;
            results.push({
                fileName: pngPath, skipped: false, skipReason: (),
                widthBefore: w, heightBefore: h, widthAfter: nw, heightAfter: nh
            });
            continue;
        }

        if backup {
            string bak = pngPath.substring(0, pngPath.length() - 4) + ".orig.png";
            check file:copy(pngPath, bak, file:REPLACE_EXISTING);
            io:println("[BACKUP] " + pngPath + " → " + bak);
        }

        string cropErr = cropImageNative(pngPath, top, bottom, left, right);
        if cropErr != "" {
            io:println("[ERROR] " + pngPath + " — " + cropErr);
            skipped += 1;
            results.push({
                fileName: pngPath, skipped: true, skipReason: cropErr,
                widthBefore: w, heightBefore: h, widthAfter: 0, heightAfter: 0
            });
            continue;
        }

        io:println("[CROP] " + pngPath + ": " + w.toString() + "x" + h.toString()
            + " → " + nw.toString() + "x" + nh.toString());
        processed += 1;
        results.push({
            fileName: pngPath, skipped: false, skipReason: (),
            widthBefore: w, heightBefore: h, widthAfter: nw, heightAfter: nh
        });
    }

    float reductionPct = pixBefore > 0
        ? 100.0 * (1.0 - (<float> pixAfter / <float> pixBefore))
        : 0.0;

    return {
        processed: processed,
        skipped: skipped,
        pixelReductionPct: reductionPct,
        results: results
    };
}

// ── Resize ───────────────────────────────────────────────────────────

# Resizes an image to exact pixel dimensions in-place.
#
# + filePath - path to the image file
# + width    - target width in pixels (must be > 0)
# + height   - target height in pixels (must be > 0)
# + return   - `error` on failure, `()` on success
public isolated function resize(string filePath, int width, int height) returns error? {
    if width <= 0 || height <= 0 {
        return error("width and height must be positive, got " + width.toString() + "x" + height.toString());
    }
    string result = resizeImageNative(filePath, width, height);
    if result != "" {
        return error("Resize failed: " + result);
    }
}

# Resizes an image to fit within a bounding box while preserving its aspect ratio.
# The result will be as large as possible without exceeding `maxWidth` or `maxHeight`.
#
# + filePath  - path to the image file
# + maxWidth  - maximum output width in pixels (must be > 0)
# + maxHeight - maximum output height in pixels (must be > 0)
# + return    - `error` on failure, `()` on success
public isolated function resizeToFit(string filePath, int maxWidth, int maxHeight) returns error? {
    if maxWidth <= 0 || maxHeight <= 0 {
        return error("maxWidth and maxHeight must be positive");
    }
    string result = resizeToFitNative(filePath, maxWidth, maxHeight);
    if result != "" {
        return error("Resize failed: " + result);
    }
}

// ── Rotate ───────────────────────────────────────────────────────────

# Rotates an image clockwise by 90, 180, or 270 degrees in-place.
# For 90° and 270° rotations the output dimensions are swapped (width ↔ height).
#
# + filePath - path to the image file
# + degrees  - rotation angle; must be `90`, `180`, or `270`
# + return   - `error` on failure or invalid degrees, `()` on success
public isolated function rotate(string filePath, int degrees) returns error? {
    if degrees != 90 && degrees != 180 && degrees != 270 {
        return error("degrees must be 90, 180, or 270; got " + degrees.toString());
    }
    string result = rotateImageNative(filePath, degrees);
    if result != "" {
        return error("Rotate failed: " + result);
    }
}

// ── Flip ─────────────────────────────────────────────────────────────

# Flips an image horizontally (mirror left↔right) in-place.
#
# + filePath - path to the image file
# + return   - `error` on failure, `()` on success
public isolated function flipHorizontal(string filePath) returns error? {
    string result = flipImageNative(filePath, true);
    if result != "" {
        return error("Flip failed: " + result);
    }
}

# Flips an image vertically (mirror top↔bottom) in-place.
#
# + filePath - path to the image file
# + return   - `error` on failure, `()` on success
public isolated function flipVertical(string filePath) returns error? {
    string result = flipImageNative(filePath, false);
    if result != "" {
        return error("Flip failed: " + result);
    }
}

// ── Grayscale ────────────────────────────────────────────────────────

# Converts an image to grayscale in-place.
#
# + filePath - path to the image file
# + return   - `error` on failure, `()` on success
public isolated function toGrayscale(string filePath) returns error? {
    string result = toGrayscaleNative(filePath);
    if result != "" {
        return error("Grayscale conversion failed: " + result);
    }
}

// ── Convert ──────────────────────────────────────────────────────────

# Converts an image to a different format, writing the result to a new file.
# Supported formats: `"PNG"`, `"JPEG"`, `"BMP"`, `"GIF"`.
# When converting to JPEG, transparent areas are composited onto white.
#
# + srcPath  - path to the source image
# + destPath - path for the output file (will be created or overwritten)
# + format   - target format string, e.g. `"PNG"` or `"JPEG"`
# + return   - `error` on failure, `()` on success
public isolated function convert(string srcPath, string destPath, string format) returns error? {
    string result = convertImageNative(srcPath, destPath, format);
    if result != "" {
        return error("Convert failed: " + result);
    }
}

// ── Thumbnail ────────────────────────────────────────────────────────

# Creates a thumbnail from an image, writing it to a new file.
# The thumbnail fits within `maxWidth × maxHeight` while preserving aspect ratio.
#
# + srcPath   - path to the source image
# + destPath  - path for the thumbnail output (will be created or overwritten)
# + maxWidth  - maximum thumbnail width in pixels (must be > 0)
# + maxHeight - maximum thumbnail height in pixels (must be > 0)
# + return    - `error` on failure, `()` on success
public isolated function thumbnail(
        string srcPath,
        string destPath,
        int maxWidth,
        int maxHeight) returns error? {
    if maxWidth <= 0 || maxHeight <= 0 {
        return error("maxWidth and maxHeight must be positive");
    }
    string result = createThumbnailNative(srcPath, destPath, maxWidth, maxHeight);
    if result != "" {
        return error("Thumbnail creation failed: " + result);
    }
}

// ── Internal helpers ──────────────────────────────────────────────────

isolated function parseDimensions(string dimStr) returns [int, int]|error {
    int sepIdx = dimStr.indexOf("x") ?: -1;
    if sepIdx < 0 {
        return error("Invalid dimension string: " + dimStr);
    }
    int w = check int:fromString(dimStr.substring(0, sepIdx));
    int h = check int:fromString(dimStr.substring(sepIdx + 1));
    return [w, h];
}
