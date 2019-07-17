`%+%` <- function(x, y) paste0(x, y)

'%ni%' <- Negate('%in%')

access_fixtures_table <- function(url) {
  Sys.sleep(0.1)
  dd <- html_session(url) %>%
    html_nodes(css = "#fixtures table") %>%
    html_table()
  dd <- dd[[1]][1:2] %>% setDT()
  dd[, X1 := X1 %>%
         sub("(\\d{4}).*", "\\1", .) %>%
         sub("^.{5}", "", .) %>%
         as.Date("%d. %m. %Y")]
  dd[, X2 := gsub("\r\n +", "", X2)]
  dd
}