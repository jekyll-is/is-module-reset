# is-module-reset

[![GitHub License](https://img.shields.io/github/license/jekyll-is/is-module-reset)](LICENSE)
[![Gem Version](https://badge.fury.io/rb/is-module-reset.svg)](https://badge.fury.io/rb/is-module-reset)
![Coverage](coverage-badge.svg)

Save and restore the state of Ruby modules and classes **in tests**: class
variables (`@@var`) and instance variables of the modules and classes
themselves (`@var`). It keeps tests that touch global state (singletons,
registries, caches, settings stored in modules) from affecting each other.

> **Not intended for production use.** The gem does not create a truly
> isolated environment: it only puts values back into the same objects.

Русская версия: [README-ru.md](README-ru.md)

## Installation

Add to your Gemfile:

```ruby
gem 'is-module-reset', group: :test
```

Or install directly:

```bash
gem install is-module-reset
```

## Quick start

```ruby
require 'is-module-reset'

module App
  @@requests = 0
  @settings = { debug: false }

  def self.requests
    @@requests
  end

  def self.hit!
    @@requests += 1
  end

  def self.settings
    @settings
  end
end
```

Run a block and roll everything back afterwards:

```ruby
IS::ModuleReset.isolate(App) do
  App.hit!
  App.settings[:debug] = true
  App.requests   # => 1
end

App.requests     # => 0
App.settings     # => { debug: false }
```

Or take a snapshot and restore it manually:

```ruby
state = IS::ModuleReset.dump(App)

App.hit!
App.settings[:debug] = true

IS::ModuleReset.undump(state)

App.requests     # => 0
App.settings     # => { debug: false }
```

## What is saved

For every module or class you pass in, and for every module or class
reachable from it through constants (recursively, using only the module's own
constants, i.e. `Module#constants(false)`), the gem saves:

- the class variables defined by that module itself (inherited ones are not
  included);
- the instance variables of the module object itself (`@var` set at module or
  class level, including those created by `attr_accessor` in `class << self`).

When restoring, all such variables are removed and the saved ones are set
again. This means that variables created after the snapshot disappear, changed
ones return to their old values, and deleted ones come back.

Values are copied with `deep_dup` from [is-deep](https://github.com/inat-get/is-deep):
`Hash` and `Array` are copied recursively (shared and circular references are
preserved), modules and classes are kept as they are, and other objects are
copied with `dup` (if an object cannot be duplicated, the same object is kept).
Restoring also works on a copy, so the same snapshot can be restored any
number of times.

## API

### `IS::ModuleReset.dump(*mods) → Hash`

Takes a snapshot of the given modules and everything reachable from them via
constants. The returned hash is an internal representation; treat it as an
opaque value and pass it to `undump`.

### `IS::ModuleReset.undump(state)`

Restores the state from a snapshot returned by `dump`. May be called multiple
times with the same snapshot.

### `IS::ModuleReset.isolate(*mods) { ... }`

Takes a snapshot, runs the block, and restores the snapshot afterwards, even if
the block raised an exception. Returns the value of the block. Raises
`ArgumentError` if no block is given.

## Test framework integration

### RSpec

Isolate every example:

```ruby
RSpec.configure do |config|
  config.around do |example|
    IS::ModuleReset.isolate(MyApp) { example.run }
  end
end
```

`around` hooks wrap `before` and `after` hooks, so changes made there are
rolled back too.

Or restore the state captured when the suite started:

```ruby
RSpec.configure do |config|
  baseline = nil
  config.before(:suite) { baseline = IS::ModuleReset.dump(MyApp) }
  config.after(:each)   { IS::ModuleReset.undump(baseline) }
end
```

### Minitest

```ruby
class Minitest::Test
  def setup
    super
    @module_reset_state = IS::ModuleReset.dump(MyApp)
  end

  def teardown
    IS::ModuleReset.undump(@module_reset_state)
    super
  end
end
```

If your test classes define their own `setup` and `teardown`, call `super`.

## Limitations

- **Constants are not restored.** Neither reassigned, added, or removed
  constants, nor the contents of mutable constants (`CONFIG = {}`).
- **Only module-level state is saved.** Global variables (`$var`), `ENV`,
  thread-local variables, instance variables of ordinary objects, and anything
  outside the namespaces you pass in are not touched.
- **Values are copies.** Objects other than `Hash` and `Array` are copied with
  a shallow `dup`: their inner mutable state is shared with the original, and
  after restoring the module holds the copy rather than the original instance.
  If you store, say, a singleton object in `@instance`, it may become a
  different object after restoring.
- **Copies are not frozen.** A frozen value becomes mutable after restoring.
- **Constants are followed blindly.** An alias to a module from another
  namespace (`Log = ::Logger`) is included in the snapshot and rolled back too.
  Traversal may also trigger loading of `autoload` constants.
- **Not thread-safe.** The gem changes global state, so do not use it with
  tests running in parallel threads of the same process. Process-based
  parallelism is fine.

## Requirements

- Ruby >= 3.4
- [is-deep](https://github.com/inat-get/is-deep)

## License

LGPL-3.0-or-later. See the [LICENSE](LICENSE) file.
