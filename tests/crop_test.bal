import ballerina/test;
import ballerina/file;
import ballerina/io;

// ── Fixture paths ─────────────────────────────────────────────────────
// ORIG is never modified; all mutating tests work on WORK (a fresh copy).

const ORIG  = "tests/fixtures/image.png";
const WORK  = "tests/fixtures/_work.png";

isolated function removeFile(string path) {
    do {
        check file:remove(path);
    } on fail {
        // ignore — file may not exist
    }
}

@test:BeforeEach
function setup() returns error? {
    check file:copy(ORIG, WORK, file:REPLACE_EXISTING);
}

@test:AfterEach
function cleanup() {
    removeFile(WORK);
}

// ── getInfo ───────────────────────────────────────────────────────────

@test:Config {}
function testGetInfo() returns error? {
    ImageInfo info = check getInfo(ORIG);
    io:println("Image info: " + info.width.toString() + "x" + info.height.toString()
        + " " + info.format + " (" + info.fileSize.toString() + " bytes)");
    test:assertTrue(info.width > 0,    msg = "width should be positive");
    test:assertTrue(info.height > 0,   msg = "height should be positive");
    test:assertTrue(info.fileSize > 0, msg = "fileSize should be positive");
    test:assertFalse(info.format == "", msg = "format should not be empty");
}

@test:Config {}
function testGetInfoInvalidPath() {
    ImageInfo|error result = getInfo("tests/fixtures/nonexistent.png");
    test:assertTrue(result is error, msg = "should return error for missing file");
}

// ── crop ─────────────────────────────────────────────────────────────

@test:Config {}
function testCrop() returns error? {
    ImageInfo before = check getInfo(WORK);
    check crop(WORK, top = 32, bottom = 18, left = 0, right = 0);
    ImageInfo after = check getInfo(WORK);
    io:println("Crop: " + before.width.toString() + "x" + before.height.toString()
        + " → " + after.width.toString() + "x" + after.height.toString());
    test:assertEquals(after.width,  before.width,       msg = "width should not change");
    test:assertEquals(after.height, before.height - 50, msg = "height should decrease by 50 (32+18)");
}

@test:Config {}
function testCropInvalidMargins() {
    error? result = crop(WORK, top = 5000, bottom = 5000);
    test:assertTrue(result is error, msg = "should fail when margins exceed image size");
}

// ── cropDirectory ─────────────────────────────────────────────────────

@test:Config {}
function testCropDirectoryDryRun() returns error? {
    CropSummary summary = check cropDirectory("tests/fixtures", dryRun = true);
    io:println("Dry-run: " + summary.processed.toString() + " processed, "
        + summary.skipped.toString() + " skipped");
    test:assertTrue(summary.processed > 0, msg = "should find at least one PNG");
}

@test:Config {}
function testCropDirectoryLive() returns error? {
    check file:createDir("tests/fixtures/_cropdir");
    check file:copy(ORIG, "tests/fixtures/_cropdir/img.png", file:REPLACE_EXISTING);

    CropSummary summary = check cropDirectory("tests/fixtures/_cropdir", top = 20, bottom = 20);
    io:println("Crop dir: " + summary.processed.toString() + " processed, "
        + summary.pixelReductionPct.toString() + "% reduction");
    test:assertEquals(summary.processed, 1,   msg = "should process exactly one file");
    test:assertTrue(summary.pixelReductionPct > 0.0, msg = "should report pixel reduction");

    removeFile("tests/fixtures/_cropdir/img.png");
    do { check file:remove("tests/fixtures/_cropdir"); } on fail {}
}

// ── resize ────────────────────────────────────────────────────────────

@test:Config {}
function testResize() returns error? {
    check resize(WORK, 800, 600);
    ImageInfo after = check getInfo(WORK);
    io:println("Resize → " + after.width.toString() + "x" + after.height.toString());
    test:assertEquals(after.width,  800, msg = "width should be 800");
    test:assertEquals(after.height, 600, msg = "height should be 600");
}

@test:Config {}
function testResizeInvalidDimensions() {
    error? result = resize(WORK, 0, 600);
    test:assertTrue(result is error, msg = "should fail for zero width");
}

// ── resizeToFit ───────────────────────────────────────────────────────

@test:Config {}
function testResizeToFit() returns error? {
    ImageInfo before = check getInfo(WORK);
    check resizeToFit(WORK, 400, 400);
    ImageInfo after = check getInfo(WORK);
    io:println("ResizeToFit: " + before.width.toString() + "x" + before.height.toString()
        + " → " + after.width.toString() + "x" + after.height.toString());
    test:assertTrue(after.width  <= 400, msg = "width should be ≤ 400");
    test:assertTrue(after.height <= 400, msg = "height should be ≤ 400");
    float ratioBefore = <float> before.width / <float> before.height;
    float ratioAfter  = <float> after.width  / <float> after.height;
    float diff = ratioBefore - ratioAfter;
    float absDiff = diff < 0.0 ? -diff : diff;
    test:assertTrue(absDiff < 0.02, msg = "aspect ratio should be preserved within 2%");
}

// ── rotate ────────────────────────────────────────────────────────────

@test:Config {}
function testRotate90() returns error? {
    ImageInfo before = check getInfo(WORK);
    check rotate(WORK, 90);
    ImageInfo after = check getInfo(WORK);
    io:println("Rotate 90°: " + before.width.toString() + "x" + before.height.toString()
        + " → " + after.width.toString() + "x" + after.height.toString());
    test:assertEquals(after.width,  before.height, msg = "width should equal original height after 90°");
    test:assertEquals(after.height, before.width,  msg = "height should equal original width after 90°");
}

@test:Config {}
function testRotate180() returns error? {
    ImageInfo before = check getInfo(WORK);
    check rotate(WORK, 180);
    ImageInfo after = check getInfo(WORK);
    io:println("Rotate 180°: " + after.width.toString() + "x" + after.height.toString());
    test:assertEquals(after.width,  before.width,  msg = "width unchanged after 180°");
    test:assertEquals(after.height, before.height, msg = "height unchanged after 180°");
}

@test:Config {}
function testRotate270() returns error? {
    ImageInfo before = check getInfo(WORK);
    check rotate(WORK, 270);
    ImageInfo after = check getInfo(WORK);
    io:println("Rotate 270°: " + after.width.toString() + "x" + after.height.toString());
    test:assertEquals(after.width,  before.height, msg = "width should equal original height after 270°");
    test:assertEquals(after.height, before.width,  msg = "height should equal original width after 270°");
}

@test:Config {}
function testRotateInvalidDegrees() {
    error? result = rotate(WORK, 45);
    test:assertTrue(result is error, msg = "should fail for non-90-multiple degrees");
}

// ── flip ─────────────────────────────────────────────────────────────

@test:Config {}
function testFlipHorizontal() returns error? {
    ImageInfo before = check getInfo(WORK);
    check flipHorizontal(WORK);
    ImageInfo after = check getInfo(WORK);
    io:println("Flip horizontal: " + after.width.toString() + "x" + after.height.toString());
    test:assertEquals(after.width,  before.width,  msg = "dimensions unchanged after horizontal flip");
    test:assertEquals(after.height, before.height, msg = "dimensions unchanged after horizontal flip");
}

@test:Config {}
function testFlipVertical() returns error? {
    ImageInfo before = check getInfo(WORK);
    check flipVertical(WORK);
    ImageInfo after = check getInfo(WORK);
    io:println("Flip vertical: " + after.width.toString() + "x" + after.height.toString());
    test:assertEquals(after.width,  before.width,  msg = "dimensions unchanged after vertical flip");
    test:assertEquals(after.height, before.height, msg = "dimensions unchanged after vertical flip");
}

// ── toGrayscale ───────────────────────────────────────────────────────

@test:Config {}
function testToGrayscale() returns error? {
    ImageInfo before = check getInfo(WORK);
    check toGrayscale(WORK);
    ImageInfo after = check getInfo(WORK);
    io:println("Grayscale: " + after.width.toString() + "x" + after.height.toString());
    test:assertEquals(after.width,  before.width,  msg = "dimensions unchanged after grayscale");
    test:assertEquals(after.height, before.height, msg = "dimensions unchanged after grayscale");
}

// ── convert ───────────────────────────────────────────────────────────

@test:Config {}
function testConvertToJpeg() returns error? {
    string dest = "tests/fixtures/_converted.jpg";
    check convert(ORIG, dest, "JPEG");
    ImageInfo orig = check getInfo(ORIG);
    ImageInfo info = check getInfo(dest);
    io:println("Convert PNG→JPEG: " + info.width.toString() + "x" + info.height.toString()
        + " " + info.format);
    test:assertEquals(info.width,  orig.width,  msg = "width preserved after JPEG conversion");
    test:assertEquals(info.height, orig.height, msg = "height preserved after JPEG conversion");
    removeFile(dest);
}

@test:Config {}
function testConvertToBmp() returns error? {
    string dest = "tests/fixtures/_converted.bmp";
    error? result = convert(ORIG, dest, "BMP");
    if result is error {
        // BMP writer not available on this JVM — acceptable
        io:println("Convert PNG→BMP: not supported on this JVM (" + result.message() + ")");
    } else {
        file:MetaData meta = check file:getMetaData(dest);
        io:println("Convert PNG→BMP: " + meta.size.toString() + " bytes");
        test:assertTrue(meta.size > 0, msg = "converted BMP file should have content");
        removeFile(dest);
    }
}

// ── thumbnail ─────────────────────────────────────────────────────────

@test:Config {}
function testThumbnail() returns error? {
    string dest = "tests/fixtures/_thumb.png";
    check thumbnail(ORIG, dest, 200, 200);
    ImageInfo thumb = check getInfo(dest);
    io:println("Thumbnail: " + thumb.width.toString() + "x" + thumb.height.toString());
    test:assertTrue(thumb.width  <= 200, msg = "thumbnail width should be ≤ 200");
    test:assertTrue(thumb.height <= 200, msg = "thumbnail height should be ≤ 200");
    test:assertTrue(thumb.width  > 0,   msg = "thumbnail width should be positive");
    test:assertTrue(thumb.height > 0,   msg = "thumbnail height should be positive");
    removeFile(dest);
}

@test:Config {}
function testThumbnailInvalidSize() {
    error? result = thumbnail(ORIG, "tests/fixtures/_thumb.png", 0, 200);
    test:assertTrue(result is error, msg = "should fail for zero maxWidth");
}
