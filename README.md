# moj-docker-images

An imaging process for MoJ CentOS7 & systemd based containers.

## Requirements

* Virtualbox
* jq
* Patience

## Usage

Edit `./provisioning/files/build_versions.json` to match those CentOS 
versions that require building and then run `./moj-docker-images.sh`.

## TODO

- [ ] Push the built images back to the appropriate Docker repo
- [ ] Implement CIS benchmarking or similar security in the kickstart scripts

## License

MIT License

## Copyright 

Copyright (c) 2018 HMCTS (HM Courts & Tribunals Service)