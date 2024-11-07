# mtc-bench

Benchmark commands using `hyperfine` and `psrecord`. Look into CPU, memory and time.

## Dependencies

- hyperfine
- psrecord

## Installing

Run the `install.sh` script to install `mtc-bench` on your `/usr/local/bin` directory.

## Run

```
mtc-bench 'CMD1 [ARGS...]' ['CMD2'...]
```

Example:

```
mtc-bench 'sleep 2' 'sleep 3'
```

## Bugs and stuff

Open a GitHub [issue](https://github.com/andrefs/mtc-bench/issues) or, preferably, send me a [pull request](https://github.com/andrefs/mtc-bench/pulls).

## License

The MIT License (MIT)

Copyright (c) 2024 André Santos andrefs@andrefs.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
