# Scooter

#### Table of Contents

1. [Overview](#overview)
2. [Usage](#usage)
3. [Versioning](#versioning)
4. [Rdocs](#rdocs)
5. [Contributing](#contributing)

## Overview

Scooter is a ruby gem developed by Puppet to facilitate http traffic between the
test runner and a Puppet Enterprise Installation. This includes the classifier, rbac,
activity service, code manager, orchestrator, and puppetdb.

## Usage

To install Scooter, simply use the gem command:

```
$ gem install scooter
```

Scooter is currently divvied into the following sections:

 - [HttpDispatchers](docs/http_dispatchers.md) – These are modules that can be mixed into classes that represent real users: whitelisted certificate users, local console users, or users connected through an LDAP directory. Check out [HttpDispatchers](lib/scooter/httpdispatchers) for a list of the modules currently supported.

 - LDAPdispatcher – This class extends the Net::LDAP library, which is a requirement to for RBAC testing with LDAP fixtures.
 - Utilities – Currently, this houses random string generators and convenience methods to use beaker to acquire certificates to impersonate whitelisted certificate users.

## Running the tests

```
bundle exec rake test
```

## Versioning

Scooter's development began with Puppet Enterprise 3.7, but that was only available for internal testing at that time; Scooter is open-sourced and available on [rubygems.org](https://rubygems.org) at version 4.x to support the LTS version of Puppet Enterprise, 2016.4.0.


## Contributing

Scooter is very closely related to [Beaker](https://github.com/voxpupuli/beaker); if you wish to contribute to this project, please follow the [outline](https://github.com/voxpupuli/beaker/blob/master/CONTRIBUTING.md) there for contributing to this repo.
