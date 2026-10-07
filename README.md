Jujutsu workspace environment

The Core Problem


By default, cloning a Git repository with jjcreates a working directory containing all the files of the default branch. If your goal is to exclusively use lightweight, isolated jjworkspaces for context-switching, this default directory becomes redundant "dead weight." Furthermore, standard clones often expose a local .git directory, cluttering your workspace if you intend to interact solely with jj.


The Solution: Headless Coordinator Layout


This setup establishes a single, central directory called the Headless Hub. This directory:

1. Contains zero source filesfrom your codebase.
2. Houses the hidden metadata (.jj), linking your local setup to the remote Git repository.
3. Hosts utility tools(like a Taskfile) to automate project management.
4. Is completely disconnected from your main project history(rooted at root()), allowing you to commit and push your helper tools to a dedicated wsbranch without polluting production history.

All actual development happens inside a dedicated sub-directory (jj-ws/), where workspaces are spun up and torn down dynamically.

```
my-project-hub/            <-- The Headless Hub (tracked on branch 'ws')
├── .jj/                    <-- Hidden jj & Git metadata
├── .gitignore              <-- Prevents workspaces from being tracked
├── Taskfile.yaml           <-- Automation for workspace lifecycle
└── jj-ws/                  <-- IGNORED BY HUB. Holds active codebases
    ├── feature-alpha/      <-- Independent jj workspace (e.g., tracking main)
    └── hotfix-security/    <-- Independent jj workspace (e.g., tracking v1.2)

```

---

Step-by-Step Implementation Guide


Step 1: Clone without Local Git Clutter


We use the --no-colocateflag to ensure that the Git backing store is safely encapsulated deep inside the .jjdirectory structure, completely out of sight.

```
jj git clone --no-colocate <your-repository-git-url> my-project-hub
cd my-project-hub

```
- Reasoning:Prevents local Git configuration files from mixing with your project root, ensuring a 100% pure jjexperience.

Step 2: Empty the Root Directory via root()


When cloned, jjautomatically checks out the default branch. We immediately move our working copy to an entirely blank canvas by creating a new change off of root().

```
jj new 'root()'

```
- Reasoning:In jj, root()(or the all-zeros ID) represents the absolute beginning of time before any files exist. Checking this out instantly safely removes all project source files from the directory, leaving it entirely empty.

Step 3: Establish Workspace Isolation


We need to ensure that the workspaces we create later inside this directory don't accidentally get treated as untracked junk files by the Hub.

```
echo "jj-ws/" > .gitignore

```
- Reasoning:This keeps the jj-ws/directory strictly local to this machine. jjinside the Hub will ignore everything inside it, while the workspaces created inside it will remain fully functional and autonomous.

Step 4: Create the Workspace Automation Manager


Create a Taskfile.yamlin the root of my-project-hub. This file contains shortcuts to quickly spin up, track, and tear down coding environments.

```
version: '3'

tasks:
  add:
    desc: Create a new workspace inside the hub. Usage -> task add name=feature-x [rev=main]
    vars:
      REV: '{{default "main" .rev}}'
    cmds:
      - jj workspace add jj-ws/{{.name}} -r {{.REV}}
      - echo "Workspace '{{.name}}' created at jj-ws/{{.name}} tracking '{{.REV}}'"

  rm:
    desc: Safety-remove a workspace from jj tracking and disk. Usage -> task rm name=feature-x
    cmds:
      - jj workspace forget jj-ws/{{.name}}
      - rm -rf jj-ws/{{.name}}
      - echo "Workspace '{{.name}}' removed."

  list:
    desc: List all active jj workspaces
    cmds:
      - jj workspace list

```

- Reasoning:Managing nested workspace paths manually can be tedious. A Taskfile standardizes the paths (jj-ws/<name>) and ensures that workspace forgetand OS file deletion happen safely in tandem.

Step 5: Publish the Environment to a Dedicated Branch


Now, we save this entire automation environment to a dedicated wsbranch and push it to the remote Git server.

```
# Track our management tools
jj track Taskfile.yaml
jj track .gitignore

# Describe the commit
jj describe -m "infra: setup headless hub environment with workspace automation"

# Create and bind the 'ws' branch to our current headless commit
jj branch set ws -r @

# Push the branch to your Git remote
jj git push --branch ws

```
- Reasoning:Because this commit is rooted at root(), it has no shared historywith your production code (main, develop, etc.). It exists as a completely parallel, lightweight infrastructure branch. Anyone else on your team can now clone this exact DevOps environment instantly.
---

Daily Usage Workflow


Once this is configured, you rarely touch the root hub directory except to execute tasks.


To Start a New Feature:

```
task add name=billing-fix rev=main
cd jj-ws/billing-fix
# You are now in a pure jj ecosystem. Write code, amend, split, and merge freely.

```

To Delete a Feature When Done:

```
# Move back to the hub root directory
cd /path/to/my-project-hub

# Purge the workspace completely
task rm name=billing-fix

```

Onboarding a New Machine / Colleague:


To spin up this exact environment anywhere else:

```
jj git clone --no-colocate <repo-url> --branch ws my-project-hub
cd my-project-hub
# The directory is already empty, holding only your Taskfile! 
task add name=dev rev=main

```

Would you like to extend the Taskfile automationto include tasks for fetching upstream updatesacross all workspaces, or configuring automatic branch naming schemasfor your feature workspaces?
