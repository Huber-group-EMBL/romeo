#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @importFrom methods setGeneric setMethod
## usethis namespace: end

## mockable bindings: start
## mockable bindings: end
NULL


# Backport from R 4.4.0
"%||%" <- function(x, y) {
  if (is.null(x)) y else x # nolint: coalesce_linter.
}
