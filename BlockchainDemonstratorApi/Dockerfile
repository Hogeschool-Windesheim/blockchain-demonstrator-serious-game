#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-buster-slim AS base
WORKDIR /app
EXPOSE 5002

FROM mcr.microsoft.com/dotnet/core/sdk:3.1-buster AS build
WORKDIR /src
COPY ["./", "BlockchainDemonstratorApi/"]
RUN dotnet restore "BlockchainDemonstratorApi/BlockchainDemonstratorApi.csproj"
COPY . .
WORKDIR "/src/BlockchainDemonstratorApi"
RUN dotnet build "BlockchainDemonstratorApi.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "BlockchainDemonstratorApi.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

ENTRYPOINT ["dotnet", "BlockchainDemonstratorApi.dll"]

