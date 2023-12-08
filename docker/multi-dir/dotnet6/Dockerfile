# syntax=docker/dockerfile:1.3

# The first image is used by Visual Studio in container fast mode - this should be the base for the final image 
# See https://aka.ms/containerfastmode to understand how Visual Studio uses the first image for faster debugging.
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build

FROM base AS final

RUN apt-get update && \
    apt-get upgrade -y
