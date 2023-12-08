# syntax=docker/dockerfile:1.3

# The first image is used by Visual Studio in container fast mode - this should be the base for the final image 
# See https://aka.ms/containerfastmode to understand how Visual Studio uses the first image for faster debugging.
FROM mcr.microsoft.com/dotnet/aspnet:7.0-cbl-mariner2.0 AS base

# This stage is used by VS for fast local debugging; it does not appear in the final image
FROM base as debug 
RUN tdnf install -y procps-ng

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build

FROM base AS final

RUN tdnf clean all dnf check-update && \
    tdnf upgrade -y && \
    tdnf clean all dnf
