#' @name default_axes
#' @rdname default_axes
#' @title Default axes for OME-NGFF files
#' 
#' @description Default axes and their OME-NGFF metadata
#' 
#' @noRd
.DEFAULT_AXES <- c("t", "c", "z", "y", "x")
  
# .DEFAULT_AXES <- list(
#   list(name = "t", type = "time", unit = "millisecond"),
#   list(name = "c", type = "channel"),
#   list(name = "z", type = "space"),
#   list(name = "y", type = "space"),
#   list(name = "x", type = "space")
# )