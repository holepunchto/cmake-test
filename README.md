# cmake-test

```
npm i cmake-test
```

```cmake
find_package(cmake-test REQUIRED PATHS node_modules/cmake-test)
```

## API

#### `add_test_executable(<target> <sources>... [LINK <libraries>...] [ARGS <arguments>...] [TIMEOUT <seconds>] [WORKING_DIRECTORY <path>] [LABELS <labels>...] [PROPERTIES <properties>...])`

#### `add_test_executables(<sources>... [PREFIX <prefix>] [BASE_DIRECTORY <path>] [DISABLED <sources>...] [LINK <libraries>...] [ARGS <arguments>...] [TIMEOUT <seconds>] [WORKING_DIRECTORY <path>] [LABELS <labels>...] [PROPERTIES <properties>...])`

Adds a test executable for each source, named after its path relative to `BASE_DIRECTORY` without the extension. `BASE_DIRECTORY` defaults to the current source directory, and relative sources are resolved against it. `DISABLED` lists sources whose tests are built but not run. Each must be one of the sources.

#### `add_test_script(<name> <file> RUNNER <command>... [ARGS <arguments>...] [TIMEOUT <seconds>] [WORKING_DIRECTORY <path>] [LABELS <labels>...] [PROPERTIES <properties>...])`

Adds a test that runs `<file>` with `RUNNER`, an executable target or a command followed by its arguments. The test runs `<command>... <file> <arguments>...`, with the absolute path of `<file>`.

#### `add_test_scripts(<files>... RUNNER <command>... [PREFIX <prefix>] [BASE_DIRECTORY <path>] [DISABLED <files>...] [ARGS <arguments>...] [TIMEOUT <seconds>] [WORKING_DIRECTORY <path>] [LABELS <labels>...] [PROPERTIES <properties>...])`

Adds a script test for each file, named after its path relative to `BASE_DIRECTORY`, including the extension. `BASE_DIRECTORY` and `DISABLED` work like those of `add_test_executables()`.

#### `add_test_subdirectory(<source_dir> [<binary_dir>] [EXCLUDE_FROM_ALL] [SYSTEM])`

Enables testing and adds the subdirectory, but only when the current project is the top-level project.

## License

Apache-2.0
