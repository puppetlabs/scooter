# default - History
## Tags
* [LATEST - 21 Jul, 2015 (8de59de2)](#LATEST)
* [2.2 - 15 Jun, 2015 (7c4645e9)](#2.2)
* [2.1.1 - 10 Jun, 2015 (6878cb4b)](#2.1.1)
* [2.1.0 - 14 May, 2015 (ce963c12)](#2.1.0)
* [2.0.1 - 13 May, 2015 (cba48153)](#2.0.1)
* [2.0.0 - 6 May, 2015 (99e32b38)](#2.0.0)
* [1.0.0 - 6 May, 2015 (4d701cbd)](#1.0.0)
* [0.1.4 - 1 Apr, 2015 (0899ec46)](#0.1.4)
* [0.1.3 - 24 Mar, 2015 (3bd68890)](#0.1.3)
* [0.1.2 - 20 Mar, 2015 (15d98713)](#0.1.2)
* [0.1.1 - 18 Mar, 2015 (8ba3e185)](#0.1.1)
* [0.1.0 - 17 Mar, 2015 (ac1abd5b)](#0.1.0)
* [0.0.2 - 5 Mar, 2015 (977d4eac)](#0.0.2)
* [0.0.1 - 25 Feb, 2015 (0ac45ec9)](#0.0.1)
* [0.0.0 - 22 Dec, 2014 (9307ec38)](#0.0.0)

## Details
### <a name = "LATEST">LATEST - 21 Jul, 2015 (8de59de2)

* (GEM) update scooter version to 2.3.0 (8de59de2)

* Merge pull request #41 from objectverbobject/QA-1937/create_base_httpdispatcher_class (3cfdcab9)


```
Merge pull request #41 from objectverbobject/QA-1937/create_base_httpdispatcher_class

(QA-1937) Create base httpdispatcher
```
* Merge pull request #40 from objectverbobject/refactor_ldapdispatcher (bda5be50)


```
Merge pull request #40 from objectverbobject/refactor_ldapdispatcher

Refactor ldapdispatcher
```
* (QA-1937) Create base httpdispatcher (71630c30)


```
(QA-1937) Create base httpdispatcher

Prior to this commit, the only real dispatcher available was the
consoledispatcher. The consoledispatcher had much of the base methods
defined in itself, which needed to be pulled out and put into another
class that all other dispatcher classes should be subclassing. This PR
creates a base httpdispatcher, making it more straightfoward to
subclass the httpdispatcher class and build different dispatching
objects.
```
* (maint) fix bug with attach_ds_to_rbac (52244b1b)


```
(maint) fix bug with attach_ds_to_rbac

A bug existed in the implementation of this method; if no ldapdispatcher
was provided, the local var settings would not be set and you would get
an uninitialized error for settings. This change fixes that issue so you
can supply an options hash with any set of directory_service parameters
you want.
```
* (maint) remove conditional ldap base logic (c1fdc861)


```
(maint) remove conditional ldap base logic

In a previous build, the ldap dispatcher used a new base_dn for windows;
a new fixture has been created and this no longer needs to be
conditional per openldap or active directory.
```
* Merge pull request #39 from objectverbobject/refactor_ldapdispatcher (921deee2)


```
Merge pull request #39 from objectverbobject/refactor_ldapdispatcher

(QA-1926) Refactor LDAPDispatcher
```
* (QA-1926) Refactor LDAPDispatcher (63bb82fa)


```
(QA-1926) Refactor LDAPDispatcher

This commit changes the LDAPDispatcher to make less assumptions about
the directory service object and allow for more settings to be adjusted,
such as the user and password settings.
```
* Merge pull request #38 from objectverbobject/fix_version_numbering (0f610643)


```
Merge pull request #38 from objectverbobject/fix_version_numbering

(maint) fix bad version number
```
* (maint) fix bad version number (54b37ddf)


```
(maint) fix bad version number

Tony accidently pushed 2.2 instead of 2.2.0 to the internal mirror; this
commit just fixes the bump so that the release pipeline doesn't break
when trying to parse the 2.2 version.
```
### <a name = "2.2">2.2 - 15 Jun, 2015 (7c4645e9)

* (HISTORY) update scooter history for gem release 2.2 (7c4645e9)

* (GEM) update scooter version to 2.2 (ba8647c8)

* Merge pull request #31 from pcarlisle/fix-ruby-2.2 (07e4e8e2)


```
Merge pull request #31 from pcarlisle/fix-ruby-2.2

(maint) Fix optional arguments for ruby 2.2
```
* Merge pull request #37 from objectverbobject/moar_rbac_helpers (cd55f50a)


```
Merge pull request #37 from objectverbobject/moar_rbac_helpers

Moar rbac helpers
```
* Add more RBAC helpers (0e274ac8)


```
Add more RBAC helpers

This adds methods to generate local users and roles. Previously, the
logic to create a local user was embedded into the v1 module, which was
not the correct location for it. The method has been moved to the Rbac
module and renamed generate_local_user.

While this is a breaking change, none of the tests actually used that
method, and so it can be safely erased.
```
* (maint) fix acquire_xcsrf to clear the prefix path (4221cb45)

* (maint) Fix optional arguments for ruby 2.2 (febef0fc)


```
(maint) Fix optional arguments for ruby 2.2

As of ruby 2.2 it's no longer possible to assign a default value in an
argument from an outer scope method of the same name.

e.g.

def foo
  10
end

def bar(foo=foo)
  puts foo
end

In ruby 2.1 this prints 10, in ruby 2.2 a blank line as foo is nil.
```
### <a name = "2.1.1">2.1.1 - 10 Jun, 2015 (6878cb4b)

* (HISTORY) update scooter history for gem release 2.1.1 (6878cb4b)

* (GEM) update scooter version to 2.1.1 (416a5c4f)

* Merge pull request #34 from objectverbobject/separate_signin_and_xcsrf_token (767b196f)


```
Merge pull request #34 from objectverbobject/separate_signin_and_xcsrf_token

(QA-1925) Change signin to not autoacquire xcsrf
```
* Merge pull request #35 from anodelman/master (951e3775)


```
Merge pull request #35 from anodelman/master

(MAINT) set pe_rbac_service based upon scooter branch
```
* (MAINT) set pe_rbac_service based upon scooter branch (34e4d15c)

* (QA-1925) Change signin to not autoacquire xcsrf (c40d3e8d)


```
(QA-1925) Change signin to not autoacquire xcsrf

The console used to not have a console view permission, allowing any
authenticated entity view access; This allowed any user to acquire an
xcsrf token after successful login.

The signin method still tries to acquire the XCSRF token, but catches
failures if the dispatcher does not have view access to the console.
```
* Merge pull request #33 from anodelman/split-pipeline-master (55ee8517)


```
Merge pull request #33 from anodelman/split-pipeline-master

(QENG-2382) scooter pipeline needs to install different pe depending...
```
* (QENG-2382) scooter pipeline needs to install different pe depending... (98958ca7)


```
(QENG-2382) scooter pipeline needs to install different pe depending...

...on target branch

- create .env file with branch appropriate testing information
```
### <a name = "2.1.0">2.1.0 - 14 May, 2015 (ce963c12)

* (HISTORY) update scooter history for gem release 2.1.0 (ce963c12)

* (GEM) update scooter version to 2.1.0 (ddf63d73)

* Merge pull request #30 from rick/docs/update-README (03439b5e)


```
Merge pull request #30 from rick/docs/update-README

Import confluence documentation
```
* Merge pull request #29 from rick/feature/add-find_or_create_node_group_model (1b6d3e40)


```
Merge pull request #29 from rick/feature/add-find_or_create_node_group_model

Add `#find_or_create_node_group_model`
```
* Import confluence documentation (2d7cdecb)


```
Import confluence documentation

This commit brings in the confluence documentation for Scooter into the
`README.md`, and creates a new `docs/` folder for some of the class-level
documentation.
```
* (QENG-2120) Add `#find_or_create_node_group_model` (34a5384c)


```
(QENG-2120) Add `#find_or_create_node_group_model`

In https://github.com/puppetlabs/pe_acceptance_tests/pull/614 we locally
introduced a `#find_or_create_node_group_model` method on the dispatcher
classifier module. This allows us to re-run tests which create node groups in
the classifier, without causing errors due to duplicate node groups in an
environment.

This commit brings that method back to `Scooter::HttpDispatchers::Classifier`.
```
### <a name = "2.0.1">2.0.1 - 13 May, 2015 (cba48153)

* (HISTORY) update scooter history for gem release 2.0.1 (cba48153)

* (GEM) update scooter version to 2.0.1 (5265b3bb)

* Merge pull request #28 from objectverbobject/add_readme_link (81070779)


```
Merge pull request #28 from objectverbobject/add_readme_link

(maint) Add link to README.md to confluence
```
* Merge pull request #27 from objectverbobject/merge_stable (019f05e0)


```
Merge pull request #27 from objectverbobject/merge_stable

(maint) Merge stable
```
* (maint) Add link to README.md to confluence (e7542509)


```
(maint) Add link to README.md to confluence

This is a temporary link that will exist until the confluence
documentation is imported into the Scooter repository.
```
* Merge remote-tracking branch 'upstream/stable' into merge_stable (1d604238)


```
Merge remote-tracking branch 'upstream/stable' into merge_stable

Merge in fix for beaker change to object inheritance for Windows::Host
object.
```
* Merge pull request #26 from objectverbobject/fix_LDAP_host_logic (32955080)


```
Merge pull request #26 from objectverbobject/fix_LDAP_host_logic

(maint) fix ldap host logic to work with beaker 2.11.0
```
* (maint) fix ldap host logic to work with beaker 2.11.0 (91df2cd1)


```
(maint) fix ldap host logic to work with beaker 2.11.0

Beaker 2.11.0 introduced a change in the object inheritance for the
Windows::Host object, making it inherit from Unix::Host. This commit
changes the order of checks in the ldapdispatcher object, making it
check for Windows first before checking if it is a Unix::Host.
```
### <a name = "2.0.0">2.0.0 - 6 May, 2015 (99e32b38)

* (GEM) update scooter version to 2.0.0 (99e32b38)

* Merge pull request #25 from anodelman/cherry (2c82eef1)


```
Merge pull request #25 from anodelman/cherry

Update paths for non-cert rbac and classifier requests
```
* Update paths for non-cert rbac and classifier requests (d83aed0c)


```
Update paths for non-cert rbac and classifier requests

This updates the paths to match the new routing for PE 4.0
```
### <a name = "1.0.0">1.0.0 - 6 May, 2015 (4d701cbd)

* (GEM) update scooter version to 1.0.0 (4d701cbd)

* Merge pull request #20 from zreichert/utilities-spec-tests (1c5d081c)


```
Merge pull request #20 from zreichert/utilities-spec-tests

Spec tests for Beaker Utilities
```
* Tests for BeakerUtilities (00befbe6)

* Tests for SrtingUtilities (4b608f31)

* enhanced gitignore, development dependencies, spec_helper (355cdfa7)

### <a name = "0.1.4">0.1.4 - 1 Apr, 2015 (0899ec46)

* (GEM) update scooter version to 0.1.4 (0899ec46)

* Merge pull request #22 from anodelman/pipeline (8f1b504c)


```
Merge pull request #22 from anodelman/pipeline

(QENG-2020) scooter + additional mini-gem pipelines
```
* (QENG-2020) scooter + additional mini-gem pipelines (4495ee3a)


```
(QENG-2020) scooter + additional mini-gem pipelines

- standardized version module format
```
* Merge pull request #21 from zreichert/two-byte-string-fix (ecb4cb8d)


```
Merge pull request #21 from zreichert/two-byte-string-fix

update method to use two byte cyrillic characters
```
* update method to use two byte cyrillic characters (4294f8c7)

* Merge pull request #19 from objectverbobject/bumpery (0777187e)


```
Merge pull request #19 from objectverbobject/bumpery

Bump version to 0.1.3
```
### <a name = "0.1.3">0.1.3 - 24 Mar, 2015 (3bd68890)

* Bump version to 0.1.3 (3bd68890)


```
Bump version to 0.1.3

This version contains new fixes for acquiring IP's for ec2 instances.
```
* Merge pull request #18 from ericwilliamson/bug/master/farady-use-reachable-name (9b723a34)


```
Merge pull request #18 from ericwilliamson/bug/master/farady-use-reachable-name

(maint) Be explicit about ip vs reachable name
```
* Update beaker_utilities.rb (a2146794)


```
Update beaker_utilities.rb

Changed self.ip to host.ip
```
* Properly set the ssl connection variable (00b08c63)

* Create new beaker method for ec2 public ip (d8caa744)


```
Create new beaker method for ec2 public ip

Beaker and ec2 don't play nice with getting the public ip. It is only
set during initial provision and can be over-ridden. If you also have to
run the script several times, or are using an existing set of nodes for
testing, beaker has no way to get the ec2 instanes public ip address,
mostly because the box it self does not expose it anywhere.  According
to the docs, you can curl the below to get it
http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-instance-addressing.html
```
* (maint) Be explicit about ip vs reachable name (c91aab3c)


```
(maint) Be explicit about ip vs reachable name

Previous to this commit, we were using beakers `reachable_hostname`
which should return ip then hostname. However on ec2, this behavior was
different between machines. This commit makes it explicit that we are
checking if the hostname is resolvable, if not, use the ip address.
```
* Merge pull request #17 from objectverbobject/bumpity (444a0db7)


```
Merge pull request #17 from objectverbobject/bumpity

Bump version for reachable name bug fixes
```
### <a name = "0.1.2">0.1.2 - 20 Mar, 2015 (15d98713)

* Bump version for reachable name bug fixes (15d98713)


```
Bump version for reachable name bug fixes

Version 0.1.2 adds logic to test the resolvability of the dashboard and
uses reachable_name if necessary, plus a bug fix for update-classes.
```
* Merge pull request #16 from ericwilliamson/bug/master/farady-use-reachable-name (6bf8df1d)


```
Merge pull request #16 from ericwilliamson/bug/master/farady-use-reachable-name

Bug/master/farady use reachable name
```
* Disable ssl verification when using a Unix::Host (6eb1750c)


```
Disable ssl verification when using a Unix::Host

Previous to this commit, when passed a Unix::Host (a beaker object) to
connect to, scooter would reach to and talk to the API via the IP
address. However this will fail since the URL we are talking to (the
ip) is not on the cert name.
This commit disables SSL CA verification for now until a better fix can
be found.
```
* Set classifier path for update_classes endpoint (610f1d28)


```
Set classifier path for update_classes endpoint

Previous to this commit, the `update_classes` endpoint in the classifier
API was not calling `set_classifier_path` resulting in the code going to
`https://dashboard/v1/update_classes` instead of the api url.
This commit fixes it by adding the `set_classifier_path` to the method.
This should probably be fixed more broadly so each method does not need
to call that method.
```
* Merge pull request #15 from objectverbobject/bumper (d57399d0)


```
Merge pull request #15 from objectverbobject/bumper

Bump version for reachable_name
```
### <a name = "0.1.1">0.1.1 - 18 Mar, 2015 (8ba3e185)

* Bump version for reachable_name (8ba3e185)


```
Bump version for reachable_name

This will be in version 0.1.1.
```
* Merge pull request #14 from ericwilliamson/bug/master/farady-use-reachable-name (6f53e078)


```
Merge pull request #14 from ericwilliamson/bug/master/farady-use-reachable-name

(maint) use reachable_name for farady connection
```
* (maint) use reachable_name for farady connection (5c574204)


```
(maint) use reachable_name for farady connection

Previous to this commit, the farady connection method was just using
`@dashboard`. However, beaker returns the node_name by default. This
works so long as the dashboard host is in your `/etc/hosts` file.
This commit changes it to use `dashboard.reachable_name` - which
defaults to IP address then hostname and is what beaker uses to
establish an ssh connection.
```
* Merge pull request #12 from objectverbobject/pe_3_series (8adc5448)


```
Merge pull request #12 from objectverbobject/pe_3_series

Bump version to major y release
```
### <a name = "0.1.0">0.1.0 - 17 Mar, 2015 (ac1abd5b)

* Bump version to major y release (ac1abd5b)


```
Bump version to major y release

0.1.x will support PE 3.7 and PE 3.8. 0.2.x will support PE 4.0 and will
live on a separate branch.
```
* Merge pull request #11 from objectverbobject/version_bump2 (fc036845)


```
Merge pull request #11 from objectverbobject/version_bump2

Version bump to 0.0.2
```
### <a name = "0.0.2">0.0.2 - 5 Mar, 2015 (977d4eac)

* Version bump to 0.0.2 (977d4eac)


```
Version bump to 0.0.2

Version bump for internal release.
```
* Merge pull request #10 from ericwilliamson/bug/master/remove-httparty-require (6c2c83b0)


```
Merge pull request #10 from ericwilliamson/bug/master/remove-httparty-require

(maint) remove httparty require
```
* Merge pull request #9 from objectverbobject/improve_ds_teardown_methods (6bc83c20)


```
Merge pull request #9 from objectverbobject/improve_ds_teardown_methods

Improve ds teardown methods
```
* (maint) remove httparty require (4836fa8c)


```
(maint) remove httparty require

Since scooter now uses farady, it no longer requires httparty. This
commit removes a left over `require httparty`.
```
* Improve ds teardown methods (1b6982be)


```
Improve ds teardown methods

This wraps the methods that delete groups and users per test into a
single invocations.
```
* Merge pull request #8 from objectverbobject/version_bump (3b383bd5)


```
Merge pull request #8 from objectverbobject/version_bump

Bump to version 0.0.1
```
* Merge pull request #7 from objectverbobject/fix_delete_all_node_groups (4e2a219e)


```
Merge pull request #7 from objectverbobject/fix_delete_all_node_groups

Fix broken delete_all_node_groups
```
* Fix broken delete_all_node_groups (b17e33f7)


```
Fix broken delete_all_node_groups

The method broke because it passed in a uuid instead of a node group
model.
```
### <a name = "0.0.1">0.0.1 - 25 Feb, 2015 (0ac45ec9)

* Bump to version 0.0.1 (0ac45ec9)


```
Bump to version 0.0.1

Version bump for release to internal mirror.
```
* Merge pull request #6 from objectverbobject/reorder_middleware (d8c7ae5c)


```
Merge pull request #6 from objectverbobject/reorder_middleware

Fix middleware logger ordering
```
* Merge pull request #5 from objectverbobject/expand_nc_functionality (bf8dd1e8)


```
Merge pull request #5 from objectverbobject/expand_nc_functionality

Add NC methods
```
* Fix middleware logger ordering (5c058e27)


```
Fix middleware logger ordering

This allows for the body of http responses to be sent to the logger
before the error handling middleware catches it.
```
* Add NC methods (5ed1b55b)


```
Add NC methods

This commit introduces several NC methods, both in the Classifier module
and in the v1 module. This commit includes methods to delete all
children of a node group, various attribute extractors, and the ability
to PUT and POST to update node groups.

Stylistically, it also removes all logic from the v1 module; this allows
for cleaner separation between the api calls and any transforms you
might want to implement.
```
* Merge pull request #4 from cthorn42/update_faraday_version_number (ea6fe884)


```
Merge pull request #4 from cthorn42/update_faraday_version_number

Faraday version update
```
* Faraday version update (5f7b95ad)


```
Faraday version update
Logger requires 0.9.1, was not working with 0.9.0
```
* Merge pull request #3 from objectverbobject/update_runtime_dependencies (10cd0d5d)


```
Merge pull request #3 from objectverbobject/update_runtime_dependencies

Add versioning to gemspec dependencies
```
* Add versioning to gemspec dependencies (e34fa7d9)


```
Add versioning to gemspec dependencies

In order to use stickler to push the dependencies to the internal
rubygems mirror, we will need to know the version numbers for the gem
dependencies scooter has. Removed minitest and httparty from the
dependency list as well.
```
* Merge pull request #2 from objectverbobject/restructure_consoledispatcher (cc9bebbc)


```
Merge pull request #2 from objectverbobject/restructure_consoledispatcher

Restructure ConsoleDispatcher file location
```
* Restructure ConsoleDispatcher file location (d7d964b9)


```
Restructure ConsoleDispatcher file location

This commit moves the ConsoleDispatcher underneath HttpDispatchers so
that it is clearer that there should be room for growth for other kinds
of http traffic objects for other services, such as the Puppet Server
and PuppetDB. There are also various changes to Rdoc strings.
```
* Merge pull request #1 from objectverbobject/working_example (b3a8235c)


```
Merge pull request #1 from objectverbobject/working_example

Initial working commit
```
### <a name = "0.0.0">0.0.0 - 22 Dec, 2014 (9307ec38)

* Initial release.
