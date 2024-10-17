#!/bin/bash

PARAM_FILE="params.txt"

K_INDEX="0"

docker build --tag task1_c . >/dev/null 2>&1

for N_CLUSTERS in $(seq 35 -1 20)
do
    for PROB_TH in $(seq 0.125 -0.001 0.115)
    do
        echo "kernel=$K_INDEX" > $PARAM_FILE
        echo "n_clusters=$N_CLUSTERS" >> $PARAM_FILE
        echo "prob_th=$PROB_TH" >> $PARAM_FILE
        
        > ./temp_output.txt

        docker run --rm -u $(id -u):$(id -g) -v "$(pwd)/$PARAM_FILE:/code/params.txt" -v "$( cd "$( dirname "$0" )" && pwd )":/results task1_c 2>/dev/null | tee "./temp_output.txt"

        COST=$(grep "Your public cost is " "./temp_output.txt" | sed -n 's/.*Your public cost is \([0-9.]*\).*/\1/p')

        if [[ -n "$COST" ]]; then
            echo "n_clusters: $N_CLUSTERS   p_threshold: $PROB_TH   -->    cost: $COST" >> "./bash_results.txt"
        else
            echo "Cost not found for parameters: $N_CLUSTERS $PROB_TH" >> "./bash_results.txt"
        fi 
    done
done
