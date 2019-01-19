databases=( ctc joom35 newsletter trip tripreports )
for db in "${databases[@]}"
do
   echo $db
   cp ctcweb9_${db}.sql ${db}.sql
   LC_ALL=C sed -i .bak 's/ctcweb9_//g' ${db}.sql
   LC_ALL=C sed -i .bak 's/utf8/utf8mb4/g' ${db}.sql
   LC_ALL=C sed -i .bak 's/utf8_unicode_ci/utf8mb4_unicode_ci/g' ${db}.sql
   LC_ALL=C sed -i .bak 's/latin1_swedish_ci/utf8mb4_unicode_ci/g' ${db}.sql
   LC_ALL=C sed -i .bak 's/latin1/utf8mb4/g' ${db}.sql
done
