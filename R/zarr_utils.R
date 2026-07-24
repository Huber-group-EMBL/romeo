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
