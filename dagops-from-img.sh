#!/bin/bash

export    ZONE="australia-southeast1-b"
export      VM="dagops"
export    TYPE="f1-micro"
export PROJECT="myfirstcontainer-263100"

if [[ -z $1 ]]
then
        export NEWDAGOPS="newdagops"
else
        export NEWDAGOPS=$1
fi

gcloud beta compute --project=$PROJECT instances create $NEWDAGOPS --zone=$ZONE --machine-type=$TYPE --subnet=default --network-tier=PREMIUM --maintenance-policy=MIGRATE --service-account=658022175146-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --image=dagopsimg --image-project=myfirstcontainer-263100 --boot-disk-size=10GB --boot-disk-type=pd-standard --boot-disk-device-name=mydagops --reservation-affinity=any
