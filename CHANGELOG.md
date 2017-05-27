# Change Log

## 0.2.0 (2017-05-27)

### Features

* Add `init` command
* Add `group_indexes` option in config file
* Rename key in config file (`indexes` -> `dummy_values`)
* Support commas within string values
* Add validation for `--in` and `--out` options
* Retry when `Encoding::UndefinedConversionError` occurred
* Specify required Ruby version (`>= 2.0.0`)

### Performance Improvements

* Parse SQL without CSV library

## 0.1.0 (2017-04-17)

### Features

* Add `mask` command
* Support INSERT, REPLACE, and COPY statements
* Add `version`, `--version`, and `-v` commands
* Support various encodings
