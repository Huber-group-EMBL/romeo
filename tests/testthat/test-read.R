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
      package = "romeo"
    )
    td <- withr::local_tempfile()
    unzip(omezarrzip, exdir = td)

    # image
    x <- ome_read(td)
    expect_s4_class(x, "ome_zarr")
    expect_identical(x@metadata$type, "image")

    # labels
    x <- ome_read(file.path(td, "labels/blobs"))
    expect_s4_class(x, "ome_zarr")
    expect_identical(x@metadata$type, "label")
  }
})
