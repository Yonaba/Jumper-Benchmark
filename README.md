Jumper-Benchmark
================

Set of benchmark tests for the pathfinding library [Jumper](https://github.com/Yonaba/Jumper)

##Download
You can retrive the contents of this repository locally on your computer with the following bash command:
```bash
git clone git://github.com/Yonaba/Jumper-Benchmark.git
```

You can also download the repository as a [.zip](https://github.com/Yonaba/Jumper-Benchmark/zipball/master) or [.tar.gz](https://github.com/Yonaba/Jumper-Benchmark/tarball/master) file

##Requirements:
The following test uses [LuaSocket](http://w3.impa.br/~diego/software/luasocket/) for high resolution time measurements (milliseconds).<br/>
*Make sure to have this dependency installed* on your computer. Find relevant instructions [here](http://w3.impa.br/~diego/software/luasocket/installation.html).

##Usage
To perform the tests, run the file [run.lua](https://github.com/Yonaba/Jumper-Benchmark/blob/master/run.lua) from Lua.<br/>
Results will be displayed in the console window, and also exported as *.log files* (one *.log file* per map) in the folder [benchmarks/logs](https://github.com/Yonaba/Jumper-Benchmark/blob/master/benchmarks/logs).

<center><img src="http://ompldr.org/vZzRlbQ" alt="" border="0" /></center>

##Command-line args
Command-line args can be passed to [run.lua](https://github.com/Yonaba/Jumper-Benchmark/blob/master/run.lua):
````
run.lua -l <path> -m <mapfile>
```

* -l <path> : where <tt>path</tt> is the path to an *existing* folder where you want to export *.log* files
* -m <mapfile> : where <tt>mapfile</tt> is a single mapfile to be processed (see [map_list](https://github.com/Yonaba/Jumper-Benchmark/blob/master/benchmarks/map_list.lua) for map files names)

Examples:
````
run lua
run.lua -m ht_keep.map
run.lua -l output
run.lua -l output -m Backwoods.map
run.lua -m w_bonepit.map -l output
```

##Maps
Maps were taken from the [2012 Grid-Based Path Planning Competition](http://movingai.com/GPPC/).<br/>
Map files format and description are given [here](http://www.movingai.com/benchmarks/formats.html).

##License##
This work is under [MIT-LICENSE](http://www.opensource.org/licenses/mit-license.php)<br/>
Copyright (c) 2012 Roland Yonaba

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.