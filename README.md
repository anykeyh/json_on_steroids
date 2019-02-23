# JSON::OnSteroid

## Description

JSON::OnSteroid provides powerful JSON document transformation and edition
with some advanced features to navigate through the keys.

Basically, it can be seen as a `JSON::Any` object on steroid.

The current Crystal stdlib JSON implementation is made of structure which are
immutable. While being performant, it turns out dealing with JSON blob with a
fully typed language can be really painful.

Transforming JSON to hash is not enough and lead to obscure type errors.

`JSON::OnSteroid` trades some performances versus functionalities:

- Mutate or construct a JSON schema easily
- Pass Hash, Array, NamedTuple etc... as parameters of keys without hassle
- Check whether a schema is dirty (has changed) or not
- Errors telling you what key/sub-schema is wrong at runtime
- Out of the box support of `Time`, which happens to be common
- Interface well with JSONB and [Clear ORM](https://github.com/anykeyh/clear)

## Example

### Build a JSON::OnSteroid structure:

```
  # build from initial json
  json = JSON.parse(%<{"a": 1, "b": 2}>).on_steroid
  json = JSON::OnSteroid.new(JSON.parse(%<{"a": 1, "b": 2}>))

  # build from initial hash and named tuples:
  json = JSON::OnSteroid.new a: 1, b: 2
  json = JSON::OnSteroid.new({a => 1, b => 2})

  # build from empty object json
  json = JSON::OnSteroid.new

  # build array
  json = JSON::OnSteroid.new [1,2,3]

  # build a value (is it useful?)
  json = JSON::OnSteroid.new "a value"
```

### Exporting to json

```crystal
  json.to_json #obvious enough
```

### Getter / setters

The API of `JSON::Any` for getters are supported. So, as with `JSON::Any`, you
can access to a specific field by using `[]` then casting using `as_xxx` where
`xxxx` can be `i`, `s`, `b` etc...

Basically, `JSON::OnSteroid` can be passed wherever a `JSON::Any` object is
required, while it's not true in the other way.

`JSON::Any::Mutate` add setters:

```crystal
json = JSON.parse(%<{"type": "event", "type": "favorites_numbers","data": [1,2,3,4] }>).mutable

json["data"][0] = "Hello"

json.to_json # => {"type": "event", "type": "favorites_numbers","data": ["Hello",2,3,4] }
```

### Digging

Digging allows you to fetch a key in your JSON schema:

```crystal
  json = JSON.parse(%<{"type": "event", "is": "favorites_numbers","data": [1,2,3,4] }>).mutable
  puts json.dig("data.1").as_i #=> 2
```

Digging can be combined with set in place feature:

```crystal
  json = JSON.parse(%<{"other": {"counter": 123}}>).mutable

  json.dig?("other.counter").try &.set{ |x| x.as_i + 1 }
  puts json.to_json # => {"other": {"counter": 124}}
```

Two flavors of dig method exists:
`dig(string)` which throw an error if the key is not found / schema doesn't match and `dig?(string)` which return
`nil` in case it can't dig (the key doesn't match).


### Introspection

`JSON::OnSteroid` objects are aware of few states:
- If they belongs to a parent by calling `json.parent` and `json.ancestors`
- How deep they are in the document by calling `json.depth`
- If they are dirty (e.g. they mutate) by calling `json.dirty?`
- In case they belongs to a map or an array,
  which key they are mapped to by calling `json.key`

`JSON::OnSteroid` objects can introspect about their state, if it has been mutated.
  It also can return the schema with the only mutated elements:

```
  json = JSON.parse(%<{"key": 1, "other": {"counter": 123}}>).mutable

  json["other"]["counter"] = 543

  json.dirty? #=> true

  puts json.dirty_only.to_json # => {"other": {"counter": 543}}
```

This is useful for:
- Snapshot between your JSON document
- Merge-able noSQL databases will crunch this in no time

You can clean a dirty object by calling `clean!` on it:

```crystal
json.dirty? # => true
json.clean! #
json.dirty? # => false
```

### Crawling

You can `crawl` the keys using `crawl` method:

```crystal
# Crawl to an aggregator:
json.crawl([]){ |agg, json| agg << json if (json.key == "type" && json.as_s? == "event") }
```

`crawl` perform from top most values to sub content values. For example:

```
%<>
```

## Q&A

### Performance tradeoff

`JSON::OnSteroid` works by encapsulate all values in a wrapper class. Performance wise, it
creates new object everytime you mutate a value. Moreover, each key keep a reference
to the parent and a dirty boolean field.

In term of CPU, it has a small overhead, usually negligible. In terms of memory,
the overhead of the wrapper is 17 bytes per fields, array items comprised.
It can then become voluminous in case of processing large JSON of few megabytes.

In case you dealing with very-large JSON or are in a memory-constrainted
environnement, I would recommend you to use data mapping or serialization strategies.

## Interfacing with libraries

### Clear

Currently, `json_on_steroid` interface with [Clear](https://github.com/anykeyh/clear),
as that's how I use it.

Add this optional requirement to use it into clear

```crystal
require "json_on_steroid/ext/clear"
```

Now your jsonb columns are mapped :).

```crystal
  column jsonb : JSON::OnSteroid
```
Usage of `dirty?` allows the edition in place of your json:

```crystal
  mdl = Model.query.first!
  mdl.jsonb["my"]["content"] = "is awesome"
  mdl.changed? # => true
  mdl.update_h #=> {"jsonb" => JSON::OnSteroid}
  mdl.save!
```

If you want to interface in another ORM or libraries, pull request are welcome !

# Future:

Currently not implemented but planned

- CSS-like query system.