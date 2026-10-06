#' @keywords internal
.get_version <- function(attr) {
  # No $ subset here because we want to make sure we don't partial match to "omero"
  attr[["ome"]]$version %||% attr$multiscales[[1]]$version
}
