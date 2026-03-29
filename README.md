# imagekit

[![Ballerina Central](https://img.shields.io/badge/Ballerina%20Central-tensors%2Fimagekit-blue)](https://central.ballerina.io/tensors/imagekit)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![GitHub last commit](https://img.shields.io/github/last-commit/Team-Tensors/imagekit)](https://github.com/Team-Tensors/imagekit/commits/main)

A general-purpose image processing library for Ballerina — the Ballerina equivalent of Python's [Pillow](https://python-pillow.org/).

Wraps Java's `javax.imageio` and `java.awt` via Ballerina–Java interop with zero external Maven dependencies.

**Supported formats:** PNG · JPEG · BMP · GIF

---

## Features

| Operation | Description |
|---|---|
| `getInfo` | Read width, height, format, and file size |
| `crop` | Remove pixels from each edge in-place |
| `cropDirectory` | Batch-crop all PNGs in a directory |
| `resize` | Resize to exact pixel dimensions in-place |
| `resizeToFit` | Resize to fit a bounding box (preserves aspect ratio) |
| `rotate` | Rotate 90 / 180 / 270° clockwise in-place |
| `flipHorizontal` | Mirror left↔right in-place |
| `flipVertical` | Mirror top↔bottom in-place |
| `toGrayscale` | Convert to grayscale in-place |
| `convert` | Convert to a different format, writing a new file |
| `thumbnail` | Create a scaled copy that fits a bounding box |

---

## Installation

Add the dependency to your `Ballerina.toml`:

```toml
[[dependency]]
org     = "tensors"
name    = "imagekit"
version = "0.1.0"
```

---

## Quick Start

```ballerina
import tensors/imagekit;
import ballerina/io;

public function main() returns error? {
    // Read metadata
    imagekit:ImageInfo info = check imagekit:getInfo("photo.png");
    io:println(info.width.toString() + "x" + info.height.toString() + " " + info.format);

    // Crop
    check imagekit:crop("photo.png", top = 20, bottom = 20, left = 10, right = 10);

    // Resize to exact dimensions
    check imagekit:resize("photo.png", 1920, 1080);

    // Resize preserving aspect ratio
    check imagekit:resizeToFit("photo.png", 800, 600);

    // Rotate 90° clockwise
    check imagekit:rotate("photo.png", 90);

    // Mirror
    check imagekit:flipHorizontal("photo.png");
    check imagekit:flipVertical("photo.png");

    // Grayscale
    check imagekit:toGrayscale("photo.png");

    // Convert format (writes a new file)
    check imagekit:convert("photo.png", "photo.jpg", "JPEG");

    // Create thumbnail (fits within 200×200, aspect ratio preserved)
    check imagekit:thumbnail("photo.png", "thumb.png", 200, 200);
}
```

---

## Examples

| Example | Description |
|---|---|
| [crop-screenshots](examples/crop-screenshots/) | Crop UI chrome from a directory of PNG screenshots |
| [generate-thumbnails](examples/generate-thumbnails/) | Batch-generate thumbnails for a directory of images |
| [batch-convert](examples/batch-convert/) | Convert all PNGs to JPEG and resize to fit 1280×720 |

---

## Comparison with Pillow

| Pillow | imagekit |
|---|---|
| `Image.open(f).size` | `getInfo(f)` → `ImageInfo` |
| `img.crop((l, t, r, b))` | `crop(f, top, bottom, left, right)` |
| `img.resize((w, h))` | `resize(f, w, h)` |
| `img.thumbnail((w, h))` | `resizeToFit(f, w, h)` |
| `img.rotate(deg)` | `rotate(f, deg)` |
| `ImageOps.mirror(img)` | `flipHorizontal(f)` |
| `ImageOps.flip(img)` | `flipVertical(f)` |
| `img.convert("L")` | `toGrayscale(f)` |
| `img.save("out.jpg")` | `convert(src, dest, "JPEG")` |
| `img.thumbnail((w,h)); img.save` | `thumbnail(src, dest, w, h)` |

---

## Building from Source

### Prerequisites

- Ballerina Swan Lake 2201.x or later
- Java 17+ JDK
- Gradle 7+

### Build

```bash
# 1. Build the Java native layer
cd native && gradle build && cd ..

# 2. Build the Ballerina package
bal build

# 3. Run tests
bal test
```

---

## License

Apache License 2.0 — see [LICENSE](LICENSE).
