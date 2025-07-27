#!/bin/bash
<< task
Deploy a Django app and handle errors gracefully
task

codeclone() {
    echo "Cloning the Django app...."
    if [ -d "django-notes-app" ]; then
        echo "Directory already exists. Skipping clone."
    else
        git clone https://github.com/LondheShubham153/django-notes-app.git
    fi
}

install_requirements() {
    echo "Installing dependencies...."
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg lsb-release

    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
        sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
      https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose nginx
}

required_restarts() {
    echo "Restarting and enabling services..."
    sudo chown "$USER" /var/run/docker.sock
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo systemctl start nginx
    sudo systemctl enable nginx

     sudo systemctl restart docker
}

deploy() {
    cd django-notes-app || exit
    docker build -t notes-app .
    
    if ! docker-compose down -v; then
        echo "Failed to stop existing containers"
        return 1
    fi

    if ! docker-compose up --build -d; then
        echo "Docker Compose failed"
        return 1
    fi
docker build -t notes-app .
    docker-compose down -v
    docker-compose up --build -d
    sudo chmod -R o+rX .
}



# Main flow
echo "Deployment Started..........."

codeclone

if ! install_requirements; then
    echo "Installation failed"
    exit 1
fi

if ! required_restarts; then
    echo "System fault identified"
    exit 1
fi

if ! deploy; then
    echo "Deployment Failed..Mailing the admin"
    # TODO: send mail alert here
    exit 1
fi

echo "Deployment Completed Successfully ✅"

