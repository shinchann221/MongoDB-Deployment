gcloud container clusters create "mongodb-cluster" --machine-type=e2-medium --num-nodes=2

# Configure host VM using daemonset to disable hugepages
kubectl apply -f ../yaml/daemonset-configurer.yaml

# Define storage class for dynamically generated persistent volumes
kubectl apply -f ../yaml/mongo_storageclass_ssd.yaml

# Manually created Persistent Disks
# Register GCE Fast SSD persistent disks and then create the persistent disks 
echo "Creating GCE disks"
for i in 1 2
do
    gcloud compute disks create --size 10GB --type pd-ssd pd-ssd-disk-$i
done
sleep 3
gloud compute disks list
sleep 3

# Create persistent volumes using disks created above
echo "Creating GKE Persistent Volumes"
for i in 1 2
do
    # this command changes "INST" in the file to the number and create persistent disks
    sed -e "s/INST/${i}/g" ../resources/xfs-gce-ssd-persistentvolume.yaml > /tmp/xfs-gce-ssd-persistentvolume.yaml
    kubectl apply -f /tmp/xfs-gce-ssd-persistentvolume.yaml
done
rm /tmp/xfs-gce-ssd-persistentvolume.yaml
sleep 3

kubectl get persistentvolumes
sleep 3

# Create keyfile for the MongoD cluster as a Kubernetes shared secret
TMPFILE=$(mktemp)
/usr/bin/openssl rand -base64 741 > $TMPFILE
kubectl create secret generic shared-bootstrap-data --from-file=internal-auth-mongodb-keyfile=$TMPFILE
rm $TMPFILE

# Create mongodb service with mongod stateful-set
kubectl apply -f ../yaml/mongo_service.yaml
echo
sleep 5
kubectl apply -f ../yaml/mongo_statefulset.yaml


# Wait until the final (3rd) mongod has started properly
echo "Waiting for the 2 containers to come up (`date`)..."
echo " (IGNORE any reported not found & connection errors)"
sleep 30
echo -n "  "
until kubectl --v=0 exec mongod-2 -c mongod-container -- mongo --quiet --eval 'db.getMongo()'; do
    sleep 5
    echo -n "  "
done
echo "...mongod containers are now running (`date`)"
echo

# Print current deployment state
kubectl get persistentvolumes
echo
kubectl get statefulset
echo
kubectl get all

