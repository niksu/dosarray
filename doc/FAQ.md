# FAQ

1. I run a cluster. Can I exclude DoSarray from running on some machines?

Yes. Remove those machines from the appropriate fields in
[dosarray_config.sh](../config/dosarray_config.sh), then restart images
(`src/dosarray_stop_containers.sh` then `src/dosarray_delete_containers.sh`,
followed by `src/dosarray_create_containers.sh` then
`src/dosarray_start_containers.sh`), then `sudo service docker stop` on the
affected machines if DoSarray is the only Docker-using system that's running
on those machines.
