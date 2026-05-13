# ome_write

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
  type = c("image", "label")
)

# S4 method for class 'character'
ome_write(
  image,
  path = "/",
  axes = NULL,
  scalefactors = c(2, 2, 2, 2),
  version = c("0.4", "0.5"),
  storage_options = NULL,
  type = c("image", "label")
)

# S4 method for class 'array'
ome_write(
  image,
  path = "/",
  axes = NULL,
  scalefactors = c(2, 2, 2, 2),
  version = c("0.4", "0.5"),
  storage_options = NULL,
  type = c("image", "label")
)

# S4 method for class 'Image'
ome_write(
  image,
  path = "/",
  axes = NULL,
  scalefactors = c(2, 2, 2, 2),
  version = c("0.4", "0.5"),
  storage_options = NULL,
  type = c("image", "label")
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

  OME-ZARR version (0.4 or 0.5), lower versions are not supported for
  writing.

- storage_options:

  a list of storage options for the zarr array (e.g. chunks)

- type:

  The type of OME pyramid written: 'image' (default) or 'label'.
