# Jujutsu workspace hub

This repository is a lightweight coordination hub for managing Jujutsu
workspaces for any Git repository. The `ws` branch stores the hub instructions
and workspace-management tools; it is not the branch for application or
project changes. Keep this guidance generic so the `ws` branch can be used in
different repositories.

## Layout and purpose

- The hub root contains management files and Jujutsu metadata, not a checkout
  of the project being worked on.
- `jj-ws/` contains local working directories created as Jujutsu workspaces.
  It is ignored by the hub, so workspace contents are not added to the hub
  branch.
- Each workspace is backed by the same Jujutsu repository and can be based on
  an appropriate revision or branch from the Git repository.
- Use Jujutsu commands for workspace and change management. Do not create
  nested Git clones inside `jj-ws/`.

## Starting an isolated work session

Agents must create a fresh workspace when beginning a new, isolated work
session. Do not start session work in the hub root or reuse another session's
workspace.

From the hub root, create a workspace with a unique, descriptive name and
choose the revision appropriate to the task:

```sh
task ws:add name=<session-name> rev=<base-revision>
cd jj-ws/<session-name>
```

The `rev` argument is optional; when omitted, the Taskfile's configured
default revision is used. Check `jj workspace list` or `task ws:list` if you
need to inspect existing workspaces. Avoid names that collide with an existing
workspace.

Do the task from inside the new workspace. Keep changes isolated there; do
not alter hub management files unless the task specifically concerns the hub.

## Finishing and cleanup

Before removing a workspace:

1. Review its changes and make sure needed work is committed or otherwise
   preserved. Do not discard uncommitted or unshared work.
2. Return to the hub root (or another workspace), not the workspace being
   removed.
3. Forget the workspace and remove its directory:

   ```sh
   task ws:rm name=<session-name>
   ```

Clean up the workspace when the isolated session is complete. If its work is
unfinished or cannot safely be removed, preserve it and report that cleanup
was deferred rather than deleting valuable changes.

## Hub maintenance

- `task ws:list` lists active workspaces.
- `task ws:add name=<name> [rev=<revision>]` creates one under `jj-ws/`.
- `task ws:rm name=<name>` forgets and deletes the named workspace.
- `task ws:rm:all` is destructive; do not use it for routine cleanup.
- Keep `jj-ws/` ignored in the hub.
- The `ws` branch is intended to carry only generic hub tooling and guidance.
  Do not put project-specific source code, names, or assumptions on it.
