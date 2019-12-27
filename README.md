# HTTP Load Testing on AWS with Locust

Set up a basic, stateless, distributed HTTP load testing platform on AWS, based on [Locust](http://locust.io/):

> _Define user behaviour with Python code, and swarm your system with millions of simultaneous users._

For more information on the format of the [Python code which specifies the load test](aws/app/locustfile.py), see ["Writing a locustfile"](http://docs.locust.io/en/latest/writing-a-locustfile.html).

## Attribution

This setup is heavily inspired by the AWS DevOps Blog post ["Using Locust on AWS Elastic Beanstalk for Distributed Load Generation and Testing"](https://aws.amazon.com/blogs/devops/using-locust-on-aws-elastic-beanstalk-for-distributed-load-generation-and-testing/) by [Abhishek Singh](https://github.com/abhiksingh), as well as the related GitHub repo [eb-locustio-sample](https://www.github.com/awslabs/eb-locustio-sample).

Essentially, this repo automates the manual setup and deployment procedure of [eb-locustio-sample](https://www.github.com/awslabs/eb-locustio-sample).

## Requirements

What you need on your local machine.

* Python >=3.7.5
* an [AWS CLI Named Profile](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html) with sufficient permissions to spin up [a VPC, Elastic Beanstalk stack, ...](aws/templates/locust/stack.yaml)

Additional dependencies will be installed in a virtual Python environment.

### Notes

Issues might arise when running certain packages/versions in the same virtual environment:

* `awsebcli` and `sceptre` have incompatible dependencies
* `locustio` versions >13.0 have incompatible dependencies

For this reason, `awsebcli` is installed in a separate `pipenv` package group.

## Usage

### Create a New Load Test Stack

1. Review [aws/config/config.yaml](aws/config/config.yaml):

    1. `profile`

        Provide the name of your [AWS CLI Named Profile](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html).

    2. `region`

        Configure your preferred AWS Region to deploy to.

1. Review [aws/config/locust/stack.yaml](aws/config/locust/stack.yaml) and update it to match your preferences.

    1. `InstanceCount`

        Configure the amount of EC2 instances (`c5.large`) to spin up.

    2. `EC2KeyPair`

        Provide an existing [AWS EC2 SSH Key Pair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html) name.

2. Create the load testing infrastructure and deploy a [sample Locust configuration](aws/app/locustfile.py):

    ```
    make install
    ```

3. The Locust web UI opens in your browser automatically once Locust is deployed on AWS.

### Upload changes to your Load Test Specification

1. Update the sample `host` and tasks (HTTP calls) in the [Locustfile](aws/app/locustfile.py).

    > See ["Writing a locustfile"](http://docs.locust.io/en/latest/writing-a-locustfile.html) for reference.

2. Deploy the updated [Locustfile](aws/app/locustfile.py):

    ```
    make update
    ```

3. The Locust web UI opens in your browser automatically once the update is complete.

### Shut Down the Stack

1. Destroy the entire load testing stack:

    ```
    make uninstall
    ```

## Overview of CLI Commands

```bash
$ make
install              Deploy Locust on AWS
uninstall            Terminate all AWS resources related to this stack
update               Deploy local changes (ie. load test suite and/or AWS resources)
reinstall            Redeploy all Locust AWS resources
dependencies         Install or upgrade local dependencies
aws-init             Deploy AWS resources for Locust
aws-update           Update AWS resources for Locust
aws-terminate        Terminate all AWS resources related to this stack
locust-smoketest     Run a short load test to validate the local load test suite
locust-deploy        (Re)deploy the Locust application
locust-open          Open the Locust web UI
```
