This is a CLI tool to automate the release process of multiple software.  
A set of instructions is associated with each software, which the release process provides to execute
in order.

## Usage
### Adding a software
The first step is saving a software so instructions can be associated with it.
```
releaser add-software
            --name <software_name>
            --root <root_path>
            --dest <dest_path>
```

### Adding a release instruction
Instructions declare how releases should be managed.  
```
releaser add-instruction
            --name <instruction_name>
            --software <software_name>
```
Based on the implementation, all the required arguments will be asked immediately afterwards via
the standard input.
All instruction arguments can contain placeholders: specifically, the following ones are available:
- `${name}`
- `${root_path}`
- `${release_path}`

All placeholders are replaced with the actual values of the software which the instructions belong
to at runtime.

### Listing all software
To list all the saved software, along all their details and release instructions, use:
```
releaser list
```

### Releasing
To execute the release process of a software, the following command is used:
```
releaser release --software <software_name>
```

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
