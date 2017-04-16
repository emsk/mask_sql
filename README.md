# MaskSQL

[![Build Status](https://travis-ci.org/emsk/mask_sql.svg?branch=master)](https://travis-ci.org/emsk/mask_sql)
[![Coverage Status](https://coveralls.io/repos/github/emsk/mask_sql/badge.svg?branch=master)](https://coveralls.io/github/emsk/mask_sql)
[![Code Climate](https://codeclimate.com/github/emsk/mask_sql/badges/gpa.svg)](https://codeclimate.com/github/emsk/mask_sql)
[![Dependency Status](https://gemnasium.com/badges/github.com/emsk/mask_sql.svg)](https://gemnasium.com/github.com/emsk/mask_sql)
[![Inline docs](http://inch-ci.org/github/emsk/mask_sql.svg?branch=master)](http://inch-ci.org/github/emsk/mask_sql)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE.txt)

Mask sensitive values in a SQL file.

## Installation

WIP

## Usage

```sh
$ mask_sql --in dump.sql --out masked_dump.sql --config mask_config.yml
```

## Command Options

| Option | Description | Default |
| :----- | :---------- | :------ |
| `-i` / `--in` | Input file path (Required) | |
| `-o` / `--out` | Output file path (Required) | |
| `-c` / `--config` | Config YAML file path | `.mask.yml` in the working directory |
| `--insert` | `true` if mask `INSERT` SQL | `false`, but `true` if `--replace` and `--copy` options are not given |
| `--replace` | `true` if mask `REPLACE` SQL | `false`, but `true` if `--insert` and `--copy` options are not given |
| `--copy` | `true` if mask `COPY` SQL | `false`, but `true` if `--insert` and `--replace` options are not given |

## Config

The following keys are needed in the config file.

| Key | Description | Type |
| :-- | :---------- | :--- |
| `mark` | Replacement text | String |
| `targets` | Array of targets | Array |
| `table` | Target table name | String |
| `columns` | Columns count of the table | Integer |
| `indexes` | Target column index (zero-based) and masking text | Hash |

The following code is an example of the config file.

```yaml
mark: '[mask]'
targets:
  - table: people
    columns: 4
    indexes:
      2: 氏名[mask]
      3: email-[mask]@example.com
  - table: cats
    columns: 2
    indexes:
      0: code-[mask]
      1: Cat name [mask]
```

## Supported Ruby Versions

* Ruby 2.0.0
* Ruby 2.1
* Ruby 2.2
* Ruby 2.3
* Ruby 2.4

## Contributing

Bug reports and pull requests are welcome.

## License

[MIT](LICENSE.txt)
