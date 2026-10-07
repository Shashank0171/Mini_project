#!/usr/bin/env python3
"""
Generate a professional PDF containing all 9 UML diagrams.
Each diagram is placed on a separate A4 landscape page with a title header.
"""

from PIL import Image
import os

# Diagram files in order with their titles
diagrams = [
    ("01_Use_Case_Diagram.png", "1. Use Case Diagram"),
    ("02_Class_Diagram.png", "2. Class Diagram"),
    ("03_Object_Diagram.png", "3. Object Diagram"),
    ("04_Sequence_Diagram.png", "4. Sequence Diagram"),
    ("05_Communication_Diagram.png", "5. Communication Diagram"),
    ("06_Activity_Diagram.png", "6. Activity Diagram"),
    ("07_State_Machine_Diagram.png", "7. State Machine Diagram"),
    ("08_Component_Diagram.png", "8. Component Diagram"),
    ("09_Deployment_Diagram.png", "9. Deployment Diagram"),
]

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

# A4 dimensions at 200 DPI (landscape)
A4_WIDTH_LANDSCAPE = 2339   # 297mm at 200dpi
A4_HEIGHT_LANDSCAPE = 1654  # 210mm at 200dpi

# A4 portrait
A4_WIDTH_PORTRAIT = 1654
A4_HEIGHT_PORTRAIT = 2339

MARGIN = 80
HEADER_HEIGHT = 100

pdf_pages = []

for filename, title in diagrams:
    filepath = os.path.join(SCRIPT_DIR, filename)
    if not os.path.exists(filepath):
        print(f"Warning: {filename} not found, skipping.")
        continue

    img = Image.open(filepath).convert("RGB")
    img_w, img_h = img.size

    # Decide orientation based on aspect ratio
    aspect = img_w / img_h
    if aspect >= 1.0:
        # Landscape page
        page_w, page_h = A4_WIDTH_LANDSCAPE, A4_HEIGHT_LANDSCAPE
    else:
        # Portrait page
        page_w, page_h = A4_WIDTH_PORTRAIT, A4_HEIGHT_PORTRAIT

    # Available area for the diagram (after margins and header)
    avail_w = page_w - 2 * MARGIN
    avail_h = page_h - 2 * MARGIN - HEADER_HEIGHT

    # Scale diagram to fit available area
    scale_w = avail_w / img_w
    scale_h = avail_h / img_h
    scale = min(scale_w, scale_h, 1.0)  # Don't upscale

    new_w = int(img_w * scale)
    new_h = int(img_h * scale)

    if scale < 1.0:
        img_resized = img.resize((new_w, new_h), Image.LANCZOS)
    else:
        img_resized = img

    # Create white page
    page = Image.new("RGB", (page_w, page_h), "white")

    # Center the diagram on the page (below header area)
    x_offset = (page_w - new_w) // 2
    y_offset = HEADER_HEIGHT + MARGIN + (avail_h - new_h) // 2

    page.paste(img_resized, (x_offset, y_offset))

    # Add title text using Pillow's built-in font
    from PIL import ImageDraw, ImageFont
    draw = ImageDraw.Draw(page)

    # Try to get a reasonable font
    try:
        font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 36)
        small_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 20)
    except (IOError, OSError):
        try:
            font = ImageFont.truetype("/System/Library/Fonts/SFNSText.ttf", 36)
            small_font = ImageFont.truetype("/System/Library/Fonts/SFNSText.ttf", 20)
        except (IOError, OSError):
            font = ImageFont.load_default()
            small_font = font

    # Draw title centered at top
    project_title = "A Smart Device for Visually Impaired Individuals to Transform Images into Speech"
    
    # Project title (smaller, above diagram title)
    bbox_proj = draw.textbbox((0, 0), project_title, font=small_font)
    proj_w = bbox_proj[2] - bbox_proj[0]
    draw.text(((page_w - proj_w) // 2, MARGIN // 2), project_title, fill="black", font=small_font)

    # Diagram title (larger)
    bbox = draw.textbbox((0, 0), title, font=font)
    title_w = bbox[2] - bbox[0]
    draw.text(((page_w - title_w) // 2, MARGIN // 2 + 40), title, fill="black", font=font)

    # Draw a thin separator line under the header
    line_y = HEADER_HEIGHT + MARGIN // 2
    draw.line([(MARGIN, line_y), (page_w - MARGIN, line_y)], fill="black", width=2)

    # Page number at bottom
    page_num = f"Page {len(pdf_pages) + 1} of {len(diagrams)}"
    bbox_pn = draw.textbbox((0, 0), page_num, font=small_font)
    pn_w = bbox_pn[2] - bbox_pn[0]
    draw.text(((page_w - pn_w) // 2, page_h - MARGIN + 10), page_num, fill="gray", font=small_font)

    pdf_pages.append(page)
    print(f"✓ Added: {title} ({img_w}x{img_h} → {new_w}x{new_h})")

# Save as PDF
output_path = os.path.join(SCRIPT_DIR, "UML_Diagrams_Complete.pdf")
if pdf_pages:
    pdf_pages[0].save(
        output_path,
        save_all=True,
        append_images=pdf_pages[1:],
        resolution=200.0,
    )
    print(f"\n✅ PDF saved: {output_path}")
    print(f"   Total pages: {len(pdf_pages)}")
else:
    print("❌ No diagrams found!")
