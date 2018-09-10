#!bin/bash

kube_master=`echo $1 | awk -F= '{print $2}'`
output_dir=`echo $2 | awk -F= '{print $2}'`

infra_properties=$output_dir/infrastructure.properties
NEW_UUID=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)

#database-name
database_name=wso2sp-kubernetes-"$NEW_UUID"

echo $kube_master
echo $output_dir

echo "KUBERNETES_MASTER=$kube_master" > $output_dir/k8s.properties

##create the database
echo $output_dir
aws rds create-db-instance --db-instance-identifier "$database_name" \
    --db-instance-class db.t2.medium \
    --engine MySQL \
    --allocated-storage 10 \
    --master-username masterawsuser \
    --master-user-password masteruserpassword \
    --backup-retention-period 0

db_port=3306

#Wait for the database to become available
aws rds wait     db-instance-available     --db-instance-identifier "$database_name"
#retrieve the database hostname
echo "DatabasePort=$db_port" >> $output_dir/infrastructure.properties
echo "DatabaseName=$database_name" >> $output_dir/infrastructure.properties
echo "DatabaseHost="$(aws rds describe-db-instances --db-instance-identifier="$database_name" --query="[DBInstances][][Endpoint][].{Address:Address}" --output=text) >> $output_dir/infrastructure.properties
echo "DBUsername=masterawsuser" >> $output_dir/infrastructure.properties
echo "DBPassword=masteruserpassword" >> $output_dir/infrastructure.properties



