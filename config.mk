# Naming
export SCEPTRE_PROJECT_CODE=blazedemo
export SCEPTRE_STACK_NAME=locust

# Cluster Size, recommendation for demo/test plan development
export CLUSTER_INSTANCE_COUNT=1
export CLUSTER_INSTANCE_TYPES=t3a.large

# Cluster Size, minimal recommendation for load testing
# export CLUSTER_INSTANCE_COUNT=3
# export CLUSTER_INSTANCE_TYPES=c5.large,c4.large

# SSH Access, leave blank to disable key-based SSH access
export CLUSTER_EC2_KEY_NAME=

# AWS Configuration, for use with AWS Named Profiles
# export AWS_REGION=eu-west-1
# export AWS_PROFILE=default
