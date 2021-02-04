# Development

## Build new package

To create new version of portable-ansible or add additional packages to existing distribution there is needed to create `builder` container.

```sh
./manage.sh builder start
./manage.sh builder prepare
./manage.sh builder run
./manage.sh builder stop
```
Note: the list of included packages are listed in the file `conf/requirements`

The result file with portable-ansible build will be available in `builds/` directory.
```sh
ls builds/

portable-ansible-<version>-py3.tar.bz2
```

## Testing

For portable-ansible testing there are needed to create two docker images:
- ansible-client: the container will contain latest ansible build
- ansible-server: this container will be used for connecting from client via ssh keys or username/password

### Preparation Steps

```sh
./manage.sh server start
./manage.sh client start
```

### Running tests
```sh
./manage.sh client local_tests
./manage.sh client remote_tests
```

### Release resources

```sh
./manage.sh server stop
./manage.sh client stop
```
Check there are no `ansible-*` containers up and running
```sh
./manage.sh container list
```
