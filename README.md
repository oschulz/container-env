# container-env (`cenv`)

`cenv` manages and runs lightweight containerized environments via
[Apptainer](https://apptainer.org) or
[Shifter](https://docs.nersc.gov/development/shifter).

Each cenv environment combines a container image with an environment-specific
user directory (mounted as `/user` in the container instance by default).
`cenv` also redirects various environment paths for Python, Julia, Node.js and
Rust to that user directory to isolate environments from each other, and
mounts the home directory to `/homedir` in container instances to allow
for site-independence of environments where absolute paths are unavoidable.

Environments live under `$CENV_BASE_DIR` (defaults to `~/.cenv`).

`cenv` is Linux-only.

## Installation

Install `cenv` as `~/.local/bin/cenv` (directly or via a symlink) and make sure
`~/.local/bin` is on your `PATH`:

```sh
ln -s /path/to/container-env/bin/cenv ~/.local/bin/cenv
```

`cenv` itself is just a shell script.

## Quick start

Create an environment from a container image and run it:

```sh
# Create an environment "myenv" from an Apptainer/Singularity image:
cenv --create myenv /path/to/image.sif

# With Shifter, associate it with a Docker image instead:
cenv --create myenv some/docker-image:tag

# Enter an interactive shell in the environment:
cenv myenv

# Run a single program inside the environment:
cenv myenv python some_program [args...]

# List the defined environments (use -v for paths):
cenv --list
```

Run `cenv --help` for the full list of commands, environment variables and
configuration files.

## Container instances (persistent sessions)

*Note: The following is currently limited to Apptainer and Singularity as
runtimes.*

Each `cenv myenv ...` run starts a separate container. A container instance
keeps running in the background instead, and any number of shells and
programs can connect to it. They share its mount, PID and IPC namespaces and
so can see and talk to each other — an interactive shell, a VS Code tunnel
server and an AI coding agent, for example. This is especially useful on
remote and batch nodes.

Instances are named `<cenv-name>/<session-name>`:

```sh
# Enter a shell in the instance "myenv/dev", starting it if it isn't running:
cenv --instance myenv/dev

# Run a program in it instead:
cenv --instance myenv/dev python some_program [args...]

# List running instances, optionally only those of "myenv":
cenv --instances [myenv]

# Stop the instance and everything running in it:
cenv --stop myenv/dev
```

Container image, bind mounts and other container options are fixed when an
instance starts — configuration changes only affect instances started
afterwards.

## Using `cenv` with VS Code

See [README-VSCode.md](README-VSCode.md) for how to use Visual Studio Code to
develop within `cenv` environments.

## Containment (isolated environments)

*Note: The following is currently limited to Apptainer as runtime.*

By default, `cenv` environments (run as container instances) mount and use the
user's `$HOME` directly (and in addition mount it as `/homedir`). Other OS
paths like `/tmp` are visible in container instances as well.

If stricter isolation of an environment is desired, e.g. for environments that
will run AI agents (e.g. for agentic coding), the Apptainer containment
feature should be used.

Create a `cenvrc` file in the cenv-environment directory
(`${CENV_BASE_DIR}/${CENV_NAME}/cenvrc`) that contains something like:

```sh
# Use a private home directory inside the environment instead of the host $HOME:
export CENV_HOME_DIR="${CENV_DIR}/homedir"

# Tell Apptainer to start "contained": don't auto-mount $HOME, /tmp, etc.;
# only explicitly bound paths are visible inside the container:
export APPTAINER_CONTAIN="1"

# Selectively bind in only the paths the workload actually needs:
export CENV_APPTAINER_OPTS="--bind /path/to/project:/path/to/project"
```
