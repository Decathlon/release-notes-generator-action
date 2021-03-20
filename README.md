<h1>
  <p align="center">
    Release Note Generator GitHub Action
  </p>
</h1>
<p align="center">
  This repository provides a GitHub action to <strong>automatically create a release notes</strong> when a milestone is closed.
</p>

**Table of Contents**
  - [Common usage](#common-usage)
  - [Why?](#why)
  - [Startup](#startup)
    - [Use GitHub action](#use-github-action)
      - [Settings for v2.0.0+ release](#settings-for-v200-release)
      - [NOTE](#note)
      - [Result illustration](#result-illustration)
    - [Configure output folder](#configure-output-folder)
    - [Custom output release file](#custom-output-release-file)
      - [Prefixed name using v2.0.0+](#prefixed-name-using-v200)
    - [Use Milestone title](#use-milestone-title)
      - [Prefixed name using v2.0.0+](#prefixed-name-using-v200-1)
      - [Result illustration](#result-illustration-1)
  - [How to use the generated file](#how-to-use-the-generated-file)

## Common usage

Each time a milestone is closed, this GitHub action scans its attached issues and pull request, and automatically generates a wonderful release note.  

_The action uses [Spring.io changelog generator](https://github.com/spring-io/github-changelog-generator) tool._

<p align="center">
  <img src="https://github.com/Decathlon/release-notes-generator-action/raw/master/images/release_notes.png" alt="Result illustration"/>
<p>

## Why?

Why aren't we simply automating the release creation and push the release notes there?  
We think in some cases it is better to keep release notes separated from the release process... yeah, maybe the right name is not release notes anymore. :) Taking as example a continuous deployment project: __anytime you push to the repository, a new version of the application is built and pushed in production.__ And so, a new release is created to complete the process; a release with a **single** feature inside.  
We think it is not a good idea to push to 'users' a new release notes message every time you generate a changes in the source code (let us say 10 times a day?).  
It may be a better way to communicate only once every week or once the sprint is over, which gives you a clearer and complete release notes containing the aggregated information pushed in production within the last sprint (or any days).

## Startup

### Use GitHub action

#### Settings for v2.0.0+ release

Create a file into your root project directory: `.github/workflows/release-notes.yml`:
```yaml
# Trigger the workflow on milestone events
on: 
  milestone:
    types: [closed]
name: Milestone Closure
jobs:
  create-release-notes:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - name: Create Release Notes
      uses: docker://decathlon/release-notes-generator-action:2.0.1
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        OUTPUT_FOLDER: temp_release_notes
        USE_MILESTONE_TITLE: "true"
```

#### Settings for workflow_dispatch
Since the release 3.1.0 the action supports to trigger it via the (GitHub workflow_dispatch)[https://github.blog/changelog/2020-07-06-github-actions-manual-triggers-with-workflow_dispatch/] allowing to manually trigger an action workflow.
To use it you should add a dispatch configuration in your action, like the following.
```yaml
on:
  milestone:
    types: [closed]
  workflow_dispatch:
    inputs:
      milestoneId:
        description: 'Milestone ID'     
        required: true
        default: '1'
```
It is important to keep the `milestoneId` variable name which is used inside the Action itself.
With the configuration in the example the action is triggered both for milestone closure and workflow_dispatch.

#### NOTE
It is important to add the *GITHUB_TOKEN* secret because the action needs to access to your repository Milestone/Issues information using the GitHub API.

As we filtered on *milestone* the action will execute anytime an event occurs on your repository milestones.

#### Result illustration

<p align="center">
  <img src="https://raw.githubusercontent.com/Decathlon/release-notes-generator-action/master/images/actions_log.png" alt="Result illustration"/>
<p>


The action is then filtered on *closed* events. All other events on the milestones will only log an action execution but the release notes won't be created.

```console
### STARTED Create Release Notes 14:25:34Z
[...]
Getting Action Information
Release note generation skipped because action was: opened

### SUCCEEDED Create Release Notes 14:25:55Z (21.262s)
```

```console
### STARTED Create Release Notes 14:25:41Z
[...]
Getting Action Information

  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::        (v2.1.0.RELEASE)

2019-04-14 14:25:57.901  INFO 125 --- [           main] io.spring.releasenotes.Application       : Starting Application v0.0.2 on 5cbc3fcc29cd with PID 125 (/github-release-notes-generator.jar started by root in /github/workspace)
2019-04-14 14:25:57.922  INFO 125 --- [           main] io.spring.releasenotes.Application       : No active profile set, falling back to default profiles: default
2019-04-14 14:26:00.905  INFO 125 --- [           main] io.spring.releasenotes.Application       : Started Application in 4.178 seconds (JVM running for 5.345)
## :star: New Features

- test 2 [#2](https://github.com/Decathlon/test/issues/2)

### SUCCEEDED Create Release Notes 14:26:07Z (26.262s)
```

### Configure output folder
By default the release file is created into the Docker home folder. If you want you can specify a custom folder for your file creation via the `OUTPUT_FOLDER` environment variable.

### Custom output release file
By default the output is created into *release_file.md* file. You can control the output name using environment variables in your action.

#### Prefixed name using v2.0.0+
```YAML
- name: Create Release Notes
  uses: docker://decathlon/release-notes-generator-action:2.0.1
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    FILENAME_PREFIX: MyMilestone
```

The output filename will be `MyMilestone_2` (if the milestone id is 2).

#### Filename using v2.0.0+
```YAML
- name: Create Release Notes
  uses: docker://decathlon/release-notes-generator-action:2.0.1
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    FILENAME: ProvidedFilename
```

The output filename will be `ProvidedFilename.md`. This can be mixed up with the `FILENAME_PREFIX`.

### Use Milestone title
Providing the `USE_MILESTONE_TITLE` environment variable which allow you to switch the name to the Milestone title instead of providing a *static* one.
The title will be modified replacing spaces with underscore '_' char. This will be overridden by `FILENAME`.

#### Prefixed name using v2.0.0+

```YAML
- name: Create Release Notes
  uses: docker://decathlon/release-notes-generator-action:2.0.1
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    USE_MILESTONE_TITLE: "true"
```

#### Result illustration
```console
[...]
Creating release notes for Milestone 1 into the Sprint_10.md file
[...]
### SUCCEEDED Create Release Notes 15:53:53Z (15.913s)
```

## Section configuration
You can manage the sections and how they are used by the release generator, creating the `.github/release-notes.yml` file in the repository where you activate the action.
An example of file content (you can find detailed information directly on the [Spring repository](https://github.com/spring-io/github-changelog-generator#customizing-sections))
```
changelog:
  sections:
  - title: "Enhancements"
    labels: ["new"]
  - title: "Bugs"
    labels: ["fix"]
```
In the sections list you can configure each section with an emoji and a list of labels to take care of for this section.

## How to use the generated file
The idea is to keep the control about what to do with the release notes file.  
So simply link a new action and: send it by mail, push it on your website, on the github wiki, ...

Personally, in some of our projects, we are pushing the release note as new GitHub wiki page using the [Wiki page creator action](https://github.com/Decathlon/wiki-page-creator-action).
