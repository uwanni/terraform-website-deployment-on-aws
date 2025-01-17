---How to run---

1. Open a terminal and configure aws cli by running the following command
    aws configure
    
    provide the required credentials (aws access key, secret access key, region, and defualt output format: json).

2. Open the terraform project folder in the text editor (vs code) and open the terraform.tfvars file.
    Replace the values for the variables (marked with the comments) with the actual values. 

3. Save the changes.

4. Navigate to the terraform project folder from the terminal and run the following commands to run the terraform script.
    terraform init
    terraform plan
    terraform apply / terraform apply --auro-approve

    This will take some time to complete. 

5. Open the url (servername you provided in the terraform.tfvars file) from the browser. 



----If the site is not working as expected with the following errors, log into the created instance using the aws console and
run the following commands-----

1. php welcome page - 
    sudo systemctl stop apache2.service 
    sudo systemctl disable apache2.service


2. 500 internal server error
    cd /var/www/<projectfolder>
    composer install
    sudo systemctl restart nginx.service
    sudo systemctl restart php8.1-fpm


3. category pages 500 
    install mongodb