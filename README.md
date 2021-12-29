# Sedit
Stupid text editor edits in 1 line

Running
``` sh
$ ./sedit.rkt [filename]
```

Currently, supports 
- basic movements (->, <-)
- deletion (backspace, delete)
- text insertion (Unicode characters)
- Opening and Saving file

Example
``` sh
$ echo "test" > test.txt
$ ./sedit test.txt # opening existing file
$ # Write "hello" in GUI, press <Enter> (\r)
$ cat test.txt
hello
$
$ ./sedit non-exist.txt # opening non-existing file
```
