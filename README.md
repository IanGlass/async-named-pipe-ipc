# Async-Named-Pipe-IPC
This project illustrates an implementation of an asynchronous named pipe between two processes, the client and the server. The server stores and sends student records while the client sends commands/data or requests data.

IPC communication is layered with a message payload struct consisting of:
* A command;
* An index, used to access/modify specific student records
* A type, used to specify a specific student property to access/modify
* Data, the data to be written in the case of a write command. The data member is also used to transfer error messages to the client if invalid actions are performed.

```cpp
/* message payload struct */
typedef struct {
	char CMD[1024];
	int Index;
	char Type[1024];
	char Data[1024];
} Payload;
```

## Server

The server contains a table for storing student data, where student objects can be added, edited or deleted through the client process.

The server supports 5 commands with expected [arguments]:
* add - Adds an empty student object to the end of the table
* delete [index] - Deletes the record number specified by index
* size - Returns the current size of the table
* get [property] [index] - Returns the property of the student specified by index
* edit [property] [index] [value] - Writes a value to the property of the student specified by index

```cpp
int main() {
	/* create a DB of students as a vector of class Student with 1 'row'*/
	std::vector<Student> StudentTable(1);
	/* empty Student obj for vector.push_back */
	Student Empty;
	/* packet used for reading data from pipe */
	Payload Packet;
	/* buffer for writing data to pipe */
	char Buffer[1024];
	/* pipe opened on instantiation */
	CPipe Server;

	while (Server.Pipe() != INVALID_HANDLE_VALUE) {
		/* wait for a client process to connect to server */
		while (Server.Connect() != FALSE) {
			/* wait to receive data from client */
			while ((ReadFile(Server.Pipe(), &Packet, sizeof(Packet), NULL, NULL) != FALSE) && (GetLastError() != ERROR_BROKEN_PIPE)) {
```

* exit - closes client process, server process continues in background. This means that the student data is persistent with the server process. The server will allow a new client connection when the old one is closed.

Currently supported student properties are: name and age

The entry point for this application is Run-IPC.sh

Have Fun!
