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
| `--insert` | `true` if mask `INSERT` SQL | `false`, but `true` if `--insert`, `--replace` and `--copy` options are not given |
| `--replace` | `true` if mask `REPLACE` SQL | `false`, but `true` if `--insert`, `--replace` and `--copy` options are not given |
| `--copy` | `true` if mask `COPY` SQL | `false`, but `true` if `--insert`, `--replace` and `--copy` options are not given |

## Config

The following keys are needed in the config YAML file.

| Key | Description | Type |
| :-- | :---------- | :--- |
| `mark` | Replacement text | String |
| `targets` | Array of targets | Array |
| `table` | Target table name | String |
| `columns` | Columns count of the table | Integer |
| `indexes` | Target column index (zero-based) and masking text | Hash |

## Examples

Config file:

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

Input file (includes sensitive values):

```sql
INSERT INTO `people` (`id`, `code`, `name`, `email`) VALUES (1,'01','坂本龍馬','ryoma-sakamoto@example.com'),(2,'02','高杉晋作','shinsaku-takasugi@example.com'),(3,'03','沖田総司','soji-okita@example.com');
INSERT INTO `cats` (`code`, `name`) VALUES ('01','Sora'),('02','Hana'),('03','Leo');

REPLACE INTO `people` (`id`, `code`, `name`, `email`) VALUES (1,'01','坂本龍馬','ryoma-sakamoto@example.com'),(2,'02','高杉晋作','shinsaku-takasugi@example.com'),(3,'03','沖田総司','soji-okita@example.com');
REPLACE INTO `cats` (`code`, `name`) VALUES ('01','Sora'),('02','Hana'),('03','Leo');

COPY people (id, code, name, email) FROM stdin;
1	01	坂本龍馬	ryoma-sakamoto@example.com
2	02	高杉晋作	shinsaku-takasugi@example.com
3	03	沖田総司	soji-okita@example.com
\.
COPY cats (code, name) FROM stdin;
01	Sora
02	Hana
03	Leo
\.
```

Output file (the sensitive values are masked):

```sql
INSERT INTO `people` (`id`, `code`, `name`, `email`) VALUES (1,'01','氏名1','email-1@example.com'),(2,'02','氏名2','email-2@example.com'),(3,'03','氏名3','email-3@example.com');
INSERT INTO `cats` (`code`, `name`) VALUES ('code-1','Cat name 1'),('code-2','Cat name 2'),('code-3','Cat name 3');

REPLACE INTO `people` (`id`, `code`, `name`, `email`) VALUES (1,'01','氏名1','email-1@example.com'),(2,'02','氏名2','email-2@example.com'),(3,'03','氏名3','email-3@example.com');
REPLACE INTO `cats` (`code`, `name`) VALUES ('code-1','Cat name 1'),('code-2','Cat name 2'),('code-3','Cat name 3');

COPY people (id, code, name, email) FROM stdin;
1	01	氏名1	email-1@example.com
2	02	氏名2	email-2@example.com
3	03	氏名3	email-3@example.com
\.
COPY cats (code, name) FROM stdin;
code-1	Cat name 1
code-2	Cat name 2
code-3	Cat name 3
\.
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
