# Using cenv with Visual Studio Code

Here's how to do remote development *inside* of a `cenv` container instances, using [Visual Studio Code](https://code.visualstudio.com/) on your local machine. This will make the remote VS-Code server instance at on the remote system(s) run inside the the container instance, so the container's file system will be fully visible to VS-Code.

VS code [doesn't natively support](https://github.com/microsoft/vscode-remote-release/issues/3066) non-Docker-like container runtimes yet, the workaround described below works well in practice though. The procedure is a bit involved, but the result is worth the effort.

Note: An alternative could be to use [Visual Studio Code Tunnels](https://code.visualstudio.com/docs/remote/tunnels), by starting the VS-Code server inside of a `cenv` instance. It may not be possible to run multiple VS-Code server instances in different `cenv` environments on one machine in parallel, though. The procedure described below uses VS-Code SSH instead of VS-Code Tunnels and *does* support parallel remote VS-code sessions in different `cenv` environments on the same remote machine.


### Step 1

Ensure that `cenv` is installed as `~/.local/bin/cenv` (directly or via symlink) on the remote system.


### Step 2

In your `"$HOME/.ssh/config"` on your *local system*, add something like

```
Host mycenv~*
  RemoteCommand ~/.local/bin/cenv mycenv
  RequestTTY yes

Host othercenv~*
  RemoteCommand ~/.local/bin/cenv othercenv
  RequestTTY yes

Host somehost mycenv~somehost othercenv~somehost
  HostName somehost.some.where

Host somehost mycenv~somehost othercenv~somehost
  HostName somehost.some.where
```

Test whether this works by running `ssh mycenv~somehost` *on your local system*. This should drop you into an SSH
session running inside of an instance of the `mycenv` cenv-environment on host "somehost.some.where"


### Step 3

In your VS-Code settings *on your local system*, set

```
"remote.SSH.enableRemoteCommand": true
```

### Step 4 (Shifter-only)

This step is optional if you use Apptainer, it is only required with Shifter as the container runtime.

Since VS-Code reuses remote server instances, the above is not sufficient to run multiple container images on the same
remote host at the same time. To get *separate* (per container image) VS-Code server instances on the *same host*, add
something like this to your VS-Code settings *on your local system*:

```
"remote.SSH.serverInstallPath": {
  "mycenv~somehost": "~/.vscode-container/mycenv",
  "mycenv~otherhost": "~/.vscode-container/mycenv",
  "othercenv~somehost": "~/.vscode-container/othercenv",
  "othercenv~otherhost": "~/.vscode-container/othercenv"
}
```

When using Apptainer, cenv will automatically try to bind-mount `/user/.vscode-server` to `$HOME/.vscode-server`, so setting `remote.SSH.serverInstallPath` in VS-Code is not required.


### Step 5

Connect to `somehost` from with VS-Code *running your local system*:

`F1 > "Connect to Host" > "mycenv~somehost”` should now start a remote VS-Code session with the VS-Code server
component running inside a cenv container instance on `somehost`. The same for `"othercenv~somehost"`,
`"mycenv~otherhost"` and `"othercenv~otherhost"`.


### Tips and tricks

If things don't work, try `"Kill server on remote"` from VS-Code and reconnect.

You can also try starting over from scratch with brute force: Close the VS-Code remote connection. Then, from an
external terminal, kill the remote VS-Code server instance (and everything else):

```shell
ssh somehost
pkill -9 node
```

(This will kill *all* Node.jl processes you own on the remote host.)

Remove the ~/.vscode-server directory in your home directory on the remote system.
