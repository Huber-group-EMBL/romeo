# /// script
# requires-python = "==3.13.0"
# dependencies = [
#   "ome-zarr==0.14.0",
#   "scikit-image==0.26.0"
# ]
# ///
import os
import shutil
import zipfile
import numpy as np
from skimage.data import binary_blobs
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
size_xy = 128
size_c = 2
rng = np.random.default_rng(0)
data = rng.poisson(lam=10, size=(size_c, size_xy, size_xy)).astype(np.uint8)

# generate labels
blobs = binary_blobs(length=size_xy, volume_fraction=0.1, n_dim=2).astype('int8')
blobs2 = binary_blobs(length=size_xy, volume_fraction=0.1, n_dim=2).astype('int8')
blobs += 2 * blobs2

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
        axes=['c', 'y', 'x'],
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
