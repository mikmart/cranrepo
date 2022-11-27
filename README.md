# cranrepo

<!-- badges: start -->
<!-- badges: end -->

cranrepo builds on [cranlike](https://cran.r-project.org/package=cranlike)
to give you the basic tools to set up your own CRAN-like R package repository.
You can:

- Set up a repository directory structure and index with `repo_create()`.
- Add source and binary package bundles to a repository with `repo_insert()`.
- Remove versions of packages from a repository with `repo_remove()`.
- Serve repositories over HTTP for development purposes with `repo_serve()`.

## Installation

You can install the development version of cranrepo from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("mikmart/cranrepo")
```
