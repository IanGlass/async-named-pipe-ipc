# Async-Named-Pipe-IPC

Simple implementation of an asynchronous named pipe to perform IPC between two processes.

The server contains a table for storing student data, where student objects can be added, edited or deleted through the client process.
Currently supported student properties are: name and age

The server supports the following commands:

* add - adds an student object to the end of the 'table'
* delete [index] -  deletes the object specified by index
* size - returns the current size of the 'table'
* get [property] [index] - returns the property of the student specified by index
* edit [property] [index] [value] - writes value to the property of the student specified by index
* exit - closes client process, server process continues in background. The server will allow a new client connection at this point
