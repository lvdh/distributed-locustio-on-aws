# HTTP Load Testing on AWS with Locust

Set up a basic, stateless, distributed HTTP load testing platform on AWS, based on [Locust](http://locust.io/):

> _Define user behaviour with Python code, and swarm your system with millions of simultaneous users._

For more information on the format of the [Python code which specifies the load test](eb/locustfile.py), see ["Writing a locustfile"](http://docs.locust.io/en/latest/writing-a-locustfile.html).

## Attribution

This setup is heavily inspired by the AWS DevOps Blog post ["Using Locust on AWS Elastic Beanstalk for Distributed Load Generation and Testing"](https://aws.amazon.com/blogs/devops/using-locust-on-aws-elastic-beanstalk-for-distributed-load-generation-and-testing/) by [Abhishek Singh](https://github.com/abhiksingh), as well as the related GitHub repo [eb-locustio-sample](https://www.github.com/awslabs/eb-locustio-sample).

Essentially, this repo automates the manual setup and deployment procedure of [eb-locustio-sample](https://www.github.com/awslabs/eb-locustio-sample).

## Requirements

What you need on your local machine:

* [Git](https://git-scm.com/) >=2.17.1
* [Python](https://www.python.org/) >=3.7.5
* [Pipenv](https://github.com/pypa/pipenv) >=2018.11.26
* An [AWS Named Profile](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html) with sufficient permissions to deploy [the CloudFormation templates](cfn/templates).

Additional dependencies will be installed in [Python 3 Virtual Environments](https://docs.python.org/3/tutorial/venv.html).

### Notes on Python Dependencies

* `awsebcli` depends on `PyYAML==3.13`, which has a known security vulnerability [CVE-2017-18342](https://nvd.nist.gov/vuln/detail/CVE-2017-18342).
* `locustio` is pinned at `0.13.0` as `pipenv` fails to resolve dependencies for `0.13.[1..5]`.
* `sceptre` has incompatible dependencies with `sceptre` and `locustio`.

## Usage

### Configuration

1. Review and update [cfn/config/config.yaml](cfn/config/config.yaml):

    1. `profile`

        Provide the name of your [AWS CLI Named Profile](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html).

    2. `region`

        Configure your preferred AWS Region to deploy to.

    3. `project_code`

        Custom name/ID for your project. (Lower case, alpha-numeric.)

2. Review and update [cfn/config/locust/cluster.yaml](cfn/config/locust/cluster.yaml):

    1. `InstanceCount`

        Total count of EC2 instances to spin up.

    2. `InstanceType`

        Type of EC2 instances (default `c5.large`) to spin up.

    3. `EC2KeyPair`

        Name of an existing [AWS EC2 SSH Key Pair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html).

### New Cluster

1. Create the load testing infrastructure and deploy a [sample Locust test suite](eb/locustfile.py):

    ```
    make install
    ```

    **Note:** Initializing the environment takes roughly 15 minutes, usually.

2. The Locust web UI opens in your browser automatically once Locust is deployed.

### Deploy New Test Suite

1. Update the sample `host` and HTTP calls ('Locust Tasks') in the [Locustfile](eb/locustfile.py).

    > See ["Writing a locustfile"](http://docs.locust.io/en/latest/writing-a-locustfile.html) for reference.

2. Deploy the updated [Locustfile](eb/locustfile.py):

    ```
    make apply
    ```

3. The Locust web UI opens in your browser automatically once the update is complete.

### Cluster Status

1. View the status of the CloudFormation stacks and the Elastic Beanstalk deployment:

    ```
    make apply
    ```

### Cluster Turndown

1. Destroy all CloudFormation stacks and clean up temporary files:

    ```
    make uninstall
    ```

## Overview of CLI Commands

```bash
$ make
install            Create the Locust environment and deploy a test suite for blazedemo.com
apply              Deploy modifications to the Locust test suite and/or CloudFormation templates
status             Show status of the CloudFormation Stacks and Locust deployment
uninstall          Delete the CloudFormation Stacks and clean up
make -s -C cfn/
install            Create the Locust environment and deploy a test suite for blazedemo.com
apply              Deploy modifications to the Locust test suite and/or CloudFormation templates
status             Show deployment status of the CloudFormation Stack(s)
uninstall          Delete the Locust environment, local dependencies and temporary files
make -s -C eb/
install            Initialize and deploy the Locust test suite
apply              Deploy an updated Locust test suite
status             Show deployment status of the Locust application
uninstall          Clean up virtual environment and temporary files
```

See [`Makefile`](Makefile) for a list of sub-targets called by `install`, `deploy` etc. in case you are developing/troubleshooting this codebase.
