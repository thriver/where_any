# Where Any

Helpers for using the PostgreSQL `ANY()` and `ALL()` expressions in ActiveRecord queries. This provides the functionality of WHERE IN, but in a more prepared statement friendly way.

Tested and validated only for PostgreSQL.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'where_any'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install where_any

Then in any of your models:

```ruby
class User < ApplicationRecord
  extend WhereAny

  # ...
end
```

Or, to install these helpers for your entire application:

```ruby
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  extend WhereAny

  # ...
end
```

## Usage

To make a where `ANY()` query, use the `where_any` method:

```ruby
User.where_any(:id, [1, 2, 3, 4, 5])
```

The first argument of `where_any` refers to the column being tested, and the second argument is a list of values to include in the condition.

Which would produce the following SQL:

```sql
SELECT "users".* FROM "users" WHERE "users"."id" = ANY($1)  [["id", "{1,2,3,4,5}"]
```

It's also possible to construct a negated where `ANY()` query, like so:

```ruby
User.where_none(:id, [1, 2, 3, 4, 5])
```

Which would produce the following SQL:

```sql
SELECT "users".* FROM "users" WHERE "users"."id" != ALL($1)  [["id", "{1,2,3,4,5}"]]
```

### Where ANY vs. Where IN

The advantage of using where `where_any` over ActiveRecord's built-in WHERE IN support is that it produces the same SQL statement regardless of the number of elements supplied. This is advantageous when using prepared statements, as the same statement can be reused regardless of the number of inputs supplied.

Consider for example:

```ruby
User.where(id: [1, 2, 3])
User.where(id: [1, 2, 3, 4])
User.where(id: [1, 2, 3, 4, 5])

# Versus

User.where_any(:id, [1, 2, 3])
User.where_any(:id, [1, 2, 3, 4])
User.where_any(:id, [1, 2, 3, 4, 5])
```

These sets of queries produce the following sets of SQL respectively:

```sql
SELECT "users".* FROM "users" WHERE "users"."id" IN ($1, $2, $3)  [["id", 1], ["id", 2], ["id", 3]]
SELECT "users".* FROM "users" WHERE "users"."id" IN ($1, $2, $3, $4)  [["id", 1], ["id", 2], ["id", 3], ["id", 4]]
SELECT "users".* FROM "users" WHERE "users"."id" IN ($1, $2, $3, $4, $5)  [["id", 1], ["id", 2], ["id", 3], ["id", 4], ["id", 5]]

-- Versus

SELECT "users".* FROM "users" WHERE "users"."id" = ANY($1)  [["id", "{1,2,3}"]]
SELECT "users".* FROM "users" WHERE "users"."id" = ANY($1)  [["id", "{1,2,3,4}"]]
SELECT "users".* FROM "users" WHERE "users"."id" = ANY($1)  [["id", "{1,2,3,4,5}"]]
```

Using the `ANY()` notation allows us to reuse the same query with the same number of parameter binds regardless of what number of inputs are supplied.

### Performance

Using modern version of Postgres, there is no disadvantage to using `ANY()` from a query plan perspective.

Here is an example query plan when using `where_any()`:

```sql
EXPLAIN for: SELECT "users".* FROM "users" WHERE "users"."id" = ANY($1) [["id", "{1,2,3,4,5}"]]
                                 QUERY PLAN
----------------------------------------------------------------------------
 Index Scan using users_pkey on users
   Index Cond: (id = ANY ('{1,2,3,4,5}'::integer[]))
(2 rows)
```

And here is the query plan when using ActiveRecord's WHERE IN:

```sql
EXPLAIN for: SELECT "users".* FROM "users" WHERE "users"."id" IN ($1, $2, $3, $4, $5) [["id", 1], ["id", 2], ["id", 3], ["id", 4], ["id", 5]]
                                 QUERY PLAN
----------------------------------------------------------------------------
 Index Scan using users_pkey on users
   Index Cond: (id = ANY ('{1,2,3,4,5}'::integer[]))
(2 rows)
```

Note how these two queries produced the exact same query plan. According to the PostgreSQL manual, these operations are equivalent:
https://www.postgresql.org/docs/current/functions-subquery.html#FUNCTIONS-SUBQUERY-ANY-SOME

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/thriver/where_any.
