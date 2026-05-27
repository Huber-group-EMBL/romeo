library(EBImage)
library(ZarrArray)

# image example
img_file <- system.file("images", "sample.png", package = "EBImage")
img <- readImage(img_file)

# label example
lbl_file <- system.file("images", "nuclei.tif", package = "EBImage")
lbl <- getFrames(readImage(lbl_file))[[1]]
lbl <- lbl > otsu(lbl)

test_that("writing 0.4 and 0.5 labels works", {
  lapply(c("0.4", "0.5"), \(.) {
    # path
    td <- tempfile(fileext = ".ome.zarr")

    # write label
    ome_label <- ome_write(
      lbl,
      path = td,
      version = .,
      scalefactors = c(2, 2, 2),
      storage_options = list(chunk_dim = c(64, 64)),
      type = "label"
    )

    # check type
    expect_equal(attr(ome_label, "type"), "label")

    # type is logical in this example
    expect_equal(type(ome_label[[1]]), "logical")
    expect_equal(type(ome_label[[1]]), type(lbl))
  })
})

test_that("writing 0.4 and 0.5 labels works (with images)", {
  lapply(c("0.4", "0.5"), \(.) {
    # path
    td <- tempfile(fileext = ".ome.zarr")

    # write image
    if (dir.exists(td)) {
      unlink(td, recursive = TRUE)
    }
    ome_img <- ome_write(
      img,
      path = td,
      version = .,
      scalefactors = c(2, 2, 2),
      storage_options = list(chunk_dim = c(64, 64))
    )

    # write label
    label_name <- "blobs"
    expect_error(
      ome_write(
        lbl,
        path = td,
        version = .,
        scalefactors = c(2, 2, 2),
        storage_options = list(chunk_dim = c(64, 64)),
        type = "label"
      ),
      regexp = "label_name has to be a string"
    )
    ome_label <- ome_write(
      lbl,
      path = td,
      version = .,
      scalefactors = c(2, 2, 2),
      storage_options = list(chunk_dim = c(64, 64)),
      type = "label",
      label_name = label_name
    )

    # check labels group metadata
    label_meta <- Rarr::read_zarr_attributes(file.path(td, "labels"))
    if (. == "0.5") {
      label_meta <- label_meta$ome
    }
    expect_contains(names(label_meta), "labels")
    expect_contains(label_meta[["labels"]][[1]], label_name)
  })
})

# writing
test_that("writing label metadata works", {
  meta <- .make_label_metadata(NULL, version = "0.4")
  expect_contains(names(meta), "image-label")

  lbl_meta <- list(
    colors = list(
      list(`label-value` = 1, rgba = list(255, 255, 255, 255)),
      list(`label-value` = 2, rgba = list(0, 255, 255, 128))
    ),
    properties = list(
      list(`label-value` = 1, class = "A"),
      list(`label-value` = 2, class = "B")
    )
  )
  expect_no_error(.make_label_metadata(lbl_meta, version = "0.4"))

  lbl_meta$properties[[2]]$`label-value` <- 1
  expect_error(
    .make_label_metadata(lbl_meta, version = "0.4"),
    regexp = "label values should be unique!"
  )

  lbl_meta$colors[[2]]$`label-value` <- 1
  expect_error(
    .make_label_metadata(lbl_meta, version = "0.4"),
    regexp = "label values should be unique!"
  )

  lbl_meta$colors[[2]]$`label-value` <- NA
  expect_error(
    .make_label_metadata(lbl_meta, version = "0.4"),
    regexp = "label-value should be a non-zero integer"
  )

  lbl_meta$colors[[1]]$rgba <- list(255, 255, 255)
  expect_error(
    .make_label_metadata(lbl_meta, version = "0.4"),
    regexp = "rgba should be a list of four"
  )

  lbl_meta$colors[[1]]$`label-value` <- NULL
  expect_error(
    .make_label_metadata(lbl_meta, version = "0.4"),
    regexp = " metadata should include 'label-value'"
  )

  lbl_meta$source <- list(temp = "../../")
  expect_error(
    .make_label_metadata(lbl_meta, version = "0.4"),
    regexp = "'source' should include 'image'"
  )
})
