library(utils)
library(withr)

# formats
format <- c(
  "0.4" = "v04",
  "0.5" = "v05",
  "0.6" = "v06"
)

test_that("all OME versions can be validated", {
  for (i in seq_along(format)) {
    omezarrzip <- system.file(
      "extdata",
      paste0("test_ngff_image_", format[i], ".ome.zarr.zip"),
      package = "romeo"
    )
    td <- withr::local_tempfile()
    unzip(omezarrzip, exdir = td)

    expect_no_condition(ome_validate(td))
  }
})
