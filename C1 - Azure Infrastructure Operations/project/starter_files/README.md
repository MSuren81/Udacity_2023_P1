# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction
For this project, you will write a Packer template and a Terraform template to deploy a customizable, scalable web server in Azure.

### Getting Started
1. Clone this repository

2. Create your infrastructure as code

3. Update this README to reflect how someone would use your code.

### Dependencies
1. Create an [Azure Account](https://portal.azure.com) 
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Instructions
1. Execute the file taggin_policy.sh to create a tagging policy that ensure that all ressources will have a tag. 
2. Create the file packerSecret.json. In this file add the following items: 
```json
{
    "client_id": "XXXXX-XXXXX-XXXXXXXXXXXX",
    "client_secret": "XXXXX-XXXXX-XXXXXXXXXXXX",
    "subscription_id": "XXXXX-XXXXX-XXXXXXXXXXXX",
    "tenant_id": "XXXXX-XXXXX-XXXXXXXXXXXX"
}
```
Add your client_id, client_secret, subscription_id and tenant_id as described above to the file and save the file. 
See picture tagging-policy.png in this repository

### Output
**Your words here**
### Packer Template execution
The packer template defines the Image of the server. 
The file server.json is the blue print for this server and it takes the imput of the packerSecret file. 
You can execute this script while running the run.sh script. 
This will create your Image. 

### TerraformScripts
The file main.tf contains the terraform description of the Infrastructure. 
To configure the basic sets open the variables.tf file and adjust the values for
1. Location
2. Tags
3. Projectname
4. prefix

for running the script please execute
```shell
{
    terraform plan -out=p1_plan
}
```
After that, please run execute the plan with 
```shell
{
    terraform apply p1_plan
}
```
With this command everything will be created, das described. 

