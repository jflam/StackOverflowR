
# Script to batch compute r_packages.Rda which will be used for more interactive data 

library(tidyverse)
library(stringr)
library(scales)
library(dplyr)

setwd("c:/Users/jflam/src/StackOverflowR/StackOverflowR")
folder <- "data"
questions <- read_csv(file.path(folder, "Questions.csv"))
answers <- read_csv(file.path(folder, "Answers.csv"))
r_posts <- bind_rows(questions, answers) %>%
    mutate(PostType = ifelse(is.na(Title), "Answer", "Question"))

tags <- read_csv(file.path(folder, "Tags.csv"))

reg <- "(library|require)\\([\"\']?(.*?)[\"\']?\\)|([\\.a-zA-Z\\d]+)::|he [\"\'\`]?([a-zA-Z\\.\\d]+)[\"\'\`]? package"

r_packages <- r_posts %>%
    mutate(Packages = str_match_all(Body, reg),
         Package = map(Packages, ~ c(.[, 3:5]))) %>%
         select(-Packages, - Body) %>%
         unnest(Package) %>%
         filter(!is.na(Package), !Package %in% c("", "R", "r")) %>%
         mutate(Package = str_replace(Package, "'", "")) %>%
         distinct(Id, Package, .keep_all = TRUE)

saveRDS(r_packages, file = "r_packages.Rda")

# More compute

library(lubridate)

year_totals <- r_posts %>%
    semi_join(r_packages, by = "Id") %>%
    count(Year = year(CreationDate)) %>%
    rename(YearTotal = n)

package_by_year <- r_packages %>%
    transmute(Id = coalesce(ParentId, Id), Package, Year = year(CreationDate)) %>%
    distinct(Id, Package, Year) %>%
    count(Package, Year) %>%
    group_by(Package) %>%
    mutate(PackageTotal = sum(n)) %>%
    ungroup() %>%
    inner_join(year_totals, by = "Year")

saveRDS(package_by_year, file = "package_by_year.Rda")