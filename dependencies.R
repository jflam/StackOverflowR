install_if_not_present <- function(name) {
    if (!(name %in% rownames(installed.packages()))) {
        install.packages(name)
    }
}

install_if_not_present("tidyverse")
install_if_not_present("stringr")
install_if_not_present("scales")
install_if_not_present("knitr")
install_if_not_present("kableExtra")
install_if_not_present("widyr")
install_if_not_present("ggraph")
