# Introduction

![](https://raw.githubusercontent.com/phusion/support_central/master/app/assets/images/logo-black.png)

_Easily manage community and commercial support with Support Central!_

Support Central is an aggregator for various support channels. It displays in a central interface which support tickets need replying on. This allows the Phusion Passenger support team to easily handle both community and commercial support in a central interface.

The following support channels are currently supported:

 * Github issue tracker
 * Supportbee

## Github issue tracking

Support Central tracks Github issues as follows. For every repository for which the webhook is installed, the following happens:

 * If a new issue is opened by a non-Phusion member, the issue gets the 'SupportCentral' label.
 * If a new issue comment is posted by a non-Phusion member, the issue gets the 'SupportCentral label'.
 * This label is removed if a Phusion member posts a comment in that issue.

Support Central displays all issues with the 'SupportCentral' label.

## Contributing

Please refer to the [contribution guide](CONTRIBUTING.md).

## Installation in production

 * If you are a Phusion employee, read the [Phusion employee deployment guide](PHUSION_DEPLOYMENT.md).
 * If you are not a Phusion employee, read the [general deployment guide](GENERAL_DEPLOYMENT.md).
