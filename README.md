# OBG-SolucionesCloud
Infraestructura Terraform para php-ecommerce-obligatorio
Este proyecto contiene toda la infraestructura necesaria para desplegar la aplicación php‑ecommerce‑obligatorio en AWS utilizando Terraform.
Incluye red, seguridad, base de datos, autoscaling, balanceador, bastion y automatización del despliegue de la aplicación.

Componentes principales
La infraestructura se crea automáticamente mediante la utilizacion de Terraform:

1. Red (VPC)

* VPC dedicada
* Subredes públicas y privadas
* Route tables
* Internet Gateway
* NAT Gateways

2. Seguridad

* Security Groups para:
* Bastion
* Aplicación
* Base de datos
* Accesos mínimos necesarios siguiendo buenas prácticas

3. Base de Datos (RDS – MySQL)

* Instancia RDS MySQL configurada
* Importación automática del archivo dump.sql desde S3
* El bastion ejecuta la importación sin intervención humana

4. S3

* Bucket para almacenar el dump de la base de datos
* Bucket para hostear el despliegue de la aplicación

5. Auto Scaling Group

* Launch Template con configuración de la instancia
* Instalación automática de apache, dependencias PHP y despliegue de la aplicación desde S3
* Conexión automática a endpoint RDS con MySQL
* Instalación del agente de CloudWatch para métricas básicas

6. Balanceo de carga (ALB)

* Application Load Balancer
* Target Group
* Listener HTTP 80
* Integración automática con el Auto Scaling Group

7. Bastion Host

* Permite acceso SSH a la VPC
* Se encarga de importar el dump a RDS automáticamente al inicio


El Launch Template ejecuta automáticamente:

* Instalación de PHP y dependencias
* Descarga de la app desde S3
* Configuración de conexión a la base
* Instalación y ejecución del agente de CloudWatch (métricas CPU/Memoria/Disk)

Monitoreo
Se activa el CloudWatch Agent, permitiendo visualizar:

* CPU
* Memoria
* Disco
* Métricas por ASG e InstanceId

Estructura del repositorio
deploy/
├── main.tf
├── network.tf
├── s3.tf
├── rds.tf
├── alb.tf
├── autoscaling.tf
├── bastion.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
└── app_userdata.sh.tpl
app/ → contenido de la aplicación (no incluido en este repo)

Se activa el CloudWatch Agent, permitiendo visualizar:
* CPU
* Memoria
* Disco
* Métricas por ASG e InstanceId

Requisitos Previos
Antes de desplegar la infraestructura, asegurarse de tener instalado:

* Terraform ≥ 1.5
Verificar con el siguiente comando sobre el host:

terraform -v

* AWS CLI configurado
Con un usuario con rol y permisos:

aws configure

* Repositorio clonado

git clone https://github.com/eoriguela/OBG-SolucionesCloud.git

cd ./deploy

El folder /deploy contiene todos los archivos .tf necesarios.

Pasos para Desplegar la Infraestructura Completa
1. Clonar el repositorio
git clone https://github.com/eoriguela/OBG-SolucionesCloud.git
cd ./deploy
2. Inicializar Terraform
terraform init
3. Validar la configuración
terraform validate
4. Revisar el plan
terraform plan
5. Aplicar cambios
terraform apply


Autores
Infraestructura desarrollada por Santiago Silva y Ezequiel Origuela, en conjunto con el soporte de Terraform y AWS.
