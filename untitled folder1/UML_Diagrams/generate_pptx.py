#!/usr/bin/env python3
"""
Generate a PPTX presentation matching the Anurag University reference style.
Each slide contains one UML diagram with proper title and footer.
"""

from pptx import Presentation
from pptx.util import Inches, Pt, Emu
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN
import os

DIAGRAMS_DIR = os.path.dirname(os.path.abspath(__file__))

# Slide data: (image_file, diagram_title)
slides_data = [
    ("01_Use_Case_Diagram.png", "Use Case Diagram"),
    ("02_Class_Diagram.png", "Class Diagram"),
    ("03_Object_Diagram.png", "Object Diagram"),
    ("04_Sequence_Diagram.png", "Sequence Diagram"),
    ("05_Communication_Diagram.png", "Communication Diagram"),
    ("06_Activity_Diagram.png", "Activity Diagram"),
    ("07_State_Machine_Diagram.png", "State Machine Diagram"),
    ("08_Component_Diagram.png", "Component Diagram"),
    ("09_Deployment_Diagram.png", "Deployment Diagram"),
]

PROJECT_TITLE = "A Smart Device for Visually Impaired Individuals to Transform Images into Speech"
FOOTER_TEXT = "INDUSTRY ORIENTED MINI PROJECT (2026-2027), DEPARTMENT OF CSE - Anurag University"

# Create presentation (16:9 widescreen)
prs = Presentation()
prs.slide_width = Inches(13.333)
prs.slide_height = Inches(7.5)

SLIDE_W = prs.slide_width
SLIDE_H = prs.slide_height

def add_title_slide(prs):
    """Add a cover/title slide."""
    slide = prs.slides.add_slide(prs.slide_layouts[6])  # blank layout

    # Red-blue diagonal design (left accent bar)
    from pptx.util import Emu
    from pptx.enum.shapes import MSO_SHAPE

    # Red accent bar on left
    shape = slide.shapes.add_shape(
        MSO_SHAPE.RECTANGLE,
        Inches(0), Inches(0),
        Inches(0.6), SLIDE_H
    )
    shape.fill.solid()
    shape.fill.fore_color.rgb = RGBColor(200, 16, 46)
    shape.line.fill.background()

    # Blue accent strip
    shape2 = slide.shapes.add_shape(
        MSO_SHAPE.RECTANGLE,
        Inches(0.6), Inches(0),
        Inches(0.15), SLIDE_H
    )
    shape2.fill.solid()
    shape2.fill.fore_color.rgb = RGBColor(0, 51, 153)
    shape2.line.fill.background()

    # Title
    txBox = slide.shapes.add_textbox(Inches(1.2), Inches(1.5), Inches(11), Inches(1.5))
    tf = txBox.text_frame
    tf.word_wrap = True
    p = tf.paragraphs[0]
    p.text = "Design Phase — UML Diagrams"
    p.font.size = Pt(36)
    p.font.bold = True
    p.font.color.rgb = RGBColor(0, 0, 0)
    p.alignment = PP_ALIGN.CENTER

    # Project Title
    txBox2 = slide.shapes.add_textbox(Inches(1.2), Inches(3.2), Inches(11), Inches(1.5))
    tf2 = txBox2.text_frame
    tf2.word_wrap = True
    p2 = tf2.paragraphs[0]
    p2.text = PROJECT_TITLE
    p2.font.size = Pt(22)
    p2.font.bold = False
    p2.font.color.rgb = RGBColor(50, 50, 50)
    p2.alignment = PP_ALIGN.CENTER

    # Subtitle
    txBox3 = slide.shapes.add_textbox(Inches(1.2), Inches(4.8), Inches(11), Inches(1))
    tf3 = txBox3.text_frame
    tf3.word_wrap = True
    p3 = tf3.paragraphs[0]
    p3.text = "B.Tech CSE Mini Project"
    p3.font.size = Pt(18)
    p3.font.color.rgb = RGBColor(100, 100, 100)
    p3.alignment = PP_ALIGN.CENTER

    # Footer
    txBox4 = slide.shapes.add_textbox(Inches(1.2), Inches(6.5), Inches(11), Inches(0.5))
    tf4 = txBox4.text_frame
    tf4.word_wrap = True
    p4 = tf4.paragraphs[0]
    p4.text = FOOTER_TEXT
    p4.font.size = Pt(10)
    p4.font.color.rgb = RGBColor(120, 120, 120)
    p4.alignment = PP_ALIGN.CENTER


def add_diagram_slide(prs, image_path, diagram_title, slide_num):
    """Add a slide with UML diagram matching the reference style."""
    slide = prs.slides.add_slide(prs.slide_layouts[6])  # blank layout

    from pptx.enum.shapes import MSO_SHAPE
    from PIL import Image as PILImage

    # ---- Red accent bar on left (matching reference) ----
    shape = slide.shapes.add_shape(
        MSO_SHAPE.RECTANGLE,
        Inches(0), Inches(0),
        Inches(0.25), SLIDE_H
    )
    shape.fill.solid()
    shape.fill.fore_color.rgb = RGBColor(200, 16, 46)
    shape.line.fill.background()

    # ---- Blue thin strip ----
    shape2 = slide.shapes.add_shape(
        MSO_SHAPE.RECTANGLE,
        Inches(0.25), Inches(0),
        Inches(0.06), SLIDE_H
    )
    shape2.fill.solid()
    shape2.fill.fore_color.rgb = RGBColor(0, 51, 153)
    shape2.line.fill.background()

    # ---- Title: "UML Diagram – [Name]" ----
    txBox = slide.shapes.add_textbox(Inches(0.6), Inches(0.15), Inches(9), Inches(0.6))
    tf = txBox.text_frame
    tf.word_wrap = True
    p = tf.paragraphs[0]
    p.text = f"UML Diagram – {diagram_title}"
    p.font.size = Pt(24)
    p.font.bold = True
    p.font.color.rgb = RGBColor(0, 0, 0)
    p.alignment = PP_ALIGN.LEFT

    # ---- Horizontal separator line under title ----
    line = slide.shapes.add_shape(
        MSO_SHAPE.RECTANGLE,
        Inches(0.6), Inches(0.75),
        Inches(12.3), Inches(0.02)
    )
    line.fill.solid()
    line.fill.fore_color.rgb = RGBColor(0, 0, 0)
    line.line.fill.background()

    # ---- Add diagram image centered ----
    img_pil = PILImage.open(image_path)
    img_w_px, img_h_px = img_pil.size

    # Available area for diagram
    avail_left = Inches(0.8)
    avail_top = Inches(0.9)
    avail_width = Inches(11.7)
    avail_height = Inches(5.8)

    # Calculate scaling to fit
    scale_w = avail_width / Emu(int(img_w_px * 914400 / 200))  # 200 DPI
    scale_h = avail_height / Emu(int(img_h_px * 914400 / 200))

    img_width_emu = int(img_w_px * 914400 / 200)
    img_height_emu = int(img_h_px * 914400 / 200)

    if img_width_emu > avail_width or img_height_emu > avail_height:
        ratio_w = avail_width / img_width_emu
        ratio_h = avail_height / img_height_emu
        ratio = min(ratio_w, ratio_h)
        img_width_emu = int(img_width_emu * ratio)
        img_height_emu = int(img_height_emu * ratio)

    # Center the image
    x_center = avail_left + (avail_width - img_width_emu) // 2
    y_center = avail_top + (avail_height - img_height_emu) // 2

    slide.shapes.add_picture(image_path, x_center, y_center, img_width_emu, img_height_emu)

    # ---- Footer ----
    txBox2 = slide.shapes.add_textbox(Inches(0.6), Inches(7.0), Inches(12), Inches(0.4))
    tf2 = txBox2.text_frame
    tf2.word_wrap = True
    p2 = tf2.paragraphs[0]
    p2.text = FOOTER_TEXT
    p2.font.size = Pt(9)
    p2.font.color.rgb = RGBColor(120, 120, 120)
    p2.alignment = PP_ALIGN.LEFT

    # ---- Page number ----
    txBox3 = slide.shapes.add_textbox(Inches(12.3), Inches(7.0), Inches(0.8), Inches(0.4))
    tf3 = txBox3.text_frame
    p3 = tf3.paragraphs[0]
    p3.text = str(slide_num)
    p3.font.size = Pt(10)
    p3.font.color.rgb = RGBColor(150, 150, 150)
    p3.alignment = PP_ALIGN.RIGHT


# ============ BUILD PRESENTATION ============

# Title slide
add_title_slide(prs)

# Diagram slides
for i, (img_file, title) in enumerate(slides_data, 1):
    img_path = os.path.join(DIAGRAMS_DIR, img_file)
    if os.path.exists(img_path):
        add_diagram_slide(prs, img_path, title, i)
        print(f"✓ Slide {i}: {title}")
    else:
        print(f"✗ Missing: {img_file}")

# Save
output_path = os.path.join(DIAGRAMS_DIR, "DesignPhase_UMLDiagrams_MiniProject.pptx")
prs.save(output_path)
print(f"\n✅ PPTX saved: {output_path}")
print(f"   Total slides: {len(prs.slides)}")
