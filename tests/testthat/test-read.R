library(utils)
library(withr)

# formats
format <- c(
  "0.4" = "v04",
  "0.5" = "v05"
)

test_that("parse ome version", {
  for (i in seq_along(format)) {
    omezarrzip <- system.file(
      "extdata",
      paste0("test_ngff_image_", format[i], ".ome.zarr.zip"),
      package = "rome"
    )
    td <- withr::local_tempfile()
    unzip(omezarrzip, exdir = td)
    
    # image
    x <- ome_read(td)
    # TODO: why S3 ? 
    expect_s3_class(x, "ome_zarr")
    expect_equal(attr(x, "type"), "image")
    
    # labels
    x <- ome_read(file.path(td, "labels/blobs"))
    # TODO: why S3 ? 
    expect_s3_class(x, "ome_zarr")
    expect_equal(attr(x, "type"), "label")
  }
})
