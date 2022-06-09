#!/usr/bin/env bash

# Run by CI/CD

set -euxo pipefail

cd $(dirname $0)/..

mkdir -p ~/.R
echo -e "PKG_CFLAGS=-fno-sanitize-recover=all\nPKG_CXXFLAGS=-fno-sanitize-recover=all" > ~/.R/Makevars

export CMAKE_UNITY_BUILD=OFF ARROW_R_DEV=TRUE LIBARROW_BINARY=true
cd tools/rpkg

RDsan -e 'writeLines(c("library(duckdb)", capture.output(dir("man", pattern = "[.]Rd$", full.names = TRUE) %>% lapply(tools::Rd2ex) %>% invisible())), "examples.R")'

RDsan -f dependencies.R
RDsan CMD INSTALL .

UBSAN_OPTIONS=print_stacktrace=1 RDsan -f tests/testthat.R
UBSAN_OPTIONS=print_stacktrace=1 RDsan -f examples.R
