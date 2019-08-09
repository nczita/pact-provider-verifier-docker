# Pact Provider Verification

This setup simplifies Pact Provider [verification](https://github.com/pact-foundation/pact-ruby#2-tell-your-provider-that-it-needs-to-honour-the-pact-file-you-made-earlier)
process in any language, by running the Pact Rake tasks in a separate Docker container.

Docker image is here: https://cloud.docker.com/repository/docker/nczita/pact-provider-verifier.

```
docker pull nczita/pact-provider-verifier
```

**Features**:

* Verify Pacts against Pacts published to a [Pact Broker](https://github.com/pact-foundation/pact_broker)
* Verify local `*.json` Pacts for testing in a development environment
* Pre-configured Docker image with Ruby installed and a sane, default `src/Rakefile` keeping things DRY
* Works with Pact [provider states](https://github.com/pact-foundation/pact-ruby/wiki/Provider-states) should you need them

## Prerequisites
* docker
* docker-compose
* working Dockerfile for your API

## Examples

### Simple API

##### Steps:

1. Create an API and a corresponding Docker image for it
1. Publish Pacts to the Pact broker (or create local ones)
1. Create a `docker-compose.yml` file connecting your API to the Pact Verifier
1. Set the following required environment variables:
   * `pact_urls` - a comma delimited list of pact file urls
   * `provider_base_url` - the base url of the pact provider (i.e. your API)
1. Run `docker-compose build` and then `docker-compose run pactverifier`

##### Sample docker-compose.yml file for a Node API exposed on port `4000`:

```
api:
  build: .
  command: npm start
  expose:
  - "4000:4000"

pactverifier:
  image: nczita/pact-provider-verifier
  links:
  - api:api
  volumes:
  - ./pact/pacts:/app/pacts                 # If you have local Pacts
  environment:
  # Those envs are required
  - provider_base_url=http://api:4000
  - pact_urls=http://pact-host:9292/pacts/provider/MyAPI/consumer/MyConsumer/latest
  # If you have local Pacts
  #- pact_urls=pacts/foo-consumer.json
  # If you have local Pacts (full path)
  #- pact_urls=/app/pacts/foo-consumer.json
  # you want to sent to Pact Broker verification result
  #- app_version=$GIT_COMMIT
  # or
  #- app_version="1.2.3"
```

### API with Provider States

Execute pact provider verification against a provider which implements the following:

* an http GET request to `provider_states_url` which returns pact provider_states by consumer
```
{
  "myConsumer": [
    "customer is logged in",
    "customer has a million dollars"
  ]
}
```

* an http POST request to `provider_states_active_url` which sets the active pact consumer and provider state (in setup - before pact replay)
```
consumer=web&state=customer%20is%20logged%20in
```

* an http DELETE request to `provider_states_active_url` which clears the active pact consumer and provider state (in setup - after pact replay)
```
consumer=web&state=customer%20is%20logged%20in
```

The following environment variables required:

* `pact_urls` - a comma delimited list of pact file urls
* `provider_base_url` - the base url of the pact provider
* `provider_states_url` - the full url of the endpoint which returns provider states by consumer
* `provider_states_active_url` - the full url of the endpoint which sets the active pact consumer and provider state

#### (non-Docker) Usage
```
$ bundle install
$ bundle exec rake verify_pacts
```

#### Docker Compose Usage

##### Sample docker-compose.yml file

```
api:
  build: .
  command: npm run-script pact-provider
  expose:
  - "4000"

pactverifier:
  image: nczita/pact-provider-verifier
  links:
  - api
  environment:
  - pact_urls=http://pact-host:9292/pacts/provider/MyProvider/consumer/myConsumer/latest
  - provider_base_url=http://api4000:
  - provider_states_url=http://api:4000/provider-states
  - provider_states_active_url=http://api:4000/provider-states/active
```