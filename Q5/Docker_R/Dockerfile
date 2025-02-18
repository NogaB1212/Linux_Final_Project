FROM r-base:latest
RUN R -e "install.packages(c('dplyr', 'ggplot2'), repos='http://cran.rstudio.com/')"
WORKDIR /app
COPY process_data.R /app/
COPY Demo_CSV.csv /app/
CMD ["bash"]
