# Read the environment variable
wdir <- Sys.getenv("WDIR")

# Define the library path using the environment variable
lib_path <- file.path(wdir, "packages_extracted")

# Function to install packages if they are not already installed
install_if_missing <- function(package_path) {
  package_name <- sub(".*/(.*)_[^_]+\\.tar\\.gz$", "\\1", package_path)
  if (!require(package_name, character.only = TRUE, lib.loc = lib_path)) {
    install.packages(package_path, lib = lib_path, repos = NULL, type = "source")
  }
}

# List of package paths
packages <- c(
  "packages/loo_2.7.0.tar.gz",
  "packages/Matrix_1.6-5.tar.gz",
  "packages/inline_0.3.19.tar.gz",
  "packages/jsonlite_1.8.8.tar.gz",
  "packages/R6_2.5.1.tar.gz",
  "packages/Rcpp_1.0.12.tar.gz",
  "packages/QuickJSR_1.1.3.tar.gz",
  "packages/RcppEigen_0.3.4.0.0.tar.gz",
  "packages/RcppParallel_5.1.7.tar.gz",
  "packages/BH_1.84.0-0.tar.gz",
  "packages/StanHeaders_2.32.6.tar.gz",
  "packages/xfun_0.43.tar.gz",
  "packages/knitr_1.46.tar.gz",
  "packages/rmarkdown_2.26.tar.gz",
  "packages/htmltools_0.5.8.1.tar.gz",
  "packages/htmlwidgets_1.6.4.tar.gz",
  "packages/colourpicker_1.3.0.tar.gz",
  "packages/threejs_0.3.3.tar.gz",
  "packages/dygraphs_1.1.1.6.tar.gz",
  "packages/shinythemes_1.2.0.tar.gz",
  "packages/Brobdingnag_1.2-9.tar.gz",
  "packages/rlang_1.1.3.tar.gz",
  "packages/scales_1.3.0.tar.gz",
  "packages/vctrs_0.6.5.tar.gz",
  "packages/lifecycle_1.0.4.tar.gz",
  "packages/ggplot2_3.5.0.tar.gz",
  "packages/rstan_2.32.5.tar.gz",
  "packages/rstantools_2.4.0.tar.gz",
  "packages/cmdstanr_0.7.1.tar.gz",
  "packages/bayesplot_1.11.1.tar.gz",
  "packages/DT_0.33.tar.gz",
  "packages/shinystan_2.6.0.tar.gz",
  "packages/bridgesampling_1.1-2.tar.gz",
  "packages/nleqslv_3.3.5.tar.gz",
  "packages/brms_2.20.4.tar.gz"
)

# Install missing packages
sapply(packages, install_if_missing)

# Load the libraries
library("loo", lib.loc = lib_path)
library("Matrix", lib.loc = lib_path)
library("inline", lib.loc = lib_path)
library("jsonlite", lib.loc = lib_path)
library("R6", lib.loc = lib_path)
library("Rcpp", lib.loc = lib_path)
library("QuickJSR", lib.loc = lib_path)
library("RcppEigen", lib.loc = lib_path)
library("RcppParallel", lib.loc = lib_path)
library("BH", lib.loc = lib_path)
library("StanHeaders", lib.loc = lib_path)
library("xfun", lib.loc = lib_path)
library("knitr", lib.loc = lib_path)
library("rmarkdown", lib.loc = lib_path)
library("htmltools", lib.loc = lib_path)
library("htmlwidgets", lib.loc = lib_path)
library("colourpicker", lib.loc = lib_path)
library("threejs", lib.loc = lib_path)
library("dygraphs", lib.loc = lib_path)
library("shinythemes", lib.loc = lib_path)
library("Brobdingnag", lib.loc = lib_path)
library("rlang", lib.loc = lib_path)
library("scales", lib.loc = lib_path)
library("vctrs", lib.loc = lib_path)
library("lifecycle", lib.loc = lib_path)
library("ggplot2", lib.loc = lib_path)
library("rstan", lib.loc = lib_path)
library("rstantools", lib.loc = lib_path)
library("cmdstanr", lib.loc = lib_path)
library("bayesplot", lib.loc = lib_path)
library("DT", lib.loc = lib_path)
library("shinystan", lib.loc = lib_path)
library("bridgesampling", lib.loc = lib_path)
library("nleqslv", lib.loc = lib_path)
library("brms", lib.loc = lib_path)

# Configure cmdstanr
library(cmdstanr)
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

install_cmdstan(
  dir = "./",
  cores = getOption("mc.cores", mc.cores),
  quiet = FALSE,
  overwrite = FALSE,
  timeout = 1200,
  version = NULL,
  release_url = NULL,
  release_file = file.path(lib_path, "cmdstan-2.34.1.tgz"),
  cpp_options = list(),
  check_toolchain = TRUE,
  wsl = FALSE
)

