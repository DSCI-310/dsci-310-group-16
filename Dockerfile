FROM rocker/rstudio:4.1.3

RUN Rscript -e "install.packages('remotes')"
RUN Rscript -e "remotes::install_version('tidyverse', '1.3.0')"
RUN Rscript -e "remotes::install_version('repr')"
RUN Rscript -e "remotes::install_version('tidymodels','0.1.1')"
RUN Rscript -e "remotes::install_version('rvest')"
RUN Rscript -e "remotes::install_version('stringr', '1.4.0')"
RUN Rscript -e "remotes::install_version('DBI')"
RUN Rscript -e "remotes::install_version('dbplyr')"
RUN Rscript -e "remotes::install_version('GGally', '2.1.2')"

WORKDIR /home/rstudio
RUN pwd