expect_file_exists <- function(file) {
  expect_true(fs::file_exists(file))
}

repo <- repo_create("./repos/latest", "4.0")
repo_path <- function(...) fs::path(repo, ...)

test_that("a new repository has all distribution trees", {
  expect_true(fs::dir_exists(repo_path("src/contrib")))
  expect_true(fs::dir_exists(repo_path("bin/windows/contrib/4.0")))
  expect_true(fs::dir_exists(repo_path("bin/macosx/contrib/4.0")))
})

test_that("a new repository has PACKAGES files", {
  expect_file_exists(repo_path("src/contrib/PACKAGES"))
  expect_file_exists(repo_path("bin/windows/contrib/4.0/PACKAGES"))
  expect_file_exists(repo_path("bin/macosx/contrib/4.0/PACKAGES"))
})

test_that("inserting packages works", {
  src <- "cranrepo_0.1.0.tar.gz"
  repo_insert(repo, src, "source")
  expect_file_exists(repo_path("src/contrib", src))

  bin <- "cranrepo_0.1.0.zip"
  repo_insert(repo, bin, "win.binary", "4.0")
  expect_file_exists(repo_path("bin/windows/contrib/4.0", bin))
})

test_that("can refuse to insert over existing packages", {
  src <- "cranrepo_0.1.0.tar.gz"
  expect_snapshot_error(repo_insert(repo, src, "source", replace = FALSE))
})

test_that("can get list of removal candidates without removing packages", {
  src <- "cranrepo_0.1.0.tar.gz"
  expect_equal(
    repo_remove(repo, "cranrepo", "0.1.0", "source", commit = FALSE),
    repo_path("src/contrib", src)
  )
  expect_file_exists(repo_path("src/contrib", src))
})

test_that("removing packages works", {
  src <- "cranrepo_0.1.0.tar.gz"
  repo_remove(repo, "cranrepo", "0.1.0", "source")
  expect_false(fs::file_exists(repo_path("src/contrib", src)))

  bin <- "cranrepo_0.1.0.zip"
  repo_remove(repo, "cranrepo", NULL, "win.binary", "4.0")
  expect_false(fs::file_exists(repo_path("bin/windows/contrib/4.0", bin)))
})

test_that("can sync exteral changes to package index", {
  bin <- "cranrepo_0.1.0.zip"
  dir <- repo_path("bin/windows/contrib/4.0")

  # Externally added files are synced
  fs::file_copy(bin, dir)
  expect_false(contrib_url_contains(dir, bin))
  repo_update(repo, "win.binary", "4.0")
  expect_true(contrib_url_contains(dir, bin))

  # Externally deleted files are synced
  fs::file_delete(fs::path(dir, bin))
  expect_true(contrib_url_contains(dir, bin))
  repo_update(repo, "win.binary", "4.0")
  expect_false(contrib_url_contains(dir, bin))
})

fs::dir_delete(repo)
