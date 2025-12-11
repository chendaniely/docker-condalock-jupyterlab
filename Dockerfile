# use the miniforge base, make sure you specify a verion
FROM condaforge/miniforge3:latest

# Install additionaly system packages -----
# curl: used to download files
# texlive: quarto install tinytex does not work for ARM64
# xetex is needed for jupyter and quarto pdf rendering
RUN apt-get update && apt-get install -y \
  curl \
  make \
  #texlive-latex-base \
  #texlive-latex-extra \
  texlive-fonts-recommended \
  texlive-fonts-extra \
  texlive-xetex \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# If you can, only edit below this line
# otherwise you will re-build the texlive install layer

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
  ln -s /opt/quarto/bin/quarto /usr/local/bin/quarto && \
  # Clean up quarto installation files we don't need
  rm -rf /opt/quarto/share/jupyter

# Install conda packages -----

# copy the lockfile into the container
COPY conda-lock.yml conda-lock.yml

# setup conda-lock
# install packages from lockfile into dockerlock environment
# clean up files (to save space)
RUN conda install -n base -c conda-forge conda-lock -y && \
  conda-lock install -n dockerlock conda-lock.yml && \
  # Clean up conda caches and unnecessary files
  conda clean -afy && \
  rm -rf /opt/conda/pkgs/* && \
  rm conda-lock.yml

# make dockerlock the default environment
RUN echo "source /opt/conda/etc/profile.d/conda.sh && conda activate dockerlock" >> ~/.bashrc

# set the default shell to use bash with login to pick up bashrc
# this ensures that we are starting from an activated dockerlock environment
SHELL ["/bin/bash", "-l", "-c"]

# expose JupyterLab port
EXPOSE 8888

# sets the default working directory
# this is also specified in the compose file
WORKDIR /workspace

# run JupyterLab on container start
# uses the jupyterlab from the install environment
CMD ["conda", "run", "--no-capture-output", "-n", "dockerlock", "jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root", "--IdentityProvider.token=''", "--ServerApp.password=''"]
