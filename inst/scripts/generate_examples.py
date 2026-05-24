# /// script
# requires-python = "==3.13.0"
# dependencies = [
#   "ome-zarr==0.14.0",
#   "scikit-image==0.26.0",
#   "tifffile==2026.5.15",
#   "imagecodecs==2026.5.10",
#   "pooch==1.9.0"
# ]
# ///
import os
import shutil
import zipfile
import numpy as np
from skimage.data import binary_blobs, human_mitosis
from skimage.filters import threshold_multiotsu
import zarr
from ome_zarr.writer import write_image, write_labels
from ome_zarr.format import (
  FormatV04, 
  FormatV05
)

# ome versions
versions = {
    "04": FormatV04(),
    "05": FormatV05()
}

# generate image
data = human_mitosis()

# generate labels
thresholds = threshold_multiotsu(data, classes=3)
blobs = np.digitize(data, bins=thresholds)

for v, fmt in versions.items():
    path = f"inst/extdata/test_ngff_image_v{v}.ome.zarr"

    if os.path.exists(path) and os.path.isdir(path):
        shutil.rmtree(path)

    # ome-zarr==0.13.0 scaling method
    # Scaler(
    #       downscale=2,
    #       max_layer=2,      
    #       method="local_mean"
    # )
    
    # write image
    write_image(
        data,
        path,
        axes=['y', 'x'],
        fmt=fmt,
        scale_factors=(2,4,8,16)
    )
    
    # write labels
    root = zarr.open_group(path, mode="a", zarr_format = fmt.zarr_format)
    write_labels(
        blobs, 
        path, 
        axes="yx", 
        name="blobs", 
        fmt=fmt,
        scale_factors=(2,4,8,16)
    )

    # zip files
    zip_path = f"{path}.zip"
    with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as z:
        for root, dirs, files in os.walk(path):
            dirs.sort()
            files.sort()
            for file in files:
                full_path = os.path.join(root, file)
                rel_path = os.path.relpath(full_path, path)
                z.write(full_path, arcname=rel_path)

    shutil.rmtree(path)
