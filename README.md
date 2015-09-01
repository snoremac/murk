# Murk

Configuration, parameterization, and environmental partitioning of AWS CloudFormation stacks.

# What it is

Murk is a tool intended to simplify the configuration, management, and partitioning of your AWS CloudFormation environment.  It offers:
- A simple CLI for creating and destroying CloudFormation stacks by name, with some simple rules for locating templates.
- A DSL for specifying the parameter values you wish to supply when creating stacks from templates.
- A mechanism for specifying different 'environments' (e.g. production, dev, qa), and the stacks that should be created within them.

# What it isn't

A DSL for generating CloudFormation templates themselves.  Murk assumes you've already authored your CloudFormation templates by hand, or generated them using another 3rd party tool.

# Requirements

- Ruby 2.2.x
- AWS SDK for Ruby v2
- Configured AWS SDK credentials

# Running the example

    gem install murk
    cd examples

    # Create a VPC stack in the 'qa' environement named 'myqa'
    murk create --stack vpc --env qa myqa

    # Create the webapp-network stack in the 'qa' environement named 'myqa'
    murk create --stack webapp-network --env qa myqa

    # Create the webapp-compute stack in the 'qa' environement named 'myqa'
    murk create --stack webapp-compute --env qa myqa

    # Delete the 'qa' webapp-compute stack
    murk delete --stack webapp-compute --env qa myqa

