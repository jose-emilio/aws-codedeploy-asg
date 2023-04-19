## Despliegue de aplicaciones con AWS CodeDeploy y Amazon EC2 Auto Scaling
**Despliegue de aplicaciones mediante AWS CodeDeploy sobre un grupo de Auto Escalado de Amazon EC2**


1. Establecer la región donde se desplegará la infraestructura:

		$ REGION=<region>

2. Crear un bucket de S3 para el servicio de AWS CloudFormation:

		$ aws s3 mb s3://<bucket-cf> --region

3. Empaquetar la plantilla de AWS CloudFormation del archivo codedeploy.yaml:

		$ aws cloudformation package \
    		--template-file codedeploy.yaml \
    		--output-template-file codedeploy-packaged.yaml \
    		--s3-bucket <bucket-cf> \
    		--region $REGION
	
4. Desplegar la plantilla de AWS CloudFormation empaquetada:

		$ aws cloudformation deploy \
    		--template-file codedeploy-packaged.yaml \
    		--stack-name codedeploy-stack \
    		--capabilities CAPABILITY_IAM \
    		--region $REGION

5. Se obtiene el nombre del bucket donde cargar los paquetes de despliegue de la aplicacion:

		$ BUCKET=$(aws cloudformation describe-stacks \
    		--stack-name codedeploy-stack \
    		--query 'Stacks[0].Outputs[?OutputKey==`Bucket`].OutputValue' \
    		--output text \
    		--region $REGION)
	
6. Se obtiene el nombre de la aplicacion de AWS CodeDeploy:

		$ APP=$(aws cloudformation describe-stacks \
    		--stack-name codedeploy-stack \
    		--query 'Stacks[0].Outputs[?OutputKey==`Aplicacion`].OutputValue' \
    		--output text \
    		--region $REGION)
	
7. Se obtiene el grupo de despliegue (grupo de autoescalado + ALB) de AWS CodeDeploy:

		$ GROUP=$(aws cloudformation describe-stacks \
    		--stack-name codedeploy-stack \
    		--query 'Stacks[0].Outputs[?OutputKey==`GrupoDespliegue`].OutputValue' \
    		--output text \
    		--region $REGION)

8. Se obtiene el nombre DNS del balanceador de carga de aplicacion:

		$ ALB=$(aws cloudformation describe-stacks \
			--stack-name codedeploy-stack \
			--query 'Stacks[0].Outputs[?OutputKey==`ALB`].OutputValue' \
			--output text \
			--region $REGION)
	
9. Comprimir el contenido del directorio app (no el propio directorio app) en un archivo app.zip

		$ cd app
		$ zip -r ../app.zip *
		$ cd ..

10. Para realizar el despliegue de una nueva version de la aplicacion, previamente hay que cargar el paquete de despliegue en el bucket proporcionado:

		$ aws s3 cp app.zip s3://$BUCKET

		$ aws deploy create-deployment \
   			--application-name $APP \
    		--deployment-group-name $GROUP \
			--s3-location bucket=$BUCKET,key=app.zip,bundleType=zip \
			--file-exists-behavior OVERWRITE \
    		--region $REGION