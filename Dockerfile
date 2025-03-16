FROM rocker/shiny-verse
RUN R -e 'install.packages(c("plotly", "bslib"), repos = "https://packagemanager.posit.co/cran/latest")'
WORKDIR /home/shinyusr
COPY data data
COPY src src
COPY www www
CMD ["R", "-e", "shiny::runApp('.', host='0.0.0.0', port=3838)"]
