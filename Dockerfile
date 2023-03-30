FROM --platform=linux/amd64 rocker/rstudio:4.1.3

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
# RUN Rscript -e "remotes::install_version('kknn','1.3.1')"
RUN Rscript -e "remotes::install_version('tidymodels','0.1.1')"
RUN Rscript -e "remotes::install_version('tidyverse','1.3.0')"
# RUN Rscript -e "remotes::install_version('rmarkdown', '2.2.1')"


# Install remaining R packages
#RUN Rscript -e "install.packages(c('kknn'))"

# run container in terminal
# RUN docker run -e PASSWORD={yourpassword} -p 8787:8787 mjbrodie/dsci-310-group-project:latest

WORKDIR /home/rstudio

ADD --chown=rstudio:rstudio Analysis /home/rstudio/Analysis
ADD --chown=rstudio:rstudio R /home/rstudio/R
ADD --chown=rstudio:rstudio data /home/rstudio/data
ADD --chown=rstudio:rstudio Tests /home/rstudio/Tests
ADD --chown=rstudio:rstudio output /home/rstudio/output
ADD --chown=rstudio:rstudio Packages /home/rstudio/Packages

COPY --chown=rstudio:rstudio Makefile .

#USER rstudio
#RUN make all #can't run because of kknn package which stops "regression" in Makefile
#USER root
