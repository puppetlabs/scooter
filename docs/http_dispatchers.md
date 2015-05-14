## HttpDispatchers

### Overview

Currently, there is only one class available in this section, the [`ConsoleDispatcher`](#console-dispatcher). A few, general ideas about the organization and procedure are as follows (All of this page needs better organization):

The underlying basis for the `ConsoleDispatcher` is the [Faraday](https://github.com/lostisland/faraday) library. A `Faraday::Connection` object should be utilized, probably as a `@connection` object defined as an `attr_accessor` for any other new httpdispatchers.

An `HttpDispatcher` should include modules representing the products/services and a mechanism for changing the versions of the service.

Method names at the service level, should, in general, not use the `@connection` object but use the methods defined in the version module; they do not necessarily need to be representative of the endpoints of the service.

Method names defined in the version module should be representative of the endpoints of the service.

```
├── classifier
│   └── v1
│       └── v1.rb
├── classifier.rb
├── consoledispatcher.rb
├── rbac
│   └── v1
│       ├── directory_service.rb
│       └── v1.rb
└── rbac.rb
```

#### Why Faraday and not HTTParty?

Faraday was designed with the concept of middleware–classes that you can add to your connection stack to act on requests and responses. That middleware stack has proven to be very valuable for dealing with redundant methods for dealing with API calls, while still retaining much of the versatility that HTTParty had. Faraday's middleware also allows for easy inclusion of other independent libraries, such as the Faraday cookie jar that the ConsoleDispatcher uses for its default connection.

### Console Dispatcher

The `ConsoleDispatcher` is designed to speak to any of the services packaged up in pe-console-services: Node Classifer, RBAC, and Activity Service. Beyond those services, the Console Dispatcher also handles connecting to the /auth endpoints, handling sessions and the CSRF token if necessary.

#### Certificate Dispatcher

``` ruby
require 'scooter'

#example beaker config
#HOSTS:
#  ubuntu1404:
#    vmname: ubuntu-1404
#    roles:
#      - master
#      - agent
#      - database
#      - dashboard
#    platform: ubuntu-14.04-amd64

certificate_dispatcher = Scooter::HttpDispatchers::ConsoleDispatcher.new(dashboard)
```

A `ConsoleDispatcher` assumes it is a certificate dispatcher if no credentials are passed in during initialization. As a certificate dispatcher, you do not need to maintain a session or signin. Once created, a certificate dispatcher talks directly to the services, defined by the dashboard object passed in.

#### Credential Dispatcher

``` ruby
require 'scooter'

#example beaker config
#HOSTS:
#  ubuntu1404:
#    vmname: ubuntu-1404
#    roles:
#      - master
#      - agent
#      - database
#      - dashboard
#    platform: ubuntu-14.04-amd64


certificate_dispatcher = Scooter::HttpDispatchers::ConsoleDispatcher.new(dashboard,
    login: 'admin',
    password: 'password')
```

A `ConsoleDispatcher` assumes it is a credential dispatcher if credentials–login and password–are passed in as parameters during creation. As a credential dispatcher, you will need to successfully signin to get a session to make further successful calls to any of the services.
