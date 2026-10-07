import numpy as np
from PIL import Image


class CurrencyService:
    """Detects Indian currency notes by analyzing dominant colors."""

    _instance = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance

    # Indian currency color profiles (average H, S, V ranges)
    CURRENCY_PROFILES = {
        "₹10": {
            "color": "brown/chocolate",
            "h_range": (8, 25),
            "s_range": (40, 180),
            "v_range": (80, 200),
        },
        "₹20": {
            "color": "greenish yellow",
            "h_range": (25, 45),
            "s_range": (40, 180),
            "v_range": (100, 220),
        },
        "₹50": {
            "color": "fluorescent blue",
            "h_range": (90, 120),
            "s_range": (30, 160),
            "v_range": (100, 230),
        },
        "₹100": {
            "color": "lavender",
            "h_range": (120, 155),
            "s_range": (20, 120),
            "v_range": (120, 240),
        },
        "₹200": {
            "color": "bright yellow/orange",
            "h_range": (15, 35),
            "s_range": (100, 255),
            "v_range": (150, 255),
        },
        "₹500": {
            "color": "stone grey/green",
            "h_range": (45, 90),
            "s_range": (15, 100),
            "v_range": (100, 210),
        },
        "₹2000": {
            "color": "magenta pink",
            "h_range": (155, 175),
            "s_range": (30, 160),
            "v_range": (100, 230),
        },
    }

    def detect_currency(self, image_path: str) -> dict:
        """Analyze image to detect Indian currency denomination."""
        try:
            img = Image.open(image_path).convert("RGB")
            img_array = np.array(img)

            # Convert to HSV for color analysis
            # Simple RGB to HSV conversion
            r, g, b = (
                img_array[:, :, 0].astype(float),
                img_array[:, :, 1].astype(float),
                img_array[:, :, 2].astype(float),
            )

            # Crop center 60% of image (where the note likely is)
            h_img, w_img = r.shape
            y1, y2 = int(h_img * 0.2), int(h_img * 0.8)
            x1, x2 = int(w_img * 0.2), int(w_img * 0.8)
            r, g, b = r[y1:y2, x1:x2], g[y1:y2, x1:x2], b[y1:y2, x1:x2]

            # Calculate HSV
            r_n, g_n, b_n = r / 255.0, g / 255.0, b / 255.0
            c_max = np.maximum(np.maximum(r_n, g_n), b_n)
            c_min = np.minimum(np.minimum(r_n, g_n), b_n)
            delta = c_max - c_min

            # Hue
            hue = np.zeros_like(delta)
            mask_r = (c_max == r_n) & (delta > 0)
            mask_g = (c_max == g_n) & (delta > 0)
            mask_b = (c_max == b_n) & (delta > 0)
            hue[mask_r] = 60 * (((g_n[mask_r] - b_n[mask_r]) / delta[mask_r]) % 6)
            hue[mask_g] = 60 * (((b_n[mask_g] - r_n[mask_g]) / delta[mask_g]) + 2)
            hue[mask_b] = 60 * (((r_n[mask_b] - g_n[mask_b]) / delta[mask_b]) + 4)
            hue = hue / 2  # Convert to 0-180 range

            # Saturation
            sat = np.zeros_like(delta)
            non_zero = c_max > 0
            sat[non_zero] = (delta[non_zero] / c_max[non_zero]) * 255

            # Value
            val = c_max * 255

            # Get median values
            med_h = np.median(hue)
            med_s = np.median(sat)
            med_v = np.median(val)

            # Also get average RGB for additional matching
            avg_r = np.mean(r)
            avg_g = np.mean(g)
            avg_b = np.mean(b)

            # Match against profiles
            best_match = None
            best_score = 0

            for denomination, profile in self.CURRENCY_PROFILES.items():
                h_min, h_max = profile["h_range"]
                s_min, s_max = profile["s_range"]
                v_min, v_max = profile["v_range"]

                # Score based on how close the median values are to the expected ranges
                h_score = 1.0 if h_min <= med_h <= h_max else max(
                    0, 1.0 - min(abs(med_h - h_min), abs(med_h - h_max)) / 30
                )
                s_score = 1.0 if s_min <= med_s <= s_max else max(
                    0, 1.0 - min(abs(med_s - s_min), abs(med_s - s_max)) / 50
                )
                v_score = 1.0 if v_min <= med_v <= v_max else max(
                    0, 1.0 - min(abs(med_v - v_min), abs(med_v - v_max)) / 50
                )

                score = (h_score * 0.5 + s_score * 0.25 + v_score * 0.25)

                if score > best_score:
                    best_score = score
                    best_match = denomination

            if best_score >= 0.4 and best_match:
                return {
                    "denomination": best_match,
                    "confidence": round(best_score, 2),
                    "color": self.CURRENCY_PROFILES[best_match]["color"],
                    "detected": True,
                }
            else:
                return {
                    "denomination": "Unknown",
                    "confidence": 0.0,
                    "color": "unrecognized",
                    "detected": False,
                }

        except Exception as e:
            return {
                "denomination": "Error",
                "confidence": 0.0,
                "color": str(e),
                "detected": False,
            }
