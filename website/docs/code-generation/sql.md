---
sidebar_position: 14
title: SQL Files Driver
description: ORM Generation for SQL Files
---

# Bob Gen for SQL

Generates an ORM based on SQL schema files

## Usage

```sh
# With env variable
SQL_DIALECT=psql go run github.com/stephenafamo/bob/gen/bobgen-sql@latest

# With configuration file
go run github.com/stephenafamo/bob/gen/bobgen-sql@latest -c ./config/bobgen.yaml
```

### Driver Configuration

#### [Link to general configuration and usage](./configuration)

The configuration for the sql driver must be prefixed by the driver name. You must use a configuration file or environment variables for configuring the database driver.

In the configuration file for sql for example you would do:

```yaml
sql:
  dialect: psql
  pattern: "schema/*.sql"
```

When you use an environment variable it must also be prefixed by the driver name:

```sh
SQL_DIALECT=psql
```

The values that exist for the drivers:

| Name          | Description                                                     | Default                                      |
| ------------- | --------------------------------------------------------------- | -------------------------------------------- |
| dialect       | Database dialect to use. `psql`, `mysql` or `sqlite` (REQUIRED) |                                              |
| driver        | Driver to use for generating driver-specific code               |                                              |
| pattern       | Glob pattern of SQL migration files                             | \*.sql                                       |
| schemas       | The database schemas to generate models for                     | public (psql dialect), main (sqlite dialect) |
| shared_schema | Schema to not include prefix in model                           | first schema found                           |
| uuid_pkg      | UUID package to use (gofrs or google)                           | "gofrs"                                      |
| queries       | Folders containing sql query files                              |                                              |
| only          | Only generate these                                             |                                              |
| except        | Skip generation for these                                       |                                              |
| concurrency   | How many tables to fetch in parallel                            | 10                                           |

Example of Only/Except:

```yaml
sql:
  # Removes public.migrations table, the name column from the addresses table, and
  # secret_col of any table from being generated. Foreign keys that reference tables
  # or columns that are no longer generated may cause problems.
  except:
    public.migrations:
    public.addresses:
      - name
    "*":
      - secret_col
```
