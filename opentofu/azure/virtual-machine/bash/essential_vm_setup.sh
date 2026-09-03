#! /bin/bash

# Purposely put to wait VM & Network to fully startup
#! Else, it will not able to run `apt update` properly
sleep 10s

# Install MySQL, Nginx Server, Tomcat
sudo apt update &>/dev/null && \
sudo apt install -y mysql-server nginx default-jdk &>/dev/null && \
sudo apt install -y tomcat9 tomcat9-admin &>/dev/null

# Change bind-address config to remote enable MySQL server
sudo sed -i -e "s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" "/etc/mysql/mysql.conf.d/mysqld.cnf"

# Restart mysql service
sudo systemctl restart mysql

# Login to MySQL as ROOT and run MySQL query
sudo mysql <<EOF
    CREATE USER 'testUser'@'%' IDENTIFIED BY 'test123';
    GRANT ALL PRIVILEGES ON *.* TO 'testUser'@'%';
    FLUSH PRIVILEGES;
EOF

# Ensure Port 8080 opened for Tomcat Access
sudo ufw allow from any to any port 8080 proto tcp