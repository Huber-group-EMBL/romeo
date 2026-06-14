# Write a multiscale OME-Zarr file

Writes an ome image to the zarr path according to ome-zarr specification

## Usage

``` r
ome_write(
  image,
  path = "/",
  axes = NULL,
  scalefactors = c(2, 2, 2, 2),
  version = c("0.4", "0.5"),
  storage_options = NULL,
  type = c("image", "label"),
  label_name = NULL,
  label_metadata = NULL
)

# S4 method for class 'array'
ome_write(
  image,
  path = "/",
  axes = NULL,
  scalefactors = c(2, 2, 2, 2),
  version = c("0.4", "0.5"),
  storage_options = NULL,
  type = c("image", "label"),
  label_name = NULL,
  label_metadata = NULL
)

# S4 method for class 'Image'
ome_write(
  image,
  path = "/",
  axes = NULL,
  scalefactors = c(2, 2, 2, 2),
  version = c("0.4", "0.5"),
  storage_options = NULL,
  type = c("image", "label"),
  label_name = NULL,
  label_metadata = NULL
)
```

## Arguments

- image:

  an n-dimensional (or a path to an) array representing the image data
  (1\<n\<6)

- path:

  the path to writing ome.zarr

- axes:

  a character vector specifying the axes of the image (e.g. c("t", "c",
  "z", "y", "x"))

- scalefactors:

  Scale factors to apply to construct a multiscale image. Importantly,
  each scale factor is relative to the previous scale factor. For
  example, if the scale factors are c(2, 2, 2), the returned multiscale
  image will have 4 scales.

- version:

  OME-Zarr version (0.4 or 0.5), lower versions are not supported for
  writing.

- storage_options:

  a list of storage options for the zarr array (e.g. chunks)

- type:

  The type of OME pyramid written: 'image' (default) or 'label'.

- label_name:

  The name of the label data.

- label_metadata:

  label metadata added to attributes.

## Value

An object of `ome_zarr` (OME-Zarr) class representing an image or label
pyramid.

## Examples

``` r
library(EBImage)
nuc <- readImage(system.file("images", "nuclei.tif", package="EBImage"))
nuc <- getFrames(nuc)[[1]]
td <- tempfile(fileext = ".ome.zarr")

# write image pyramid
ome_nuc <- ome_write(nuc,
                     path = td,
                     version = "0.4",
                     storage_options = list(chunk_dim = c(64,64)))

# nuclei segmentation using otsu's method
nuc_th = nuc > otsu(nuc)

# write label pyramid
ome_nuc_th <- ome_write(nuc_th,
                        path = td,
                        version = "0.4",
                        scalefactors = c(2,2,3),
                        storage_options = list(chunk_dim = c(64,64)),
                        label_name = "nuclei_segmentation",
                        type = "label")
#> An image pyramid was found at '/tmp/RtmpEJV3FK/file1bba52e0ffc6.ome.zarr', writing labels to 'labels/nuclei_segmentation'
```
