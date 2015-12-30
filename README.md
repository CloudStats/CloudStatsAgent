# CloudStats Agent

The new agent for http://cloudstats.me

## How to install
### Install the stable version
Get your install code from http://login.cloudstats.me

### Install the version from this repo
You can get the latest prerelease version from this repository and use it. But it
will need a little more work to install it.

1. You have to install a ruby version on your box.
It has been tested on 2.1 and 2.2 on Linux and OS X. You can install it with your package manager or with [rvm](http://rvm.io)

2. You clone this repository:
```bash
git clone https://github.com/CloudStats/CloudStatsAgent.git && cd CloudStatsAgent
```

3. You install the gems with the command:
```bash
bundle install
```

4. You grab the API key for your account from the top menu: Add New Monitor -> Add New Server -> Windows -> API Key

5. You setup the agent with your API Key
```bash
INSTALL_PATH=`pwd` bundle exec ruby lib/cloudstats.rb --setup YOUR_API_KEY
```

6. You can run the agent with
```bash
INSTALL_PATH=`pwd` bundle exec ruby lib/cloudstats.rb
```

7. You can modify the existing script in init.d/cloudstats-agent to start the
agent or you can add it as startup into `/etc/rc.local`:
```bash
INSTALL_PATH='the path where the agent is installed' bundle exec ruby lib/cloudstats.rb
```
