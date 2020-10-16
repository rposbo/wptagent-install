#!/bin/bash

# Prompt for the configuration options
echo "WebPageTest instance template creator."

if [ "$DEVSHELL_PROJECT_ID" == "" ]; then
    echo "This script is meant to be run from within a Google Cloud Shell"
    exit
fi
read -e -p "Instance template name: " -i "wpt-agent" TEMPLATE_NAME
while [[ "$INSTANCE_METADATA" == "" ]]
do
    read -p "Instance Metadata String (wpt_server=...): " INSTANCE_METADATA
done

if [[ "$MACHINE_TYPE" == "" ]]
then
    DEFAULT_MACHINE_TYPE=n1-standard-2
    read -p "Machine type (see https://cloud.google.com/compute/docs/machine-types) [${DEFAULT_MACHINE_TYPE}]: " MACHINE_TYPE
    if [[ "$MACHINE_TYPE" == "" ]]
    then
        MACHINE_TYPE="${DEFAULT_MACHINE_TYPE}"
    fi
fi

ESCAPED_METADATA=$(printf %q "$INSTANCE_METADATA")

COMMAND="gcloud compute --project=${DEVSHELL_PROJECT_ID} instance-templates create ${TEMPLATE_NAME} --machine-type=${MACHINE_TYPE} --network=projects/${DEVSHELL_PROJECT_ID}/global/networks/default --metadata=wpt_data=${ESCAPED_METADATA} --no-restart-on-failure --maintenance-policy=TERMINATE --preemptible --min-cpu-platform=Automatic --image=wpt-linux-20200127 --image-project=webpagetest-official --boot-disk-size=10GB --boot-disk-type=pd-standard --boot-disk-device-name=${TEMPLATE_NAME}"
echo $COMMAND
eval $COMMAND

echo "Created the $TEMPLATE_NAME template in the $DEVSHELL_PROJECT_ID project."
