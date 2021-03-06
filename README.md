# Integration Tests Utils

## Components

- Docker & Docker compose to load the environment simulation
- Karate as BDD testing tool https://github.com/intuit/karate
- Kafka pixy to interact with kafka https://github.com/mailgun/kafka-pixy
- Mountebank as mock server http://www.mbtest.org/

## Quick Start

- Install docker & docker-compose. (https://docs.docker.com/install/)
- Install sdk man  (https://sdkman.io/install)
- Create `xint.sh` script in your repository, and change permission chmod 755 xint.sh

```
#!/bin/bash
TOOL_HOME=target/3rd
if [ ! -d ${TOOL_HOME}/integration-tests-utils ]; then
    mkdir -p ${TOOL_HOME};cd ${TOOL_HOME};git clone https://github.com/sbonacho/integration-tests-utils.git;cd -
fi
${TOOL_HOME}/integration-tests-utils/xint.sh $*
```
- To install and start environment run: 

```
./xint.sh
``` 
- `karate-config.js`: Karate config is generated
- `docker-compose.yml`: Complete with your services
- To run all tests
```
./xint.sh test
```
- To stop environment
```
./xint.sh stop
```
- To clear environment
```
./xint.sh clear
```

- (Only if you want to add more repositories to docker-compose) 
- Create `env.sh` file with all repositories that you want to build, **only for your project**. 

```
REPOS="
"
SMOKE_URL=http://localhost:8085/actuator/health
```

`REPOS`: Each line has

1. Gitlab repository
2. Branch/tag/commit Id
3. Build method: **javamvn / go** 
4. Version: **sdk java version** 

`SMOKE_URL`: Used for smoke testing before start running all tests


## Tests Configuration

The tests structure is:

```
- tests
    - epic_dir_name
        - feature_name.feature
```

Add epic.config file to epic folder for configuration 

```
CLASSPATH_ADDED=../../target/3rd/mobile-file-reader/target/ReadFileAndSendEvent-1.0-SNAPSHOT-jar-with-dependencies.jar
JIRA_SKIPPED=true

ZEPHYR_TYPE=cucumber
ZEPHYR_PROJECT_KEY=ORXPMO
ZEPHYR_RELEASE_VERSION="PI2-Q419"
```

- `JIRA_SKIPPED`: Default: false - Use for skip uploading to jira server
- `ZEPHYR_TYPE`: Default: cucumber - json type
- `ZEPHYR_PROJECT_KEY`: Default "ORXPMO" - Project key in jira server
- `ZEPHYR_RELEASE_VERSION`: Release code in jira