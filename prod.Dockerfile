# +++ +++ +++ +++ +++ +++ +++ +++ +++ +++ +++ +++ +++ +++ +++ #
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
# ---               HUGO BASE CONTAINER IMAGE             --- #
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
# +++ +++ +++ +++ +++ +++ +++ +++ +++ +++ +++ +++ +++ +++ +++ #

ARG ALPINE_OCI_IMAGE_TAG=${ALPINE_OCI_IMAGE_TAG}
ARG GOLANG_VERSION=${GOLANG_VERSION:-1.15.6}
FROM golang:$GOLANG_VERSION-alpine$ALPINE_OCI_IMAGE_TAG AS hugo_build_base

ARG ALPINE_OCI_IMAGE_TAG=${ALPINE_OCI_IMAGE_TAG:-'latest'}

ARG GOLANG_VERSION=${GOLANG_VERSION}
ARG HUGO_VERSION=${HUGO_VERSION}
ARG HUGO_BASE_URL=http://rotorock-io.io

RUN echo "GOLANG_VERSION=[${GOLANG_VERSION}] and HUGO_VERSION=[${HUGO_VERSION}] and HUGO_BASE_URL=[${HUGO_BASE_URL}]"
USER root
# [build-base] because the hugo installation requires gcc and [build-base] package contains the proper gcc
RUN apk update && apk add curl git tree tar bash build-base
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
# ---              CHECKING GOLANG VERSION                --- #
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #

RUN export PATH=$PATH:/usr/local/go/bin && go version

# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
# ---                   INSTALLING HUGO                   --- #
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #

COPY alpine.hugo-extended.setup.sh .
RUN chmod +x ./alpine.hugo-extended.setup.sh && ./alpine.hugo-extended.setup.sh
RUN echo "Is Hugo properly installed ?"
RUN export PATH=$PATH:/usr/local/go/bin && hugo version && hugo env

# +++ +++ +++ +++ +++ +++ +++ +++ +++ +++ +++ +++ +++ +++ +++ #
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
# ---               HUGO BUILD CONTAINER IMAGE            --- #
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
# +++ +++ +++ +++ +++ +++ +++ +++ +++ +++ +++ +++ +++ +++ +++ #

FROM hugo_build_base AS hugo_build
# FROM alpine:${ALPINE_OCI_IMAGE_TAG} AS hugo_build

ARG GIT_COMMIT_ID=${GIT_COMMIT_ID}
ARG CICD_BUILD_ID=${CICD_BUILD_ID}
# export CICD_BUILD_TIMESTAMP=$(date --rfc-3339 seconds)
ARG CICD_BUILD_TIMESTAMP=${CICD_BUILD_TIMESTAMP}
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
# ---                  HUGO BUILD                         --- #
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
LABEL io.rotorock-io.oci.base.image="golang:${GOLANG_VERSION}-alpine${ALPINE_OCI_IMAGE_TAG}"
LABEL io.rotorock-io.golang.version="${GOLANG_VERSION}"
LABEL io.rotorock-io.hugo.version="${HUGO_VERSION}"
LABEL io.rotorock-io.git.commit.id="${GIT_COMMIT_ID}"
LABEL io.rotorock-io.cicd.build.id="${CICD_BUILD_ID}"
LABEL io.rotorock-io.cicd.build.timestamp="${CICD_BUILD_TIMESTAMP}"
LABEL io.rotorock-io.website="https://rotorock-io.herokuapp.com"
LABEL io.rotorock-io.github.org="https://github.com/rotorock-io"
LABEL io.rotorock-io.author="Jean-Baptiste Lasselle <jean.baptiste.ricard.io@gmail.com>"
LABEL io.rotorock-io.maintainer="Jean-Baptiste Lasselle <jean.baptiste.ricard.io@gmail.com>"

RUN mkdir -p /rotorock-io.io/hugo/src/
# COPY . /rotorock-io.io/hugo/src/
# COPY .git /rotorock-io.io/hugo/src/
RUN ls -allh /rotorock-io.io/hugo/src/

COPY . /rotorock-io.io/hugo/src/
RUN export PATH=$PATH:/usr/local/go/bin && cd /rotorock-io.io/hugo/src/ && hugo -b "${HUGO_BASE_URL}"


FROM hugo_build AS hugo_release

ARG HUGO_BASE_URL=http://rotorock-io.io
ENV HUGO_BASE_URL=${HUGO_BASE_URL}
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
# ---                  HUGO SERVER RUNTIME                --- #
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
# Of course you would not ever distribute the hugo dev server in
# production, this is just an example... (And I do what I want to
# do, with my production env., because it mine: the pint is how do
#  you choose that)
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- #
COPY serve.sh /rotorock-io.io/hugo/
EXPOSE 1313
WORKDIR /rotorock-io.io/hugo/src/
# RUN echo 'export PATH=$PATH:/usr/local/go/bin' > /rotorock-io.io/entrypoint.sh
# RUN chmod +x /rotorock-io.io/entrypoint.sh
# ENTRYPOINT [ "/rotorock-io.io/entrypoint.sh" ]
CMD ["/rotorock-io.io/hugo/serve.sh"]
