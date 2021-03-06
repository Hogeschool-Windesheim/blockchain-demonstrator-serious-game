[![.github/workflows/Build & Test project.yml](https://github.com/Hogeschool-Windesheim/Beer-Game/actions/workflows/Build%20&%20Test%20project.yml/badge.svg)](https://github.com/Hogeschool-Windesheim/Beer-Game/actions/workflows/Build%20&%20Test%20project.yml)
[![Continuous Integration and Deployment](https://github.com/Hogeschool-Windesheim/Beer-Game/actions/workflows/Continuous%20Integration%20and%20Deployment.yml/badge.svg)](https://github.com/Hogeschool-Windesheim/Beer-Game/actions/workflows/Continuous%20Integration%20and%20Deployment.yml)
# Beer-Game
Code for the Blockchain Demonstrator Lab

# Installation guide
There are two methods of installation. The first method uses an installation script which has to be 
manually executed. The second method uses GitHub actions, this method also has the benefit of enabling CI/CD 
on your server. 
## Installation script
The steps below will take you through the installation process using an installation script.
### Prerequisite 
You have downloaded the installation script from the GitHub repository. Don't mind the Build & Test project.yml & Continious Intergration and Deployment failing as that does not matter for this installation process.
<br>
<br>
### <b> THE SCRIP WILL OUTPUT A "Segmentation fault" Ignore this. It's irrelivant </b>
### Step 1
After the virtual machine has been set up, you should first make sure the following ports are open: 80 and 8080. Because 
these are needed for the web application to work

### Step 2

The second step is to get the project code on the new virtual machine. 
To download the project code on the virtual machine, use the following command.

`git clone https://github.com/Hogeschool-Windesheim/blockchain-demonstrator-serious-game.git`

### Step 3

After the project code is on the virtual machine, it next to needs to be installed. 
In order to install the project code, the installation script requires permission to be able to be run
This can be given with the following command.

`chmod a+x install.sh`

### Step 4

Finally, to install the project code, use the following command.

`sudo ./install.sh`

It is important to both use sudo and the ./ otherwise the script will not work.
Step 3 and 4 can also be performed on the start and exit script.

## Github actions
The steps below will take you through the installation process using GitHub actions. <ins>The GitHub actions process has not been fully finished</ins>, for that reason we recommend you to use the installation script instead which can be found above. The steps below are to help you get started with Github actions. 
### Step 1:
Setup GitHub actions runner on your server. Go to settings > actions > runners and click add runner. 
Follow the steps provided by Github

Adding a runner to your server will also enable the CI/CD functionality of the workflow.

### Step 2: 
Go to the Actions tab in our repository. Then select the Continuous Integration and Deployment workflow. 
Then click on Run workflow located at the right side of your screen. Then just click the green ***Run workflow*** 
button. Then the workflow should start running on your server.

### Step 3:
Since the last step created two new images on your server webapp:latest and api:latest.
Create a docker container for each project.\
This can be done by running these commands: 
`sudo docker run --name api -d -p 0.0.0.0:5002:80 api:latest` and 
`sudo docker run --name webapp -d -p 0.0.0.0:5000:80 webapp:latest`

### Step 4:
With the containers running in their own environment, we just need to set up a proxy pass. 
We coupled our server port 80 to 0.0.0.0:5000. When the proxy is set up this will redirect all http traffic
to the docker container containing the web application. For the REST API we couple port 8080 to 0.0.0.0:5002. 
This will redirect all traffic towards the server using port 8080 to the REST API.

We used Nginx to handle the redirections. Our /etc/nginx/sites-available/default file looks like this.

    server {
    listen 80 default_server;
    listen [::]:80 default_server;

        root /home/BlockchainDemonstrator/Webapp;

        index index.html index.htm index.nginx-debian.html;

        server_name _;

        location / {

                proxy_pass         http://0.0.0.0:5000/;
                proxy_http_version 1.1;
                proxy_set_header   Upgrade $http_upgrade;
                proxy_set_header   Connection keep-alive;
                proxy_set_header   Host $host;
                proxy_cache_bypass $http_upgrade;
                proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header   X-Forwarded-Proto $scheme;
        }
    }

    server {
    listen 8080;
    listen [::]:8080;

        server_name _;

        root /home/BlockchainDemonstrator/Api;

        location / {
        proxy_pass         http://0.0.0.0:5002/;
        proxy_http_version 1.1;
        proxy_set_header   Upgrade $http_upgrade;
        proxy_set_header   Connection keep-alive;
        proxy_set_header   Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto $scheme;
        }
    }
