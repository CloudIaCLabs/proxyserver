
Build yourown VPC with pulic and private networks and proxyserver in AWS Cloud using terraform by Cloud IaC Labs <br/>


Install aws cli & setup your Secure shell auth <br/>
Install terraform [terraform --version] <br/>


make sure to update "variables.tf" with your account specific parameters, as well as validate default values  <br/>
Don't forget to un-comment sections where you updated <br/>


Comment and/or un-comment main.tf section depending on your registered domain status/Domain registar <br/>
you may need to do manual DNS configuation if  you are hosting your DNS elsewhere <br/>


#Terraform IaC Example for creating Proxy Server aws cloud on demand <br/>
#Destroy when done, or keep running | repeat process ad-hoc as needed <br/>



# Setup terraform
terraform init
terraform fmt
terraform validate


#Create your Infrastructure
terraform plan -out main.tfplan
terraform apply main.tfplan


# Test/Validate/Run as you choose
# ssh -i <Key> ec2-user@IPAddress #


#Cleanup your Infrastructure
terraform plan -destroy -out main.destroy.tfplan
terraform apply main.destroy.tfplan


terraform destroy -auto-approve
