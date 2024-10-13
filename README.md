This is a CLI tool to manage the release process of multiple software projects.  
A set of instructions is associated with each software, which the release process provides to execute in the order they were added.
## Usage
Whenever paths are required, paths with an ending slash (or backward slash for Windows) will be treated as directories, otherwise they'll be treated as files.   
All data is stored inside CSV files in the directory `.releaser` within user's home directory.
### Adding a software project
The first step is adding a software project so instructions can be associated with it.
```
releaser add-software --name <software_name> --root <root_path> --dest <dest_path>
```
### Adding a release instruction
Instructions declare how releases should be managed.  
```
releaser add-instruction --name <instruction_name> --software <software_name>
```
Based on the implementation, all the required arguments will be asked immediately afterwards via
the standard input. The available instructions are:
- `copy`: copies a file or a directory to the specified destination path
- `zip`: compresses only directories to the specified destination path

All instruction arguments can contain placeholders. The following ones are available:
- `${name}`
- `${root_path}`
- `${dest_path}`
- `${version}`, specified during release using `--version`

All placeholders are replaced with the actual values of the software which the instructions belong
to at runtime during the release process.
### Listing all software projects
To list all saved software projects, along with all their details and release instructions, use:
```
releaser list
```
### Releasing
To execute the release process of a software project, the following command is used:
```
releaser release --software <software_name> --version <version_string>
```
### Deleting a software project
This is pretty straightforward and also deletes all related instructions.
```
releaser delete-software <software_name>
```
### Example
This is a real world example to use the **releaser** tool.
```
releaser add-software --name my_software --root /home/ciro23/my_software/ --dest /home/ciro23/released_builds/{version}/
```
```
releaser add-instruction --software my_software --name copy
--------------------------------------------
Available placeholders:
- ${name} => 'my_software'
- ${root_path} => '/home/ciro23/my_software/'
- ${dest_path} => '/home/ciro23/released_builds/{version}/'
- ${version} => the specified version during release
--------------------------------------------

Enter the source path:
${root_path}build/

Enter the destination path:
${dest_path}
```
```
releaser add-instruction --software my_software --name zip
--------------------------------------------
Available placeholders:
- ${name} => 'my_software'
- ${root_path} => '/home/ciro23/my_software/'
- ${dest_path} => '/home/ciro23/released_builds/{version}/'
- ${version} => the specified version during release
--------------------------------------------

Enter the source path:
${root_path}build/

Enter the destination path:
${dest_path}${name}.zip
```
```
releaser list
```
```
releaser release --software my_software --version 1.0.0
```
## Unsupported actions
1. Instructions cannot be modified, except directly through the CSV files where they're stored.
2. Instructions are executed in the order they've been added, and it's not possible to update it, except directly through the CSV files where they're stored.
## Building from source
Generated classes are built using
```
dart run build_runner build
```
or
```
dart run build_runner watch
```
for continuous build after each change.
