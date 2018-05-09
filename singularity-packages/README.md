# Singularity Package Builder

Builds the [Singularity](http://singularity.lbl.gov/install-linux) packages from their [Github source](https://github.com/singularityware/singularity) based on the tag specified as an environment variable named `SINGULARITY_VERSION` (default is `SINGULARITY_VERSION=2.5.1`)

Supported builds (defaults shown):

- CentOS 7 
	- `singularity-2.5.1-1.el7.centos.x86_64.rpm`
	- `singularity-debuginfo-2.5.1-1.el7.centos.x86_64.rpm`
	- `singularity-devel-2.5.1-1.el7.centos.x86_64.rpm`
	- `singularity-runtime-2.5.1-1.el7.centos.x86_64.rpm`
- Ubuntu 16.04
	- `singularity-container_2.5.1-1_amd64.deb`

## CentOS 7

Builds the Singularity RPMs from source for CentOS 7 using Docker [centos:7](https://hub.docker.com/_/centos/) image

### Build the image

Build the docker image

```
$ cd centos-7/
$ docker build -t singularity.rpm:latest .
```

### Run the image 

- Specify the version of Singularity you wish to build as the environment variable `SINGULARITY_VERSION` (default is `SINGULARITY_VERSION=2.5.1`).
- Specify the volume to which you'd like to save the resultant rpm files (maps to `/packages` of the container).


**Generate RPMs**:

```
$ docker run --rm \
	-e SINGULARITY_VERSION=2.5.1 \
	-v $(pwd)/rpms:/packages \
	singularity.rpm:latest
```

**Verify RPMs**:

```console
$ ls -lh $(pwd)/rpms/
total 2032
-rw-r--r--  1 xxxxx  xxxxx   262K May  9 08:01 singularity-2.5.1-1.el7.centos.x86_64.rpm
-rw-r--r--  1 xxxxx  xxxxx   493K May  9 08:01 singularity-debuginfo-2.5.1-1.el7.centos.x86_64.rpm
-rw-r--r--  1 xxxxx  xxxxx    69K May  9 08:01 singularity-devel-2.5.1-1.el7.centos.x86_64.rpm
-rw-r--r--  1 xxxxx  xxxxx   181K May  9 08:01 singularity-runtime-2.5.1-1.el7.centos.x86_64.rpm
```

## Ubuntu 16.04

Builds the Singularity DEB files from source for Ubuntu 16.04 (Xenial) using Docker [ubuntu:16.04](https://hub.docker.com/_/ubuntu/) image

### Build the image

Build the docker image

```
$ cd ubuntu-16.04/
$ docker build -t singularity.deb:latest .
```

### Run the image 

- Specify the version of Singularity you wish to build as the environment variable `SINGULARITY_VERSION` (default is `SINGULARITY_VERSION=2.5.1`).
- Specify the volume to which you'd like to save the resultant deb files (maps to `/packages` of the container).


**Generate DEB files**:

```
$ docker run --rm \
	-e SINGULARITY_VERSION=2.5.1 \
	-v $(pwd)/debs:/packages \
	singularity.deb:latest
```

**Verify DEB files**:

```console
$ ls -lh $(pwd)/debs/
total 664
-rw-r--r--  1 xxxxx  xxxxx   329K May  9 08:25 singularity-container_2.5.1_amd64.deb
```

## Test Singularity packages using Docker

Test the installation and ability to build and run a simple singularity image from: [https://github.com/GodloveD/lolcow](https://github.com/GodloveD/lolcow)

### CentOS 7

Share the generated rpm files to be installed with a new instance of a centos:7 docker container (directory `$(pwd)/rpms` is used in this example).

- **NOTE**: To use Singularity within a Docker container you must use the `--privileged` Docker option

```
$ docker run --rm -ti \
	-v $(pwd)/rpms:/rpms \
	--privileged \
	--name test-rpms \
	centos:7 /bin/bash
```

Install the RPMs from within the container

```
# yum -y localinstall \
	/rpms/singularity-runtime-2.5.1-1.el7.centos.x86_64.rpm \
	/rpms/singularity-devel-2.5.1-1.el7.centos.x86_64.rpm \
	/rpms/singularity-debuginfo-2.5.1-1.el7.centos.x86_64.rpm \
	/rpms/singularity-2.5.1-1.el7.centos.x86_64.rpm
```

- Should denote the following dependencies also being installed

    ```
    lzo
    squashfs-tools
    libarchive
    ```

Build the lolcow singularity image.

```
# singularity build lolcow.simg docker://godlovedc/lolcow
```

Run the lolcow image.

```console
# ./lolcow.simg
Singularity: action-suid (U=0,P=126)> USER=root, IMAGE='lolcow.simg', COMMAND='run'

 _________________________________________
/ You will gain money by a speculation or \
\ lottery.                                /
 -----------------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```


### Ubuntu 16.04

Share the generated deb files to be installed with a new instance of a ubuntu:16.04 docker container (directory `$(pwd)/debs` is used in this example).

- **NOTE**: To use Singularity within a Docker container you must use the `--privileged` Docker option

```
$ docker run --rm -ti \
	-v $(pwd)/debs:/debs \
	--privileged \
	--name test-debs \
	ubuntu:16.04 /bin/bash
```

Install the DEB files and prerequisites from within the container.

```
# apt-get update -qqq
# apt-get -y install \
	ca-certificates \
	python \
	squashfs-tools \
	libarchive13
# dpkg -i /debs/singularity-container_2.5.1-1_amd64.deb
```

Build the lolcow singularity image.

```
# singularity build lolcow.simg docker://godlovedc/lolcow
```

Run the lolcow image.

```console
# ./lolcow.simg
Singularity: action-suid (U=0,P=2834)> Non existent 'bind path' source: '/etc/localtime'

WARNING: Non existent 'bind path' source: '/etc/localtime'
Singularity: action-suid (U=0,P=2834)> USER=root, IMAGE='lolcow.simg', COMMAND='run'

 _________________________________
/ AWAKE! FEAR! FIRE! FOES! AWAKE! \
|                                 |
| FEAR! FIRE! FOES!               |
|                                 |
| AWAKE! AWAKE!                   |
|                                 |
\ -- J. R. R. Tolkien             /
 ---------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```


## Run from the host

Invoke the lolcow image from the host using `docker exec`

**CentOS 7**

Container `test-rpms`:

```console
$ docker exec test-rpms /lolcow.simg
 _________________________________________
/ Q: How many lawyers does it take to     \
| change a light bulb? A: Whereas the     |
| party of the first part, also known as  |
| "Lawyer", and the party of the second   |
| part, also known as "Light Bulb", do    |
| hereby and forthwith agree to a         |
| transaction wherein the party of the    |
| second part shall be removed from the   |
| current position as a result of failure |
| to perform previously agreed upon       |
| duties, i.e., the lighting,             |
| elucidation, and otherwise illumination |
| of the area ranging from the front      |
| (north) door, through the entryway,     |
| terminating at an area just inside the  |
| primary living area, demarcated by the  |
| beginning of the carpet, any spillover  |
| illumination being at the option of the |
| party of the second part and not        |
| required by the aforementioned          |
| agreement between the parties.          |
|                                         |
| The aforementioned removal transaction  |
| shall include, but not be limited to,   |
| the following. The party of the first   |
| part shall, with or without elevation   |
| at his option, by means of a chair,     |
| stepstool, ladder or any other means of |
| elevation, grasp the party of the       |
| second part and rotate the party of the |
| second part in a counter-clockwise      |
| direction, this point being tendered    |
| non-negotiable. Upon reaching a point   |
| where the party of the second part      |
| becomes fully detached from the         |
| receptacle, the party of the first part |
| shall have the option of disposing of   |
| the party of the second part in a       |
| manner consistent with all relevant and |
| applicable local, state and federal     |
| statutes. Once separation and disposal  |
| have been achieved, the party of the    |
| first part shall have the option of     |
| beginning installation. Aforesaid       |
| installation shall occur in a manner    |
| consistent with the reverse of the      |
| procedures described in step one of     |
| this self-same document, being careful  |
| to note that the rotation should occur  |
| in a clockwise direction, this point    |
| also being non-negotiable. The above    |
| described steps may be performed, at    |
| the option of the party of the first    |
| part, by any or all agents authorized   |
| by him, the objective being to produce  |
| the most possible revenue for the       |
\ Partnership.                            /
 -----------------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||

```

**Ubuntu 16.04**

Container `test-debs`:

```console
$ docker exec test-debs /lolcow.simg
WARNING: Non existent 'bind path' source: '/etc/localtime'
 _________________________________________
/ There is no character, howsoever good   \
| and fine, but it can be destroyed by    |
| ridicule, howsoever poor and witless.   |
| Observe the ass, for instance: his      |
| character is about perfect, he is the   |
| choicest spirit among all the humbler   |
| animals, yet see what ridicule has      |
| brought him to. Instead of feeling      |
| complimented when we are called an ass, |
| we are left in doubt.                   |
|                                         |
| -- Mark Twain, "Pudd'nhead Wilson's     |
\ Calendar"                               /
 -----------------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```
