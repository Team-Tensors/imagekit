import ballerina/test;
import ballerina/file;
import tensors/imagekit;

const FIXTURES = "tests/fixtures/";

@test:Config {}
function testCropSingleImage() returns error? {
    string work = FIXTURES + "_work_crop.jpeg";
    check file:copy(FIXTURES + "image1.jpeg", work, file:REPLACE_EXISTING);

    imagekit:ImageInfo before = check imagekit:getInfo(work);
    check imagekit:crop(work, top = 32, bottom = 18);
    imagekit:ImageInfo after = check imagekit:getInfo(work);

    test:assertEquals(after.width,  before.width,       msg = "width unchanged after crop");
    test:assertEquals(after.height, before.height - 50, msg = "height reduced by 50px (32+18)");

    do { check file:remove(work); } on fail {}
}

@test:Config {}
function testCropDirectoryDryRun() returns error? {
    imagekit:CropSummary summary = check imagekit:cropDirectory(
        FIXTURES, top = 32, bottom = 18, dryRun = true);

    test:assertTrue(summary.processed > 0, msg = "should find at least one image");
    test:assertEquals(summary.skipped, 0,  msg = "no images should be skipped");
}

@test:Config {}
function testCropDirectoryWithBackup() returns error? {
    string dir = FIXTURES + "_backup_test/";
    check file:createDir(dir);
    check file:copy(FIXTURES + "image1.jpeg", dir + "image1.jpeg", file:REPLACE_EXISTING);

    imagekit:CropSummary summary = check imagekit:cropDirectory(
        dir, top = 20, bottom = 20, backup = true);

    test:assertEquals(summary.processed, 1, msg = "should process one image");
    test:assertTrue(check file:test(dir + "image1.orig.jpeg", file:EXISTS),
        msg = "backup file should exist");

    do { check file:remove(dir + "image1.jpeg"); } on fail {}
    do { check file:remove(dir + "image1.orig.jpeg"); } on fail {}
    do { check file:remove(dir); } on fail {}
}
