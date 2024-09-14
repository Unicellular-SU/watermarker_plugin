use image::{GenericImageView, Rgba};
use std::path::Path;

#[flutter_rust_bridge::frb(dart_async)]
pub fn add_watermark(src_path: &str, watermark_path: &str, output_path: &str) {
    // Load the source image and watermark image
    let src_image = image::open(src_path).expect("Failed to open image");
    let watermark_image = image::open(watermark_path).expect("Failed to open image");

    // Get dimensions of source image
    let (src_width, src_height) = src_image.dimensions();

    // Calculate new dimensions of the watermark image
    let (new_watermark_width, new_watermark_height) = if src_width < src_height {
        (src_width, watermark_image.height() * src_width / watermark_image.width())
    } else {
        (src_width / 2, watermark_image.height() * (src_width / 2) / watermark_image.width())
    };

    // Resize the watermark image
    let resized_watermark = watermark_image.resize_exact(new_watermark_width, new_watermark_height, image::imageops::FilterType::Lanczos3);

    // Calculate position to place watermark (left bottom corner)
    let (x_pos, y_pos) = (0, src_height - new_watermark_height);

    // Create a mutable view of the source image
    let mut src_image_buffer = src_image.to_rgba8();

    // Overlay the watermark on the source image
    for y in 0..new_watermark_height {
        for x in 0..new_watermark_width {
            let pixel = resized_watermark.get_pixel(x, y);
            let alpha = pixel[3] as f32 / 255.0;
            if alpha > 0.0 {
                let src_pixel = src_image_buffer.get_pixel_mut(x + x_pos, y + y_pos);
                let blended_pixel = blend_pixels(*src_pixel, pixel, alpha);
                *src_pixel = blended_pixel;
            }
        }
    }

    // Save the result
    src_image_buffer.save(Path::new(output_path)).expect("Failed to save image");
}

fn blend_pixels(src: Rgba<u8>, watermark: Rgba<u8>, alpha: f32) -> Rgba<u8> {
    let inv_alpha = 1.0 - alpha;
    let blended = [
        (src[0] as f32 * inv_alpha + watermark[0] as f32 * alpha) as u8,
        (src[1] as f32 * inv_alpha + watermark[1] as f32 * alpha) as u8,
        (src[2] as f32 * inv_alpha + watermark[2] as f32 * alpha) as u8,
        255,
    ];
    Rgba(blended)
}