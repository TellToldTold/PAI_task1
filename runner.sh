
#!/bin/bash

> ./params.txt

docker build --tag task1 . 

docker run --rm -u $(id -u):$(id -g) -v "$(pwd)/params.txt:/code/params.txt" -v "$( cd "$( dirname "$0" )" && pwd )":/results task1 

