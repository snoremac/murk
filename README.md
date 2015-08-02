# CloudSeed

Configuration, parameterization, and environmental partitioning of AWS CloudFormation stacks.

# What it is

CloudSeed is a tool intended to simplify the configuration, management, and partitioning of your AWS CloudFormation environment.  It offers:
- A simple CLI for creating and destroying CloudFormation stacks by name, with some simple rules for locating templates.
- A DSL for specifying the parameter values you wish to supply when creating stacks from templates.
- A mechanism for specifying different 'environments' (e.g. production, dev, qa), and the stacks that should be created within them.

# What it isn't

A DSL for generating CloudFormation templates themselves.  CloudSeed assumes you've already authored your CloudFormation templates by hand, or generated them using another 3rd party tool.

# Requirements

- Ruby 2.2.x
- AWS SDK for Ruby v2
- Configured AWS SDK credentials

# Running the example

    gem install cloudseed
    cd examples

    # Create the stacks in the 'user' environement (named based on the logged in user)
    cloudseed create vpc
    cloudseed create asg

    # Delete the stacks
    cloudseed delete asg
    cloudseed delete vpc

    # Create the stacks in the 'qa' environement
    export CLOUDSEED_ENV=qa
    cloudseed create vpc
    cloudseed create asg

    # Delete the stacks
    cloudseed delete asg
    cloudseed delete vpc
