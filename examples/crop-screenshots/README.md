# Example: Crop Screenshots

This example demonstrates how to use the [`tensors/imagekit`](https://central.ballerina.io/tensors/imagekit) library to batch-crop UI chrome (tab bars, status bars, toolbars) from a directory of screenshots in a single call.

## Overview

The program scans a `screenshots/` directory, removes 32 pixels from the top and 18 pixels from the bottom of every image (PNG, JPEG, BMP, GIF), and saves each file in-place. Original files are preserved as `*.orig.<ext>` backups.

## Prerequisites

- [Ballerina Swan Lake](https://ballerina.io/downloads/) 2201.x or later
- `tensors/imagekit` published to Ballerina Central or available locally

## Project Structure

```
crop-screenshots/
├── Ballerina.toml          # package manifest with imagekit dependency
├── main.bal                # main program
├── screenshots/            # place your input images here
│   ├── image1.jpeg
│   ├── image2.jpeg
│   └── image3.jpeg
└── tests/
    ├── fixtures/           # test images
    └── lib_test.bal        # unit tests
```

## Run

Place your images inside the `screenshots/` directory, then:

```bash
bal run
```

### Expected Output

```
Processed : 3
Skipped   : 0
Reduction : 3.2%
[OK]   screenshots/image1.jpeg  1920x1080 → 1920x1030
[OK]   screenshots/image2.jpeg  1920x1080 → 1920x1030
[OK]   screenshots/image3.jpeg  1920x1080 → 1920x1030
```

## Customise Margins

Edit `main.bal` to adjust the crop margins for your specific use case:

```ballerina
imagekit:CropSummary summary = check imagekit:cropDirectory(
    "screenshots/",
    top    = 32,   // pixels to remove from top
    bottom = 18,   // pixels to remove from bottom
    left   = 0,
    right  = 0,
    backup = true
);
```

## Run Tests

```bash
bal test
```

The tests verify single-file cropping, dry-run behaviour, and backup file creation without modifying the sample fixtures.
