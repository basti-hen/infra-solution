# ThoughtWorks infra-solution

This is the README.md for the project infra-solution. The goal is to solve the infrastructure problem [infra-problem](https://github.com/ThoughtWorksInc/infra-problem) given by ThoughtWorks.

### Description
It consists of the following components:
| Component | Purpose |
| ------ | ------ |
| Terraform Config File | Used to provision a VM in Microsoft Azure and copy a script that configures the machine. |
| Configuration Script (Shell) | Used to compile the application, install Docker and Docker Compose and build the containers. |
| docker-compose.yml | Contains configuration information for deployment of the containers. |
| Dockerfiles | Contain the construction plans for the individual containers. |

First, the Terraform Deployment must be executed because it provides the required IaaS components (the VM and required resources). Terraform then automatically copies a script to configure the machine to the VM and executes it. This script first builds the JAR files, then packs them into three containers, builds an additional container for the static contents and then starts them using docker-compose. After that, the contents are accessible via the public IP address of the VM. The VM can be destroyed at any time with a destroy command.

### Usage
1) Install the [Azure CLI](https://docs.microsoft.com/de-de/cli/azure/install-azure-cli) on your local device
2) Install [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) on your local device
3) Open the Terminal, run the following command and enter your Azure account credentials:
```sh
$ az login
```
3) If not done yet, unzip the archive, open the Terminal and navigate to the location where the Terraform files are located:
```sh
$ unzip files.zip
$ cd files
```
4) Copy your Private Key File (Name: id_rsa) to the folder
4) Run the following commands to execute the Terraform deployment:
```sh
$ terraform init
$ terraform plan
$ terraform apply
```

Note: If a Service Principal is available, the Terraform Configuration File can be adapted very quickly to use this form of authentication.

### View Results
It takes about nine minutes until the Terraform script is ready. During this time eight resources are created in Microsoft Azure, the automation script is executed and the containers are started via docker-compose. Since port 80 has been configured as the inbound port, the page can be accessed with the browser on the host system.

As a small help for the user, Terraform provides the IP address of the VM after successful deployment, which only needs to be entered into your favourite browser:

```sh
Apply complete! Resources: 8 added, 0 changed, 0 destroyed.

Outputs:

thoughtworks-pip = 51.124.27.47
```

### Conclusion
1) It is not far to a pipeline: The Build Tasks are already defined. However, you would not run a build process on an IaaS resource in Microsoft Azure, but (in a container) in a pipeline. 
2) One goal was to create a portable application environment. By building Docker Containers and using Docker Compose, this goal can be achieved. 

### Future Ideas
1) Use PaaS services: Azure Container Instances or AWS ECS are ideal for running containers in a managed environment. This leads to more scalability. In addition, services should generally work excellently with CI/CD pipelines (e.g. Azure DevOps).
2) Use a pipeline to build the JAR files: Such a pipeline only allocates resources if a build process really takes place. Also, the JAR files can be passed on more easily.

The basic procedure for building a CI/CD pipeline would be as follows:
1) Definition of a repository as starting point
2) Definition of a pipeline trigger (e.g. a new commit)
3) Definition of jobs and tasks to build the application
4) Deployment in an environment