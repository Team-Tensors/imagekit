package io.tensors.imagecrop;

import io.ballerina.runtime.api.values.BString;
import io.ballerina.runtime.api.utils.StringUtils;

import javax.imageio.ImageIO;
import javax.imageio.ImageReader;
import javax.imageio.stream.ImageInputStream;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.util.Iterator;

public class ImageCropper {

    // ── Info ─────────────────────────────────────────────────────────

    /**
     * Returns "width,height,format,fileSize" or "ERROR:..." on failure.
     */
    public static BString getImageInfo(BString filePath) {
        String path = filePath.getValue();
        try {
            File file = new File(path);
            BufferedImage img = ImageIO.read(file);
            if (img == null) return error("Cannot read image: " + path);
            String fmt = detectFormat(path);
            return StringUtils.fromString(img.getWidth() + "," + img.getHeight() + "," + fmt + "," + file.length());
        } catch (IOException e) {
            return error(e.getMessage());
        }
    }

    /**
     * Returns "WIDTHxHEIGHT" or "ERROR:..." on failure.
     */
    public static BString getImageDimensions(BString filePath) {
        try {
            BufferedImage img = ImageIO.read(new File(filePath.getValue()));
            if (img == null) return error("Cannot read image: " + filePath.getValue());
            return StringUtils.fromString(img.getWidth() + "x" + img.getHeight());
        } catch (IOException e) {
            return error(e.getMessage());
        }
    }

    // ── Crop ─────────────────────────────────────────────────────────

    /**
     * Crops in-place. Returns "" on success, error message on failure.
     */
    public static BString cropImage(BString filePath, long top, long bottom, long left, long right) {
        String path = filePath.getValue();
        try {
            File file = new File(path);
            BufferedImage img = ImageIO.read(file);
            if (img == null) return fail("Cannot read image: " + path);

            int w = img.getWidth(), h = img.getHeight();
            int x = (int) left, y = (int) top;
            int x2 = w - (int) right, y2 = h - (int) bottom;

            if (x >= x2 || y >= y2)
                return fail("Margins exceed image dimensions (" + w + "x" + h + ")");

            int nw = x2 - x, nh = y2 - y;
            BufferedImage out = new BufferedImage(nw, nh, safeType(img));
            Graphics2D g = out.createGraphics();
            g.drawImage(img.getSubimage(x, y, nw, nh), 0, 0, null);
            g.dispose();
            writeImage(out, detectFormat(path), file);
            return StringUtils.fromString("");
        } catch (IOException e) {
            return fail(e.getMessage());
        }
    }

    // ── Resize ───────────────────────────────────────────────────────

    /**
     * Resizes to exact dimensions in-place. Returns "" on success, error message on failure.
     */
    public static BString resizeImage(BString filePath, long width, long height) {
        String path = filePath.getValue();
        try {
            File file = new File(path);
            BufferedImage img = ImageIO.read(file);
            if (img == null) return fail("Cannot read image: " + path);

            BufferedImage out = new BufferedImage((int) width, (int) height, safeType(img));
            Graphics2D g = out.createGraphics();
            g.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BILINEAR);
            g.setRenderingHint(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY);
            g.drawImage(img, 0, 0, (int) width, (int) height, null);
            g.dispose();
            writeImage(out, detectFormat(path), file);
            return StringUtils.fromString("");
        } catch (IOException e) {
            return fail(e.getMessage());
        }
    }

    /**
     * Resizes to fit within maxWidth x maxHeight, preserving aspect ratio.
     * Returns "" on success, error message on failure.
     */
    public static BString resizeToFit(BString filePath, long maxWidth, long maxHeight) {
        String path = filePath.getValue();
        try {
            File file = new File(path);
            BufferedImage img = ImageIO.read(file);
            if (img == null) return fail("Cannot read image: " + path);

            double scale = Math.min((double) maxWidth / img.getWidth(), (double) maxHeight / img.getHeight());
            int nw = Math.max((int) (img.getWidth() * scale), 1);
            int nh = Math.max((int) (img.getHeight() * scale), 1);

            BufferedImage out = new BufferedImage(nw, nh, safeType(img));
            Graphics2D g = out.createGraphics();
            g.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BILINEAR);
            g.setRenderingHint(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY);
            g.drawImage(img, 0, 0, nw, nh, null);
            g.dispose();
            writeImage(out, detectFormat(path), file);
            return StringUtils.fromString("");
        } catch (IOException e) {
            return fail(e.getMessage());
        }
    }

    // ── Rotate ───────────────────────────────────────────────────────

    /**
     * Rotates clockwise by 90, 180, or 270 degrees in-place.
     * Returns "" on success, error message on failure.
     */
    public static BString rotateImage(BString filePath, long degrees) {
        String path = filePath.getValue();
        try {
            File file = new File(path);
            BufferedImage img = ImageIO.read(file);
            if (img == null) return fail("Cannot read image: " + path);

            int w = img.getWidth(), h = img.getHeight();
            boolean swap = (degrees == 90 || degrees == 270);
            int nw = swap ? h : w, nh = swap ? w : h;

            BufferedImage out = new BufferedImage(nw, nh, safeType(img));
            Graphics2D g = out.createGraphics();
            g.translate(nw / 2.0, nh / 2.0);
            g.rotate(Math.toRadians(degrees));
            g.translate(-w / 2.0, -h / 2.0);
            g.drawImage(img, 0, 0, null);
            g.dispose();
            writeImage(out, detectFormat(path), file);
            return StringUtils.fromString("");
        } catch (IOException e) {
            return fail(e.getMessage());
        }
    }

    // ── Flip ─────────────────────────────────────────────────────────

    /**
     * Flips horizontally or vertically in-place.
     * Returns "" on success, error message on failure.
     */
    public static BString flipImage(BString filePath, boolean horizontal) {
        String path = filePath.getValue();
        try {
            File file = new File(path);
            BufferedImage img = ImageIO.read(file);
            if (img == null) return fail("Cannot read image: " + path);

            int w = img.getWidth(), h = img.getHeight();
            BufferedImage out = new BufferedImage(w, h, safeType(img));
            Graphics2D g = out.createGraphics();
            if (horizontal) g.drawImage(img, w, 0, -w, h, null);
            else            g.drawImage(img, 0, h, w, -h, null);
            g.dispose();
            writeImage(out, detectFormat(path), file);
            return StringUtils.fromString("");
        } catch (IOException e) {
            return fail(e.getMessage());
        }
    }

    // ── Grayscale ────────────────────────────────────────────────────

    /**
     * Converts to grayscale in-place.
     * Returns "" on success, error message on failure.
     */
    public static BString toGrayscale(BString filePath) {
        String path = filePath.getValue();
        try {
            File file = new File(path);
            BufferedImage img = ImageIO.read(file);
            if (img == null) return fail("Cannot read image: " + path);

            BufferedImage out = new BufferedImage(img.getWidth(), img.getHeight(), BufferedImage.TYPE_BYTE_GRAY);
            Graphics2D g = out.createGraphics();
            g.drawImage(img, 0, 0, null);
            g.dispose();
            writeImage(out, detectFormat(path), file);
            return StringUtils.fromString("");
        } catch (IOException e) {
            return fail(e.getMessage());
        }
    }

    // ── Convert ──────────────────────────────────────────────────────

    /**
     * Converts an image to a different format, writing to destPath.
     * Returns "" on success, error message on failure.
     */
    public static BString convertImage(BString srcPath, BString destPath, BString format) {
        try {
            BufferedImage img = ImageIO.read(new File(srcPath.getValue()));
            if (img == null) return fail("Cannot read image: " + srcPath.getValue());

            String fmt = format.getValue().toUpperCase();
            BufferedImage out = img;
            if (fmt.equals("JPEG") || fmt.equals("JPG")) {
                // JPEG does not support alpha; composite onto white
                out = new BufferedImage(img.getWidth(), img.getHeight(), BufferedImage.TYPE_INT_RGB);
                Graphics2D g = out.createGraphics();
                g.setColor(Color.WHITE);
                g.fillRect(0, 0, img.getWidth(), img.getHeight());
                g.drawImage(img, 0, 0, null);
                g.dispose();
                fmt = "JPEG";
            }
            boolean written = ImageIO.write(out, fmt, new File(destPath.getValue()));
            if (!written) {
                return fail("No image writer available for format: " + fmt);
            }
            return StringUtils.fromString("");
        } catch (IOException e) {
            return fail(e.getMessage());
        }
    }

    // ── Thumbnail ────────────────────────────────────────────────────

    /**
     * Creates a thumbnail at destPath fitting within maxWidth x maxHeight.
     * Returns "" on success, error message on failure.
     */
    public static BString createThumbnail(BString srcPath, BString destPath, long maxWidth, long maxHeight) {
        try {
            BufferedImage img = ImageIO.read(new File(srcPath.getValue()));
            if (img == null) return fail("Cannot read image: " + srcPath.getValue());

            double scale = Math.min((double) maxWidth / img.getWidth(), (double) maxHeight / img.getHeight());
            int nw = Math.max((int) (img.getWidth() * scale), 1);
            int nh = Math.max((int) (img.getHeight() * scale), 1);

            BufferedImage out = new BufferedImage(nw, nh, safeType(img));
            Graphics2D g = out.createGraphics();
            g.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BILINEAR);
            g.setRenderingHint(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY);
            g.drawImage(img, 0, 0, nw, nh, null);
            g.dispose();
            writeImage(out, detectFormat(srcPath.getValue()), new File(destPath.getValue()));
            return StringUtils.fromString("");
        } catch (IOException e) {
            return fail(e.getMessage());
        }
    }

    // ── Private helpers ──────────────────────────────────────────────

    /** Prefix "ERROR:" — used only by getImageInfo / getImageDimensions. */
    private static BString error(String msg) {
        return StringUtils.fromString("ERROR:" + msg);
    }

    /** Plain error string (no prefix) — used by mutating operations. */
    private static BString fail(String msg) {
        return StringUtils.fromString(msg);
    }

    private static void writeImage(BufferedImage img, String format, File dest) throws IOException {
        String fmt = (format == null || format.isEmpty()) ? "PNG" : format;
        if (!ImageIO.write(img, fmt, dest)) {
            ImageIO.write(img, "PNG", dest);
        }
    }

    private static String detectFormat(String path) {
        try (ImageInputStream iis = ImageIO.createImageInputStream(new File(path))) {
            if (iis != null) {
                Iterator<ImageReader> readers = ImageIO.getImageReaders(iis);
                if (readers.hasNext()) {
                    String fmt = readers.next().getFormatName().toUpperCase();
                    return fmt.equals("JPEG") ? "JPEG" : fmt;
                }
            }
        } catch (IOException ignored) {}
        int dot = path.lastIndexOf('.');
        if (dot >= 0) {
            String ext = path.substring(dot + 1).toUpperCase();
            return ext.equals("JPG") ? "JPEG" : ext;
        }
        return "PNG";
    }

    private static int safeType(BufferedImage img) {
        int t = img.getType();
        return t == 0 ? BufferedImage.TYPE_INT_ARGB : t;
    }
}
