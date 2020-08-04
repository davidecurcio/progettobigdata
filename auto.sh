#!/bin/bash

for training in 5 15 20 30
do
    for test in 2 5 10 15 20 30
    do 
        python3 auto.py $training $test
    done
done
