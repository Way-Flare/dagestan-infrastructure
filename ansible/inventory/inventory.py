#!/user/bin/env python3

import json
import sys
import os

from dotenv import load_dotenv
import yandexcloud
from yandex.cloud.compute.v1 import instance_service_pb2_grpc
from yandex.cloud.compute.v1.instance_service_pb2 import ListInstancesRequest
load_dotenv()

def get_hosts():
    yc_sdk = yandexcloud.SDK(token=os.getenv("YC_TOKEN"))
    instance_service = yc_sdk.client(instance_service_pb2_grpc.InstanceServiceStub)
    folder_id = os.getenv("FOLDER_ID")
    response = instance_service.List(ListInstancesRequest(folder_id=folder_id))

    return response.instances


def main():
    instances = get_hosts()
    inventory = {"_meta": {"hostvars": {}}}

    for instance in instances:
        ip_address = None
        for net_if in instance.network_interfaces:
            if net_if.primary_v4_address is not None:
                ip_address = net_if.primary_v4_address.one_to_one_nat.address
                print(net_if.primary_v4_address)
                hostname = instance.labels.get("hostname", instance.id)
                inventory["_meta"]["hostvars"][hostname] = {
                        "ansible_host": ip_address,
                        "instance_id": instance.id,
                        "name": instance.name,
                        "zone": instance.zone_id
                        }
                group = instance.zone_id
                if group not in inventory:
                    inventory[group] = {'hosts': []}
                inventory[group]['hosts'].append(hostname)

    print(json.dumps(inventory, indent=2))

if __name__ == "__main__":
    main()
    

