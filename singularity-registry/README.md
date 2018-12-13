# Singularity Registry (Hub)

### What is Singularity Registry

Singularity Registry is a management and storage of Singularity images for an institution or user to deploy locally. It does not manage building, but serves endpoints to obtain and save containers. The Registry is expected to be available for use in the Fall.

Github: [https://github.com/singularityhub/sregistry](https://github.com/singularityhub/sregistry)

## Usage

The scripts provided here make use of the [singularityhub/sregistry](https://github.com/singularityhub/sregistry) source code and alter the deployment of it to be run in docker locally.

The code has been tested in macOS and Linux on CentOS 7. Configuration choices may be particular depending on platform, and whether or not the hostname is DNS resolvable.


### Configuration

The `deploy-sregistry.sh` script makes the assumption that [installation dependencies](https://singularityhub.github.io/sregistry/install) are satisfied on the local machine.

A new version of [docker-compose.yml](docker-compose.yml) is provided to:

- Better define container names in a predictable way
- Run nginx on port `8080` of the host instead of `80`

The values of some variables from `settings.py` and `config.py` are defined in the [sregistry.env](sregistry.env) file and can be modified by the user prior to running the [deploy-sregistry.sh](deploy-sregistry.sh) script. This is done to better control what is being deployed locally.

- Details on the settings can be found at [https://singularityhub.github.io/sregistry/install](https://singularityhub.github.io/sregistry/install)

Contents of `sregistry.env`:

```bash
### sregistry.env ###

### sregistry/shub/settings/secrets.py
export SECRET_KEY='+y06=f1kh__nzz=@$gkqty6-auygg54@ucw(!f80r2rzhe!zo_'

### sregistry/shub/settings/config.py

# AUTHENTICATION
export ENABLE_GOOGLE_AUTH='False'
export ENABLE_TWITTER_AUTH='False'
export ENABLE_GITHUB_AUTH='False'
export ENABLE_GITLAB_AUTH='False'

# DOMAIN NAMES
export DOMAIN_NAME='http://nginx'
export DOMAIN_NAME_HTTP='http://nginx'
export ADMINS_USER='mjstealey'
export ADMINS_MAIL='mjstealey@gmail.com'
export HELP_CONTACT_EMAIL='mjstealey@gmail.com'
export HELP_INSTITUTION_SITE='https://mjstealey.com'
export REGISTRY_NAME='mjstealey Singularity Registry'
export REGISTRY_URI='mjstealey'

# PERMISSIONS
# Allow users to create public collections
export USER_COLLECTIONS='True'
# Should registries by default be private, with no option for public?
export PRIVATE_ONLY='False'
# Should the default for a new registry be private or public?
export DEFAULT_PRIVATE='False'

```

- **NOTE**: The `DOMAIN_NAME` and `DOMAIN_NAME_HTTP` are both set to `http://nginx` in this example due to the `nginx` container being the http gatekeeper from docker's point of view. The `nginx` container translates to a docker based address on the host, for example `172.17.0.6`. 

  - If the hostname is DNS resolvable, then that hostname should be used in place of of `http://nginx`

- **NOTE**: The included `docker-compose.yml` file will define a mapping from the host to the nginx container for web browser interaction.

  - `localhost:8080` maps to `nginx:80`

### Running

Execute the `deploy-sregistry.sh` from the `singularity-registry` directory.

```
./deploy-sregistry.sh
```

On completion you should have five containers running as detailed below.

```
$ docker ps
CONTAINER ID        IMAGE                     COMMAND                  CREATED             STATUS              PORTS                           NAMES
eacb058a9282        vanessa/sregistry_nginx   "nginx -g 'daemon of…"   2 minutes ago       Up 2 minutes        443/tcp, 0.0.0.0:8080->80/tcp   nginx
d2ac37c97d36        vanessa/sregistry         "celery worker -A sh…"   7 minutes ago       Up 2 minutes        3031/tcp                        worker
0de9cb4ed873        vanessa/sregistry         "/bin/sh -c /code/ru…"   7 minutes ago       Up 2 minutes        3031/tcp                        uwsgi
723f71b6aa68        postgres                  "docker-entrypoint.s…"   7 minutes ago       Up 2 minutes        5432/tcp                        db
cb561d82e323        redis:latest              "docker-entrypoint.s…"   7 minutes ago       Up 2 minutes        0.0.0.0:6379->6379/tcp          redis
```

After a few moments your local Singularity Registry will be accessible at [http://localhost:8080/](http://localhost:8080/)

<img width="80%" alt="Running sregistry" src="https://user-images.githubusercontent.com/5332509/37221094-b6b68f50-2396-11e8-8820-2b91323bc06d.png">

## Adding users

Since the sregistry code is [Django](https://www.djangoproject.com) based it is possible to add users via the `manage.py` interface from the `uwsgi` container.

- If we were to try using the **Login** link now, it would be blank since no third part OAuth clients were configured. This document will not cover adding users from OAuth services and is left for the user to research on their own 

To see what options are available from `manage.py`, run `docker exec uwsgi python manage.py help`

We'll be interested in the following options:

```
$ docker exec uwsgi python manage.py help

Type 'manage.py help <subcommand>' for help on a specific subcommand.

Available subcommands:

[auth]
    changepassword
    createsuperuser     <-- This
...
[users]
    add_admin           <-- This
    add_superuser       <-- and This
    remove_admin
    remove_superuser
```

Review the official documentation for [Creating Accounts](https://singularityhub.github.io/sregistry/setup#create-accounts).

Create a superuser account, provide **admin** and **superuser** access

- **admin**: you can push images, but not have significant impact on the registry application.
- **superuser**: you are an admin that can do anything, you have all permissions.

### createsuperuser

```console
$ docker exec -ti uwsgi \
  python manage.py createsuperuser --username mjstealey
Email address: mjstealey@gmail.com
Password: ********
Password (again): ********
Superuser created successfully.
```

### add_admin

```
$ docker exec -ti uwsgi \
  python manage.py add_admin --username mjstealey
DEBUG Username: mjstealey
CommandError: This user can already manage and build.
```
- NOTE: An error was generated denoting that the user **mjstealey** already has **admin** rights. This is because we had initially declared that username/email combination to be an admin in `config.py` as `ADMINS = (( 'mjstealey', 'mjstealey@gmail.com'),)`

### add_superuser

```
$ docker exec -ti uwsgi \
  python manage.py add_superuser --username mjstealey
DEBUG Username: mjstealey
DEBUG mjstealey is now a superuser.
```

At this time you will be able to log into the admin panel of the regisistry using your username and password.

Login: [http://localhost:8080/admin](http://localhost:8080/admin/login/?next=/admin/)

<img width="80%" alt="Admin login" src="https://user-images.githubusercontent.com/5332509/37222587-b95d33b2-239b-11e8-9a48-e8781c310e4b.png">

<img width="80%" alt="Admin panel" src="https://user-images.githubusercontent.com/5332509/37222571-a944b040-239b-11e8-98bd-210581ad0eb7.png">

Choose to **View Site** from the upper right portion of the page and notice that you'll now have an icon and menu options from your user dropdown.

<img width="80%" alt="User dropdown" src="https://user-images.githubusercontent.com/5332509/37222698-0b8ff3f4-239c-11e8-9631-5cfc51ed4894.png">

We'll want to capture the **Token** information from the user profile so that we can use it to interact with the regsitry externally using the [sregistry-cli commands](https://github.com/singularityhub/sregistry-cli/tree/master/docs/getting-started#commands).

<img width="80%" alt="Get Token" src="https://user-images.githubusercontent.com/5332509/37222786-4e292c9e-239c-11e8-9d40-6557bc43f62f.png">

Token (whitespace added for readablity):

```json
{ 
  "registry": 
  { 
    "token": "6bc217c3afc17a3eb6056fd223937585964dd824", 
    "username": "mjstealey", 
    "base": "http://nginx" 
  }
}
```

See section on **sregistry-cli** for example usage.


The singularity registry also provides a RESTful API. This can be in interacted with from the site at [http://localhost:8080/api/](http://localhost:8080/api/)

<img width="80%" alt="RESTful API" src="https://user-images.githubusercontent.com/5332509/37227923-d15b82be-23ac-11e8-9e93-160994478b84.png">

## Not Covered

This project is meant to cover the basics of standing up a Singularity Registry and further configuration is left to the user

- OAuth authentication: See [Authentication Secrets](https://singularityhub.github.io/sregistry/install) section
- SSL: See [SSL](https://singularityhub.github.io/sregistry/install) section
- Setup beyond basics: See [Setup](https://singularityhub.github.io/sregistry/setup) section
