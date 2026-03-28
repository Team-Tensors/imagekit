# imagekit

A general-purpose image processing library for Ballerina — the Ballerina equivalent of
Python's [Pillow](https://python-pillow.org/). Wraps Java's `javax.imageio` and `java.awt`
via Ballerina–Java interop. Supports PNG, JPEG, BMP, and GIF.

## Quick Start

```ballerina
import tensors/imagekit;

public function main() returns error? {
    // Read image metadata
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

    // Convert format
    check imagekit:convert("photo.png", "photo.jpg", "JPEG");

    // Create thumbnail (fits within 200×200, aspect ratio preserved)
    check imagekit:thumbnail("photo.png", "thumb.png", 200, 200);
}
```

## Batch Crop

```ballerina
imagekit:CropSummary summary = check imagekit:cropDirectory(
    "images/",
    top    = 20,
    bottom = 20,
    backup = true   // saves originals as *.orig.png
);
io:println("Cropped " + summary.processed.toString() + " files, "
    + summary.pixelReductionPct.toString() + "% pixel reduction");
```

## API Reference

| Function           | Description                                              |
|--------------------|----------------------------------------------------------|
| `getInfo`          | Read width, height, format, and file size                |
| `crop`             | Remove pixels from each edge in-place                    |
| `cropDirectory`    | Batch-crop all PNGs in a directory                       |
| `resize`           | Resize to exact pixel dimensions in-place                |
| `resizeToFit`      | Resize to fit a bounding box (preserves aspect ratio)    |
| `rotate`           | Rotate 90 / 180 / 270° clockwise in-place                |
| `flipHorizontal`   | Mirror left↔right in-place                              |
| `flipVertical`     | Mirror top↔bottom in-place                              |
| `toGrayscale`      | Convert to grayscale in-place                            |
| `convert`          | Convert to a different format, writing a new file        |
| `thumbnail`        | Create a scaled copy fitting a bounding box              |

## Comparison with Pillow

| Pillow                              | imagekit                                    |
|-------------------------------------|---------------------------------------------|
| `Image.open(f).size`                | `getInfo(f)` → `ImageInfo`                  |
| `img.crop((l, t, r, b))`           | `crop(f, top, bottom, left, right)`         |
| `img.resize((w, h))`               | `resize(f, w, h)`                           |
| `img.thumbnail((w, h))`            | `resizeToFit(f, w, h)`                      |
| `img.rotate(deg)`                  | `rotate(f, deg)`                            |
| `ImageOps.mirror(img)`             | `flipHorizontal(f)`                         |
| `ImageOps.flip(img)`               | `flipVertical(f)`                           |
| `img.convert("L")`                 | `toGrayscale(f)`                            |
| `img.save("out.jpg")`              | `convert(src, dest, "JPEG")`                |
| `img.thumbnail((w, h)); img.save`  | `thumbnail(src, dest, w, h)`                |
