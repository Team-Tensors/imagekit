import ballerina/test;
import ballerina/file;
import tensors/imagekit;

const FIXTURES = "tests/fixtures/";

@test:Config {}
function testThumbnailDimensions() returns error? {
    string dest = FIXTURES + "_thumb.jpeg";
    check imagekit:thumbnail(FIXTURES + "image1.jpeg", dest, 200, 200);

    imagekit:ImageInfo thumb = check imagekit:getInfo(dest);
    test:assertTrue(thumb.width  <= 200, msg = "thumbnail width should be ≤ 200");
    test:assertTrue(thumb.height <= 200, msg = "thumbnail height should be ≤ 200");
    test:assertTrue(thumb.width  > 0,   msg = "thumbnail should have positive width");

    do { check file:remove(dest); } on fail {}
}

@test:Config {}
function testThumbnailAspectRatio() returns error? {
    string dest = FIXTURES + "_thumb_ratio.jpeg";
    imagekit:ImageInfo orig = check imagekit:getInfo(FIXTURES + "image1.jpeg");
    check imagekit:thumbnail(FIXTURES + "image1.jpeg", dest, 400, 400);

    imagekit:ImageInfo thumb = check imagekit:getInfo(dest);
    float ratioBefore = <float> orig.width  / <float> orig.height;
    float ratioAfter  = <float> thumb.width / <float> thumb.height;
    float diff = ratioBefore - ratioAfter;
    float absDiff = diff < 0.0 ? -diff : diff;
    test:assertTrue(absDiff < 0.02, msg = "aspect ratio should be preserved within 2%");

    do { check file:remove(dest); } on fail {}
}

@test:Config {}
function testThumbnailAllImages() returns error? {
    string outDir = FIXTURES + "_thumbs/";
    check file:createDir(outDir);

    string[] images = ["image1.jpeg", "image2.jpeg", "image3.jpeg"];
    foreach string img in images {
        string dest = outDir + img;
        check imagekit:thumbnail(FIXTURES + img, dest, 150, 150);
        imagekit:ImageInfo info = check imagekit:getInfo(dest);
        test:assertTrue(info.width <= 150 && info.height <= 150,
            msg = img + " thumbnail should fit within 150x150");
    }

    do {
        check file:remove(outDir + "image1.jpeg");
        check file:remove(outDir + "image2.jpeg");
        check file:remove(outDir + "image3.jpeg");
        check file:remove(outDir);
    } on fail {}
}
