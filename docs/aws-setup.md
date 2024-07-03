# Configuración de AWS

Para configurar la infraestructura de AWS necesaria para nuestra solución de análisis del S&P 500, siga estos pasos:

1. Asegúrese de tener Terraform instalado en su máquina local.

2. Clone el repositorio del proyecto:
git clone https://github.com/tu-usuario/sp500-analysis.git
cd sp500-analysis
Copy
3. Navegue al directorio de infraestructura:
cd infrastructure
Copy
4. Revise y, si es necesario, modifique el archivo `aws.tf` para ajustar cualquier configuración específica de su entorno.

5. Inicialice Terraform:
terraform init
Copy
6. Revise el plan de Terraform:
terraform plan
Copy
7. Si el plan parece correcto, aplique la configuración:
terraform apply
Copy
8. Confirme la aplicación escribiendo "yes" cuando se le solicite.

9. Una vez completada la ejecución, Terraform mostrará los detalles de la infraestructura creada. Guarde esta información, ya que la necesitará para configurar Snowflake y Airflow.

Recuerde que este proceso creará recursos en AWS que pueden generar costos. Asegúrese de entender estos costos 