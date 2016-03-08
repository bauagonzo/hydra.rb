#hydra.rb

##Description
This tool helps to execute the same command on multiple servers via ssh.
It is better to have a clean ~/.ssh/config & ssh key pair authentication working.

##Usage
```
hydra.rb 'toto@db1,root@db2' 'ifconfig'
```

The option --parallel give the number of threads to be executed in parallel ; 0 means as much thread as we have hosts
```
hydra.rb --parallel=0 'toto@db1,root@db2,db3,db4' 'tail -F /var/log/messages'
```

hydra support ARGF & therefore
```
echo 'ls' | hydra.rb -p 2 'toto@db1,root@db2,db3,db4'
hydra.rb -p 2 'toto@db1,root@db2,db3,db4' < my_commands
```

##TODO
* ``hydra.rb '*' 'uname -a'``
 * get pattern from ``grep 'HostName *' ~/.ssh/config``
 * (and/or) ``cut -f 1 -d ' ' < ~/.ssh/known_hosts | cut -f 1 -d ','``
 * (and/or) a config.yml
 * take the correct port from ~/.ssh/config
* Add group in config.yml : ``hydra.rb -G 'srm,web' 'hostname'``
```
db:
 - db1
 - db2
web:
 - *.web.mycorp.com
```
* Add --output=pretty (with color on stdout & nice json in a file ; includes $? of the command (not the ssh))
* capture sig interrupt ; if 1 ctrl-c "Are you sure you wanna stop ?" ; 2 ctrl-c kills every threads
* better thread pool

## License
The MIT License (MIT)
Copyright (c) 2016 <baua.gonzo@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
