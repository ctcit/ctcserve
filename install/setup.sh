WD=${PWD}
INSTALL=${PWD}/install
DOCKERDIR=${WD}/docker
WWW=${WD}/www
DB=${WD}/db

mkdir -p ${WWW}
mkdir -p ${DB}

# Build the docker images
echo ""
echo "# Building docker images"
echo "This may take a while the first time.... go and make a cup of coffee or grab a beer"
cd ${DOCKERDIR}
docker-compose build

echo ""
echo "# Attemping to start the server..."
docker-compose up -d

# Install Joomla
echo ""
echo "# Downloading and installing Joomla"
JOOMLA_INSTALL_URL=https://downloads.joomla.org/cms/joomla3/3-8-7/
JOOMLA_INSTALL_ZIP=Joomla_3.8.7-Stable-Full_Package.zip
cd ${WWW}
wget ${JOOMLA_INSTALL_URL}${JOOMLA_INSTALL_ZIP}
unzip ${JOOMLA_INSTALL_ZIP}
rm -rf ${JOOMLA_INSTALL_ZIP}

echo ""
echo "# Applying CTC Joomla changes"
cd ${WD}
git clone https://github.com/ctcit/ctcjoomlachanges.git ctcjoomlachanges
cp -r ctcjoomlachanges/* ${WWW}
cp -r ${INSTALL}/configs/joomla.php  ${WWW}/configuration.php
rm -rf ctcjoomlachanges
mkdir -p ${WWW}/ctcdocuments
mkdir -p ${WWW}/newsletters

# Set up db subsystem
echo ""
echo "# Setting up DB subsystem"
cd ${WWW}
git clone https://github.com/ctcit/ctcdb.git db
cp ${INSTALL}/configs/database/database.php  ${WWW}/db/application/config/
cp ${INSTALL}/configs/database/config.php  ${WWW}/db/application/config/

# Set up trip reports subsystem
echo ""
echo "# Setting up Trip-Reports subsystem"
cd ${WWW}
git clone https://github.com/ctcit/tripreports.git tripreports
cp ${INSTALL}/configs/tripreport.site.js  ${WWW}/tripreports/app/config/site.js

# Set up newsletter subsystem
echo ""
echo "# Setting up Newsletter subsystem"
cd ${WWW}
git clone https://github.com/ctcit/newsletter.git newsletter
cp ${INSTALL}/configs/newsletter.php  ${WWW}/newsletter/config.php

 # Set up trip signup subsystem
echo ""
echo "# Setting up Trip-Signup subsystem"
cd ${WWW}
git clone https://github.com/ctcit/trips.git tripsignup

# Create databases & load sample data
echo ""
echo "# Setting up database"
MYSQL_HOST=127.0.0.1
MYSQL_PORT=3306
MYSQL_USER=root
MYSQL_PASS=docker
mysql -u ${MYSQL_USER} -P ${MYSQL_PORT} -h ${MYSQL_HOST} -p${MYSQL_PASS} < ${INSTALL}/clean_dumps/create_dbs.sql
mysql ctcweb9_tripreports --max_allowed_packet=100M -u ${MYSQL_USER} -P ${MYSQL_PORT} -h ${MYSQL_HOST} -p${MYSQL_PASS} < ${INSTALL}/clean_dumps/ctcweb9_tripreports.sql
mysql ctcweb9_trip -u ${MYSQL_USER} -P ${MYSQL_PORT} -h ${MYSQL_HOST} -p${MYSQL_PASS} < ${INSTALL}/clean_dumps/ctcweb9_trip.sql
mysql ctcweb9_newsletter -u ${MYSQL_USER} -P ${MYSQL_PORT} -h ${MYSQL_HOST} -p${MYSQL_PASS} < ${INSTALL}/clean_dumps/ctcweb9_newsletter.sql
mysql ctcweb9_ctc -u ${MYSQL_USER} -P ${MYSQL_PORT} -h ${MYSQL_HOST} -p${MYSQL_PASS} < ${INSTALL}/clean_dumps/ctcweb9_ctc.sql
mysql ctcweb9_joom35 -u ${MYSQL_USER} -P ${MYSQL_PORT} -h ${MYSQL_HOST} -p${MYSQL_PASS} < ${INSTALL}/clean_dumps/ctcweb9_joom35.sql

echo ""
cd ${WD}
echo "Good to go!"
echo "The server is still running, and is available on http://localhost:80"
echo "phpMyAdmin is available on http://localhost:8080"
echo "Use the following command to stop the servers (must be in the docker/ directory_:"
echo "   docker-compose stop"
echo "... and the following to restart them"
echo "   docker-compose up -d"
