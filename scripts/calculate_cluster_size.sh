#!/bin/bash
# reference: https://github.com/awslabs/amazon-eks-ami/blob/master/files/eni-max-pods.txt
# Input: Total number of pods, Max pods per instance, vCPUs per instance, Memory per instance (in GiB)
read -p "Enter total number of pods: " total_pods
read -p "Enter max pods per instance (e.g., 4 for t3.micro): " max_pods_per_instance
read -p "Enter vCPUs per instance (e.g., 2 for t3.micro): " vcpus_per_instance
read -p "Enter memory per instance in GiB (e.g., 1 for t3.micro): " memory_per_instance

# Calculating the number of instances needed
num_instances=$(( (total_pods + max_pods_per_instance - 1) / max_pods_per_instance ))

# Calculating the total vCPUs and Memory needed
total_vcpus=$(( num_instances * vcpus_per_instance ))
total_memory=$(( num_instances * memory_per_instance ))

echo "Number of instances needed: $num_instances"
echo "Total vCPUs needed: $total_vcpus"
echo "Total memory needed in GiB: $total_memory"
