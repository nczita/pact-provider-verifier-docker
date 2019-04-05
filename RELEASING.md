# Releasing

```
docker build -t nczita/pact-provider-verifier .
docker push nczita/pact-provider-verifier
```


# Update gems

Actually this is work in progress, right now:

* remove `Gemfile.lock`
* remove `COPY Gemfile.lock /app/` in `Dockerfile:9`
* build image
* start container
* copy `Gemfile.lock` to host
* stop (and remove) container
* commit updated `Gemfile.lock` only (reset other changes!)
