# cranrepo

<!-- badges: start -->
<!-- badges: end -->

cranrepo builds on [cranlike](https://cran.r-project.org/package=cranlike)
to give you the basic tools to set up your own CRAN-like R package repository.
You can:

- Set up a repository directory structure with `repo_create()`.
- Add packages to repositories with `repo_insert()`.
- Remove packages from repositories with `repo_remove()`.
- Serve repositories over HTTP for development purposes with `repo_serve()`.

## Installation

You can install the development version of cranrepo from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("mikmart/cranrepo")
```
