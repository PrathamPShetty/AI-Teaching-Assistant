import base64
from PIL import Image
import io

def image_to_base64(image_path):
    """
    Convert an image to a base64-encoded string.

    Args:
        image_path (str): Path to the image file.

    Returns:
        str: Base64-encoded image string.
    """
    with open(image_path, "rb") as image_file:
        print("image is converted into base64")
        return base64.b64encode(image_file.read()).decode("utf-8")