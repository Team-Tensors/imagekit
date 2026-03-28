import ballerina/jballerina.java;

// ── Info ─────────────────────────────────────────────────────────────

# Returns image metadata as `"width,height,format,fileSize"` or `"ERROR:..."` on failure.
#
# + filePath - path to the image file
# + return   - metadata string or error-prefixed string
isolated function getImageInfo(string filePath) returns string =
    @java:Method {
        name:  "getImageInfo",
        'class: "io.tensors.imagecrop.ImageCropper"
    } external;

# Returns image dimensions as `"WIDTHxHEIGHT"` or `"ERROR:..."` on failure.
#
# + filePath - path to the image file
# + return   - dimension string or error-prefixed string
isolated function getImageDimensions(string filePath) returns string =
    @java:Method {
        name:  "getImageDimensions",
        'class: "io.tensors.imagecrop.ImageCropper"
    } external;

// ── Crop ─────────────────────────────────────────────────────────────

# Crops an image in-place. Returns `""` on success, error message on failure.
#
# + filePath - path to the image file
# + top      - pixels to remove from the top
# + bottom   - pixels to remove from the bottom
# + left     - pixels to remove from the left
# + right    - pixels to remove from the right
# + return   - empty string on success, error message on failure
isolated function cropImageNative(
        string filePath,
        int top,
        int bottom,
        int left,
        int right) returns string =
    @java:Method {
        name:  "cropImage",
        'class: "io.tensors.imagecrop.ImageCropper"
    } external;

// ── Resize ───────────────────────────────────────────────────────────

# Resizes an image to exact dimensions in-place. Returns `""` on success.
#
# + filePath - path to the image file
# + width    - target width in pixels
# + height   - target height in pixels
# + return   - empty string on success, error message on failure
isolated function resizeImageNative(string filePath, int width, int height) returns string =
    @java:Method {
        name:  "resizeImage",
        'class: "io.tensors.imagecrop.ImageCropper"
    } external;

# Resizes to fit within a bounding box preserving aspect ratio. Returns `""` on success.
#
# + filePath  - path to the image file
# + maxWidth  - maximum width in pixels
# + maxHeight - maximum height in pixels
# + return    - empty string on success, error message on failure
isolated function resizeToFitNative(string filePath, int maxWidth, int maxHeight) returns string =
    @java:Method {
        name:  "resizeToFit",
        'class: "io.tensors.imagecrop.ImageCropper"
    } external;

// ── Rotate ───────────────────────────────────────────────────────────

# Rotates an image clockwise in-place. Returns `""` on success.
#
# + filePath - path to the image file
# + degrees  - rotation angle: 90, 180, or 270
# + return   - empty string on success, error message on failure
isolated function rotateImageNative(string filePath, int degrees) returns string =
    @java:Method {
        name:  "rotateImage",
        'class: "io.tensors.imagecrop.ImageCropper"
    } external;

// ── Flip ─────────────────────────────────────────────────────────────

# Flips an image in-place. Returns `""` on success.
#
# + filePath   - path to the image file
# + horizontal - true for horizontal (left-right) flip, false for vertical (top-bottom)
# + return     - empty string on success, error message on failure
isolated function flipImageNative(string filePath, boolean horizontal) returns string =
    @java:Method {
        name:  "flipImage",
        'class: "io.tensors.imagecrop.ImageCropper"
    } external;

// ── Grayscale ────────────────────────────────────────────────────────

# Converts an image to grayscale in-place. Returns `""` on success.
#
# + filePath - path to the image file
# + return   - empty string on success, error message on failure
isolated function toGrayscaleNative(string filePath) returns string =
    @java:Method {
        name:  "toGrayscale",
        'class: "io.tensors.imagecrop.ImageCropper"
    } external;

// ── Convert ──────────────────────────────────────────────────────────

# Converts an image to a different format. Returns `""` on success.
#
# + srcPath  - path to the source image
# + destPath - path for the output file
# + format   - target format string (e.g. `"PNG"`, `"JPEG"`)
# + return   - empty string on success, error message on failure
isolated function convertImageNative(string srcPath, string destPath, string format) returns string =
    @java:Method {
        name:  "convertImage",
        'class: "io.tensors.imagecrop.ImageCropper"
    } external;

// ── Thumbnail ────────────────────────────────────────────────────────

# Creates a thumbnail at destPath. Returns `""` on success.
#
# + srcPath   - path to the source image
# + destPath  - path for the thumbnail output
# + maxWidth  - maximum thumbnail width in pixels
# + maxHeight - maximum thumbnail height in pixels
# + return    - empty string on success, error message on failure
isolated function createThumbnailNative(
        string srcPath,
        string destPath,
        int maxWidth,
        int maxHeight) returns string =
    @java:Method {
        name:  "createThumbnail",
        'class: "io.tensors.imagecrop.ImageCropper"
    } external;
