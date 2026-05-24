# only xyc and xy are accepted for when axes=NULL
test_that("check axes when given", {
  expect_equal(.get_valid_axes(array(dim = c(1, 2, 5))), c("x", "y", "c"))
  expect_equal(.get_valid_axes(array(dim = c(1, 2))), c("x", "y"))

  dim_img <- c("x", "y", "z", "c", "t")
  im <- array(dim = c(1, 1, 1, 2, 5))
  expect_equal(.get_valid_axes(im, dim_img), dim_img)
  expect_equal(.get_valid_axes(im, "xyzct"), dim_img)
})

# beyond 2D and 3D, axes should be provided
test_that("check axes when not given", {
  im <- array(dim = c(1, 2, 5))
  expect_equal(.get_valid_axes(im), c("x", "y", "c"))
  im <- array(dim = c(2, 5))
  expect_equal(.get_valid_axes(im), c("x", "y"))

  # check fails when cant be guessed
  im <- array(dim = c(1, 1, 1, 2, 5))
  expect_error(.get_valid_axes(im), regexp = "Can't be guessed beyond 2D")
  im <- array(dim = c(1, 1, 1, 2))
  expect_error(.get_valid_axes(im), regexp = "Can't be guessed beyond 2D")
  im <- array(dim = c(10))
  expect_error(.get_valid_axes(im), regexp = "Can't be guessed beyond 2D")
})

# beyond 2D and 3D, axes should be provided
test_that("invalid axes", {
  im <- array(dim = c(1, 2, 5))
  expect_error(
    .get_valid_axes(im, c("x", "y", "a")),
    regexp = "Some axes are invalid"
  )
  expect_error(
    .get_valid_axes(im, c("x", "y", "y")),
    regexp = "Duplicated axes are detected"
  )
})
