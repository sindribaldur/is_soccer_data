# Packages
library(rvest)
library(magrittr)
library(data.table)


# Helper functions
source("../../../r-helpers/functions.R", encoding = "UTF-8")


# Table URLs
# LUT (made by copy and paste from ksi.is)
ar2motnumer <- fread("urvalsdeild_motnumer.csv", colClasses = "character") %>%
  .[, setNames(motnumer, ar)]
complurl <- list()
complurl[names(ar2motnumer)] <- "https://www.ksi.is/mot/stakt-mot?motnumer=" %+%
  ar2motnumer


# Download data
# Can't find http://ksi.is/robots.txt
tables <- lapply(
  complurl,
  function(x) {
    message(x)
    ourrun <- try(access_fixtures_table(x))
    if ('try-error' %ni% class(ourrun)) {
      ourrun
    }
  }
)


# Clean data
DT <- rbindlist(tables, idcol = "year")
DT[, c("home_team", "away_team") := tstrsplit(X2, "\\d")[1:2]]
score_cols <- c("home_score", "away_score")
DT[, (score_cols) := tstrsplit(X2, "\\D+")[-1] %>% lapply(as.integer)]
DT <- DT[is.na(X1) | X1 < Sys.Date() | X1 == Sys.Date() & !is.na(home_score)]
DT[, X2 := NULL]
setnames(DT, "X1", "date")


# Export csv/rds
fwrite(DT, "urvalsdeild_all_results.csv")
