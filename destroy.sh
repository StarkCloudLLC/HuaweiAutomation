#!/bin/bash

cd ecs

terraform destroy -auto-approve

cd ..

## solo destruye la maquina y las redes, no la imagen generada