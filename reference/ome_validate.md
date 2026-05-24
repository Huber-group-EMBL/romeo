# Validate a multiscale OME-Zarr file

Validate a multiscale OME-Zarr file

## Usage

``` r
ome_validate(path, s3_client = NULL)
```

## Arguments

- path:

  Path to the OME-Zarr file.

- s3_client:

  Object created by
  [`paws.storage::s3()`](https://paws-r.r-universe.dev/paws.storage/reference/s3.html).
  Only required for a file on S3. Leave as `NULL` for a file on local
  storage.

## Value

This function is used for its side-effect and will return the type of
the OME-Zarr schema (image, label), otherwise will invoke an error when
passed an invalid OME-Zarr file

## Examples

``` r
omezarrzip <- system.file("extdata",
                          "test_ngff_image_v04.ome.zarr.zip",
                          package = "rome")
dir.create(td <- tempfile())
unzip(omezarrzip, exdir = td)
ome_validate(td)
#> [1] "image"
```
