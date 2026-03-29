# Example: Batch Convert PNG to JPEG

This example demonstrates how to use the [`tensors/imagekit`](https://central.ballerina.io/tensors/imagekit) library to convert a directory of PNG images to JPEG and resize them to fit within a target resolution while preserving aspect ratio.

## Overview

The program scans an `input/` directory, converts every PNG to JPEG, resizes each output to fit within 1280×720, and writes the results to an `output/` directory. Original files are not modified.

## Prerequisites

- [Ballerina Swan Lake](https://ballerina.io/downloads/) 2201.x or later
- `tensors/imagekit` published to Ballerina Central or available locally

## Project Structure

```
batch-convert/
├── Ballerina.toml          # package manifest with imagekit dependency
├── main.bal                # main program
├── input/                  # place your PNG input images here
│   ├── image1.jpeg
│   ├── image2.jpeg
│   └── image3.jpeg
├── output/                 # converted JPEG files are written here (git-ignored)
└── tests/
    ├── fixtures/           # test images
    └── lib_test.bal        # unit tests
```

## Run

Place your PNG files inside the `input/` directory, then:

```bash
bal run
```

### Expected Output

```
[OK] image1.jpeg  3024x4032 → 540x720 JPEG
[OK] image2.jpeg  4032x3024 → 1280x960 JPEG
[OK] image3.jpeg  3024x4032 → 540x720 JPEG
Converted 3 file(s) to output/
```

## Customise Target Resolution

Edit the constants in `main.bal` to change the output resolution:

```ballerina
const int MAX_WIDTH  = 1280;
const int MAX_HEIGHT = 720;
```

## Run Tests

```bash
bal test
```

The tests verify JPEG→PNG conversion, resize-after-convert behaviour, and batch processing of all three sample images.
