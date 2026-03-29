## Overview

[imagekit](https://github.com/Team-Tensors/imagekit) is a general-purpose image processing library for Ballerina — the Ballerina equivalent of Python's [Pillow](https://python-pillow.org/). It wraps Java's built-in `javax.imageio` and `java.awt` APIs via Ballerina–Java interop, requiring zero external Maven dependencies.

### Key Features

- Read image metadata: dimensions, format, and file size
- Crop images by removing pixels from any edge
- Resize to exact dimensions or fit within a bounding box while preserving aspect ratio
- Rotate images clockwise by 90, 180, or 270 degrees
- Flip images horizontally or vertically
- Convert images to grayscale
- Convert between formats: PNG, JPEG, BMP, GIF
- Generate thumbnails
- Batch-crop all PNGs in a directory with dry-run and backup support

**Supported formats:** PNG · JPEG · BMP · GIF

## Quickstart

### Step 1: Add the dependency

Add `imagekit` to your `Ballerina.toml`:

```toml
[[dependency]]
org     = "tensors"
name    = "imagekit"
version = "0.1.3"
```

### Step 2: Import the module

```ballerina
import tensors/imagekit;
```

### Step 3: Read image metadata

```ballerina
imagekit:ImageInfo info = check imagekit:getInfo("photo.png");
io:println(info.width.toString() + "x" + info.height.toString() + " " + info.format);
// 1920x1080 PNG
```

### Step 4: Transform images

```ballerina
// Crop 20px from top and bottom
check imagekit:crop("photo.png", top = 20, bottom = 20);

// Resize to 800x600
check imagekit:resize("photo.png", 800, 600);

// Resize preserving aspect ratio
check imagekit:resizeToFit("photo.png", 800, 600);

// Rotate 90° clockwise
check imagekit:rotate("photo.png", 90);

// Flip horizontally
check imagekit:flipHorizontal("photo.png");

// Convert to grayscale
check imagekit:toGrayscale("photo.png");

// Convert PNG to JPEG
check imagekit:convert("photo.png", "photo.jpg", "JPEG");

// Create a thumbnail (fits within 200×200, aspect ratio preserved)
check imagekit:thumbnail("photo.png", "thumb.png", 200, 200);
```

### Step 5: Run

```bash
bal run
```

## Batch Operations

Crop all PNG files in a directory in one call:

```ballerina
imagekit:CropSummary summary = check imagekit:cropDirectory(
    "images/",
    top    = 20,
    bottom = 20,
    backup = true   // save originals as *.orig.png
);

io:println("Processed : " + summary.processed.toString());
io:println("Skipped   : " + summary.skipped.toString());
io:println("Reduction : " + summary.pixelReductionPct.toString() + "%");
```

Use `dryRun = true` to preview what would be cropped without writing any files:

```ballerina
imagekit:CropSummary preview = check imagekit:cropDirectory("images/", dryRun = true);
```

## Examples

The `imagekit` library provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/Team-Tensors/imagekit/tree/main/examples/), covering the following use cases:

1. [Crop screenshots](https://github.com/Team-Tensors/imagekit/tree/main/examples/crop-screenshots) — Crop UI chrome (tab bars, status bars) from a directory of PNG screenshots.

2. [Generate thumbnails](https://github.com/Team-Tensors/imagekit/tree/main/examples/generate-thumbnails) — Batch-generate 200×200 thumbnails for all images in a directory, preserving aspect ratio.

3. [Batch convert](https://github.com/Team-Tensors/imagekit/tree/main/examples/batch-convert) — Convert all PNGs to JPEG and resize them to fit within 1280×720.
