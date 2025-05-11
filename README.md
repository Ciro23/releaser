## Introduction

This is a CLI tool to manage the release process of multiple software projects.  
A set of instructions is associated with each software, which the release process provides to execute in the order they were added.

For example, when releasing a new software's version, you may want to zip the source code and copy the compiled executable and move both to a certain directory, or run other shell scripts.  
This tool helps you automating all these boring steps.

## Usage

Whenever paths are required, paths with an ending slash (or backward slash for Windows) will be treated as directories, otherwise they'll be treated as files.  
All data is stored inside a SQLite database stored in `~/.releaser/releaser.db` (`~` is the user's home directory).

### Adding a software project

The first step is adding a software project so instructions can be associated with it.

```shell
releaser add-software --name <software_name> --root <root_path> --dest <dest_path>
```

### Adding a release instruction

Instructions declare how releases should be managed.

```shell
releaser add-instruction --name <instruction_name> --software <software_name>
```

Based on the implementation, all the required arguments will be asked immediately afterwards via
the standard input. The available instructions are:

- `copy`: copies a file or a directory to the specified destination path (cross-platform compatible).
- `zip`: compresses only directories to the specified destination path (cross-platform compatible).
- `shell`: runs a shell script on the user's default shell (_Bash_, _Zsh_, _PowerShell_, etc.).

All instruction arguments can contain placeholders. The following ones are available:

- `${name}`
- `${root_path}`
- `${dest_path}`
- `${version}`, specified during release using `--version`

All placeholders are replaced with their actual values at runtime during the release process.

### Listing all software projects

To list all saved software projects, along with all their details and release instructions, use:

```shell
releaser list
```

### Editing a software

If you need to change the value of a software's properties, you can use:

```shell
releaser edit-software --software my_software --name <new_software_name> --root <new_root_path> --dest <new_dest_path>
```

You can specify just what you need to change. For example, if you only need to update the name, you can omit both `--root` and `--dest`.

### Releasing

To execute the release process of a software project, the following command is used:

```shell
releaser release --software <software_name> --version <version_string>
```

### Deleting a software project

This is pretty straightforward and also deletes all related instructions.

```shell
releaser delete-software --software <software_name>
```

### Example

This is a real world example to use the **releaser** tool.

```shell
releaser add-software --name my_software --root /home/ciro23/my_software/ --dest /home/ciro23/release_builds/
```

```
# Copy the executable
releaser add-instruction --software my_software --name copy
--------------------------------------------
Available placeholders:
- ${name} => 'my_software'
- ${root_path} => '/home/ciro23/my_software/'
- ${dest_path} => '/home/ciro23/release_builds/'
- ${version} => the specified version during release
--------------------------------------------

Enter the source path:
${root_path}build/executable

Enter the destination path (non-existent directories are created automatically):
${dest_path}${name}/${version}/
```

```
# Zip the source code
releaser add-instruction --software my_software --name zip
--------------------------------------------
Available placeholders:
- ${name} => 'my_software'
- ${root_path} => '/home/ciro23/my_software/'
- ${dest_path} => '/home/ciro23/release_builds/'
- ${version} => the specified version during release
--------------------------------------------

Enter the source path:
${root_path}

Enter the destination path (non-existent directories are created automatically):
${dest_path}${name}/${version}/${name}-${version}.zip
```

```
# Create source code tarball
releaser add-instruction --software my_software --name shell
--------------------------------------------
Available placeholders:
- ${name} => 'my_software'
- ${root_path} => '/home/ciro23/my_software/'
- ${dest_path} => '/home/ciro23/release_builds/'
- ${version} => the specified version during release
--------------------------------------------

Enter the shell script:
tar -czf ${dest_path}${name}/${version}/${name}-${version}.tar.gz -C ${root_path} .
```

```shell
# Verify the software and its instruction were created successfully
releaser list
```

```shell
# Run software's instructions
releaser release --software my_software --version 1.0.0
```

## Unsupported actions

1. Instructions cannot be modified, except directly through the SQLite database where they're stored.
2. Instructions are executed in the order they've been added, and it's not possible to update it, except directly through the SQLite database where they're stored.

## Building from source

Generated classes are built using

```shell
dart run build_runner build
```

or

```shell
dart run build_runner watch
```

for continuous build after each change.
