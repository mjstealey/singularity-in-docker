# Singularity in Docker

Use [Docker](https://www.docker.com) to explore the various components of [Singularity](http://singularity.lbl.gov)

### Contents

1. [singularity-registry](singularity-registry) - Deploy a local Singularity registry to interact with
2. [singularity-packages](singularity-packages) - Build the RPM or DEB packages for running Singuarity on CentOS 7 or Ubuntu 16.04
3. [sregistry-cli](sregistry-cli) - Build/Use a container that runs both Singularity and sregistry-cli to interact with your local singualrity registry

 [Singularity](http://singularity.lbl.gov) | [Docker](https://www.docker.com) | [Singularity Registry](https://github.com/singularityhub/sregistry) 
 :----------: | :----: | :------------------: 
 <img width="50%" alt="Singularity" src="http://singularity.lbl.gov/images/logo/logo.svg"> | <img width="90%" alt="Docker" src="https://www.docker.com/sites/default/files/vertical.png"> | <img width="100%" alt="Singularity Registry" src="https://singularityhub.github.io/sregistry/assets/img/logo.png"> 

## References

Singularity: [http://singularity.lbl.gov](http://singularity.lbl.gov)

- Singularity enables users to have full control of their environment. Singularity containers can be used to package entire scientific workflows, software and libraries, and even data. This means that you don’t have to ask your cluster admin to install anything for you - you can put it in a Singularity container and run. Did you already invest in Docker? The Singularity software can import your Docker images without having Docker installed or being a superuser. Need to share your code? Put it in a Singularity container and your collaborator won’t have to go through the pain of installing missing dependencies. Do you need to run a different operating system entirely? You can “swap out” the operating system on your host for a different one within a Singularity container. As the user, you are in control of the extent to which your container interacts with its host. There can be seamless integration, or little to no communication at all. What does your workflow look like?

Singularity Hub: [https://www.singularity-hub.org](https://www.singularity-hub.org)

- Singularity Hub is a registry for scientific [linux containers](https://opensource.com/resources/what-are-linux-containers).
- **What is a Linux container?** A container image is an encapsulated, portable environment that is created to distribute a scientific analysis or a general function. Containers help with reproducibility of such content as they nicely package software and data dependencies, along with libraries that are needed. Thus, the core of Singularity Hub are these Singularity container images, and by way of being on Singularity Hub they can be easily built, updated, referenced with a url for a publication, and shared. This small guide will help you to get started building your containers using Singularity Hub and your Github repositories.

Singularity Registry: [https://github.com/singularityhub/sregistry](https://github.com/singularityhub/sregistry)

- Singularity Registry is a management and storage of Singularity images for an institution or user to deploy locally. It does not manage building, but serves endpoints to obtain and save containers. The Registry is expected to be available for use in the Fall.

Docker: [https://www.docker.com](https://www.docker.com)

- Docker is the company driving the container movement and the only container platform provider to address every application across the hybrid cloud. Today’s businesses are under pressure to digitally transform but are constrained by existing applications and infrastructure while rationalizing an increasingly diverse portfolio of clouds, datacenters and application architectures. Docker enables true independence between applications and infrastructure and developers and IT ops to unlock their potential and creates a model for better collaboration and innovation.
