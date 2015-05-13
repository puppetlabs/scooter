# Scooter

#### Table of Contents

1. [Overview](#overview)
2. [Usage](#usage)
3. [Versioning](#versioning)
4. [Releasing](#releasing)
  * [Pushing a new version to the internal rubygems mirror](#pushing-a-new-version-to-the-internal-rubygems-mirror)
5. [Rdocs](#rdocs)
6. [Contributing](#contributing)

## Overview

Scooter is a ruby gem developed by QA to facilitate http traffic between the
test runner and a Puppet Enterprise Installation–specifically the services
available in the pe-console-services process: Classifier, RBAC, and Activity
Service.

## Usage

Scooter only supports versions of Puppet Enterprise 3.7 and higher. Scooter is only available on the internal server, rubygems.delivery.puppetlabs.net.

To install Scooter, simply use the gem command with the source flag set to the internal rubygems mirror–remember that you will have to be on Puppet's DNS to see the mirrored gem server.

```
$ gem install scooter --source http://rubygems.delivery.puppetlabs.net
```

Scooter is currently divvied into the following sections:

 - [HttpDispatchers](docs/http_dispatchers.md) – These are modules that can be mixed into classes that represent real users: whitelisted certificate users, local console users, or users connected through an LDAP directory. Currently, there is only one dispatcher currently defined--ConsoleDispatcher–but there could be new dispatchers created to facilitate traffic to other products, such as Puppet Server and PuppetDB.

 - LDAPdispatcher – This class extends the Net::LDAP library, which is a requirement to for RBAC testing with LDAP fixtures.
 - Utilities – Currently, this houses random string generators and convenience methods to use beaker to acquire certificates to impersonate whitelisted certificate users.

## Versioning

Scooter supports semantic versioning, with any 1.x release of scooter supporting all PE versions between 3.7.x and 4.0.

If you are looking for scooter support for PE 4.0 aka shallow gravy, please use any scooter version that is 2.x. Routes to the services changed between PE 3.7 and PE 4.0, requiring a major version bump of scooter between those versions.

## Releasing

The plan is to release Scooter at a regular cadence, probably once a week. Early on, we will release more often, as the port from qatests is not totally complete. Early feedback may significantly change the structure, so be cautious about building any significant dependencies yet. Once the dust has settled, a 1.0 release will be cut and support normal semantic versioning.

Discussion is still ongoing about whether this library will be publicly available on rubygems or not. Please feel free to email the the QA team for any further information regarding a public release.

 - One issue blocking a public release of Scooter is to avoid possibly leaking information about unreleased features/products that Scooter might have information on. This could be mitigated by careful version control of Scooter, releasing it to the public only periodically, but releasing internally at a more frequent basis for internal testing.

 - Should the gem accept PR's from the public? That seems to require significant overhead in terms of testing and stability of PR's. Perhaps make the gem public without accepting PR's from the public? Make the gem available on rubygems.org while the repo stays private?

### Pushing a new version to the internal rubygems mirror

 1. Log into jenkins-qe

 2. Trigger the Scooter Release Pipeline

   a. The pipeline is responsible for checking in the version bump, generating a new HISTORY.md file, creating and pushing the gem

   b. Select an appropriate version number *** WARNING - whatever version number you select will be auto-created and pushed liver, BE CAREFUL ***

## Rdocs

Much of the documentation of Scooter is embedded in the ruby code itself, using rdoc standards for documentation. Currently, Puppet does not have an internal server delivering yard documentation; if you wish to view the rdocs, you must build it out yourself after you have downloaded the gem.

```
prompt:~$ yard server --gems

#>> YARD 0.8.7.4 documentation server at http://0.0.0.0:8808
#Thin web server (v1.6.2 codename Doc Brown)
#Maximum connections set to 1024
#Listening on 0.0.0.0:8808, CTRL+C to stop
#
#goto: http://0.0.0.0:8808/docs/scooter/frames
```

## Contributing

You are encouraged to fork and submit PR's to Scooter. Tony Vu or Chris Cowell-Shah are your best bet for getting a PR merged in; that list will grow as QA adds more regular contributors to the repo.
