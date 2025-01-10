#!/bin/bash

mkdir --parents ../data

for SCRIPT in ../queries/*.sh; do
    $SCRIPT > "../data/$(basename $SCRIPT .sh).csv"
done
