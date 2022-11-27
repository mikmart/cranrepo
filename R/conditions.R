abort_existing_packages <- function(paths) {
  dirs <- fs::path_dir(paths)
  files <- fs::path_file(paths)
  rlang::abort(c(
    "Refused to replace existing packages.",
    rlang::set_names(sprintf("%s exists at %s", files, dirs), "x"),
    i = "Specify `replace = TRUE` to overwrite them."
  ), call = rlang::caller_env())
}

inform_removal_candidates <- function(paths) {
  rlang::inform(c(
    `!` = "Would remove the following packages:",
    rlang::set_names(paths, " "),
    i = "Specify `commit = TRUE` to permanently delete them."
  ))
}
