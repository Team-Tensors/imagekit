import tensors/imagekit;
import ballerina/io;
import ballerina/file;

// Generates a thumbnail for every PNG/JPEG in an input directory,
// writing results to an output directory.

const string INPUT_DIR  = "images/";
const string OUTPUT_DIR = "thumbnails/";
const int    MAX_WIDTH  = 200;
const int    MAX_HEIGHT = 200;

public function main() returns error? {
    check file:createDir(OUTPUT_DIR);

    file:MetaData[] entries = check file:readDir(INPUT_DIR);

    int count = 0;
    foreach file:MetaData entry in entries {
        string src = entry.absPath;
        if !src.endsWith(".png") && !src.endsWith(".jpg") && !src.endsWith(".jpeg") {
            continue;
        }

        // Derive destination path inside thumbnails/
        string fileName = check file:basename(src);
        string dest     = OUTPUT_DIR + fileName;

        check imagekit:thumbnail(src, dest, MAX_WIDTH, MAX_HEIGHT);

        imagekit:ImageInfo info = check imagekit:getInfo(dest);
        io:println("[OK] " + fileName + " → " + info.width.toString() + "x" + info.height.toString());
        count += 1;
    }

    io:println("Generated " + count.toString() + " thumbnail(s) in " + OUTPUT_DIR);
}
