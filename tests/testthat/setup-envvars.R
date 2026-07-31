# Avoid expected warnings from Rarr on oldrel to fail expect_no_condition() tests
if (getRversion() < "4.6.0") {
  Sys.setenv("OLDREL_TESTS" = "true")
}
