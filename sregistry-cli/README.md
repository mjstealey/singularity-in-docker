# sregistry-cli

Demonstrate using [sregistry-cli commands](https://github.com/singularityhub/sregistry-cli/tree/master/docs/getting-started#commands) with a local singularity registry.

### Environment Variables

The container will contain the following environment variables by default:

```
USER_UID=1000
USER_GID=1000
SINGULARITY_VERSION=2.6.1
PYTHON_VERSION=3.6
REGISTRY_TOKEN=''
REGISTRY_USERNAME=''
REGISTRY_BASE=''
BRANCH='master'
```

The `USER_UID=1000` and `USER_GID=1000` variables can be used to change the **UID** and/or **GID** that the user named **singularity** runs as. It can be benefitial to match the UID and GID of the local user running the container for permissions reasons.

The `REGISTRY_TOKEN`, `REGISTRY_USERNAME` and `REGISTRY_BASE` variables are used to set a default `${HOME}/.sregistry` file for the singularity user which will allow **sregistry-cli** interaction with the defined registry.

The `BRANCH` variable determines which branch of the **sregistry-cli** repository gets checked out and built from.

## Usage

The documentation assumes you already have a locally running singularity registry and know what your **Token** is. See [singularity-registry](/singularity-registry) for more details.

### Prerequisites

Build the CentOS 7 rpm files if they don't already exist using the `build-rpms.sh` script (saves to local `rpms` directory).

```console
$ ./build-rpms.sh
...
INFO: packages have been built sucessfully
-rw-r--r--  1 xxxxx  xxxxx   265K Dec 13 14:24 singularity-2.6.1-1.el7.x86_64.rpm
-rw-r--r--  1 xxxxx  xxxxx   512K Dec 13 14:24 singularity-debuginfo-2.6.1-1.el7.x86_64.rpm
-rw-r--r--  1 xxxxx  xxxxx    72K Dec 13 14:24 singularity-devel-2.6.1-1.el7.x86_64.rpm
-rw-r--r--  1 xxxxx  xxxxx   195K Dec 13 14:24 singularity-runtime-2.6.1-1.el7.x86_64.rpm
```

### Build

Build the docker image named `sregistry.cli:latest`

```
docker build -t sregistry.cli:latest .
```

### Running

Recall the Token that was generated from the registry

```json
{
  "registry":
  {
    "token": "09e94fd84b435b838a002b8ceab77ad63ea90962",
    "username": "mjstealey",
    "base": "http://host.docker.internal:8080"
  }
}
```

The attributes to use our local registry can be injected into the new container by specifying the values for

```
"token":   as REGISTRY_TOKEN
"username" as REGISTRY_USERNAME 
"base"     as REGISTRY_BASE
```

- **NOTE**: The value for **REGISTRY_BASE** may need to be altered to accomodate being run on the localhost over port 8080.   
    - **macOS**: `REGISTRY_BASE=http://host.docker.internal:8080`
    - **Linux**: `REGISTRY_BASE=http://192.168.0.1:8080` # IP of `docker0` from host
- **NOTE**: In order to execute `singularity` calls the container needs to run with elevated privilege (`--privileged`).
- **NOTE**: The `sregistry-cli` container may not be able to locally resolve the address `http://nginx` and the user will need to manually add this to the container's `/etc/hosts` file.
    - `docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' nginx`

Example running on macOS:

```
docker run --rm -ti \
  --name sregistry-cli \
  -e SREGISTRY_CLIENT=registry \
  -e SREGISTRY_CLIENT_SECRETS=/home/singularity/.sregistry \
  -e REGISTRY_TOKEN=09e94fd84b435b838a002b8ceab77ad63ea90962 \
  -e REGISTRY_USERNAME=mjstealey \
  -e REGISTRY_BASE=http://host.docker.internal:8080 \
  -v $(pwd)/hello-world:/home/singularity/hello-world \
  --privileged \
  sregistry.cli:latest /bin/bash
```

At this point the `sregistry-cli` container should be running and have landed you as **root** in the `/home/singularity` directory.

```console
# whoami
root
# pwd
/home/singularity
```

If using `http://nginx` as the `DOMAIN_NAME` or `DOMAIN_NAME_HTTP`, verify that you can ping it from the `sregistry-cli` container.

```console
# ping nginx
ping: nginx: Name or service not known
```

If ping fails, add an entry into `/etc/hosts` for `nginx`.

- On the host:

    ```
    $ docker exec sregistry-cli sh -c "echo \"$(docker inspect -f \
      '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' \
      nginx) nginx\" >> /etc/hosts"
    ```
- On the `sregistry-cli` container:

    ```
    $ cat /etc/hosts
    127.0.0.1	localhost
    ::1	localhost ip6-localhost ip6-loopback
    fe00::0	ip6-localnet
    ff00::0	ip6-mcastprefix
    ff02::1	ip6-allnodes
    ff02::2	ip6-allrouters
    172.17.0.7	a33c4b48536f
    172.17.0.5 nginx
    $ ping nginx
    PING nginx (172.17.0.5) 56(84) bytes of data.
    64 bytes from nginx (172.17.0.5): icmp_seq=1 ttl=64 time=0.174 ms
    64 bytes from nginx (172.17.0.5): icmp_seq=2 ttl=64 time=0.140 ms
    64 bytes from nginx (172.17.0.5): icmp_seq=3 ttl=64 time=0.140 ms
    ...
    ```

### As root user

The root user will always operate as root and interact with files at that permission level. If you want to interact with mounted volumes as a different UID:GID that root, then use the **singularity** user.

```
# id
uid=0(root) gid=0(root) groups=0(root)
```


### As singularity user

```
$ docker exec -ti -u singularity sregistry-cli /bin/bash
```

The singularity user will operate using the UID:GID provided to the container when it was instantiated. This will default to 1000:1000 if no options are provided.

```
$ id
uid=1000(singularity) gid=1000(singularity) groups=1000(singularity)
```

## Example

All interaction will be performed as the **singularity** user.

```
$ docker exec -ti -u singularity sregistry-cli /bin/bash
```

### Basic sregistry sanity checks

To ensure that the credentials in the `/home/singularity/.sregistry` file are correct we can perform some sanity checks.

Check `--help`:

```console
# sregistry --help
usage: sregistry [-h] [--debug]
                 {version,shell,images,inspect,get,record,add,rm,rmi,search,push,pull,delete}
                 ...

Singularity Registry tools

optional arguments:
  -h, --help            show this help message and exit
  --debug               use verbose logging to debug.

actions:
  actions for Singularity Registry Global Client

  {version,shell,images,inspect,get,record,add,rm,rmi,search,push,pull,delete}
                        sregistry actions
    version             show software version
    shell               shell into a session a client.
    images              list local images, optionally with query
    inspect             inspect a container in your database
    get                 get a container path from your storage
    record              interact with a container record.
    add                 add a container to local storage
    rm                  remove a container from the database
    rmi                 remove a container from the database AND storage
    search              search remote containers
    push                push one or more images to a registry
    pull                pull an image from a registry
    delete              delete an image from the registry.
```

Check shell, note placement in `[client|registry]` (This would be `[client|hub]` if we were talking to the official **hub**):

```console
# sregistry shell
[client|registry] [database|sqlite:////root/.singularity/sregistry.db]
Python 3.6.5 (default, Apr 10 2018, 17:08:37)
[GCC 4.8.5 20150623 (Red Hat 4.8.5-16)] on linux
Type "help", "copyright", "credits" or "license" for more information.
(InteractiveConsole)
>>>
```

### Create collection in registry

From the **My Collections** page, create a new collection: [http://localhost:8080/collections/my](http://localhost:8080/collections/my)

<img width="80%" alt="My Collections page" src="https://user-images.githubusercontent.com/5332509/37228327-39851ec6-23ae-11e8-9e01-232b3deeae4d.png">

<img width="80%" alt="New Collection" src="https://user-images.githubusercontent.com/5332509/37228318-31f3496c-23ae-11e8-8e55-4ddba57f81fa.png">

<img width="80%" alt="New Collection settings" src="https://user-images.githubusercontent.com/5332509/37228309-2aaaaace-23ae-11e8-8a03-b60053e5f60c.png">

Search for the new collection using the `sregistry` command.

```console
# sregistry search mjstealey
[client|registry] [database|sqlite:////root/.singularity/sregistry.db]
COLLECTION mjstealey
```

### Create hello-world.simg

An example Singularity definition file has been provided for this example inside of the `hello-world` directory (as the user `singularity`).

```console
# su - singularity
$ id
uid=1000(singularity) gid=1000(singularity) groups=1000(singularity)
$ cd hello-world/
$ ls
Singularity  rawr.sh
```

Build the image 

```console
$ sudo singularity build hello-world.simg Singularity
Singularity: image-type (U=0,P=141)> Unknown image format/type: Singularity

Singularity: image-type (U=0,P=141)> Retval = 255

Using container recipe deffile: Singularity
Sanitizing environment
Adding base Singularity environment to container
Docker image path: index.docker.io/library/ubuntu:14.04
Cache folder set to /root/.singularity/docker
[4/4] |===================================| 100.0%
Singularity: docker-extract (U=0,P=174)> Provide a single docker tar file to extract

Singularity: docker-extract (U=0,P=174)> Retval = 255

Exploding layer: sha256:aa1a66b8583aebb7079effdfe4f95e93dbad248eb4016d1204b28a1b4daf0be1.tar.gz
Exploding layer: sha256:aaccc2e362b2a0d1730104c2ec458779bf780014de00161d1844f910e41adbfd.tar.gz
Exploding layer: sha256:a53116a2808f001c7a5ca43153ddc0ba788204142fe6fd928761d94d6c8e66bb.tar.gz
Exploding layer: sha256:b3a7298e318c5e03f94da0eb1a7d1aba5c973086135a2063a3088b4035d4d933.tar.gz
Exploding layer: sha256:c6a9ef4b9995d615851d7786fbc2fe72f72321bee1a87d66919b881a0336525a.tar.gz
User defined %runscript found! Taking priority.
Adding files to container
Copying 'rawr.sh' to '/rawr.sh'
Adding environment to container
Running post scriptlet
+ chmod u+x /rawr.sh
Adding deffile section labels to container
Adding runscript
Finalizing Singularity container
Calculating final size for metadata...
Skipping checks
Building Singularity image...
Singularity container built: hello-world.simg
Cleaning up...
```

Test the image

```console
$ ./hello-world.simg
RaawwWWWWWRRRR!! mjstealey!
```

### Push hello-world.simg to registry

Set `SREGISTRY_CLIENT`

```console
$ export SREGISTRY_CLIENT=registry
$ sregistry search
[client|registry] [database|sqlite:////home/singularity/.singularity/sregistry.db]
Collections
```

Check usage

```console
$ sregistry push --help
usage: sregistry push [-h] [--tag TAG] --name NAME image

positional arguments:
  image        full path to image file

optional arguments:
  -h, --help   show this help message and exit
  --tag TAG    tag for image. If not provided, defaults to latest
  --name NAME  name of image, in format "library/image"
```
Push to registry as `mjstealey/hello-world:latest`

```console
$ sregistry push \
  --tag latest \
  --name mjstealey/hello-world \
  hello-world.simg  
[client|registry] [database|sqlite:////home/singularity/.singularity/sregistry.db]

[1. Collection return status 200 OK]
[================================] 59/59 MB - 00:00:00
[Return status 200 Upload Complete]
```

Search the `mjstealey` collection for the newly pushed image

```
$ sregistry search mjstealey
[client|registry] [database|sqlite:////home/singularity/.singularity/sregistry.db]
COLLECTION mjstealey
1  mjstealey/hello-world:latest	http://nginx/containers/1
```

Check the registry UI

Check the **mjstealey** collection at [http://localhost:8080/collections/1](http://localhost:8080/collections/1)

<img width="80%" alt="Push images to collection" src="https://user-images.githubusercontent.com/5332509/37230071-2d972b4e-23b4-11e8-8c16-157ba27f2ca6.png">

<img width="80%" alt="hello-world.simg" src="https://user-images.githubusercontent.com/5332509/37230154-60e68e54-23b4-11e8-9d0e-f0b9ee1d9e19.png">

Also available from the RESTful API [http://localhost:8080/api/#!/collections/collections_list](http://localhost:8080/api/#!/collections/collections_list)

Using CURL:

```console
$ curl -X GET \
    --header 'Accept: application/json' \
    --header 'X-CSRFToken: ORWKGmcmhSr9pMU002T6q8hlzCuwsto7JJ45oV8jeJjEUlXox56zeK9nAiMD2WII' \
    'http://localhost:8080/api/collections/' | jq .
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   315  100   315    0     0  17015      0 --:--:-- --:--:-- --:--:-- 17500
{
  "count": 1,
  "next": null,
  "previous": null,
  "results": [
    {
      "id": 1,
      "name": "mjstealey",
      "add_date": "2018-12-13T13:34:59.246111-06:00",
      "modify_date": "2018-12-13T13:34:59.269733-06:00",
      "metadata": {},
      "containers": [
        {
          "detail": "http://nginx/containers/1",
          "uri": "mjstealey/hello-world:latest",
          "tag": "latest",
          "name": "hello-world"
        }
      ]
    }
  ]
}
```

### Pull image to local store

Usage

```console
$ sregistry pull --help
usage: sregistry pull [-h] [--name NAME] [--force] [--no-cache] image

positional arguments:
  image        full uri of image

optional arguments:
  -h, --help   show this help message and exit
  --name NAME  custom name for image
  --force, -f  force overwrite of existing image
  --no-cache   if storage active, don't add the image to it
```

Validate empty local store

```console
$ sregistry images

```

Pull image from registry and save to local store

```console
$ sregistry pull mjstealey/hello-world:latest
[client|registry] [database|sqlite:////home/singularity/.singularity/sregistry.db]
Progress |===================================| 100.0%
[container][new] mjstealey/hello-world-latest
Success! /home/singularity/.singularity/shub/mjstealey-hello-world-latest.simg
```

Show image in local store

```console
$ sregistry images
Containers:   [date]   [client]	[uri]
1  December 13, 2018	   [registry]	mjstealey/hello-world:latest@472de5720652ea9385b4dc21509534e7
```

Run image

```console
$ singularity run /home/singularity/.singularity/shub/mjstealey-hello-world-latest.simg
RaawwWWWWWRRRR!! mjstealey!
```

If image pulls without executable flag set... Fix this and try again.

```console
$ chmod +x /home/singularity/.singularity/shub/mjstealey-hello-world:latest
$ /home/singularity/.singularity/shub/mjstealey-hello-world:latest.simg
RaawwWWWWWRRRR!! mjstealey!
```

## References

Singularity Global Client [https://singularityhub.github.io/sregistry-cli/client-registry](https://singularityhub.github.io/sregistry-cli/client-registry)
