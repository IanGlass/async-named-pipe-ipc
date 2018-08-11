# Async-Named-Pipe-IPC
This project illustrates an implementation of an asynchronous named pipe between two processes, the client and the server. The server stores and sends student records while the client sends commands/data or requests data.

IPC communication is layered with a message payload struct consisting of:
* A command;
* An index, used to access/modify specific student records
* A type, used to specify a specific student property to access/modify
* Data, the data to be written in the case of a write command. The data member is also used to transfer error messages to the client if invalid actions are performed.

Currently supported student properties are: name and age

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

The server begins by instantiating a vector of class type *Student* of length 1. The *Empty* Student object is used to add an empty student object to the end of the vector when the 'add' command is invoked. The constructor method of class CPipe automatically creates a pipe on instantiation and a destructor closes the pipe. 
Once the pipe is created, the server waits for a client process connection and then enters an infinite loop waiting to receive client data.
The *GetLastError* method allows the server to drop the current pipe connection of the client disconnects and opens a new one when a new client is available.

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

This *SetLastError* method is crucial to ensure the server can re-enter read-mode and receive client payloads.
```cpp
/* clear error code to prevent reaching this line again without new error */
			SetLastError(0);
			/* close pipe as client has been dropped */
			DisconnectNamedPipe(Server.Pipe());
```

## Client
The client feeds its first input into a payload struct.CMD and will drop a connection and end the process if it receives 'exit'. 
```cpp
while (std::cin >> Packet.CMD) {
			if (strcmp(Packet.CMD, "exit") == 0) { break; } /* Close program */
			HandleInputs(&Packet);
```

A handler method will flush stdin for the number of arguments depending on the command issued and store them in the appropriate payload struct member. 
```cpp
/* handles the various input formats */
void HandleInputs(Payload *Packet) {
	/* <add> and <size> expects no arguments */
	/* <delete> format: delete index */
	if (strcmp(Packet->CMD, "delete") == 0) {
		std::cin >> Packet->Index;
	}
	/* <get> format: get type index  */
	else if (strcmp(Packet->CMD, "get") == 0) {
		std::cin >> Packet->Type >> Packet->Index;
	}
	/* <edit> format: edit type index data */
	else if (strcmp(Packet->CMD, "edit") == 0) {
		std::cin >> Packet->Type >> Packet->Index >> Packet->Data;
	}
}
```

Once the payload is appropriately populated, the client sends it to the server via a named pipe and starts a thread which uses a blocking read to wait for receiving data. This allows the main process to continue with other actions while waiting for a server response.
```cpp
WriteFile(Client.Pipe(), &Packet, sizeof(Packet), NULL, NULL);
			/* perform async read from server through thread */
			std::thread first(ReadData, Client.Pipe());
			/* flush pipe data */
			Packet = { 0 };
			
			/* code added here will run asynchronously to the readfile function */
			
			/* reach code which needs value from server so ensure read thread is complete */
			first.join();
```
```cpp
/* thread fn for async data reading */
void ReadData(HANDLE Pipe) {
	char readBuffer[1024];
	/* perform blocking read from server */
	ReadFile(Pipe, &readBuffer, sizeof(readBuffer), NULL, NULL);
	printf("%s\n", readBuffer);
}
```

The entry point for this application is Run-IPC.sh

Have Fun!
