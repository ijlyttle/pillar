context("format_time")

test_that("output test", {
  expect_pillar_output(as.POSIXct("2017-07-28 18:04:35 +0200"), filename = "time.txt")
  expect_pillar_output(as.POSIXlt("2017-07-28 18:04:35 +0200"), filename = "time-posix.txt")
})

test_olson <- c(
  "EST5EDT",
  "America/Chicago",
  "Europe/Paris",
  "America/Kentucky/Louisville",
  "America/Indiana/Indianapolis"
)

result_olson_14 <- c(
  `EST5EDT` = "EST5EDT",
  `America/Chicago` = "Amer/Chicago",
  `Europe/Paris` = "Eur/Paris",
  `America/Kentucky/Louisville` = "Amer/KY/Losvll",
  `America/Indiana/Indianapolis` = "Amer/IN/Indnpl"
)

result_olson_10 <- c(
  `EST5EDT` = "EST5EDT",
  `America/Chicago` = "Amr/Chicag",
  `Europe/Paris` = "Eur/Paris",
  `America/Kentucky/Louisville` = "Amr/KY/Lsv",
  `America/Indiana/Indianapolis` = "Amr/IN/Ind"
)

test_that("component works", {
  expect_identical(
    component("America/Chicago"),
    data.frame(
      tz = rep("America/Chicago", 2L),
      index = c(1L, 2L),
      index_max = c(2L, 2L),
      component = c("America", "Chicago"),
      stringsAsFactors = FALSE
    )
  )
})

test_that("budget_initial_vector works", {
  # minwidth 14
  expect_identical(budget_initial_vector(1L, minwidth = 14L), c(14L))
  expect_identical(budget_initial_vector(2L, minwidth = 14L), c(4L, 9L))
  expect_identical(budget_initial_vector(3L, minwidth = 14L), c(4L, 2L, 6L))
  # minwidth 10
  expect_identical(budget_initial_vector(2L, minwidth = 10L), c(3L, 6L))
  expect_identical(budget_initial_vector(3L, minwidth = 10L), c(3L, 2L, 3L))
  # minwidth 25
  expect_identical(budget_initial_vector(2L, minwidth = 25L), c(7L, 17L))
  expect_identical(budget_initial_vector(3L, minwidth = 25L), c(7L, 2L, 14L))
  # minwidth 28
  expect_identical(budget_initial_vector(3L, minwidth = 28L), c(7L, 5L, 14L))
})

test_that("budget_initial works", {
  expect_identical(
    budget_initial(14L),
    data.frame(
      index =          c( 1L, 1L, 2L, 1L, 2L, 3L),
      index_max =      c( 1L, 2L, 2L, 3L, 3L, 3L),
      budget_initial = c(14L, 4L, 9L, 4L, 2L, 6L)
    )
  )
})

test_that("decompose_tz works", {

  text <- paste(
    '"index","index_max","tz",                           "component",    "budget_initial"',
    '1,      1,          "EST5EDT",                      "EST5EDT",      14',
    '1,      2,          "America/Chicago",              "America",      4',
    '1,      2,          "Europe/Paris",                 "Europe",       4',
    '1,      3,          "America/Kentucky/Louisville",  "America",      4',
    '1,      3,          "America/Indiana/Indianapolis", "America",      4',
    '2,      2,          "America/Chicago",              "Chicago",      9',
    '2,      2,          "Europe/Paris",                 "Paris",        9',
    '2,      3,          "America/Kentucky/Louisville",  "Kentucky",     2',
    '2,      3,          "America/Indiana/Indianapolis", "Indiana",      2',
    '3,      3,          "America/Kentucky/Louisville",  "Louisville",   6',
    '3,      3,          "America/Indiana/Indianapolis", "Indianapolis", 6',
    sep = '\n'
  )

  text <- gsub(" ", "", text) # get rid of "formatting" spaces
  decomp_tz <- read.csv(text = text, stringsAsFactors = FALSE)

  expect_identical(decompose_tz(test_olson, 14L), as.data.frame(decomp_tz))

})

test_that("budget_final works", {

  component <-          c("chicago", "chicago", "denver")
  budget_provisional <- c(       5L,        4L,       3L)

  budget_final <-       c(       4L,        4L,       3L)

  expect_identical(
    budget_final(budget_provisional, component),
    budget_final
  )
})

test_that("abbv_dict works", {

  dict <- c(foo2 = "foo", bar2 = "bar")

  input <-    c("foo2",  "notfoo", "bar2")
  minwidth <- c(    3L,        3L,     4L)
  result <-   c( "foo",  "notfoo", "bar2")

  expect_identical(
    abbv_dict(input, minwidth, dictionary = dict),
    result
  )
})

test_that("abbv_final works", {

  # this test is a bit pathological as none of the strings
  # is abbreviated to the length we want - instead the point is
  # to make sure that all the 4's are considered together
  # and all the 5's are considered together

  abbv_dict <-    c("new_yorks",  "new_york", "chicagos", "chicago")
  budget_final <- c(         5L,          5L,         4L,        4L)

  abbv_final <-   c( "nw_yrks",    "new_yrk",    "chcgs",   "chicg")

  expect_identical(
    abbv_final(abbv_dict, budget_final),
    abbv_final
  )

})

test_that("abbreviate_olson works", {
  expect_identical(abbreviate_olson(test_olson), result_olson_14)
  expect_identical(
    abbreviate_olson(test_olson, minwidth = 10L),
    result_olson_10
  )
})



