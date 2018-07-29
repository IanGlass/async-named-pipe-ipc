#!/bin/bash
echo starting server
#detach server process from main
./Server/Debug/Server.exe &
echo starting client
./Client/Debug/Client.exe