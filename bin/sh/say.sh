#!/usr/bin/env bash

# should say something (usage: say.sh something)
(espeak || say || cat) << $1

