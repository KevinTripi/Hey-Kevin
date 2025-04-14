import os
import shutil
from APITESTING import main

INPUT_DIR = "lib/bing_api/images" #images from https://github.com/yavuzceliker/sample-images/tree/main/images
WORKING_IMG_PATH = "lib/bing_api/reduced.jpg"  # image used by main, is replaced
EXPORT_DIR = "lib/bing_api/exports"         # Contains exported_data.json-s for images

def ensure_dirs():
    os.makedirs(EXPORT_DIR, exist_ok=True)

def copy_image_to_working_path(image_path):
    shutil.copy(image_path, WORKING_IMG_PATH)

def generate_export_filename(image_path):
    base_name = os.path.splitext(os.path.basename(image_path))[0]
    return os.path.join(EXPORT_DIR, f"{base_name}_export.json")

def process_images():
    ensure_dirs()

    images = [f for f in os.listdir(INPUT_DIR) if f.lower().endswith(('.jpg', '.jpeg', '.png'))]

    if not images:
        print("No images found in the input directory.")
        return

    for img_file in images:
        print(f"\nProcessing: {img_file}")
        img_path = os.path.join(INPUT_DIR, img_file)

        try:
            # Replace reduced.jpg with the new image from folder
            copy_image_to_working_path(img_path)

            # Call main
            result_json = main()

            # Save the exported JSON under a new name
            export_path = generate_export_filename(img_path)
            with open(export_path, "w") as f:
                f.write(result_json)

            print(f"Exported JSON saved to {export_path}")

        except Exception as e:
            print(f"Failed to process {img_file}: {e}")

if __name__ == "__main__":
    process_images()
