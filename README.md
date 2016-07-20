SJobQ is a very simple queue system written in Bourne shell. It manages serial executions that run in a local form. The aim is to keep the computer working all the time, in order to exploit as much as possible your available computing resources. Regarding standard available programs to manage queues, very often they are a bit complicated to install and/or to configure, or simply you need administrative privileges to install them and you have no those permissions. For these cases, SJobQ is the solution, because in order to install it, you only need to download six files and that's all !. You can start to work. 

### INSTALLING
Download the .zip file from this page and extract the files,
```
$ unzip sjobq-master.zip
Archive:  sjobq-master.zip
1dde49967385f2ba76d34a1af52f70df9d4174f9
   creating: sjobq-master/
  inflating: sjobq-master/README.md
  inflating: sjobq-master/sjobq.d
  inflating: sjobq-master/sjobq.del
  inflating: sjobq-master/sjobq.push
  inflating: sjobq-master/sjobq.stat
$ mv sjobq-master/ sjobq
```
or clone the repository using git
```
$ git clone https://github.com/nfaguirrec/sjobq.git
```
This should be the content of the sjobq directory if previous steps were successful:
```
$ ls sjobq
README.md  sjobq.client  sjobq.daemon  sjobq.del  sjobq.sort  sjobq.push  sjobq.stat
```
Finally, to install the program, you simply have to copy the files in a directory included in the PATH system variable, as for example bin in your home directory:
```
$ cp sjobq/* $HOME/bin/
```

### DEMON STARTUP
```
$ sjobq.daemon start
==============================
 SJobQ daemon has been started
==============================
```

### PUTTING JOBS IN THE QUEUE
To put jobs into queue, use the command sjob.queue before its statement.
Its important to point out you have to use the character \ if you are going to use special bash characters like !,$,#.

```
$ sjobq.push sleep 30s
id      = 1
command = sleep 30s
dir     = ~/Downloads

$ sjobq.push echo \"Hola\"
id      = 2
command = echo "Hola"
dir     = ~/Downloads

$ sjobq.push find /etc/ -name \"\*.conf\" \> output \; sleep 30
id      = 3
command = find /etc/ -name "*.conf" > output ; sleep 30
dir     = ~/Downloads
```

### CHECKING JOBS STATUS
The command sjobq.stat will show the jobs which they are running, queued and those what already have finished.

```
$ sjobq.stat
+-------------+
| Current job |
+-------------+

pid          = 29406
command      = sleep 30s
dir          = ~/Downloads
time spent   = 00-00:00:09
pids         = 29406 
tree         =
        sleep(29406)

+-------+
| QUEUE |
+-------+------------------+--------------------
|    id |        directory |  command
|       |                  |  
|     2 |      ~/Downloads |  echo "Hola"
|     3 |      ~/Downloads |  find /etc/ -name "*.conf" > output ; sleep 30
+-------+------------------+--------------------
```
after 2 minutes ...
```
$ sjobq.stat

+-------------+
| HISTORY     |
+-------------+------------------+--------------------
|  time spent |        directory |  command
|             |                  |  
| 00-00:00:30 |      ~/Downloads |  sleep 30s
| 00-00:00:04 |      ~/Downloads |  echo "Hola"
| 00-00:00:31 |      ~/Downloads |  find /etc/ -name "*.conf" > output ; sleep 30
+-------------+------------------+--------------------
```

### DELETING AND SORTING JOBS
Let's consider you put the following commands in the queue 
```
$ sjobq.push sleep 1h
id      = 4
command = sleep 1h
dir     = ~/Downloads

$ sjobq.push sleep 2h
id      = 5
command = sleep 1h
dir     = ~/Downloads

$ sjobq.push sleep 3h
id      = 6
command = sleep 1h
dir     = ~/Downloads

$ sjobq.push sleep 4h
id      = 6
command = sleep 1h
dir     = ~/Downloads

$ sjobq.stat
+-------------+
| Current job |
+-------------+

pid          = 30778
command      = sleep 1h
dir          = ~/Downloads
time spent   = 00-00:00:29
pids         = 30778 
tree         =
        sleep(30778)

+-------+
| QUEUE |
+-------+------------------+--------------------
|    id |        directory |  command
|       |                  |  
|     5 |      ~/Downloads |  sleep 2h
|     6 |      ~/Downloads |  sleep 3h
|     7 |      ~/Downloads |  sleep 4h
+-------+------------------+--------------------

+-------------+
| HISTORY     |
+-------------+------------------+--------------------
|  time spent |        directory |  command
|             |                  |  
| 00-00:00:30 |      ~/Downloads |  sleep 30s
| 00-00:00:04 |      ~/Downloads |  echo "Hola"
| 00-00:00:31 |      ~/Downloads |  find /etc/ -name "*.conf" > output ; sleep 30
+-------------+------------------+--------------------
```
You can sort the queued jobs by using its identifier (id). The id is provided in the output of the sqjob.stat command.
For example:

Move the specified jobID to the top of the queue:
```
$ sjobq.sort top 7
$ sjobq.stat
+-------------+
| Current job |
+-------------+

pid          = 30778
command      = sleep 1h
dir          = ~/Downloads
time spent   = 00-00:00:29
pids         = 30778 
tree         =
        sleep(30778)

+-------+
| QUEUE |
+-------+------------------+--------------------
|    id |        directory |  command
|       |                  |  
|     5 |      ~/Downloads |  sleep 4h
|     6 |      ~/Downloads |  sleep 3h
|     7 |      ~/Downloads |  sleep 2h
+-------+------------------+--------------------

+-------------+
| HISTORY     |
+-------------+------------------+--------------------
|  time spent |        directory |  command
|             |                  |  
| 00-00:00:30 |      ~/Downloads |  sleep 30s
| 00-00:00:04 |      ~/Downloads |  echo "Hola"
| 00-00:00:31 |      ~/Downloads |  find /etc/ -name "*.conf" > output ; sleep 30
+-------------+------------------+--------------------
```

or swap two jobs in the queue:
```
$ sjobq.sort swap 5 7
$ sjobq.stat
+-------------+
| Current job |
+-------------+

pid          = 30778
command      = sleep 1h
dir          = ~/Downloads
time spent   = 00-00:00:29
pids         = 30778 
tree         =
        sleep(30778)

+-------+
| QUEUE |
+-------+------------------+--------------------
|    id |        directory |  command
|       |                  |  
|     5 |      ~/Downloads |  sleep 2h
|     6 |      ~/Downloads |  sleep 3h
|     7 |      ~/Downloads |  sleep 4h
+-------+------------------+--------------------

+-------------+
| HISTORY     |
+-------------+------------------+--------------------
|  time spent |        directory |  command
|             |                  |  
| 00-00:00:30 |      ~/Downloads |  sleep 30s
| 00-00:00:04 |      ~/Downloads |  echo "Hola"
| 00-00:00:31 |      ~/Downloads |  find /etc/ -name "*.conf" > output ; sleep 30
+-------------+------------------+--------------------
```
For more options, please take a look to the available parameters of the sjobq.sort command: raise,lower,top,bottom and swap.

You can also delete a queued job by using its identifier (id).
```
$ sjobq.del 6
Job with id=6 has been deleted !!

$ sjobq.stat
+-------------+
| Current job |
+-------------+

pid          = 30778
command      = sleep 1h
dir          = ~/Downloads
time spent   = 00-00:00:29
pids         = 30778 
tree         =
        sleep(30778)

+-------+
| QUEUE |
+-------+------------------+----------
|    id |        directory |  command
|       |                  |  
|     5 |      ~/Downloads |  sleep 2h
+-------+------------------+----------

+-------------+
| HISTORY     |
+-------------+------------------+----------
|  time spent |        directory |  command
|             |                  |  
| 00-00:00:30 |      ~/Downloads |  sleep 30s
| 00-00:00:04 |      ~/Downloads |  echo "Hola"
| 00-00:00:31 |      ~/Downloads |  find /etc/ -name "*.conf" > output ; sleep 30
+-------------+------------------+----------
```

It is also possible to delete the running job by using the identifier "current". 
```
$ sjobq.del current
Job with id=current has been deleted !!

$ sjobq.stat
+-------------+
| Current job |
+-------------+

pid          = 31544
command      = sleep 2h
dir          = ~/Downloads
time spent   = 00-00:00:05
pids         = 31544 
tree         =
        sleep(31544)

+-------------+
| HISTORY     |
+-------------+------------------+----------
|  time spent |        directory |  command
|             |                  |  
| 00-00:00:30 |      ~/Downloads |  sleep 30s
| 00-00:00:04 |      ~/Downloads |  echo "Hola"
| 00-00:00:31 |      ~/Downloads |  find /etc/ -name "*.conf" > output ; sleep 30
| 00-00:02:57 |      ~/Downloads |  sleep 1h
+-------------+------------------+----------
```

### DAEMON SHUTDOWN
If you want simply to stop the daemon:
```
$ sjobq.d stop
==============================
 SJobQ daemon has been stopped
==============================
```
Note that the current job will be still running after this. Additionally, those enqueued jobs will be recovered when daemon is restarted. 

If you want to stop the daemon and clean all configuration data:
```
$ sjobq.d stop clean
Job with id=current has been deleted !!
The SjobQ configuration has been cleaned up successfully !!
==============================
 SJobQ daemon has been stopped
==============================
```

### Authors and Contributors
Néstor F. Aguirre (@nfaguirrec) 2010-2016
