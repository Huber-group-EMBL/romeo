# Plot an `ome_zarr` object.

Plot an `ome_zarr` object.

## Usage

``` r
# S3 method for class 'ome_zarr'
plot(x, level = 1, ...)
```

## Arguments

- x:

  An `ome_zarr` object.

- level:

  Integer. The scale level to plot. Defaults to `1` (the highest
  resolution).

- ...:

  Additional arguments passed to
  [`plot()`](https://rdrr.io/r/graphics/plot.default.html).

## Value

None

## Examples

``` r
omezarrzip <- system.file("extdata",
                          "test_ngff_image_v04.ome.zarr.zip",
                          package = "romeo")
dir.create(td <- tempfile())
unzip(omezarrzip, exdir = td)
x <- ome_read(td)
plot(x)

plot(x, 2)

plot(x, all = TRUE)

```
