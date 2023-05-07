#See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["PredictionBot-Operation/PredictionBot-Operation.csproj", "PredictionBot-Operation/"]
COPY ["PredictionBot-Operation-Application/PredictionBot-Operation-Application.csproj", "PredictionBot-Operation-Application/"]
COPY ["PredictionBot-Operation-Infrastructure/PredictionBot-Operation-Infrastructure.csproj", "PredictionBot-Operation-Infrastructure/"]
COPY ["PredictionBot-Operation-Domain/PredictionBot-Operation-Domain.csproj", "PredictionBot-Operation-Domain/"]
RUN dotnet restore "PredictionBot-Operation/PredictionBot-Operation.csproj"
COPY . .
WORKDIR "/src/PredictionBot-Operation"
RUN dotnet build "PredictionBot-Operation.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "PredictionBot-Operation.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "PredictionBot-Operation.dll"]