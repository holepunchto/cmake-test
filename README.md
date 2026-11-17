# cmake-test

```
npm i cmake-test
```

```cmake
find_package(cmake-test REQUIRED PATHS node_modules/cmake-test)
```

## API

#### `add_test_executable(<target> <sources>... [LINK <libraries>...] [EXPORTS [<symbols>...]] [ARGS <arguments>...] [TIMEOUT <seconds>] [WORKING_DIRECTORY <path>] [LABELS <labels>...] [PROPERTIES <properties>...])`

Adds a test executable built from `<sources>`. `LINK` entries of the form `<package>::<TYPE>` link `<package>::shared` when it exists, so that the exports of the library are tested too, and `<package>::static` otherwise, such as on platforms without shared libraries. To let code that the test loads at runtime resolve functions defined by the test, list the symbols to export with `EXPORTS`. Other symbols are not exported, and each listed symbol must be defined by the test. A lone `EXPORTS`, without any symbols, exports every symbol of the test executable instead.

#### `add_test_executables(<sources>... [PREFIX <prefix>] [BASE_DIRECTORY <path>] [DISABLED <sources>...] [LINK <libraries>...] [EXPORTS [<symbols>...]] [ARGS <arguments>...] [TIMEOUT <seconds>] [WORKING_DIRECTORY <path>] [LABELS <labels>...] [PROPERTIES <properties>...])`

Adds a test executable for each source, named after its path relative to `BASE_DIRECTORY` without the extension. `BASE_DIRECTORY` defaults to the current source directory, and relative sources are resolved against it. `DISABLED` lists sources whose tests are built but not run. Each must be one of the sources.

#### `add_test_script(<name> <file> RUNNER <command>... [OPTIONAL] [ARGS <arguments>...] [TIMEOUT <seconds>] [WORKING_DIRECTORY <path>] [LABELS <labels>...] [PROPERTIES <properties>...])`

Adds a test that runs `<file>` with `RUNNER`, an executable target or a command followed by its arguments. The test runs `<command>... <file> <arguments>...`, with the absolute path of `<file>`. With `OPTIONAL`, the test is only added if `<command>` exists, as a target, a file, or a program on the `PATH`, such as an executable that isn't built on every platform.

#### `add_test_scripts(<files>... RUNNER <command>... [OPTIONAL] [PREFIX <prefix>] [BASE_DIRECTORY <path>] [DISABLED <files>...] [ARGS <arguments>...] [TIMEOUT <seconds>] [WORKING_DIRECTORY <path>] [LABELS <labels>...] [PROPERTIES <properties>...])`

Adds a script test for each file, named after its path relative to `BASE_DIRECTORY`, including the extension. `BASE_DIRECTORY` and `DISABLED` work like those of `add_test_executables()`.

#### `add_test_subdirectory(<source_dir> [<binary_dir>] [EXCLUDE_FROM_ALL] [SYSTEM])`

Enables testing and adds the subdirectory, but only when the current project is the top-level project.

## License

Apache-2.0
