FROM rocker/rstudio:4.1.3

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libssl-dev \
        libcurl4-openssl-dev \
        libxml2-dev \
        libpq-dev && \
    rm -rf /var/lib/apt/lists/*

# Install specific R packages
RUN Rscript -e "install.packages('remotes')"
RUN Rscript -e "remotes::install_version('data.table', '1.12.8')"
RUN Rscript -e "remotes::install_version('GGally', '2.1.0')"
RUN Rscript -e "remotes::install_version('here', '1.0.1')"
RUN Rscript -e "remotes::install_version('tidymodels','0.1.1')"
RUN Rscript -e "remotes::install_version('tidyverse','1.3.0')"

# Install remaining R packages
RUN Rscript -e "install.packages(c('knitr', 'testthat'))"

# run container in terminal
# docker run run -e PASSWORD={yourpassword} -p 8787:8787 mjbrodie/dsci-310-group-project:latest


WORKDIR /home/rstudio

COPY --chown=rstudio:rstudio renv.lock .
COPY --chown=rstudio:rstudio renv renv
COPY --chown=rstudio:rstudio .Rprofile .

RUN ls -alh

USER rstudio
RUN Rscript -e "renv::repair()"
USER root
