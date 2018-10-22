#!/bin/bash

exec play -q -n -c 2 \
	synth 0 \
	noise 100 \
	noise 100 \
	lowpass 100 \
	gain 12 \
	tremolo 0.125 80
