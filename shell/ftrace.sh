#!/bin/bash
mkdir -p /debug
mount -t debugfs nodev /debug 2>&1
echo '*' >/debug/tracing/set_ftrace_filter
echo function >/debug/tracing/current_tracer
echo 1 >/debug/tracing/tracing_on
read -p "press ENTER key to cancel .." var
echo 0 >/debug/tracing/tracing_on
cat /debug/tracing/trace > /tmp/tracing.out$$
echo "/tmp/tracing.out$$ is created .."


