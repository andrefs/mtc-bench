# mtc-bench

Benchmark commands using `hyperfine` and `psrecord`. Look into CPU, memory and time.

## Dependencies

- hyperfine
- psrecord

## Installing

Run the `install.sh` script to install `mtc-bench` on your `/usr/local/bin` directory.

You can use the `INSTALL_DIR` ENV var to install on another place, e.g.:

```
INSTALL_DIR=$HOME/.local/bin ./install.sh
```

## Rebuilding

The build process uses `App::Fatpacker` to bundle `mtc-bench.pl` together with it's dependencies and generate `mtc-bench`.

If you want to change stuff you should edit `mtc-bench.pl` and in the end run

```
fatpack pack mtc-bench.pl > mtc-bench
```

## Run

```bash
mtc-bench 'CMD1 [ARGS...]' ['CMD2'...]
```

Example:

```bash
mtc-bench 'sleep 2' 'sleep 3'
```

Alternatively, you can pass a CSV file with commands to be run, using the flag `-f CMDS_FILE`. The file should have a header row, and then one command per line:

```csv
label, prepare, command
cmdLabel1, , command1 arg1 arg2
cmdLabel2, , command2
```

## Options

- `-h, --help`: Print help message
- `-v, --verbose`: Print verbose output
- `-s, --show-output`: Show output of the commands
- `-p, --prepare`: Prepare commands to run before benchmarking. See `hyperfine --help`
- `-f, --file`: Read commands from a CSV file

## ENV vars

You can also change the behavior of `mtc-bench` using the following ENV variables:

- `WARMUP`: Number of warmup runs
- `RES_DIR`: Directory to store results
- `RUNS`: Number of runs

## Performance

In `mtc-bench`, `hyperfine` invokes `psrecord`, which in turn invokes the command to be benchmarked.
This means that `hyperfine` is not directly measuring the command's run time, but `psrecord`'s instead.

I ran a few tests on my laptop and `psrecord` seems to add around 0.7s to the command's run time in each run (probably because it is generating the output log and image).
Anyway, it shouldn't change much across runs, so the comparisons between the commands being benchmarked still stand.

## Bugs and stuff

Open a GitHub [issue](https://github.com/andrefs/mtc-bench/issues) or, preferably, send me a [pull request](https://github.com/andrefs/mtc-bench/pulls).

## License

The MIT License (MIT)

Copyright (c) 2024 André Santos andrefs@andrefs.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
