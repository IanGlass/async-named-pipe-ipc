# Async-Named-Pipe-IPC

Simple implementation of a named pipe to perform IPC between two processes

The client commands are:
ADD, SUB, MUL and DIV expecting the format [CMD] [arg1] [arg2]

SAV [type] [arg1] - saving either a string or an int, where [type] is str or int

GET [type] - returns the stored value

EXT - closing the client program
