INSTALL=$PWD/install
DUMPS=$1
DBPREFIX=$2
MYSQL_HOST=127.0.0.1
MYSQL_PORT=3306
MYSQL_USER=root
MYSQL_PASS=docker

echo ${INSTALL}/drop_dbs.sql
mysql -u ${MYSQL_USER} -P ${MYSQL_PORT} -h ${MYSQL_HOST} -p${MYSQL_PASS} < ${INSTALL}/drop_dbs.sql
echo ${INSTALL}/create_dbs.sql
mysql -u ${MYSQL_USER} -P ${MYSQL_PORT} -h ${MYSQL_HOST} -p${MYSQL_PASS} < ${INSTALL}/create_dbs.sql
echo ${DUMPS}/${DBPREFIX}tripreports.sql
mysql ${DBPREFIX}tripreports --max_allowed_packet=100M -u ${MYSQL_USER} -P ${MYSQL_PORT} -h ${MYSQL_HOST} -p${MYSQL_PASS} < ${DUMPS}/${DBPREFIX}tripreports.sql
echo ${DUMPS}/${DBPREFIX}trip.sql
mysql ${DBPREFIX}trip -u ${MYSQL_USER} -P ${MYSQL_PORT} -h ${MYSQL_HOST} -p${MYSQL_PASS} < ${DUMPS}/${DBPREFIX}trip.sql
echo ${DUMPS}/${DBPREFIX}newsletter.sql
mysql ${DBPREFIX}newsletter -u ${MYSQL_USER} -P ${MYSQL_PORT} -h ${MYSQL_HOST} -p${MYSQL_PASS} < ${DUMPS}/${DBPREFIX}newsletter.sql
echo ${DUMPS}/${DBPREFIX}ctc.sql
mysql ${DBPREFIX}ctc -u ${MYSQL_USER} -P ${MYSQL_PORT} -h ${MYSQL_HOST} -p${MYSQL_PASS} < ${DUMPS}/${DBPREFIX}ctc.sql
echo ${DUMPS}/${DBPREFIX}joom35.sql
mysql ${DBPREFIX}joom35 -u ${MYSQL_USER} -P ${MYSQL_PORT} -h ${MYSQL_HOST} -p${MYSQL_PASS} < ${DUMPS}/${DBPREFIX}joom35.sql
