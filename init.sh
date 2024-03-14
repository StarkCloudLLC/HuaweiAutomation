#!/bin/bash

# Ejecutar Terraform en el orden correcto
terraform init
terraform apply -auto-approve

# Obtén la dirección IP de la instancia desde Terraform output
SECGROUP_ID=$(terraform output -raw secgroup_id)  # Utiliza -raw para obtener la salida sin comillas

# Elimina las comillas al principio y al final
SECGROUP_ID=$(echo "$SECGROUP_ID" | tr -d '"')

# Establece la variable de entorno
export SECGROUP_ID

# Ejecutar Packer
packer build hw-win-2019.pkr.hcl

# Liberar recursos
terraform destroy -auto-approve

# Liberar variable de entorno

unset SECGROUP_ID

# Obtiene la fecha en el formato deseado y la añade al nombre de la imagen
TF_VAR_WINIMGNAME="sap_base_image_win_2019_$(date +'%m-%d-%Y')"

# Establece la variable de entorno
export TF_VAR_WINIMGNAME

# Crea una maquina con la imagen

cd ecs

terraform init
terraform apply -auto-approve

cd ..

# Liberar variable de entorno

unset TF_VAR_WIN_IMG_NAME

# Ejecutar con source ./init.sh