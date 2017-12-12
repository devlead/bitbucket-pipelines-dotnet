FROM ubuntu:16.04

# Enable SSL
RUN apt-get update \
    && apt-get install -y apt-transport-https curl tzdata git

# Install .NET Core
RUN curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg \
    && mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg \
    && sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-xenial-prod xenial main" > /etc/apt/sources.list.d/dotnetdev.list' \
    && apt-get update \
    && apt-get install -y dotnet-dev-1.1.5 unzip


# Install mono
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF \
    && echo "deb http://download.mono-project.com/repo/debian wheezy/snapshots/4.4.2 main" > /etc/apt/sources.list.d/mono-xamarin.list \
    && apt-get update \
    && apt-get install -y mono-devel \
    && rm -rf /var/lib/apt/lists/*

# Install NuGet
RUN mkdir -p /opt/nuget \
    && curl -Lsfo /opt/nuget/nuget.exe https://dist.nuget.org/win-x86-commandline/latest/nuget.exe

ENV PATH "$PATH:/opt/nuget"

# Prime dotnet
RUN mkdir dotnettest \
    && cd dotnettest \
    && dotnet new console -lang C# \
    && dotnet restore \
    && dotnet build \
    && dotnet run \
    && cd .. \
    && rm -r dotnettest

# Prime Cake
ADD cakeprimer cakeprimer
RUN cd cakeprimer \
    && dotnet restore Cake.sln \
    --source "https://www.myget.org/F/xunit/api/v3/index.json" \
    --source "https://dotnet.myget.org/F/dotnet-core/api/v3/index.json" \
    --source "https://dotnet.myget.org/F/cli-deps/api/v3/index.json" \
    --source "https://api.nuget.org/v3/index.json" \
     /property:UseTargetingPack=true \
    && cd .. \
    && rm -rf cakeprimer

# Cake
ENV CAKE_NUGET_USEINPROCESSCLIENT true
ENV CAKE_VERSION 0.23.0
RUN mkdir -p /opt/Cake/Cake \
    && curl -Lsfo Cake.zip "https://www.myget.org/F/cake/api/v2/package/Cake/$CAKE_VERSION" \
    && unzip -q Cake.zip -d "/opt/Cake/Cake" \
    && rm -f Cake.zip

ADD cake /usr/bin/cake
RUN chmod 755 /usr/bin/cake

# Test Cake
RUN mkdir caketest \
    && cd caketest \
    && cake --version \
    && cd .. \
    && rm -rf caketest

# Display info installed components
RUN mono --version
RUN dotnet --info
RUN apt-get clean
