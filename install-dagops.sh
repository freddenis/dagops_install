#!/bin/bash
#
#
export    ZONE="australia-southeast1-b"
export      VM="dagops"
export    TYPE="f1-micro"
export PROJECT="myfirstcontainer-263100"
#
# Create a VM
#
gcloud compute instances delete $VM --zone $ZONE --quiet
gcloud beta compute --project=$PROJECT instances create $VM --zone=$ZONE --machine-type=$TYPE --subnet=default --network-tier=PREMIUM --maintenance-policy=MIGRATE --service-account=658022175146-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --image=centos-7-v20191210 --image-project=centos-cloud --boot-disk-size=10GB --boot-disk-type=pd-standard --boot-disk-device-name=dagops --reservation-affinity=any
#
# Connect and execute the installation script
#
sleep 10                                                                        # Sleep a bit to let the VM to warm up
chmod u+x to_run_on_the_vm.sh
gcloud compute scp to_run_on_the_vm.sh $VM:/tmp/. --zone=$ZONE
# Once we have got clone automatized:
#gcloud beta compute --project $PROJECT ssh --zone $ZONE $VM << END
#/tmp/to_run_on_the_vm.sh
#rm /tmp/to_run_on_the_vm.sh
#END
# In the meantime:
cat << END
        Please run:
        $ gcloud beta compute --project $PROJECT ssh --zone $ZONE $VM
        $ /tmp/to_run_on_the_vm.sh
        $ rm /tmp/to_run_on_the_vm.sh
END
#
# How to connect to the VM
#
cat << END
        You can connect on the VM doing:
        $ gcloud beta compute --project $PROJECT ssh --zone $ZONE $VM
END
