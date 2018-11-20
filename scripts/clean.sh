#!/bin/bash

make clean
repo forall -c 'git reset --hard ; git clean -fdx'
