#!/bin/bash

while true 
do
    number=$((RANDOM * -1))

    if [[ $number -eq 0 ]]; then
        break  # Exit the loop when 0 is entered
    fi

    if [[ $number -lt 0 ]]; then
        echo "Negative numbers are not allowed."
        continue  # Skip the rest of the loop and go to the next iteration
    fi

    echo "The square of $number is $((number * number))"
done
