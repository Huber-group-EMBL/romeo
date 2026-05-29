# Subset an `ome-zarr` object

Subset operation is applied on all levels of the multiscale `ome-zarr`
object. The result is an `ome-zarr` object with the same number of
levels, but each level is subsetted according to the provided indices.

## Usage

``` r
# S3 method for class 'ome_zarr'
x[...]
```

## Arguments

- x:

  An `ome-zarr` object.

- ...:

  Indices to subset the `ome-zarr` object.

## Value

A subset of an object of `ome_zarr` (OME-Zarr) class representing an
image or label pyramid.

## Details

The first image is subsetted using the provided indices, and the
resulting dimensions are used to subset the remaining levels, while
conserving the same scaling factor across levels

## Examples

``` r
omezarrzip <- system.file("extdata",
                          "test_ngff_image_v04.ome.zarr.zip",
                          package = "romeo")
dir.create(td <- tempfile())
unzip(omezarrzip, exdir = td)
x <- ome_read(td)
y <- x[1:5,1:5]
plot(y, level = 2)

```
