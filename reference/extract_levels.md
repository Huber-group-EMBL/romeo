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
#> <2 x 5 x 5> DelayedArray object of type "integer":
#> ,,1
#>      [,1] [,2] [,3] [,4] [,5]
#> [1,]   11   16    9   11   11
#> [2,]    9    7   10    6   11
#> 
#> ,,2
#>      [,1] [,2] [,3] [,4] [,5]
#> [1,]    2   11    8   11   10
#> [2,]   12    2    8   11   11
#> 
#> ,,3
#>      [,1] [,2] [,3] [,4] [,5]
#> [1,]   11    6   18    4    7
#> [2,]   12    8   13    6    9
#> 
#> ,,4
#>      [,1] [,2] [,3] [,4] [,5]
#> [1,]   13    8   17    6    3
#> [2,]    9    6    8    5    8
#> 
#> ,,5
#>      [,1] [,2] [,3] [,4] [,5]
#> [1,]   14   13    4   10    5
#> [2,]    9   11    6   12    6
#> 
extract_levels(x, 2)
#> <2 x 64 x 64> DelayedArray object of type "integer":
#> ,,1
#>       [,1]  [,2]  [,3]  [,4] ... [,61] [,62] [,63] [,64]
#> [1,]     9     9    11    11   .    11    10    11    11
#> [2,]     7     8     9    11   .     8     9    10     9
#> 
#> ,,2
#>       [,1]  [,2]  [,3]  [,4] ... [,61] [,62] [,63] [,64]
#> [1,]     9    10     7     8   .     9     9    11    11
#> [2,]     8     8     8     9   .     9    12    10     9
#> 
#> ...
#> 
#> ,,63
#>       [,1]  [,2]  [,3]  [,4] ... [,61] [,62] [,63] [,64]
#> [1,]    11    10    10    10   .    10    12    11     9
#> [2,]     9    12     9    11   .    10     8     9     9
#> 
#> ,,64
#>       [,1]  [,2]  [,3]  [,4] ... [,61] [,62] [,63] [,64]
#> [1,]     9     8     9     9   .    11     8     9    10
#> [2,]    10     7     9    10   .    12    13    10    11
#> 
```
