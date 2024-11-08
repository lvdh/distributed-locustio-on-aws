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
* AWS credentials with sufficient permissions to deploy [the CloudFormation templates](cfn/templates)
    1. Recommended: [`aws-vault`](https://github.com/99designs/aws-vault)
    2. Alternatively: [AWS Named Profile](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html)

Additional dependencies will be installed in [Python 3 Virtual Environments](https://docs.python.org/3/tutorial/venv.html).

## Usage

### Configuration

Review and update [config.mk](config.mk):

1. `SCEPTRE_PROJECT_CODE` (required)

    Custom name/ID for your project. (Lower case, alpha-numeric.)

    **Default:** `blazedemo`

2. `SCEPTRE_STACK_NAME` (required)

    The Sceptre Stack Name.

    **Default:** `locust`

    **Note:** The default is determined by [`cfn/config/locust`](cfn/config/locust). See Sceptre's [Cascading Config](https://sceptre.cloudreach.com/2.2.1/docs/stack_group_config.html#cascading-config) documentation for more details.

3. `CLUSTER_INSTANCE_COUNT` (required)

    Total count of EC2 instances to spin up.

    **Default:** `3`

4. `CLUSTER_INSTANCE_TYPES` (required)

    Type of EC2 instances to run Locust on.

    **Default:** `c5.large,c4.large`

    **Note:** Accepts a comma-separated list of 1 (min.) to 10 (max.) instance types. [AWS recommends providing at least two instance types.](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/command-options-general.html#command-options-general-ec2instances)

5. `CLUSTER_EC2_KEY_NAME` (optional)

    Name of an existing [AWS EC2 SSH Key Pair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html).

    **Default:** `<empty>`

6. `AWS_PROFILE` (set only when using AWS profiles directly vs. using `aws-vault`)

    Provide the name of your [AWS CLI Named Profile](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html).

7. `AWS_REGION` (set only when using AWS profiles directly vs. using `aws-vault`)

    Configure your preferred AWS Region to deploy to.

### Deployment

**Note:** Execute the `make` commands without any prefix when not using `aws-vault`:

```bash
make verify
```

**Note:** When using `aws-vault`, `make all` might fail due to the default AWS session duration of 15 minutes. Use the `--assume-role-ttl 1h` to increase the session duration to the [maximum session duration of 1h](https://docs.aws.amazon.com/STS/latest/APIReference/API_GetSessionToken.html).

```bash
aws-vault exec --assume-role-ttl 1h <profile> -- make all
```

#### Verify the Templates and Test Suite

1. Do a quick verification of the CloudFormation Templates and Locust Test Suite code before deploying it to the cluster.

    **Note:** This runs a short Locust load test locally, which targets the Locust `host` (see below).

    ```bash
    aws-vault exec <profile> -- make verify
    ```

#### Install Cluster

1. Create the load testing infrastructure and deploy a [sample Locust test suite](eb/locustfile.py):

    ```bash
    aws-vault exec <profile> -- make install
    ```

    **Note:** Initializing the environment takes roughly 15 minutes, usually.

2. The Locust web UI opens in your browser automatically once Locust is deployed.

#### Deploy Changes

Deploy a new test suite, or changes to CloudFormation templates.

1. Update the sample `host` and HTTP calls ('Locust Tasks') in the [Locustfile](eb/locustfile.py).

    > See ["Writing a locustfile"](http://docs.locust.io/en/latest/writing-a-locustfile.html) for reference.

2. Deploy the updated [Locustfile](eb/locustfile.py):

    ```bash
    aws-vault exec <profile> -- make update
    ```

3. The Locust web UI opens in your browser automatically once the update is complete.

#### View Cluster Status

1. View the status of the CloudFormation stacks and the Elastic Beanstalk deployment:

    ```bash
    aws-vault exec <profile> -- make status
    ```

#### Terminate Cluster

1. Destroy all CloudFormation stacks and clean up temporary files:

    ```bash
    aws-vault exec <profile> -- make uninstall
    ```

#### Run Integration Test

1. Run a full cycle: test, install, deploy, status, uninstall:

    ```bash
    aws-vault exec <profile> -- make all
    ```

## Overview of CLI Commands

```bash
$ make
all                Deploy and destroy (integration test)
verify             Verify the CloudFormation templates and Locust test suite
install            Deploy/update the CloudFormation templates and Locust test suite
uninstall          Delete the CloudFormation Stacks and clean up
status             Show status of the CloudFormation Stacks and Locust deployment
clean              Delete virtual environments and temporary files
```

### Sub Makefiles

See Makefiles below for a list of sub-targets which may be useful during development and troubleshooting.

#### CloudFormation

[`cfn/Makefile`](cfn/Makefile)

```bash
$ make -s -C cfn/
all                Integration test
verify             Validate CloudFormation Template(s)
install            Deploy CloudFormation Stack(s)
uninstall          Terminate CloudFormation Stack(s) and clean up local files
status             Show deployment status of the CloudFormation Stack(s)
```

#### Elastic Beanstalk

[`eb/Makefile`](eb/Makefile)

```bash
$ make -C eb/
all                Integration test
verify             Run a smoke test on the local Locust test suite
install            (Re)deploy the Locust test suite to Elastic Beanstalk
uninstall          Delete the local virtual environment and temporary files
status             Show deployment status of the Locust application
```

## Notes

### Python Package Dependencies

* `awsebcli` depends on `PyYAML==3.13`, which has a known security vulnerability [CVE-2017-18342](https://nvd.nist.gov/vuln/detail/CVE-2017-18342).
* `locustio` is pinned at `0.13.0`
  * `pipenv` fails to resolve dependencies for `0.13.[1..5]`.
  * Additionally, the EB Solution Stack provides Python <3.6.
* `sceptre` has incompatible dependencies with `sceptre` and `locustio`.
