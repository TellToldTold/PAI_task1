#!/bin/bash

PARAM_FILE="params.txt"

docker build --tag task1_k . >/dev/null 2>&1

for K_INDEX in $(seq 0 1 5)
do
    for N_CLUSTERS in $(seq 100 -10 20)
    do
        for PROB_TH in $(seq 0.15 -0.1 0.05)
        do
            echo "kernel=$K_INDEX" > $PARAM_FILE
            echo "n_clusters=$N_CLUSTERS" >> $PARAM_FILE
            echo "prob_th=$PROB_TH" >> $PARAM_FILE
            
            > ./temp_output.txt

            docker run --rm -u $(id -u):$(id -g) -v "$(pwd)/$PARAM_FILE:/code/params.txt" -v "$( cd "$( dirname "$0" )" && pwd )":/results task1_k 2>/dev/null | tee "./temp_output.txt"

            COST=$(grep "Your public cost is " "./temp_output.txt" | sed -n 's/.*Your public cost is \([0-9.]*\).*/\1/p')

            if [[ -n "$COST" ]]; then
                echo "n_clusters: $N_CLUSTERS   p_threshold: $PROB_TH   -->    cost: $COST" >> "./bash_results$K_INDEX.txt"
            else
                echo "Cost not found for parameters: $N_CLUSTERS $PROB_TH" >> "./bash_results.txt"
            fi 

        done
done