# cmake-test

```
npm i cmake-test
```

```cmake
find_package(cmake-test REQUIRED PATHS node_modules/cmake-test)
```

## API

#### `add_test_executable(<target> <sources>... [LINK <libraries>...] [TIMEOUT <seconds>] [WORKING_DIRECTORY <path>] [LABELS <labels>...] [PROPERTIES <properties>...])`

#### `add_test_executables(<sources>... [PREFIX <prefix>] [LINK <libraries>...] [TIMEOUT <seconds>] [WORKING_DIRECTORY <path>] [LABELS <labels>...] [PROPERTIES <properties>...])`

#### `add_test_subdirectory(<source_dir> [<binary_dir>] [EXCLUDE_FROM_ALL] [SYSTEM])`

Enables testing and adds the subdirectory, but only when the current project is the top-level project.

## License

Apache-2.0
