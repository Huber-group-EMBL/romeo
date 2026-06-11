#' create_zarr_group
#'
#' Create a zarr group
#'
#' @param store the location of (zarr) store
#' @param name name of the group
#' @param version zarr version, 2L for v2 and 3L for v3
#'
#' @importFrom cli cli_abort
#' @importFrom utils tail
#'
#' @return `NULL`
#'
#' @noRd
#'
#' @examples
#' store <- tempfile(fileext = ".zarr")
#' create_zarr(store)
#' create_zarr_group(store, "gp")
create_zarr_group <- function(store, name, version = 2L) {
  split_name <- strsplit(name, split = "/", fixed = TRUE)[[1]]
  if (length(split_name) > 1) {
    split_name <- vapply(
      seq_along(split_name),
      function(x) paste(split_name[seq_len(x)], collapse = "/"),
      FUN.VALUE = character(1)
    )
    split_name <- rev(split_name)[1:2]
    if (!dir.exists(file.path(store, split_name[2]))) {
      create_zarr_group(store = store, name = split_name[2], version = version)
    }
  }
  dir.create(file.path(store, split_name[1]), showWarnings = FALSE)
  switch(
    as.character(version),
    "2" = {
      write(
        "{\"zarr_format\":2}",
        file = file.path(store, split_name[1], ".zgroup")
      )
    },
    "3" = {
      write(
        "{\"zarr_format\": 3,\n\"node_type\": \"group\"}",
        file = file.path(store, split_name[1], "zarr.json")
      )
    },
    cli::cli_abort("Only zarr v2 and v3 are supported. Use version = 2L or 3L")
  )
}

#' create_zarr
#'
#' Create zarr store
#'
#' @param store the location of zarr store
#' @param version zarr version
#'
#' @return `NULL`
#'
#' @noRd
#'
#' @examples
#' store <- tempfile(fileext = ".zarr")
#' create_zarr(store)
create_zarr <- function(store, version = "v2") {
  prefix <- basename(store)
  dir <- gsub(paste0(prefix, "$"), "", store)
  create_zarr_group(store = dir, name = prefix, version = version)
}

#' is_zarr_empty
#'
#' check if a zarr store is empty or not.
#'
#' @param store the location of zarr store
#'
#' @return returns TRUE if zarr store is empty
#'
#' @noRd
#'
#' @examples
#' store <- tempfile(fileext = ".zarr")
#' create_zarr(store)
#' is_zarr_empty(store)
is_zarr_empty <- function(store) {
  files <- list.files(store, recursive = FALSE, full.names = FALSE)
  all(files %in% c(".zarray", ".zattrs", ".zgroup", "zarr.json"))
}

#' zarr_exists
#'
#' Check if the path is a Zarr store, group or array.
#'
#' @return Whether the `target_path` exists in `store`
#' @noRd
#'
#' @param store Path to a Zarr store
#' @param target_path The path within the store to test for
zarr_exists <- function(store, target_path = "/") {
  zarr <- file.path(store, target_path)
  if (!dir.exists(zarr)) {
    return(FALSE)
  }

  list_files <- list.files(
    path = zarr,
    full.names = FALSE,
    recursive = FALSE,
    all.files = TRUE
  )
  any(c(".zarray", ".zattrs", ".zgroup", "zarr.json") %in% list_files)
}
