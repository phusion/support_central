# Introduction

![](https://raw.githubusercontent.com/phusion/support_central/master/app/assets/images/logo-black.png)

_Easily manage community and commercial support with Support Central!_

Support Central is an aggregator for various support channels. It displays in a central interface which support tickets need replying on. This allows the Phusion Passenger support team to easily handle both community and commercial support in a central interface.

The following support channels are currently supported:

 * Github issue tracker
 * [Supportbee](https://supportbee.com/)
 * [FrontApp](https://frontapp.com/)
 * RSS feed (or Stack Overflow search query)

## Github issue tracking

Support Central tracks Github issues as follows. For every repository for which the webhook is installed, the following happens:

 * If a new issue is opened by a non-company member, the issue gets the 'SupportCentral' label.
 * If a new issue comment is posted by a non-company member, the issue gets the 'SupportCentral' label.
 * This label is removed if a company member posts a comment in that issue.

Support Central displays all issues with the 'SupportCentral' label.

## Contributing

Please refer to the [contribution guide](CONTRIBUTING.md).

## Installation in production

Please refer to the [general deployment guide](GENERAL_DEPLOYMENT.md).
 
(If you are a Phusion employee, read the [Phusion employee deployment guide](PHUSION_DEPLOYMENT.md).)
