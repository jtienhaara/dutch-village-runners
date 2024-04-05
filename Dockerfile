#
# To run this and convert an HTML file to PDF, run it with:
#
#     docker run ... \
#         --volume /x/y/z/htmltopdf/:/htmltopdf:rw \
#         ... \
#         xyz.html xyz.pdf
#
# It will read in xyz.html, and write out xyz.pdf,
# in the /x/y/z/htmltopdf/ directory.
#
# @version Last updated 2023-10-28
# Image from:
#
#     https://hub.docker.com/_/debian
#
FROM debian:12.2-slim

USER root

ENV DEBIAN_FRONTEND=noninteractive

#
# Most of these packages are copied from Musaico core.
#
# wkhtmltopdf is what we really want.
#
RUN apt-get update --yes \
    && apt-get install --no-install-recommends --yes \
       age \
       bind9-dnsutils \
       ca-certificates \
       cmake \
       curl \
       emacs \
       gcc \
       git \
       make \
       tcpdump \
       traceroute \
       vim \
       wget \
       wkhtmltopdf \
    && apt-get clean

#
# Package:
#
#     sops [required] [encryption]
#
# (See [footnote]s above in this file.)
#
ENV SOPS_VERSION=3.8.0
RUN if test `uname -m` = 'aarch64' \
    -o `uname -m` = 'arm64'; \
    then \
        SOPS_ARCH="arm64"; \
    else \
        SOPS_ARCH="amd64"; \
    fi; \
    wget https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops_${SOPS_VERSION}_${SOPS_ARCH}.deb \
        --output-document /tmp/sops_${SOPS_VERSION}.${SOPS_ARCH}.deb; \
    cp /tmp/sops_${SOPS_VERSION}.${SOPS_ARCH}.deb /tmp/sops_${SOPS_VERSION}.deb
RUN dpkg -i /tmp/sops_${SOPS_VERSION}.deb

#
# User htmltopdf
#
# Install a non-root user, to mitigate intrusions and mistakes
# at runtime.
#
# 32 digit random number for htmltopdf user's password.
#
RUN mkdir /home/htmltopdf \
    && useradd \
           --home-dir /home/htmltopdf \
           --password `od --read-bytes 32 --format u --address-radix none /dev/urandom | tr --delete ' \n'` \
           htmltopdf \
    && chown -R htmltopdf:htmltopdf /home/htmltopdf

RUN mkdir /htmltopdf \
    && chown -R htmltopdf:htmltopdf /htmltopdf \
    && chmod ug+rwx,o-rwx /htmltopdf

USER htmltopdf
WORKDIR /htmltopdf

#
# Specify the input .html file and output .pdf file.
#
CMD [""]
ENTRYPOINT ["wkhtmltopdf", \
            "--page-size", "Letter", \
            "--enable-local-file-access", \
            "--print-media-type"]
