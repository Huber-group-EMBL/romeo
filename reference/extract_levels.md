# Extract specific levels from a multiscale `ome-zarr` object

Extract specific levels from a multiscale `ome-zarr` object

## Usage

``` r
extract_levels(x, levels)
```

## Arguments

- x:

  An `ome-zarr` object.

- levels:

  Integer vector specifying the levels to extract.

## Value

- If `levels` is of length 1, an array

- If `levels` is of length more than 1, an `ome-zarr` object

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
extract_levels(x, c(1, 3))
#> Multiscale OME-Zarr  (v) object.
#> Scale: 1/2 
#> <5 x 5> DelayedMatrix object of type "integer":
#>      [,1] [,2] [,3] [,4] [,5]
#> [1,]    8    8    8    8    8
#> [2,]    8    8    7    8    8
#> [3,]    9    8    8    8    8
#> [4,]    8    9    8    9    8
#> [5,]    9    8    8    9    8
extract_levels(x, 2)
#> <256 x 256> ZarrMatrix object of type "integer":
#>          [,1]   [,2]   [,3]   [,4] ... [,253] [,254] [,255] [,256]
#>   [1,]      7      7      7      8   .     14     19     54     72
#>   [2,]      8      8      8      8   .     15     18     42     62
#>   [3,]      8      8      8      8   .     14     15     25     48
#>   [4,]      7      8      8      8   .     15     15     17     21
#>   [5,]      7      8      8      8   .     16     14     15     17
#>    ...      .      .      .      .   .      .      .      .      .
#> [252,]      7      7      7      7   .     13     13     14     15
#> [253,]      8      7      7      7   .     12     12     14     17
#> [254,]      8      7      7      7   .     13     13     15     27
#> [255,]      8      7      7      8   .     14     13     15     38
#> [256,]      8      7      7      8   .     12     13     15     32
```
