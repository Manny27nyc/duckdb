test_that("structs can be read", {
  con <- dbConnect(duckdb::duckdb())
  on.exit(dbDisconnect(con, shutdown = TRUE))

  res <- dbGetQuery(con, "SELECT {'x': 100, 'y': 'hello', 'z': 3.14} AS s")
  expect_equal(res$s$x, 100)
  expect_equal(res$s$y, "hello")
  expect_equal(res$s$z, 3.14)

  res <- dbGetQuery(con, "SELECT 1 AS n, {'x': 100, 'y': 'hello', 'z': 3.14} AS s")
  expect_equal(res$n, 1)
  expect_equal(res$s$x, 100)
  expect_equal(res$s$y, "hello")
  expect_equal(res$s$z, 3.14)

  res <- dbGetQuery(con, "values (100, {'x': 100}), (200, {'x': 200}), (300, NULL)")
  expect_equal(res$col0, c(100, 200, 300))
  expect_equal(res$col1$x, c(100, 200, NA))

  res <- dbGetQuery(con, "values ('a', {'x': 100, 'y': {'a': 1, 'b': 2}}), ('b', {'x': 200, y: NULL}), ('c', NULL)")
  expect_equal(res$col0, c("a", "b", "c"))
  expect_equal(res$col1$x, c(100, 200, NA))
  expect_equal(res$col1$y$a, c(1, NA, NA))

  res <- dbGetQuery(con, "select 100 AS other, [{'x': 1, 'y': 'a'}, {'x': 2, 'y': 'b'}] AS s")
  expect_equal(res$other, 100)
  expect_equal(res$s[[1]], data.frame(x = c(1L, 2L), y = c("a", "b")))

  res <- dbGetQuery(con, "values ([{'x': 1, 'y': 'a'}, {'x': 2, 'y': 'b'}]), ([]), ([{'x': 1, 'y': 'a'}])")
  expect_equal(res$col0[[1]], data.frame(x = c(1L, 2L), y = c("a", "b")))
  expect_equal(res$col0[[2]], data.frame(x = integer(0), y = character(0)))
  expect_equal(res$col0[[3]], data.frame(x = 1L, y = "a"))
})

