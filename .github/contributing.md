# Contributing

Please first discuss the changes you would like to make to this repository by first opening an issue.

## Documentation

All CI tests on pull requests must be passing before being merged.
Documentation is auto-generated via [terraform-docs](https://terraform-docs.io/).
A github action will check that all README files are up to date via a [pre-commit](https://pre-commit.com/) hook in our [.pre-commit-config.yaml](../pre-commit-config.yaml).
You will want to run this locally in order to get our CI test to pass.
Be sure that you have both [pre-commit](https://pre-commit.com/#installation) and [terraform-docs](https://terraform-docs.io/user-guide/installation/) installed.
Then before commiting changes to your branch run `pre-commit run -a` to update documentation.
