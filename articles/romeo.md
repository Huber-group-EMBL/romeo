# Introduction to \`romeo\`

## Introduction

### romeo

*[romeo](https://bioconductor.org/packages/3.24/romeo)* is a minimal R
package that provides tools to read, validate, and write multiscale
images and labels (image labels, segmentation masks, etc.) stored as
OME-Zarr files.

The package also provides helpers and methods to manipulate the OME-Zarr
images and labels (as `ome_zarr` objects) the same way one would
manipulate traditional arrays in R. You can subset an `ome_zarr` object
like data arrays (using the `[` operator) where subsetting is applied to
all levels of the multiscale OME-Zarr object.

*[romeo](https://bioconductor.org/packages/3.24/romeo)* uses the
*[Rarr](https://bioconductor.org/packages/3.24/Rarr)* package to
manipulate images stored as Zarr datasets and OME-Zarr metadata while
the *[ZarrArray](https://bioconductor.org/packages/3.24/ZarrArray)*
package is used to lazily read larger-than-memory images.

### What is OME-Zarr?

OME-Zarr is a cloud-friendly data format for storing large bioimaging
datasets, such as microscopy images. It combines:

- **(i)** **Zarr**, a chunked, compressed array storage format
  (<https://zarr.dev/>) designed for scalable access to multidimensional
  data and
- **(ii)** **OME Next-Generation File Formats**, or **OME-NGFF**
  (<https://ngff.openmicroscopy.org/>), that defines standardized
  structures and metadata conventions for multiscale labels,
  segmentations, and coordinate transformations of bioimaging datasets.

In essence, an OME-Zarr file is a collection of data arrays with XYZCT
dimensions representing an image pyramid, combined with metadata (lives
in the attributes property of Zarr arrays) that describes the properties
of these arrays, such as scales, annotations and coordinate spaces
(Figure 1).

Currently, there exists multiple OME-Zarr formats each having its own
OME-NGFF specifications (0.3, 0.4, 0.5 etc.) and Zarr formats (versions
2 or 3). Currently,
*[romeo](https://bioconductor.org/packages/3.24/romeo)* provides
utilities for manipulating OME-Zarr datasets using NGFF versions 0.4 and
0.5.. The current released version of the OME-Zarr specification is 0.5.
See <https://ngff.openmicroscopy.org/specifications> for more
information.

![](chunks.svg)

    {
      "multiscales": [
        {
          "version": "0.4",
          "name": "example",
          "axes": [
            {"name": "t", "type": "time", "unit": "millisecond"},
            {"name": "c", "type": "channel"},
            {"name": "z", "type": "space", "unit": "micrometer"},
            {"name": "y", "type": "space", "unit": "micrometer"},
            {"name": "x", "type": "space", "unit": "micrometer"}
          ],
          "datasets": [
            {
              "path": "0",
              "coordinateTransformations": [{
                // the voxel size for the first scale level (0.5 micrometer)
                "type": "scale",
                "scale": [1.0, 1.0, 0.5, 0.5, 0.5]
              }]
            },
            {
              "path": "1",
              "coordinateTransformations": [{
                // the voxel size for the second scale level (downscaled by a factor of 2 on x, y and z dimensions)
                "type": "scale",
                "scale": [1.0, 1.0, 1.0, 1.0, 1.0]
              }]
            },
            {
              "path": "2",
              "coordinateTransformations": [{
                // the voxel size for the third scale level (downscaled by a factor of 4 on x, y and z dimensions)
                "type": "scale",
                "scale": [1.0, 1.0, 2.0, 2.0, 2.0]
              }]
            }
          ],
          "coordinateTransformations": [{
            // the time unit (0.1 milliseconds), which is the same for each scale
            "type": "scale",
            "scale": [0.1, 1.0, 1.0, 1.0, 1.0]
          }],
          ...

## Installation

You can install the development version of
*[romeo](https://bioconductor.org/packages/3.24/romeo)* like so:

``` r

install.packages("pak")
pak::pak("Huber-group-EMBL/romeo")
```

## Reading OME-Zarr files

### Images

This is a basic example which shows you how to read an OME-Zarr image of
version 0.4. By default, data are read lazily using `ZarrArray`.

``` r

library(romeo)
library(utils)
omezarrzip <- system.file("extdata", "test_ngff_image_v04.ome.zarr.zip", package = "romeo")
td <- withr::local_tempfile(fileext = ".ome.zarr")
dir.create(td)
unzip(omezarrzip, exdir = td)
x <- ome_read(td)
plot(x, 1)
```

![](romeo_files/figure-html/read-1.png)

Alternatively, the data can be read into memory:

``` r

x <- ome_read(td, lazy = FALSE)
```

### Labels

Labels of image pyramids can also be read as images

``` r

omezarrzip <- system.file("extdata", "test_ngff_image_v04.ome.zarr.zip", package = "romeo")
td <- withr::local_tempfile(fileext = ".ome.zarr")
dir.create(td)
unzip(omezarrzip, exdir = td)
x <- ome_read(file.path(td, "labels/blobs"))
plot(x, all = TRUE)
```

![](romeo_files/figure-html/read_label-1.png)

## Reading from S3 storage

For remote OME-Zarr files, you can use the
[`paws.storage::s3`](https://paws-r.r-universe.dev/paws.storage/reference/s3.html)
client to read the data directly from the S3 bucket without downloading
it first:

``` r

library(paws)
s3_client <- paws.storage::s3(
  config = list(
    credentials = list(anonymous = TRUE),
    region = "auto",
    endpoint = "https://uk1s3.embassy.ebi.ac.uk"
  )
)
x <- ome_read(
  "https://uk1s3.embassy.ebi.ac.uk/idr/zarr/v0.4/idr0076A/10501752.zarr",
  s3_client = s3_client,
)
plot(x[1:2, 1:50, 1:50])
```

    ## Only the first frame of the image stack is displayed.
    ## To display all frames use 'all = TRUE'.

![](romeo_files/figure-html/read_remote-1.png)

## Writing OME-Zarr files

### Images

*[romeo](https://bioconductor.org/packages/3.24/romeo)* also provides
utilities for writing OME-Zarr images compatible with OME-NGFF versions
0.4 and 0.5.

``` r

library(EBImage)
```

    ## 
    ## Attaching package: 'EBImage'

    ## The following object is masked from 'package:paws':
    ## 
    ##     translate

``` r

img_file <- system.file("extdata", "example_RGB.png", package = "romeo")
img <- readImage(img_file)

# write image pyramid
ome_img <- ome_write(img,
                     path = tempfile(fileext = ".ome.zarr"),
                     axes = c("x", "y", "c"),
                     version = "0.4",
                     storage_options = list(chunk_dim = c(64, 64, 1)))
plot(ome_img, 1)
```

    ## Only the first frame of the image stack is displayed.
    ## To display all frames use 'all = TRUE'.

![](romeo_files/figure-html/write-1.png)

Users can also define their own scaling factors to write image pyramids.
For a `scalefactors` vector with length three, the resulting pyramid
will contain four scales. Each scale factor in the vector defines the
scale factor relative to the previous scale.

``` r

ome_img <- ome_write(img,
                     path = tempfile(fileext = ".ome.zarr"),
                     axes = c("x", "y", "c"),
                     version = "0.5",
                     scalefactors = c(2, 2, 3),
                     storage_options = list(chunk_dim = c(64, 64, 1)))
```

### Labels

OME-Zarr label pyramids can be generated in the same way. We first
create our own label data using EBImage.

``` r

library(EBImage)

# read the first frame of image
nuc <- readImage(system.file("images", "nuclei.tif", package = "EBImage"))
nuc <- getFrames(nuc)[[1]]

# threshold using otsu's method
nuc_th <- nuc > otsu(nuc)
```

We can now write the label pyramid. The arguments are similar to those
used for writing images

``` r

ome_nuc_th <- ome_write(nuc_th,
                        path = tempfile(fileext = ".ome.zarr"),
                        version = "0.4",
                        scalefactors = c(2, 2, 3),
                        storage_options = list(chunk_dim = c(64, 64)),
                        type = "label")
plot(ome_nuc_th, 3)
```

![](romeo_files/figure-html/write_label-1.png)

Additional metadata information about labels can be provided using the
`label_metadata` argument.

``` r

# write label, version 0.4
ome_nuc_th <- ome_write(nuc_th,
                        path = tempfile(fileext = ".ome.zarr"),
                        version = "0.4",
                        scalefactors = c(2, 2, 3),
                        storage_options = list(chunk_dim = c(64, 64)),
                        type = "label",
                        label_name = "blobs",
                        label_metadata = list(
                          colors = list(
                            list(`label-value` = 1, rgba = list(255, 255, 255, 255)),
                            list(`label-value` = 2, rgba = list(0, 255, 255, 128))
                          ),
                          properties = list(
                            list(`label-value` = 1, class = "A"),
                            list(`label-value` = 2, class = "B")
                          )
                        ))
```

If the path already includes an image pyramid, then we should define a
name (e.g. `blobs`) for the label pyramid associated with the image.

``` r

td <- tempfile(fileext = ".ome.zarr")

# write image pyramid
ome_nuc <- ome_write(nuc,
                     path = td,
                     version = "0.4",
                     storage_options = list(chunk_dim = c(64, 64)))

ome_nuc_th <- ome_write(nuc_th,
                        path = td,
                        version = "0.4",
                        scalefactors = c(2, 2, 3),
                        storage_options = list(chunk_dim = c(64, 64)),
                        type = "label",
                        label_name = "blobs")
```

    ## An image pyramid was found at '/tmp/Rtmp92F1hm/file1ccd21c06e68.ome.zarr', writing labels to 'labels/blobs'

``` r

# plot
layout(matrix(1:2, nrow = 1))
plot(ome_nuc, 3)
plot(ome_nuc_th, 3)
```

![](romeo_files/figure-html/write_image_label-1.png)

## Appendix

### Session info

    ## R Under development (unstable) (2026-06-12 r90141)
    ## Platform: x86_64-pc-linux-gnu
    ## Running under: Ubuntu 24.04.4 LTS
    ## 
    ## Matrix products: default
    ## BLAS:   /usr/lib/x86_64-linux-gnu/openblas-pthread/libblas.so.3 
    ## LAPACK: /usr/lib/x86_64-linux-gnu/openblas-pthread/libopenblasp-r0.3.26.so;  LAPACK version 3.12.0
    ## 
    ## locale:
    ##  [1] LC_CTYPE=C.UTF-8       LC_NUMERIC=C           LC_TIME=C.UTF-8       
    ##  [4] LC_COLLATE=C.UTF-8     LC_MONETARY=C.UTF-8    LC_MESSAGES=C.UTF-8   
    ##  [7] LC_PAPER=C.UTF-8       LC_NAME=C              LC_ADDRESS=C          
    ## [10] LC_TELEPHONE=C         LC_MEASUREMENT=C.UTF-8 LC_IDENTIFICATION=C   
    ## 
    ## time zone: UTC
    ## tzcode source: system (glibc)
    ## 
    ## attached base packages:
    ## [1] stats     graphics  grDevices utils     datasets  methods   base     
    ## 
    ## other attached packages:
    ## [1] EBImage_4.55.0   paws_0.10.0      romeo_0.99.1     BiocStyle_2.41.0
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] xfun_0.58             bslib_0.11.0          httr2_1.2.2          
    ##  [4] htmlwidgets_1.6.4     lattice_0.22-9        tools_4.7.0          
    ##  [7] bitops_1.0-9          generics_0.1.4        stats4_4.7.0         
    ## [10] curl_7.1.0            paws.common_0.8.9     R.oo_1.27.1          
    ## [13] Matrix_1.7-5          desc_1.4.3            S4Vectors_0.50.1     
    ## [16] lifecycle_1.0.5       compiler_4.7.0        textshaping_1.0.5    
    ## [19] tiff_0.1-12           htmltools_0.5.9       sass_0.4.10          
    ## [22] RCurl_1.98-1.19       yaml_2.3.12           pkgdown_2.2.0        
    ## [25] crayon_1.5.3          jquerylib_0.1.4       R.utils_2.13.0       
    ## [28] cachem_1.1.0          DelayedArray_0.38.2   jsonvalidate_1.5.0   
    ## [31] abind_1.4-8           locfit_1.5-9.12       digest_0.6.39        
    ## [34] paws.storage_0.10.0   bookdown_0.46         fastmap_1.2.0        
    ## [37] grid_4.7.0            cli_3.6.6             SparseArray_1.13.2   
    ## [40] Rarr_2.0.1            magrittr_2.0.5        S4Arrays_1.13.0      
    ## [43] withr_3.0.2           rappdirs_0.3.4        rmarkdown_2.31       
    ## [46] XVector_0.53.0        matrixStats_1.5.0     fftwtools_0.9-11     
    ## [49] jpeg_0.1-11           otel_0.2.0            ragg_1.5.2           
    ## [52] png_0.1-9             R.methodsS3_1.8.2     evaluate_1.0.5       
    ## [55] knitr_1.51            IRanges_2.46.0        V8_8.2.0             
    ## [58] rlang_1.2.0           Rcpp_1.1.1-1.1        glue_1.8.1           
    ## [61] ZarrArray_1.1.0       BiocManager_1.30.27   xml2_1.5.2           
    ## [64] BiocGenerics_0.58.1   jsonlite_2.0.0        R6_2.6.1             
    ## [67] MatrixGenerics_1.25.0 systemfonts_1.3.2     fs_2.1.0
