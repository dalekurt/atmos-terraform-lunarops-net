#
# This is an example of a Dockerfile that customizes Geodesic
# for a customer using the Cloud Posse Reference Architecture.
# Use it as a basis for your own customizations.
#
# Note that Geodesic supports runtime customizations that
# do not require a custom Dockerfile. See:
#   https://github.com/cloudposse/geodesic/blob/master/docs/customization.md
#
# See Dockerfile.options for some common options you might want.
#
# Note that the version numbers in this file are not maintained,
# you will want to update them to current versions when you start
# and then have a plan for regularly updating them as you go along.
#

# We always recommend pinning versions where changes are likely to break things.
# We put the versions up top here so they are easy to find and update.
ARG VERSION=1.2.1
# Changing base OS for Geodesic is possible by changing this arg, but
# unfortunately, the package managers are different, so it is not that simple.
ARG OS=debian

FROM cloudposse/geodesic:$VERSION-$OS

ENV DOCKER_IMAGE="examplecorp/infrastructure"
ENV DOCKER_TAG="latest"

# Geodesic banner message
ENV BANNER="Lunar Ops, Inc"
# The project "Namespace" used in AWS identifiers and elsewhere
# to ensure globally unique names are generated.
ENV NAMESPACE="xamp"

# Default AWS_PROFILE
ENV AWS_PROFILE="xamp-gbl-identity-admin"
ENV ASSUME_ROLE_INTERACTIVE_QUERY="xamp-gbl-"
# Enable advanced AWS assume role chaining for tools using AWS SDK
# https://docs.aws.amazon.com/sdk-for-go/api/aws/session/
ENV AWS_SDK_LOAD_CONFIG=1
# Region abbreviation types are "fixed" (always 3 chars), "short" (4-5 chars), or "long" (the full AWS string)
# See https://github.com/cloudposse/terraform-aws-utils#introduction
ENV AWS_REGION_ABBREVIATION_TYPE=fixed
ENV AWS_DEFAULT_REGION=us-east-1
ENV AWS_DEFAULT_SHORT_REGION=ue1

# Install specific versions of Terraform.
# We patch specific patch versions because Terraform will not operate
# on Terraform "states" that have been touched by later versions.
ARG TF_014_VERSION=0.14.10
ARG TF_015_VERSION=0.15.4
ARG TF_1_VERSION=1.0.4
RUN apt-get update && apt-get install -y -u \
  terraform-0.14="${TF_014_VERSION}-*" terraform-0.15="${TF_015_VERSION}-*" \
  terraform-1="${TF_1_VERSION}-*"
# Set Terraform 0.14.x as the default `terraform`. You can still use
# version 0.15.x by calling `terraform-0.15` or version 1.x as terraform-1
RUN update-alternatives --set terraform /usr/share/terraform/0.14/bin/terraform

# Pin kubectl minor version (must be within 1 minor version of cluster version)
# Note, however, that due to Docker layer caching and the structure of this
# particular Dockerfile, the patch version will not automatically update
# until you change the minor version or change the base Geodesic version.
# If you want, you can pin the patch level so you can update it when desired.
ARG KUBECTL_VERSION=1.20
RUN apt-get update && apt-get install kubectl-${KUBECTL_VERSION}

# Install Atmos CLI (https://github.com/cloudposse/atmos)
RUN apt-get install atmos

COPY rootfs/ /

WORKDIR /
