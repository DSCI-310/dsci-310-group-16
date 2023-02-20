FROM rocker/rstudio:4.1.3

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libssl-dev \
        libcurl4-openssl-dev \
        libxml2-dev \
        libpq-dev && \
    rm -rf /var/lib/apt/lists/*

# Install R packages
RUN Rscript -e "install.packages(c('remotes', 'tidyverse', 'repr', 'tidymodels', 'rvest', 'stringr', 'DBI', 'dbplyr', 'GGally'))"

WORKDIR /home/rstudio
