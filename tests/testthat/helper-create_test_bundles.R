create_test_bundles <- function() {
  src <- pkgbuild::build(".", dest_path = tempdir())
  bin <- pkgbuild::build(src, dest_path = tempdir(), binary = TRUE)
  fs::file_move(c(src, bin), "./tests/testthat")
}
