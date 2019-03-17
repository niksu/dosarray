## Releasing involves...

1. running a full set of experiments on various clusters, and checking that the graphs look fine. The graphs are compared to those on DoStbin.
2. updating [CHANGELOG.md](CHANGELOG.md) with the main changes since the last release.
3. updating "Current version" in [README.md](../README.md).
4. updating DOSARRAY_VERSION in [config/dosarray_config.sh](../config/dosarray_config.sh) and [config/dosarray_config.sh_accessnode](../config/dosarray_config.sh_accessnode)
5. then finally making the release at: https://github.com/niksu/dosarray/releases

Instead of the last step you could alternatively could run:
```
$ git tag v0.4
$ git push --tags
```
(where instead of `v0.4` state the new version)
