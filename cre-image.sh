#!/bin/bash
#

printf "\n\t\033[1;36m%s\033[m\n\n" "1/4 -- Removing previous image"
gcloud compute images delete dagopsimg --project=myfirstcontainer-263100 --quiet

printf "\n\t\033[1;36m%s\033[m\n\n" "2/4 -- Stopping source VM"
gcloud compute instances stop dagops --zone=australia-southeast1-b

printf "\n\t\033[1;36m%s\033[m\n\n" "3/4 -- Creating image"
gcloud compute images create dagopsimg --project=myfirstcontainer-263100 --source-disk=dagops --source-disk-zone=australia-southeast1-b --storage-location=australia-southeast1

printf "\n\t\033[1;36m%s\033[m\n\n" "4/4 -- Restarting source VM"
gcloud compute instances start dagops --zone=australia-southeast1-b
