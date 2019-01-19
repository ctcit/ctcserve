WD=${PWD}
INSTALL=${PWD}/install
DUMPS=${INSTALL}/clean_dumps
DOCKERDIR=${WD}/docker
WWW=${WD}/www
DB=${WD}/db
DBPREFIX=

mkdir -p ${WWW}
mkdir -p ${WWW}/ctcdocuments
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
git clone -b newServer https://github.com/ctcit/ctcjoomlachanges.git ctcjoomlachanges
cp -r ctcjoomlachanges/* ${WWW}
cp -r ${INSTALL}/configs/joomla.php  ${WWW}/configuration.php

# Set up db subsystem
echo ""
echo "# Setting up DB subsystem"
cd ${WWW}
git clone -b newServer https://github.com/ctcit/ctcdb.git db
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
git clone -b newServer https://github.com/ctcit/newsletter.git newsletter
cp ${INSTALL}/configs/newsletter.php  ${WWW}/newsletter/config.php

 # Set up trip signup subsystem
echo ""
echo "# Setting up Trip-Signup subsystem"
cd ${WD}
git clone -b newServer https://github.com/ctcit/trips.git tripsignup
cd tripsignup
npm install --save-dev @4awpawz/buster
node busterPOSIX.js
cp -r stage ${WWW}/tripsignup

 # Set up mailchimp sync subsystem
echo ""
echo "# Setting up mailchimp sync subsystem"
cd ${WWW}
git clone https://github.com/ctcit/mailchimp.git mailchimp

# Create databases & load sample data
echo ""
echo "# Setting up database"
cd ${WD}
source ${INSTALL}/reload_db.sh ${DUMPS}

echo ""
cd ${WD}
echo "Good to go!"
echo "The server is still running, and is available on http://localhost:80"
echo "phpMyAdmin is available on http://localhost:8080"
echo "Use the following command to stop the servers (must be in the docker/ directory_:"
echo "   docker-compose stop"
echo "... and the following to restart them"
echo "   docker-compose up -d"
