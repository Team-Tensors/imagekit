import tensors/imagekit;
import ballerina/io;

// Demonstrates cropping UI chrome from a directory of screenshots.
// Removes 32px from the top and 18px from the bottom of each image.
// Supports PNG, JPEG, BMP, and GIF.

public function main() returns error? {
    imagekit:CropSummary summary = check imagekit:cropDirectory(
        "screenshots/",
        top    = 32,
        bottom = 18,
        backup = true   // originals saved as *.orig.<ext>
    );

    io:println("Processed : " + summary.processed.toString());
    io:println("Skipped   : " + summary.skipped.toString());
    io:println("Reduction : " + summary.pixelReductionPct.toString() + "%");

    foreach imagekit:CropResult r in summary.results {
        if r.skipped {
            io:println("[SKIP] " + r.fileName + " — " + (r.skipReason ?: ""));
        } else {
            io:println("[OK]   " + r.fileName
                + "  " + r.widthBefore.toString() + "x" + r.heightBefore.toString()
                + " → " + r.widthAfter.toString()  + "x" + r.heightAfter.toString());
        }
    }
}
