# MaskSQL

[![Gem Version](https://badge.fury.io/rb/mask_sql.svg)](https://badge.fury.io/rb/mask_sql)
[![Build Status](https://github.com/emsk/mask_sql/actions/workflows/build.yml/badge.svg)](https://github.com/emsk/mask_sql/actions/workflows/build.yml)
[![Build Status](https://travis-ci.org/emsk/mask_sql.svg?branch=main)](https://travis-ci.org/emsk/mask_sql)
[![Build Status](https://dev.azure.com/emsk/mask_sql/_apis/build/status/emsk.mask_sql?branchName=main)](https://dev.azure.com/emsk/mask_sql/_build/latest?definitionId=5&branchName=main)
[![Codecov](https://codecov.io/gh/emsk/mask_sql/branch/main/graph/badge.svg)](https://codecov.io/gh/emsk/mask_sql)
[![Code Climate](https://codeclimate.com/github/emsk/mask_sql/badges/gpa.svg)](https://codeclimate.com/github/emsk/mask_sql)
[![Inline docs](http://inch-ci.org/github/emsk/mask_sql.svg?branch=main)](http://inch-ci.org/github/emsk/mask_sql)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE.txt)

MaskSQL is a command-line tool to mask sensitive values in a SQL file.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mask_sql'
```

And then execute:

```sh
$ bundle
```

Or install it yourself as:

```sh
$ gem install mask_sql
```

## Usage

### Mask sensitive values in a SQL file

```sh
$ mask_sql --in dump.sql --out masked_dump.sql --config mask_config.yml
```

### Generate a config file

```sh
$ mask_sql init
```

## Command Options

| Option | Alias | Description | Default |
| :----- | :---- | :---------- | :------ |
| `--in` | `-i` | Input file path (Required). | |
| `--out` | `-o` | Output file path (Required). | |
| `--config` | `-c` | Config YAML file path. | `.mask.yml` in the working directory. |
| `--insert` | | `true` if mask `INSERT` SQL. | `false`, but `true` if `--insert`, `--replace`, and `--copy` options are not given. |
| `--replace` | | `true` if mask `REPLACE` SQL. | `false`, but `true` if `--insert`, `--replace`, and `--copy` options are not given. |
| `--copy` | | `true` if mask `COPY` SQL. | `false`, but `true` if `--insert`, `--replace`, and `--copy` options are not given. |

## Config

The following keys are available in the config YAML file.

### Top level keys

| Key | Description | Type |
| :-- | :---------- | :--- |
| `mark` | Replacement text. | String |
| `targets` | Array of targets. | Array |

### Keys for `targets`

| Key | Description | Type |
| :-- | :---------- | :--- |
| `table` | Target table name. | String |
| `columns` | Columns count of the table. | Integer |
| `dummy_values` | Target column index (zero-based) and dummy text. | Hash |
| `group_indexes` | Array of column indexes (zero-based).<br>Records that have the same values in these indexes are considered as the same numbering group. | Array |

## Examples

Input file (includes sensitive values):

```sql
INSERT INTO `people` (`id`, `code`, `name`, `email`) VALUES (1,'01','坂本龍馬','ryoma-sakamoto@example.com'),(2,'02','高杉晋作','shinsaku-takasugi@example.com'),(3,'03','沖田総司','soji-okita@example.com');
INSERT INTO `cats` (`code`, `name`) VALUES ('01','Sora'),('02','Hana'),('03','Leo');
INSERT INTO `dogs` (`code`, `name`, `house_id`, `room_id`) VALUES ('01','Pochi',1,1),('02','Rose',2,1),('03','Momo',1,1),('04','Sakura',1,2);

REPLACE INTO `people` (`id`, `code`, `name`, `email`) VALUES (1,'01','坂本龍馬','ryoma-sakamoto@example.com'),(2,'02','高杉晋作','shinsaku-takasugi@example.com'),(3,'03','沖田総司','soji-okita@example.com');
REPLACE INTO `cats` (`code`, `name`) VALUES ('01','Sora'),('02','Hana'),('03','Leo');
REPLACE INTO `dogs` (`code`, `name`, `house_id`, `room_id`) VALUES ('01','Pochi',1,1),('02','Rose',2,1),('03','Momo',1,1),('04','Sakura',1,2);

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
COPY dogs (code, name, house_id, room_id) FROM stdin;
01	Pochi	1	1
02	Rose	2	1
03	Momo	1	1
04	Sakura	1	2
\.
```

Output file (the sensitive values are masked):

```sql
INSERT INTO `people` (`id`, `code`, `name`, `email`) VALUES (1,'01','氏名1','email-1@example.com'),(2,'02','氏名2','email-2@example.com'),(3,'03','氏名3','email-3@example.com');
INSERT INTO `cats` (`code`, `name`) VALUES ('code-1','Cat name 1'),('code-2','Cat name 2'),('code-3','Cat name 3');
INSERT INTO `dogs` (`code`, `name`, `house_id`, `room_id`) VALUES ('code-1','Dog name 1',1,1),('code-1','Dog name 1',2,1),('code-2','Dog name 2',1,1),('code-1','Dog name 1',1,2);

REPLACE INTO `people` (`id`, `code`, `name`, `email`) VALUES (1,'01','氏名1','email-1@example.com'),(2,'02','氏名2','email-2@example.com'),(3,'03','氏名3','email-3@example.com');
REPLACE INTO `cats` (`code`, `name`) VALUES ('code-1','Cat name 1'),('code-2','Cat name 2'),('code-3','Cat name 3');
REPLACE INTO `dogs` (`code`, `name`, `house_id`, `room_id`) VALUES ('code-1','Dog name 1',1,1),('code-1','Dog name 1',2,1),('code-2','Dog name 2',1,1),('code-1','Dog name 1',1,2);

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
COPY dogs (code, name, house_id, room_id) FROM stdin;
code-1	Dog name 1	1	1
code-1	Dog name 1	2	1
code-2	Dog name 2	1	1
code-1	Dog name 1	1	2
\.
```

Config file:

```yaml
mark: '[mask]'
targets:
  - table: people
    columns: 4
    dummy_values:
      2: 氏名[mask]
      3: email-[mask]@example.com
  - table: cats
    columns: 2
    dummy_values:
      0: code-[mask]
      1: Cat name [mask]
  - table: dogs
    columns: 4
    dummy_values:
      0: code-[mask]
      1: Dog name [mask]
    group_indexes:
      - 2
      - 3
```

## Supported Ruby Versions

Ruby 2.0.0, 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 3.0

## Contributing

Bug reports and pull requests are welcome.

## Related

* [mruby-masksql](https://github.com/emsk/mruby-masksql) - An mruby implementation of the mask_sql

## License

[MIT](LICENSE.txt)
