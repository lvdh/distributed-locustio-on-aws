# HTTP Load Testing on AWS with Locust

Set up a basic, stateless, distributed HTTP load testing platform on AWS, based on [Locust](http://locust.io/):

> _Define user behaviour with Python code, and swarm your system with millions of simultaneous users._

For more information on the format of the [Python code which specifies the load test](aws/files/app/locustfile.py), see ["Writing a locustfile"](http://docs.locust.io/en/latest/writing-a-locustfile.html).

## Attribution

This setup is heavily inspired by the AWS DevOps Blog post ["Using Locust on AWS Elastic Beanstalk for Distributed Load Generation and Testing"](https://aws.amazon.com/blogs/devops/using-locust-on-aws-elastic-beanstalk-for-distributed-load-generation-and-testing/) by [Abhishek Singh](https://github.com/abhiksingh), as well as the related GitHub repo [eb-locustio-sample](https://www.github.com/awslabs/eb-locustio-sample).

Essentially, this repo automates the manual setup and deployment procedure of [eb-locustio-sample](https://www.github.com/awslabs/eb-locustio-sample).

## Requirements

What you need on your local machine:

* Git client
* Python >=3.7.5
* [pipenv](https://github.com/pypa/pipenv) >=2018.11.26
* A [Named Profile](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html) for AWS CLI with sufficient permissions to manage AWS resources defined by [the CloudFormation templates](aws/templates).

Where required, additional dependencies will be installed in a Python 3 'virtual environment'.

### Notes on Python Package Incompatibility

* `awsebcli` and `sceptre` have incompatible dependencies
    * For this reason, `awsebcli` is installed in a separate `pipenv` package group.
* `locustio` package versions >=13.1 have dependencies incompatible with `sceptre`
    * For this reason, `locustio` is pinned at version 13.0.

## Usage

### Create a New Load Test Stack

1. Review and update [aws/config/config.yaml](aws/config/config.yaml):

    1. `profile`

        Provide the name of your [AWS CLI Named Profile](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html).

    2. `region`

        Configure your preferred AWS Region to deploy to.

    3. `project_code`

        Custom name/ID for your project. (Lower case, alpha-numeric.)

2. Review and update [aws/config/locust/cluster.yaml](aws/config/locust/cluster.yaml):

    1. `InstanceCount`

        Total count of EC2 instances to spin up.

    2. `InstanceType`

        Type of EC2 instances (default `c5.large`) to spin up.

    3. `EC2KeyPair`

        Name of an existing [AWS EC2 SSH Key Pair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html).

3. Create the load testing infrastructure and deploy a [sample Locust test suite](aws/files/app/locustfile.py):

    ```
    make install
    ```

3. The Locust web UI opens in your browser automatically once Locust is deployed.

### Upload changes to your Load Test Specification

1. Update the sample `host` and HTTP calls ('Locust Tasks') in the [Locustfile](aws/files/app/locustfile.py).

    > See ["Writing a locustfile"](http://docs.locust.io/en/latest/writing-a-locustfile.html) for reference.

2. Deploy the updated [Locustfile](aws/files/app/locustfile.py):

    ```
    make deploy
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
install            Create the Locust environment and deploy a test suite for blazedemo.com
deploy             Deploy modifications to the Locust test suite and/or CloudFormation templates
uninstall          Delete the Locust environment
```

See [`Makefile`](Makefile) for a list of sub-targets called by `install`, `deploy` etc. in case you are developing/troubleshooting this codebase.
