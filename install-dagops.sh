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

printf "\n\t\033[1;36m%s\033[m\n\n" "1/5 -- Deleting the $VM VM"
gcloud compute instances delete $VM --zone $ZONE --quiet

printf "\n\t\033[1;36m%s\033[m\n\n" "2/5 -- Creating the new $VM VM"
gcloud beta compute --project=$PROJECT instances create $VM --zone=$ZONE --machine-type=$TYPE --subnet=default --network-tier=PREMIUM --maintenance-policy=MIGRATE --service-account=658022175146-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --image=centos-7-v20191210 --image-project=centos-cloud --boot-disk-size=10GB --boot-disk-type=pd-standard --boot-disk-device-name=dagops --reservation-affinity=any
#
# Connect and execute the installation script
#
printf "\n\t\033[1;36m%s\033[m\n\n" "3/5 -- Sleeping 10 seconsd to let everything starting. . ."
sleep 10                                                                        # Sleep a bit to let the VM to warm up

printf "\n\t\033[1;36m%s\033[m\n\n" "4/5 -- Copy file to VM"
chmod u+x to_run_on_the_vm.sh
echo gcloud compute scp to_run_on_the_vm.sh $VM:/tmp/. --zone=$ZONE
gcloud compute scp to_run_on_the_vm.sh $VM:/tmp/. --zone=$ZONE

# Once we have got clone automatized:
#gcloud beta compute --project $PROJECT ssh --zone $ZONE $VM << END
#/tmp/to_run_on_the_vm.sh
#rm /tmp/to_run_on_the_vm.sh
#END
# In the meantime:
printf "\n\t\033[1;36m%s\033[m\n\n" "5/5 -- Please execute the below steps to finish the dagops installation"
cat << END
        $ gcloud beta compute --project $PROJECT ssh --zone $ZONE $VM
        $ /tmp/to_run_on_the_vm.sh
        $ rm /tmp/to_run_on_the_vm.sh

END
#
# How to connect to the VM
#
printf "\n\t\033[1;36m%s\033[m\n\n" "INFO -- How to connect to the $VM VM"
cat << END
        You can connect on the VM doing:
        $ gcloud beta compute --project $PROJECT ssh --zone $ZONE $VM

END
