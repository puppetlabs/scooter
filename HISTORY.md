# default - History
## Tags
* [LATEST - 6 May, 2015 (cd09d0ca)](#LATEST)
* [0.1.4 - 1 Apr, 2015 (13b845c3)](#0.1.4)
* [0.1.3 - 24 Mar, 2015 (27880f54)](#0.1.3)
* [0.1.2 - 20 Mar, 2015 (b401e9db)](#0.1.2)
* [0.1.1 - 18 Mar, 2015 (5bab4213)](#0.1.1)
* [0.1.0 - 17 Mar, 2015 (0f781ef8)](#0.1.0)
* [0.0.2 - 5 Mar, 2015 (e000b146)](#0.0.2)
* [0.0.1 - 25 Feb, 2015 (8437a298)](#0.0.1)
* [0.0.0 - 22 Dec, 2014 (190723f0)](#0.0.0)

## Details
### <a name = "LATEST">LATEST - 6 May, 2015 (cd09d0ca)

* (GEM) update scooter version to 1.0.0 (cd09d0ca)

* Merge pull request #20 from zreichert/utilities-spec-tests (67fa0791)


```
Merge pull request #20 from zreichert/utilities-spec-tests

Spec tests for Beaker Utilities
```
* (HISTORY) update scooter history for gem release 0.1.4 (44399151)

* (GEM) update scooter version to 0.1.4 (1c75d298)

* Merge pull request #22 from anodelman/pipeline (0de9673c)


```
Merge pull request #22 from anodelman/pipeline

(QENG-2020) scooter + additional mini-gem pipelines
```
* Tests for BeakerUtilities (f8da323b)

* Tests for SrtingUtilities (f05a4cc0)

* (QENG-2020) scooter + additional mini-gem pipelines (fe73a4ee)


```
(QENG-2020) scooter + additional mini-gem pipelines

- standardized version module format
```
* enhanced gitignore, development dependencies, spec_helper (fe01226f)

* Merge pull request #21 from zreichert/two-byte-string-fix (11725810)


```
Merge pull request #21 from zreichert/two-byte-string-fix

update method to use two byte cyrillic characters
```
* update method to use two byte cyrillic characters (4c2c6d1b)

* Merge pull request #19 from objectverbobject/bumpery (f954f17a)


```
Merge pull request #19 from objectverbobject/bumpery

Bump version to 0.1.3
```
* Bump version to 0.1.3 (7113e4ca)


```
Bump version to 0.1.3

This version contains new fixes for acquiring IP's for ec2 instances.
```
* Merge pull request #18 from ericwilliamson/bug/master/farady-use-reachable-name (12565ac9)


```
Merge pull request #18 from ericwilliamson/bug/master/farady-use-reachable-name

(maint) Be explicit about ip vs reachable name
```
* Update beaker_utilities.rb (ea334509)


```
Update beaker_utilities.rb

Changed self.ip to host.ip
```
* Properly set the ssl connection variable (f89dce10)

* Create new beaker method for ec2 public ip (8484b1fa)


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
* (maint) Be explicit about ip vs reachable name (24f9a78f)


```
(maint) Be explicit about ip vs reachable name

Previous to this commit, we were using beakers `reachable_hostname`
which should return ip then hostname. However on ec2, this behavior was
different between machines. This commit makes it explicit that we are
checking if the hostname is resolvable, if not, use the ip address.
```
* Merge pull request #17 from objectverbobject/bumpity (55d0544e)


```
Merge pull request #17 from objectverbobject/bumpity

Bump version for reachable name bug fixes
```
* Bump version for reachable name bug fixes (4816ceb8)


```
Bump version for reachable name bug fixes

Version 0.1.2 adds logic to test the resolvability of the dashboard and
uses reachable_name if necessary, plus a bug fix for update-classes.
```
* Merge pull request #16 from ericwilliamson/bug/master/farady-use-reachable-name (df10d040)


```
Merge pull request #16 from ericwilliamson/bug/master/farady-use-reachable-name

Bug/master/farady use reachable name
```
* Disable ssl verification when using a Unix::Host (04a1a261)


```
Disable ssl verification when using a Unix::Host

Previous to this commit, when passed a Unix::Host (a beaker object) to
connect to, scooter would reach to and talk to the API via the IP
address. However this will fail since the URL we are talking to (the
ip) is not on the cert name.
This commit disables SSL CA verification for now until a better fix can
be found.
```
* Set classifier path for update_classes endpoint (da11ad56)


```
Set classifier path for update_classes endpoint

Previous to this commit, the `update_classes` endpoint in the classifier
API was not calling `set_classifier_path` resulting in the code going to
`https://dashboard/v1/update_classes` instead of the api url.
This commit fixes it by adding the `set_classifier_path` to the method.
This should probably be fixed more broadly so each method does not need
to call that method.
```
* Merge pull request #15 from objectverbobject/bumper (cd1232f5)


```
Merge pull request #15 from objectverbobject/bumper

Bump version for reachable_name
```
* Bump version for reachable_name (7a8377ef)


```
Bump version for reachable_name

This will be in version 0.1.1.
```
* Merge pull request #14 from ericwilliamson/bug/master/farady-use-reachable-name (5ca18c0a)


```
Merge pull request #14 from ericwilliamson/bug/master/farady-use-reachable-name

(maint) use reachable_name for farady connection
```
* (maint) use reachable_name for farady connection (baaf1dfd)


```
(maint) use reachable_name for farady connection

Previous to this commit, the farady connection method was just using
`@dashboard`. However, beaker returns the node_name by default. This
works so long as the dashboard host is in your `/etc/hosts` file.
This commit changes it to use `dashboard.reachable_name` - which
defaults to IP address then hostname and is what beaker uses to
establish an ssh connection.
```
* Merge pull request #12 from objectverbobject/pe_3_series (127be6c3)


```
Merge pull request #12 from objectverbobject/pe_3_series

Bump version to major y release
```
* Bump version to major y release (c8acd695)


```
Bump version to major y release

0.1.x will support PE 3.7 and PE 3.8. 0.2.x will support PE 4.0 and will
live on a separate branch.
```
* Merge pull request #11 from objectverbobject/version_bump2 (0c9de255)


```
Merge pull request #11 from objectverbobject/version_bump2

Version bump to 0.0.2
```
* Version bump to 0.0.2 (4664f26c)


```
Version bump to 0.0.2

Version bump for internal release.
```
* Merge pull request #10 from ericwilliamson/bug/master/remove-httparty-require (bdc4137d)


```
Merge pull request #10 from ericwilliamson/bug/master/remove-httparty-require

(maint) remove httparty require
```
* Merge pull request #9 from objectverbobject/improve_ds_teardown_methods (efc123c4)


```
Merge pull request #9 from objectverbobject/improve_ds_teardown_methods

Improve ds teardown methods
```
* (maint) remove httparty require (0e0c3ca6)


```
(maint) remove httparty require

Since scooter now uses farady, it no longer requires httparty. This
commit removes a left over `require httparty`.
```
* Improve ds teardown methods (35e8dad9)


```
Improve ds teardown methods

This wraps the methods that delete groups and users per test into a
single invocations.
```
* Merge pull request #8 from objectverbobject/version_bump (74f57a7c)


```
Merge pull request #8 from objectverbobject/version_bump

Bump to version 0.0.1
```
* Merge pull request #7 from objectverbobject/fix_delete_all_node_groups (5fbdc474)


```
Merge pull request #7 from objectverbobject/fix_delete_all_node_groups

Fix broken delete_all_node_groups
```
* Fix broken delete_all_node_groups (fe25d36a)


```
Fix broken delete_all_node_groups

The method broke because it passed in a uuid instead of a node group
model.
```
* Bump to version 0.0.1 (013b3265)


```
Bump to version 0.0.1

Version bump for release to internal mirror.
```
* Merge pull request #6 from objectverbobject/reorder_middleware (c2cde614)


```
Merge pull request #6 from objectverbobject/reorder_middleware

Fix middleware logger ordering
```
* Merge pull request #5 from objectverbobject/expand_nc_functionality (e541e753)


```
Merge pull request #5 from objectverbobject/expand_nc_functionality

Add NC methods
```
* Fix middleware logger ordering (22cff937)


```
Fix middleware logger ordering

This allows for the body of http responses to be sent to the logger
before the error handling middleware catches it.
```
* Add NC methods (7a541d45)


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
* Merge pull request #4 from cthorn42/update_faraday_version_number (a085cf0d)


```
Merge pull request #4 from cthorn42/update_faraday_version_number

Faraday version update
```
* Faraday version update (90fe5475)


```
Faraday version update
Logger requires 0.9.1, was not working with 0.9.0
```
* Merge pull request #3 from objectverbobject/update_runtime_dependencies (a94dc8be)


```
Merge pull request #3 from objectverbobject/update_runtime_dependencies

Add versioning to gemspec dependencies
```
* Add versioning to gemspec dependencies (81118b74)


```
Add versioning to gemspec dependencies

In order to use stickler to push the dependencies to the internal
rubygems mirror, we will need to know the version numbers for the gem
dependencies scooter has. Removed minitest and httparty from the
dependency list as well.
```
* Merge pull request #2 from objectverbobject/restructure_consoledispatcher (2a3005b9)


```
Merge pull request #2 from objectverbobject/restructure_consoledispatcher

Restructure ConsoleDispatcher file location
```
* Restructure ConsoleDispatcher file location (68bf858b)


```
Restructure ConsoleDispatcher file location

This commit moves the ConsoleDispatcher underneath HttpDispatchers so
that it is clearer that there should be room for growth for other kinds
of http traffic objects for other services, such as the Puppet Server
and PuppetDB. There are also various changes to Rdoc strings.
```
* Merge pull request #1 from objectverbobject/working_example (75e942d5)


```
Merge pull request #1 from objectverbobject/working_example

Initial working commit
```
* Initial working commit (0a2b3c4c)


```
Initial working commit

This is the initial working commit for the scooter project. The simplest
request for rbac, creating a local user, has been implemented.
```
### <a name = "0.1.4">0.1.4 - 1 Apr, 2015 (13b845c3)

* (HISTORY) update scooter history for gem release 0.1.4 (13b845c3)

* (GEM) update scooter version to 0.1.4 (7f08a8c4)

* Merge pull request #22 from anodelman/pipeline (736f2e14)


```
Merge pull request #22 from anodelman/pipeline

(QENG-2020) scooter + additional mini-gem pipelines
```
* (QENG-2020) scooter + additional mini-gem pipelines (96666ab5)


```
(QENG-2020) scooter + additional mini-gem pipelines

- standardized version module format
```
* Merge pull request #21 from zreichert/two-byte-string-fix (f581d304)


```
Merge pull request #21 from zreichert/two-byte-string-fix

update method to use two byte cyrillic characters
```
* update method to use two byte cyrillic characters (7b70564f)

* Merge pull request #19 from objectverbobject/bumpery (e8c518ed)


```
Merge pull request #19 from objectverbobject/bumpery

Bump version to 0.1.3
```
### <a name = "0.1.3">0.1.3 - 24 Mar, 2015 (27880f54)

* Bump version to 0.1.3 (27880f54)


```
Bump version to 0.1.3

This version contains new fixes for acquiring IP's for ec2 instances.
```
* Merge pull request #18 from ericwilliamson/bug/master/farady-use-reachable-name (4e0d5172)


```
Merge pull request #18 from ericwilliamson/bug/master/farady-use-reachable-name

(maint) Be explicit about ip vs reachable name
```
* Update beaker_utilities.rb (54bfd96e)


```
Update beaker_utilities.rb

Changed self.ip to host.ip
```
* Properly set the ssl connection variable (4fadd49b)

* Create new beaker method for ec2 public ip (b723e477)


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
* (maint) Be explicit about ip vs reachable name (8ffa44a7)


```
(maint) Be explicit about ip vs reachable name

Previous to this commit, we were using beakers `reachable_hostname`
which should return ip then hostname. However on ec2, this behavior was
different between machines. This commit makes it explicit that we are
checking if the hostname is resolvable, if not, use the ip address.
```
* Merge pull request #17 from objectverbobject/bumpity (30220fb4)


```
Merge pull request #17 from objectverbobject/bumpity

Bump version for reachable name bug fixes
```
### <a name = "0.1.2">0.1.2 - 20 Mar, 2015 (b401e9db)

* Bump version for reachable name bug fixes (b401e9db)


```
Bump version for reachable name bug fixes

Version 0.1.2 adds logic to test the resolvability of the dashboard and
uses reachable_name if necessary, plus a bug fix for update-classes.
```
* Merge pull request #16 from ericwilliamson/bug/master/farady-use-reachable-name (bb68718a)


```
Merge pull request #16 from ericwilliamson/bug/master/farady-use-reachable-name

Bug/master/farady use reachable name
```
* Disable ssl verification when using a Unix::Host (2f3a87b9)


```
Disable ssl verification when using a Unix::Host

Previous to this commit, when passed a Unix::Host (a beaker object) to
connect to, scooter would reach to and talk to the API via the IP
address. However this will fail since the URL we are talking to (the
ip) is not on the cert name.
This commit disables SSL CA verification for now until a better fix can
be found.
```
* Set classifier path for update_classes endpoint (90e18e55)


```
Set classifier path for update_classes endpoint

Previous to this commit, the `update_classes` endpoint in the classifier
API was not calling `set_classifier_path` resulting in the code going to
`https://dashboard/v1/update_classes` instead of the api url.
This commit fixes it by adding the `set_classifier_path` to the method.
This should probably be fixed more broadly so each method does not need
to call that method.
```
* Merge pull request #15 from objectverbobject/bumper (629974f2)


```
Merge pull request #15 from objectverbobject/bumper

Bump version for reachable_name
```
### <a name = "0.1.1">0.1.1 - 18 Mar, 2015 (5bab4213)

* Bump version for reachable_name (5bab4213)


```
Bump version for reachable_name

This will be in version 0.1.1.
```
* Merge pull request #14 from ericwilliamson/bug/master/farady-use-reachable-name (9d895677)


```
Merge pull request #14 from ericwilliamson/bug/master/farady-use-reachable-name

(maint) use reachable_name for farady connection
```
* (maint) use reachable_name for farady connection (ea99249d)


```
(maint) use reachable_name for farady connection

Previous to this commit, the farady connection method was just using
`@dashboard`. However, beaker returns the node_name by default. This
works so long as the dashboard host is in your `/etc/hosts` file.
This commit changes it to use `dashboard.reachable_name` - which
defaults to IP address then hostname and is what beaker uses to
establish an ssh connection.
```
* Merge pull request #12 from objectverbobject/pe_3_series (b6d7e599)


```
Merge pull request #12 from objectverbobject/pe_3_series

Bump version to major y release
```
### <a name = "0.1.0">0.1.0 - 17 Mar, 2015 (0f781ef8)

* Bump version to major y release (0f781ef8)


```
Bump version to major y release

0.1.x will support PE 3.7 and PE 3.8. 0.2.x will support PE 4.0 and will
live on a separate branch.
```
* Merge pull request #11 from objectverbobject/version_bump2 (a84106e4)


```
Merge pull request #11 from objectverbobject/version_bump2

Version bump to 0.0.2
```
### <a name = "0.0.2">0.0.2 - 5 Mar, 2015 (e000b146)

* Version bump to 0.0.2 (e000b146)


```
Version bump to 0.0.2

Version bump for internal release.
```
* Merge pull request #10 from ericwilliamson/bug/master/remove-httparty-require (43663c25)


```
Merge pull request #10 from ericwilliamson/bug/master/remove-httparty-require

(maint) remove httparty require
```
* Merge pull request #9 from objectverbobject/improve_ds_teardown_methods (b4fa1334)


```
Merge pull request #9 from objectverbobject/improve_ds_teardown_methods

Improve ds teardown methods
```
* (maint) remove httparty require (eb3d8505)


```
(maint) remove httparty require

Since scooter now uses farady, it no longer requires httparty. This
commit removes a left over `require httparty`.
```
* Improve ds teardown methods (6113025d)


```
Improve ds teardown methods

This wraps the methods that delete groups and users per test into a
single invocations.
```
* Merge pull request #8 from objectverbobject/version_bump (fb49229c)


```
Merge pull request #8 from objectverbobject/version_bump

Bump to version 0.0.1
```
* Merge pull request #7 from objectverbobject/fix_delete_all_node_groups (700942d7)


```
Merge pull request #7 from objectverbobject/fix_delete_all_node_groups

Fix broken delete_all_node_groups
```
* Fix broken delete_all_node_groups (83a004c8)


```
Fix broken delete_all_node_groups

The method broke because it passed in a uuid instead of a node group
model.
```
### <a name = "0.0.1">0.0.1 - 25 Feb, 2015 (8437a298)

* Bump to version 0.0.1 (8437a298)


```
Bump to version 0.0.1

Version bump for release to internal mirror.
```
* Merge pull request #6 from objectverbobject/reorder_middleware (42004fea)


```
Merge pull request #6 from objectverbobject/reorder_middleware

Fix middleware logger ordering
```
* Merge pull request #5 from objectverbobject/expand_nc_functionality (2d05f8c6)


```
Merge pull request #5 from objectverbobject/expand_nc_functionality

Add NC methods
```
* Fix middleware logger ordering (dbca715b)


```
Fix middleware logger ordering

This allows for the body of http responses to be sent to the logger
before the error handling middleware catches it.
```
* Add NC methods (7db94215)


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
* Merge pull request #4 from cthorn42/update_faraday_version_number (a37c9941)


```
Merge pull request #4 from cthorn42/update_faraday_version_number

Faraday version update
```
* Faraday version update (0ca3cbae)


```
Faraday version update
Logger requires 0.9.1, was not working with 0.9.0
```
* Merge pull request #3 from objectverbobject/update_runtime_dependencies (5f0a1e7f)


```
Merge pull request #3 from objectverbobject/update_runtime_dependencies

Add versioning to gemspec dependencies
```
* Add versioning to gemspec dependencies (7d998d63)


```
Add versioning to gemspec dependencies

In order to use stickler to push the dependencies to the internal
rubygems mirror, we will need to know the version numbers for the gem
dependencies scooter has. Removed minitest and httparty from the
dependency list as well.
```
* Merge pull request #2 from objectverbobject/restructure_consoledispatcher (00e6c88f)


```
Merge pull request #2 from objectverbobject/restructure_consoledispatcher

Restructure ConsoleDispatcher file location
```
* Restructure ConsoleDispatcher file location (0ca5e593)


```
Restructure ConsoleDispatcher file location

This commit moves the ConsoleDispatcher underneath HttpDispatchers so
that it is clearer that there should be room for growth for other kinds
of http traffic objects for other services, such as the Puppet Server
and PuppetDB. There are also various changes to Rdoc strings.
```
* Merge pull request #1 from objectverbobject/working_example (8dfece71)


```
Merge pull request #1 from objectverbobject/working_example

Initial working commit
```
### <a name = "0.0.0">0.0.0 - 22 Dec, 2014 (190723f0)

* Initial release.
