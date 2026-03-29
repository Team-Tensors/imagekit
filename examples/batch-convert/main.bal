import tensors/imagekit;
import ballerina/io;
import ballerina/file;

// Converts all PNG files in an input directory to JPEG,
// resizes them to fit within 1280x720, and saves to an output directory.

const string INPUT_DIR  = "input/";
const string OUTPUT_DIR = "output/";
const int    MAX_WIDTH  = 1280;
const int    MAX_HEIGHT = 720;

public function main() returns error? {
    check file:createDir(OUTPUT_DIR);

    file:MetaData[] entries = check file:readDir(INPUT_DIR);

    int converted = 0;
    foreach file:MetaData entry in entries {
        string src = entry.absPath;
        if !src.endsWith(".png") {
            continue;
        }

        imagekit:ImageInfo before = check imagekit:getInfo(src);

        // Build output path: replace .png with .jpg
        string fileName  = check file:basename(src);
        string baseName  = fileName.substring(0, fileName.length() - 4);
        string dest      = OUTPUT_DIR + baseName + ".jpg";

        // Convert PNG → JPEG
        check imagekit:convert(src, dest, "JPEG");

        // Resize to fit within 1280×720 preserving aspect ratio
        check imagekit:resizeToFit(dest, MAX_WIDTH, MAX_HEIGHT);

        imagekit:ImageInfo after = check imagekit:getInfo(dest);
        io:println("[OK] " + fileName
            + "  " + before.width.toString() + "x" + before.height.toString()
            + " → " + after.width.toString()  + "x" + after.height.toString()
            + " JPEG");
        converted += 1;
    }

    io:println("Converted " + converted.toString() + " file(s) to " + OUTPUT_DIR);
}
