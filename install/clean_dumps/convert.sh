databases=( ctc joom35 newsletter trip tripreports )
for db in "${databases[@]}"
do
   echo $db
   cp ctcweb9_${db}.sql ${db}.sql
   LC_ALL=C sed -i .bak 's/ctcweb9_//g' ${db}.sql
done
