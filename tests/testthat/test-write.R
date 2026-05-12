library(EBImage)
img_file <- system.file("images", "sample.png", package="EBImage")
img <- readImage(img_file)

# no support for 0.1, 0.2 and 0.3
test_that("check version", {
  
  lapply(c("0.1", "0.2", "0.3"), \(.) {
    expect_error(
      ome_img <- ome_write(img,
                           path = tempfile(fileext = ".ome.zarr"),
                           version = .,
                           storage_options = list(chunk_dim = c(64,64))) 
    )
  })
})

# writing
test_that("writing 0.4 and 0.5", {
  
  lapply(c("0.4", "0.5"), \(.) {
    
    # path
    td <- tempfile(fileext = ".ome.zarr")
    
    ome_img <- ome_write(img,
                         path = td,
                         version = .,
                         scalefactors = c(2,2,2),
                         storage_options = list(chunk_dim = c(64,64)))
    
    # check version, 0.4 or 0.5
    expect_identical(.get_version(Rarr::read_zarr_attributes(td)), .)
    
    # length(scalefactors) + 1 is the number of scales
    expect_equal(length(ome_img), 4)
    
    # first scale is the original scale
    expect_equal(dim(ome_img[[1]]), dim(img))
    
    # TODO: for now, chunk_dim has to be specified:
    expect_error(
      ome_img <- ome_write(img,
                           path = tempfile(fileext = ".ome.zarr"),
                           version = .)
    )
    
    # scales have to be non-negative, non-zero and MUST have incremental 
    # values
    # NOTE: incremental scales are not dictated by NGFF but the specification
    # says it has to be ordered from largest to lowest
    # See:
    #   https://ngff.openmicroscopy.org/specifications/0.4/index.html#multiscales-metadata
    #   https://ngff.openmicroscopy.org/specifications/0.5/index.html#multiscales-metadata
    expect_error(.check_scalefactors(c(2,0.1,2)))
    expect_error(.check_scalefactors(c(2,NA,2)))
    expect_error(.check_scalefactors(c(2,-1,2)))
    expect_error(.check_scalefactors(c()))
    expect_error(.check_scalefactors(NULL))
  })
  
})

# only xyc and xy are accepted for when axes=NULL
test_that("check axes when given", {
  
  expect_equal(.get_valid_axes(array(dim = c(1,2,5))), c("x", "y", "c"))
  expect_equal(.get_valid_axes(array(dim = c(1,2))), c("x", "y"))
  
  dim_img <- c("x", "y", "z", "c", "t")
  im <- array(dim = c(1,1,1,2,5))
  expect_equal(.get_valid_axes(im, dim_img), dim_img)
  expect_equal(.get_valid_axes(im, "xyzct"), dim_img)
})

# beyond 2D and 3D, axes should be provided
test_that("check axes when not given", {
  
  im <- array(dim = c(1,2,5))
  expect_equal(.get_valid_axes(im), c("x", "y", "c"))
  im <- array(dim = c(2,5))
  expect_equal(.get_valid_axes(im), c("x", "y"))

  # check fails when cant be guessed
  im <- array(dim = c(1,1,1,2,5))
  expect_error(.get_valid_axes(im), regexp = "Can't be guessed beyond 2D")
  im <- array(dim = c(1,1,1,2))
  expect_error(.get_valid_axes(im), regexp = "Can't be guessed beyond 2D")
  im <- array(dim = c(10))
  expect_error(.get_valid_axes(im), regexp = "Can't be guessed beyond 2D")
  
})

# beyond 2D and 3D, axes should be provided
test_that("invalid axes", {
  
  im <- array(dim = c(1,2,5))
  expect_error(
    .get_valid_axes(im, c("x", "y", "a")), 
    regexp = "Some axes are invalid"
  )
  expect_error(
    .get_valid_axes(im, c("x", "y", "y")), 
    regexp = "Duplicated axes are detected"
  )
  
})
