# use the miniforge base, make sure you specify a verion
FROM condaforge/miniforge3:latest


# Install quarto -----
# install Quarto based on target architecture
ARG TARGETARCH
ARG QUARTO_VERSION=1.8.26
RUN if [ "$TARGETARCH" = "amd64" ]; then \
  QUARTO_ARCH="amd64"; \
  elif [ "$TARGETARCH" = "arm64" ]; then \
  QUARTO_ARCH="arm64"; \
  else \
  echo "Unsupported architecture: $TARGETARCH" && exit 1; \
  fi && \
  curl -LO https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-${QUARTO_ARCH}.tar.gz && \
  mkdir -p /opt/quarto && \
  tar -xzf quarto-${QUARTO_VERSION}-linux-${QUARTO_ARCH}.tar.gz -C /opt/quarto --strip-components=1 && \
  rm quarto-${QUARTO_VERSION}-linux-${QUARTO_ARCH}.tar.gz && \
  ln -s /opt/quarto/bin/quarto /usr/local/bin/quarto

# Install conda packages -----

# copy the lockfile into the container
COPY conda-lock.yml conda-lock.yml

# setup conda-lock
RUN conda install -n base -c conda-forge conda-lock -y

# install packages from lockfile into dockerlock environment
RUN conda-lock install -n dockerlock conda-lock.yml

# make dockerlock the default environment
RUN echo "source /opt/conda/etc/profile.d/conda.sh && conda activate dockerlock" >> ~/.bashrc

# set the default shell to use bash with login to pick up bashrc
# this ensures that we are starting from an activated dockerlock environment
SHELL ["/bin/bash", "-l", "-c"]

# expose JupyterLab port
EXPOSE 8888

# sets the default working directory
# this is also specified in the compose file
WORKDIR /workplace

# print some checks
RUN quarto --version
RUN quarto check

# run JupyterLab on container start
# uses the jupyterlab from the install environment
CMD ["conda", "run", "--no-capture-output", "-n", "dockerlock", "jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root", "--IdentityProvider.token=''", "--ServerApp.password=''"]
