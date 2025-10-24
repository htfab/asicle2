#!/bin/bash
f4pga -vv build --flow asicle2-basys3.json
mkdir -p build/log
mv *.log build/log/
cp build/basys3/fpga_top.bit asicle2.bit
