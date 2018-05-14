echo $USER
aws ecr create-repository --repository-name test --region ap-south-1 
docker build -t test .
docker tag test:latest 466749146115.dkr.ecr.ap-south-1.amazonaws.com/test:latest
eval $(aws ecr get-login --region ap-south-1 --no-include-email | sed "s|https://||")
docker push 466749146115.dkr.ecr.ap-south-1.amazonaws.com/test:latest
if [[ $(docker images -q --filter "dangling=true") ]]; then docker rmi -f $(docker images --filter "dangling=true" -q --no-trunc); else echo "No dangling images found"; fi
aws ecr list-images  --region ap-south-1 --repository-name test --query "imageIds[?type(imageTag)!='string'].[imageDigest]" --output text | while read line; do aws ecr batch-delete-image  --region ap-south-1 --repository-name test --image-ids imageDigest=$line; done
