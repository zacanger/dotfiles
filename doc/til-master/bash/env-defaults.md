# Environment Variable Defaults

Creating a environment variable in bash goes something like this:


```bash
$ export FOO=bar
$ echo ${FOO}
bar
```

This is typically done for use cases such as deployments to cloud based infrastructure with defaults. Now what if you want a default for environment variable if it's _not_ set?

```bash
$ echo ${FOO=default}
default
$ export FOO=bar
$ echo ${FOO=default}
bar
```

Strange syntax but very concise and powerful.

### Caveat:
Please use `unset FOO` before changing the default if you would like to change it for future use.
