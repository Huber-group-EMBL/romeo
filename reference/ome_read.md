# Read a multiscale OME-Zarr file

Read a multiscale OME-Zarr file

## Usage

``` r
ome_read(path, s3_client = NULL, lazy = TRUE, validate = TRUE)
```

## Arguments

- path:

  Path to the OME-Zarr file.

- s3_client:

  Object created by
  [`paws.storage::s3()`](https://paws-r.r-universe.dev/paws.storage/reference/s3.html).
  Only required for a file on S3. Leave as `NULL` for a file on local
  storage.

- lazy:

  Logical. If `TRUE` (the default), use ZarrArray to read data lazily.
  If `FALSE`, read data into memory using Rarr. If the data can fit into
  memory, setting `lazy = FALSE` may result in better performance.

- validate:

  Logical.If `TRUE` (the default), validate the OME-Zarr file.

## Value

An object of `ome_zarr` (OME-Zarr) class representing an image or label
pyramid.

## Examples

``` r
omezarrzip <- system.file("extdata", 
                          "test_ngff_image_v04.ome.zarr.zip", 
                          package = "rome")
dir.create(td <- tempfile())
unzip(omezarrzip, exdir = td)
x <- ome_read(td)
```
