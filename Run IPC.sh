#!/bin/bash
echo starting server
#open server as daemon thread
./Server/Debug/Server.exe -d
echo starting client
./Client/Debug/Client.exe
echo ready