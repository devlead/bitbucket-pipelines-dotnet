#!/bin/sh
export NUGET_XMLDOC_MODE=skip
export DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1
export DOTNET_CLI_TELEMETRY_OPTOUT=1
exec mono /opt/Cake/Cake/Cake.exe "$@"