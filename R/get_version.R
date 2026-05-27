#' @keywords internal
.get_version <- function(attr) {
  attr$ome$version %||% attr$multiscales[[1]]$version
}
