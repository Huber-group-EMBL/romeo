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

test_that("read spatialdata elements", {
  skip_if_not_installed("spatialdataR")

  blobs_image <- system.file(
    "extdata",
    "blobs_v3.zarr",
    "images",
    "blobs_multiscale_image",
    package = "spatialdataR"
  )

  x <- ome_read(blobs_image) |>
    expect_no_condition()

  expect_s3_class(x, "ome_zarr")
  expect_identical(attr(x, "type"), "image")

  blobs_label <- system.file(
    "extdata",
    "blobs_v3.zarr",
    "labels",
    "blobs_multiscale_labels",
    package = "spatialdataR"
  )

  x <- ome_read(blobs_label) |>
    expect_no_condition()

  expect_s3_class(x, "ome_zarr")
  # This is a bit counterintuitive but spatialdata labels elements are encoded
  # as multiscale image from an OME point of view.
  expect_identical(attr(x, "type"), "image")
})
