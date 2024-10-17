#!/bin/bash

# Path to the parameter file
PARAM_FILE="params.txt"

# Example: array of values to iterate over
VALUES=("value1" "value2" "value3")

for N_CLUSTERS in $(seq 32 -1 20)
do
    # Iterate over the second parameter range (1 to 1.3, increment by 0.02)
    for PROB_TH in $(seq 0.125 -0.001 0.115)
    do
        # Update the parameter file with both parameters
        echo "n_clusters=$N_CLUSTERS" > $PARAM_FILE
        echo "prob_th=$PROB_TH" >> $PARAM_FILE
        
        > ./temp_output.txt

        docker rmi -f task1

        # Rebuild the Docker image
        docker build --tag task1 . >/dev/null 2>&1

        # Run the Docker container
        docker run --rm -u $(id -u):$(id -g) -v "$( cd "$( dirname "$0" )" && pwd )":/results task1 2>/dev/null | tee "./temp_output.txt"

        # Extract the cost value from the temporary output file
        COST=$(grep "Your public cost is " "./temp_output.txt" | sed -n 's/.*Your public cost is \([0-9.]*\).*/\1/p')

        if [[ -n "$COST" ]]; then
            echo "n_clusters: $N_CLUSTERS   p_threshold: $PROB_TH $COST   -->    cost: $COST" >> "./bash_results.txt"
        else
            echo "Cost not found for parameters: $N_CLUSTERS $PROB_TH" >> "./bash_results.txt"
        fi 

    done
done