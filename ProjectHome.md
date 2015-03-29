SJobQ is a very simple queue system written in Bourne shell for managing serial jobs that run in local form on one machine only. In some situations is important to let that a set of jobs run in series without human supervision. This allow you to exploit the computing resources available on your machine, in order to keep the machine working all the time. The principal problem is that the available queue systems are a bit complicated to install or simply you need to be root to install them and you don't have those permissions. SJobQ is the solution, because, you don't need to be root and in order to install it you only need download three files and go !, you can begin to work.

**INSTALLING**
```
$ svn checkout http://sjobq.googlecode.com/svn/trunk/ sjobq-read-only
A    sjobq-read-only/sjobq.d
A    sjobq-read-only/sjobq.del
A    sjobq-read-only/sjobq.stat
A    sjobq-read-only/sjobq.push
Checked out revision 3.

$ ls sjobq-read-only/
sjobq.d  sjobq.del  sjobq.push  sjobq.stat

$ cp sjobq-read-only/* $HOME/bin/
```

**DEMON STARTUP**
```
$ sjobq.d start
```

**PUTTING JOBS IN THE QUEUE**

To put jobs into queue, use the command **sjob.queue** before its statement. Its important to point out you have to use the character \ if you are going to use special bash characters like !,$,#.

```
$ sjobq.push sleep 30s
id      = 1
command = sleep 30s
dir     = /home/nestor/Downloads

$ sjobq.push echo \"Hola\"
id      = 2
command = echo "Hola"
dir     = /home/nestor/Downloads

$ sjobq.push find /etc/ -name \"\*.conf\" \> output \; sleep 30
id      = 3
command = find /etc/ -name "*.conf" > output
dir     = /home/nestor/Downloads
```

**CHECKING JOBS STATUS**

The command **sjobq.stat** will show the jobs which are running, queued and finished.

```
$ sjobq.stat
-------------
 Current job
-------------
pid          = 5644
command      = sleep 30s
dir          = /home/nestor/Downloads
time spent   = 0h 0m 3s
pids         = 5644 
tree         =
        sleep(5644)

-----------
 Job queue
-----------
id      = 2
command = echo "Hola"
dir     = /home/nestor/Downloads

id      = 3
command = find /etc/ -name "*.conf" > output ; sleep 30
dir     = /home/nestor/Downloads

---------
 History
---------
```

after 2 minutes ...

```
$ sjobq.stat
---------
 History
---------
command      = sleep 30
dir          = /home/nestor/Downloads
time spent   = 0h 0m 31s

command      = echo "Hola"
dir          = /home/nestor/Downloads
time spent   = 0h 0m 4s

command      = find /etc/ -name "*.conf" > output ; sleep 30
dir          = /home/nestor/Downloads
time spent   = 0h 0m 31s
```

**DELETING JOBS**

Imagine that you put the following commands in the queue

```
$ sjobq.push sleep 1h
id      = 4
command = sleep 1h
dir     = /home/nestor/Downloads

$ sjobq.push sleep 2h
id      = 5
command = sleep 1h
dir     = /home/nestor/Downloads

$ sjobq.push sleep 3h
id      = 6
command = sleep 1h
dir     = /home/nestor/Downloads

$ sjobq.stat
-------------
 Current job
-------------
pid          = 27378
command      = sleep 1h
dir          = /home/nestor/Downloads
time spent   = 0h 0m 13s
pids         = 27378 
tree         =
        sleep(27378)

-----------
 Job queue
-----------
id      = 5
command = sleep 2h
dir     = /home/nestor/Downloads

id      = 6
command = sleep 3h
dir     = /home/nestor/Downloads

---------
 History
---------
command      = sleep 30
dir          = /home/nestor/Downloads
time spent   = 0h 0m 31s

command      = echo "Hola"
dir          = /home/nestor/Downloads
time spent   = 0h 0m 4s

command      = find /etc/ -name "*.conf" > output ; sleep 30
dir          = /home/nestor/Downloads
time spent   = 0h 0m 31s

```

You can delete a queued job by using its identifier (id). The id is provided in the output of the **sqjob.stat** command.
```
$ sjobq.del 6
Job with id=6 has been deleted !!

$ sjobq.stat
-------------
 Current job
-------------
pid          = 27378
command      = sleep 1h
dir          = /home/nestor/Downloads
time spent   = 0h 0m 13s
pids         = 27378 
tree         =
        sleep(27378)

-----------
 Job queue
-----------
id      = 5
command = sleep 2h
dir     = /home/nestor/Downloads

---------
 History
---------
command      = sleep 30
dir          = /home/nestor/Downloads
time spent   = 0h 0m 31s

command      = echo "Hola"
dir          = /home/nestor/Downloads
time spent   = 0h 0m 4s

command      = find /etc/ -name "*.conf" > output ; sleep 30
dir          = /home/nestor/Downloads
time spent   = 0h 0m 31s

```

Also it is possible to delete the running job by using the identifier "current".
```
$ sjobq.del current
Job with id=current has been deleted !!

$ sjobq.stat
-------------
 Current job
-------------
pid          = 28465
command      = sleep 2h
dir          = /home/nestor/Downloads
time spent   = 0h 1m 6s
pids         = 28465 
tree         =
        sleep(28465)

---------
 History
---------
command      = sleep 30
dir          = /home/nestor/Downloads
time spent   = 0h 0m 31s

command      = echo "Hola"
dir          = /home/nestor/Downloads
time spent   = 0h 0m 4s

command      = find /etc/ -name "*.conf" > output ; sleep 30
dir          = /home/nestor/Downloads
time spent   = 0h 0m 31s

command      = sleep 1h
dir          = /home/nestor/Downloads
time spent   = 0h 5m 8s
```

**DAEMON SHUTDOWN**
```
$ sjobq.d stop
```