import ballerina/test;
import ballerina/file;
import tensors/imagekit;

const FIXTURES = "tests/fixtures/";

@test:Config {}
function testConvertJpegToPng() returns error? {
    string dest = FIXTURES + "_converted.png";
    check imagekit:convert(FIXTURES + "image1.jpeg", dest, "PNG");

    imagekit:ImageInfo orig = check imagekit:getInfo(FIXTURES + "image1.jpeg");
    imagekit:ImageInfo conv = check imagekit:getInfo(dest);
    test:assertEquals(conv.width,  orig.width,  msg = "width preserved after JPEG→PNG");
    test:assertEquals(conv.height, orig.height, msg = "height preserved after JPEG→PNG");
    test:assertEquals(conv.format, "PNG",       msg = "format should be PNG");

    do { check file:remove(dest); } on fail {}
}

@test:Config {}
function testResizeToFitAfterConvert() returns error? {
    string dest = FIXTURES + "_resized.jpg";
    check imagekit:convert(FIXTURES + "image1.jpeg", dest, "JPEG");
    check imagekit:resizeToFit(dest, 1280, 720);

    imagekit:ImageInfo info = check imagekit:getInfo(dest);
    test:assertTrue(info.width  <= 1280, msg = "width should be ≤ 1280");
    test:assertTrue(info.height <= 720,  msg = "height should be ≤ 720");

    do { check file:remove(dest); } on fail {}
}

@test:Config {}
function testBatchConvertAllImages() returns error? {
    string outDir = FIXTURES + "_output/";
    check file:createDir(outDir);

    string[] images = ["image1.jpeg", "image2.jpeg", "image3.jpeg"];
    foreach string img in images {
        string baseName = img.substring(0, img.length() - 5); // strip .jpeg
        string dest = outDir + baseName + ".jpg";
        check imagekit:convert(FIXTURES + img, dest, "JPEG");
        check imagekit:resizeToFit(dest, 1280, 720);

        imagekit:ImageInfo info = check imagekit:getInfo(dest);
        test:assertTrue(info.width <= 1280 && info.height <= 720,
            msg = img + " should fit within 1280x720 after resize");
    }

    do {
        check file:remove(outDir + "image1.jpg");
        check file:remove(outDir + "image2.jpg");
        check file:remove(outDir + "image3.jpg");
        check file:remove(outDir);
    } on fail {}
}
