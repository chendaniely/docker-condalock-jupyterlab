# docker-condalock-jupyterlab

tl;dr: Type `make` or `make help` to see available commands

Example repository showing:

1. Specifying a conda environment with an `environment.yml` file
2. Creating a `conda-lock.yml` file of the conda environment across all major operating systems and architectures
3. Creating a local conda environment from the lock file
4. Building a docker container with the `Dockerfile`
5. Running the docker container locally using the `docker-compose.yml` file
6. Specifying all the terminal commands using the `Makefile`
7. Github action that automates updating the `conda-lock.yml` file
8. Github action that automates building and pushing the docker image to docker hub
9. Gihub action that runs the analysis with the built container

dockerhub image: <https://hub.docker.com/repository/docker/chendaniely/docker-condalock-jupyterlab/>

This repository was created to supplement the materials in the
[Reproducible and Trustworthy Workflows for Data Science](https://ubc-dsci.github.io/reproducible-and-trustworthy-workflows-for-data-science/) textbook used at the University of British Columbia.

## Changelog

2025-12-08: Now with quarto!
