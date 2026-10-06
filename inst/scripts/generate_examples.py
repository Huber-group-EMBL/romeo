# /// script
# requires-python = "==3.13.0"
# dependencies = [
#   "ome-zarr==0.19.0",
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
from skimage.data import human_mitosis
from skimage.filters import threshold_multiotsu
from ome_zarr import OMEZarrImage, OMEZarrLabels, OMEZarrMultiscale

# generate image
data = human_mitosis()

# generate labels
thresholds = threshold_multiotsu(data, classes=3)
blobs = np.digitize(data, bins=thresholds)

scale_factors = (2, 4, 8, 16)

for version in ["0.4", "0.5", "0.6"]:
    path = f"inst/extdata/test_ngff_image_v{version.replace('.', '')}.ome.zarr"

    if os.path.exists(path) and os.path.isdir(path):
        shutil.rmtree(path)

    # write image
    image = OMEZarrImage(
        data,
        axes=['y', 'x']
    )

    # write labels
    label_image = OMEZarrImage(data=blobs, axes=["y", "x"], name="blobs")
    labels = OMEZarrLabels(image=label_image, scale_factors=scale_factors)

    multiscales = OMEZarrMultiscale(
        image=image,
        scale_factors=scale_factors,
        method="resize",
        labels=labels
    )

    multiscales.to_ome_zarr(path, version=version)

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
