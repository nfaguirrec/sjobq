SJobQ is a very simple queue system written in Bourne shell for managing serial executions running in a local form on only one machine. In some situations is important to let that a set of jobs running one by one without human supervision. This allow you to exploit the computing resources available on your machine, in order to keep the machine working all the time. The principal problem is that the available queue systems are a bit complicated to install or simply you need to be root to install them and you don't have those permissions. SJobQ is the solution, because, you don't need to be root and in order to install it you only need download three files and go !, you can begin to work. 

### INSTALLING
```
DOWNLOAD THE .tar.gz FILE FROM THIS PAGE AND TYPE NEXT COMMANDS
$ tar xvfz nfaguirrec-sjobq-xxxxxxx.tar.gz 
nfaguirrec-sjobq-xxxxxxx/
nfaguirrec-sjobq-xxxxxxx/sjobq.d
nfaguirrec-sjobq-xxxxxxx/sjobq.del
nfaguirrec-sjobq-xxxxxxx/sjobq.push
nfaguirrec-sjobq-xxxxxxx/sjobq.stat

$ ls nfaguirrec-sjobq-xxxxxxx
sjobq.d  sjobq.del  sjobq.push  sjobq.stat

$ cp nfaguirrec-sjobq-xxxxxxx/* $HOME/bin/
```

### DEMON STARTUP
```
$ sjobq.d start
==============================
 SJobQ daemon has been started
==============================
```

### PUTTING JOBS IN THE QUEUE
To put jobs into queue, use the command sjob.queue before its statement. Its important to point out you have to use the character \ if you are going to use special bash characters like !,$,#.

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
command = find /etc/ -name "*.conf" > output ; sleep 30
dir     = /home/nestor/Downloads
```

### CHECKING JOBS STATUS
The command sjobq.stat will show the jobs which are running, queued and finished. 

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
+-------+------------------+----------
|    id |        directory |  command
|       |                  |  
|     2 |      ~/Downloads |  echo "Hola"
|     3 |      ~/Downloads |  find /etc/ -name "*.conf" > output ; sleep 30
+-------+------------------+----------
```
after 2 minutes ...
```
$ sjobq.stat

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

### DELETING JOBS
Imagine that you put the following commands in the queue 
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
|     6 |      ~/Downloads |  sleep 3h
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
You can delete a queued job by using its identifier (id). The id is provided in the output of the sqjob.stat command. 
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
Also it is possible to delete the running job by using the identifier "current". 
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
```
$ sjobq.d stop
==============================
 SJobQ daemon has been stopped
==============================
```

### Authors and Contributors
Néstor F. Aguirre (@nfaguirrec) 2010-2015
