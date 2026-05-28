library(utils)

version <- c(
  "0.4" = "v04",
  "0.5" = "v05"
)

test_that("parse ome version", {
  for (i in seq_along(version)) {
    omezarrzip <- system.file(
      "extdata",
      paste0("test_ngff_image_", version[i], ".ome.zarr.zip"),
      package = "romeo"
    )
    td <- withr::local_tempfile()
    unzip(omezarrzip, exdir = td)
    expect_identical(
      .get_version(Rarr::read_zarr_attributes(td)),
      names(version)[i]
    )
  }
})
