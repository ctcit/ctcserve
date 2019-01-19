DUMPDIR=$1
databases=( ctc joom35 newsletter trip tripreports )
for db in "${databases[@]}"
do
   echo $DUMPDIR/$db
   cp $DUMPDIR/ctcweb9_${db}.sql $DUMPDIR/${db}.sql
   LC_ALL=C sed -i 's/ctcweb9_//g; s/`ctcweb9`@/`ctcview`@/g; s/CHARSET=[[:alnum:]_]\{1,\}/CHARSET=utf8mb4/; s/COLLATE=[[:alnum:]_]\{1,\}/COLLATE=utf8mb4_general_ci/; s/CHARACTER SET [[:alnum:]_]\{1,\}/CHARACTER SET utf8mb4/; s/COLLATE [[:alnum:]_]\{1,\}/COLLATE utf8mb4_general_ci/; s/utf8mb4_unicode_ci/utf8mb4_general_ci/' $DUMPDIR/${db}.sql
done
