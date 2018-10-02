#!bin/bash

echo "Resource deletion script is being executed !"
DIR=$2
echo $DIR

testplan_props=${DIR}/testplan-props.properties
infra_props=${DIR}/infrastructure.properties

#delete database
db_identifier=`cat ${infra_props} | grep -w DatabaseName ${infra_props} | cut -d'=' -f2`
aws rds delete-db-instance --db-instance-identifier "$db_identifier" --skip-final-snapshot
echo "rds deletion triggered"

delete_cluster=`cat ${testplan_props} | grep -w DeleteCluster ${testplan_props} | cut -d'=' -f2`
if [ "$delete_cluster" == "TRUE" ];then
	#delete cluster resources
	cluster_name=`cat ${infra_props} | grep -w ClusterName ${infra_props} | cut -d'=' -f2`
	aws cloudformation delete-stack --stack-name=EKS-$cluster_name-DefaultNodeGroup
	aws cloudformation delete-stack --stack-name=EKS-$cluster_name-ControlPlane
	aws cloudformation delete-stack --stack-name=EKS-$cluster_name-VPC
	aws cloudformation delete-stack --stack-name=EKS-$cluster_name-ServiceRole
	echo " cluster resources deletion triggered"
fi

