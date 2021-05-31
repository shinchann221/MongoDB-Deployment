# MongoDB Deployment
 Bash Scripts and YAML files for running Mongodb on k8s GCP

# MongoDB Deployment for Kubernetes on GKE

## 1 How To Run

### 1.1 Prerequisites

```shell
$ gcloud init
$ gcloud components install kubectl
$ gcloud auth application-default login
$ gcloud config set compute/zone asia-south1-a
```
 
**Note:** To specify an alternative zone to deploy to, in the above command, you can first view the list of available zones by running the command: `$ gcloud compute zones list`

### 1.2 Main Deployment Steps 

1. To create a Kubernetes cluster, create the required disk storage (and associated PersistentVolumes), and deploy the MongoDB Service (including the StatefulSet running "mongod" containers), via a command-line terminal/shell (ensure the script files are set to be executable):

    ```shell
    $ cd scripts
    $ ./init.sh
    ```

2. Execute the following script which connects to the first Mongod instance running in a container of the Kubernetes StatefulSet, via the Mongo Shell, to 
(1) initialise the MongoDB Replica Set, and 
(2) create a MongoDB admin user (specify the password you want as the argument to the script, replacing 'abc123').
(3) Create an internal load balancer to and assign a static IP to access outside the cluster.

    ```shell
    $ ./configure_repset_loadbalancer.sh abc123
    ```

You should now have a MongoDB Replica Set initialised, secured and running in a Kubernetes Stateful Set. You can view the list of Pods that contain these MongoDB resources, by running the following:

    $ kubectl get pods

You can also view the the state of the deployed environment via the [Google Cloud Platform Console](https://console.cloud.google.com) (look at both the “Kubernetes Engine” and the “Compute Engine” sections of the Console).

The running replica set members will be accessible to any "app tier" containers, that are running in the same Kubernetes cluster, via the following hostnames and ports (remember to also specify the username and password, when connecting to the database):

    mongo-0.mongodb-service.default.svc.cluster.local:27017
    mongo-1.mongodb-service.default.svc.cluster.local:27017

### 1.3 Undeploying & Cleaning Down the Kubernetes Environment

**Important:** This step is required to ensure you aren't continuously charged by Google Cloud for an environment you no longer need.

Run the following script to undeploy the MongoDB Service & StatefulSet plus related Kubernetes resources, followed by the removal of the GCE disks before finally deleting the GKE Kubernetes cluster.

    $ ./teardown.sh
    
It is also worth checking in the [Google Cloud Platform Console](https://console.cloud.google.com), to ensure all resources have been removed correctly.



