# JSON::OnSteroids

[![Build Status](https://travis-ci.org/anykeyh/json_on_steroids.svg)](https://travis-ci.org/anykeyh/json_on_steroids/)
[![API Docs](https://img.shields.io/badge/docs-available-brightgreen.svg)](https://anykeyh.github.io/json_on_steroids/)

## Description

`json_on_steroids` provides powerful JSON document transformation and edition
with some advanced features to navigate through the keys.

Basically, it can be seen as a `JSON::Any` object on steroid.

The current Crystal stdlib JSON implementation is made of immutable structures.
While being performant, it turns out dealing with JSON blob with a fully typed language can be really painful.

Transforming JSON to hash or array is often not enough and lead to obscure type errors and ninja type castings.

`JSON::OnSteroids` trades some performance to offers functionalities:

- Mutate or construct from zero a JSON schema easily
- Pass Hash, Array, NamedTuple etc... as parameters of keys without hassle
- Check whether a schema is dirty (has changed) or not
- Errors telling you what key/sub-schema is wrong at runtime
- Out of the box support of `Time`, which happens to be common in JSON
- Interface well with PostgreSQL's JSONB column and [Clear ORM](https://github.com/anykeyh/clear)

## Example

### Build a JSON::OnSteroids structure:

```crystal
  # build from scratch (empty object `{}`)
  json = JSON::OnSteroids.new

  # build from initial json
  json = JSON.parse(%<{"a": 1, "b": 2}>).on_steroids
  json = JSON::OnSteroids.new(JSON.parse(%<{"a": 1, "b": 2}>))

  # build from initial hash and named tuples:
  json = JSON::OnSteroids.new a: 1, b: 2
  json = JSON::OnSteroids.new({"a" => 1, "b" => 2})

  # build from empty object json
  json = JSON::OnSteroids.new

  # build array
  json = JSON::OnSteroids.new [1,2,3]

  # build a value (is it useful?)
  json = JSON::OnSteroids.new "a value"
```

### Exporting to json

```crystal
  json.to_json #obvious enough
```

### Getter / setters

The API of `JSON::Any` for getters are supported. So, as with `JSON::Any`, you
can access to a specific field by using `[]` then casting using `as_xxx` where
`xxxx` can be `i`, `s`, `b` etc...

Basically, a `JSON::OnSteroids` can be passed wherever a `JSON::Any` object is
required, while it's not true in the other way.

`JSON::OnSteroids` add setters:

```crystal
json = JSON.parse(%<{"type": "event", "type": "favorites_numbers","data": [1,2,3,4] }>).on_steroids

json["data"][0] = "Hello"

json.to_json # => {"type": "event", "type": "favorites_numbers","data": ["Hello",2,3,4] }

# Automatically import from named tuples, arrays and hashes

from_tuple = {
  type: "collection",
  pages: {
    count: 3,
    current: 2,
    next_page: "http://myservice/api/collection?page=3"
  },
  data: [
    { type: "_user", id: 1 },
    { type: "_user", id: 2 }
  ]
}

json = JSON::OnSteroids.new(from_tuple)
```

### Digging

Digging allows you to fetch a key in your JSON schema:

```crystal
  json = JSON.parse(%<{"type": "event", "is": "favorites_numbers","data": [1,2,3,4] }>).mutable
  puts json.dig("data.1").as_i #=> 2
```

Two flavors of dig method exists:
`dig(string)` which throw an error if the key is not found / schema doesn't match and `dig?(string)` which return
`nil` in case it can't dig (the key doesn't match).

### Set / remove in place
Digging can be combined with set in place and remove feature:

```crystal
  json = JSON.parse(%<{"other": {"counter": 123}}>).on_steroids

  json.dig("other.counter").set(&.as_i.+(1)) # Add 1 to the counter
  puts json.to_json # => {"other": {"counter": 124}}

  json.dig("other.counter").remove
  puts json.to_json # => {"other": {}}
```

### Introspection

`JSON::OnSteroids` objects are aware of few states:
- You can reverse traversing by calling `json.parent`
- How deep they are in the document by calling `json.depth`
- If they are dirty (e.g. they mutate) by calling `json.dirty?`
- In case they belongs to a map or an array,
  which key they are mapped to by calling `json.key`
- The full path of an element can be found by calling `json.path`

`JSON::OnSteroids` objects can introspect about their mutation state.
  It also can return the schema with the only mutated elements:

```crystal
  json = JSON.parse(%<{"key": 1, "other": {"counter": 123}}>).on_steroids

  json["other"]["counter"] = 543

  json.dirty? #=> true

  puts json.dirty_only.to_json # => {"other": {"counter": 543}}
```

This is useful for:
- Snapshot between your JSON document
- Merge-able noSQL databases will crunch this in no time \o/

You can clean a dirty object by calling `clean!` on it:

```crystal
json.dirty? # => true
json.clean! #
json.dirty? # => false
```

## Q&A

### Performance tradeoff

`JSON::OnSteroids` works by encapsulating all values in a wrapper class. Performance wise, it
creates new object everytime you mutate a value. Moreover, each key keep a reference
to the parent and a dirty boolean field.

In term of CPU, it has a small overhead, usually negligible. In terms of memory,
the overhead of the wrapper is 17 bytes per fields, array items comprised.
It can then become voluminous in case of processing large JSON of few megabytes.

In case you dealing with very-large JSON or are in a memory-constrainted
environnement, I would recommend you to use data mapping or serialization strategies.

## Interfacing with libraries

### Clear

Currently, `json_on_steroids` interface with [Clear](https://github.com/anykeyh/clear),
as that's how I use it.

Add this optional requirement to use it into clear

```crystal
require "json_on_steroids/ext/clear"
```

Now your jsonb columns are mapped :).

```crystal
  column jsonb : JSON::OnSteroids
```
Usage of `dirty?` allows the edition in place of your json:

```crystal
  mdl = Model.query.first!
  mdl.jsonb["my"]["content"] = "is awesome"
  mdl.changed? # => true
  mdl.update_h #=> {"jsonb" => JSON::OnSteroids}
  mdl.save!
```

If you want to interface in another ORM or libraries, pull request are welcome !

## Future on this shard

Currently not implemented but planned:

### Searching

**WIP: Not implemented yet.**

You can `search` through the document a key responding to a specific rule:

```crystal
puts "Events from facebook or google:"

# search every elements which contains the keys `type` and `provider`:
json.search(type: "event", provider: /^(facebook|google)$/){ |evt|
  puts evt["url"]
}
```
