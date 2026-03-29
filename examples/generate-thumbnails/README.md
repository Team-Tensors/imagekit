# Example: Generate Thumbnails

This example demonstrates how to use the [`tensors/imagekit`](https://central.ballerina.io/tensors/imagekit) library to batch-generate thumbnails for a directory of images while preserving their aspect ratio.

## Overview

The program scans an `images/` directory, creates a 200×200 thumbnail for every PNG and JPEG file it finds, and writes the results to a `thumbnails/` directory. Each thumbnail fits within the 200×200 bounding box without distortion.

## Prerequisites

- [Ballerina Swan Lake](https://ballerina.io/downloads/) 2201.x or later
- `tensors/imagekit` published to Ballerina Central or available locally

## Project Structure

```
generate-thumbnails/
├── Ballerina.toml          # package manifest with imagekit dependency
├── main.bal                # main program
├── images/                 # place your input images here
│   ├── image1.jpeg
│   ├── image2.jpeg
│   └── image3.jpeg
├── thumbnails/             # generated thumbnails are written here (git-ignored)
└── tests/
    ├── fixtures/           # test images
    └── lib_test.bal        # unit tests
```

## Run

Place your images inside the `images/` directory, then:

```bash
bal run
```

### Expected Output

```
[OK] image1.jpeg → 200x150
[OK] image2.jpeg → 200x133
[OK] image3.jpeg → 150x200
Generated 3 thumbnail(s) in thumbnails/
```

## Customise Thumbnail Size

Edit the constants in `main.bal` to change the bounding box:

```ballerina
const int MAX_WIDTH  = 200;
const int MAX_HEIGHT = 200;
```

## Run Tests

```bash
bal test
```

The tests verify thumbnail dimensions, aspect ratio preservation, and batch generation across all three sample images.
