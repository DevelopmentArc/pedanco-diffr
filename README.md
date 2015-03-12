# pedanco-diffr

[![Gem Version](https://badge.fury.io/rb/pedanco-diffr.svg)](http://badge.fury.io/rb/pedanco-diffr)
[![Codeship Status for DevelopmentArc/pedanco-diffr](https://codeship.com/projects/2ca2cec0-a9a6-0132-8917-427bb4181a39/status?branch=master)](https://codeship.com/projects/67769)
[![Code Climate](https://codeclimate.com/github/DevelopmentArc/pedanco-diffr/badges/gpa.svg)](https://codeclimate.com/github/DevelopmentArc/pedanco-diffr)
[![Coverage Status](https://coveralls.io/repos/DevelopmentArc/pedanco-diffr/badge.svg?branch=master)](https://coveralls.io/r/DevelopmentArc/pedanco-diffr?branch=master)

A change set library for managing how data is evolved overtime. `Pedanco::Diffr` allows you to track changes in a `ChangeSet` and then query the `ChangeSet` to determine if the data has changed, what the current value is and what the previous value was. This was inspired by the [ActiveModel::Dirty](http://api.rubyonrails.org/classes/ActiveModel/Dirty.html) class, but has been isolated so that it can be used to track any kind of data change without the ActiveModel/ActiveRecord inclusions.

# Installation
```bash
gem install pedanco-diffr
```

Or add it to your Gemfile:

```bash
gem 'pedanco-diffr'
```

# Usage

```ruby
# Create a new ChangeSet
change_set = Pedanco::Diffr::ChangeSet.new(name: ['Tim', 'Tom'])

# Add another change and query the ChangeSet
change_set.add_change(:age, 21, 23) # => Pedanco::Diffr::Change
change_set.name_changed? # => true
change_set.changed?(:age) # => true

# Remove a change and query the ChangeSet
change_set.remove_change(:age) # => Pedanco::Diffr::Change
change_set.age_changed? # => false
change_set.changed?(:age) # => false

# Extract a change
name_change = change_set.get_change(:name) # => Pedanco::Diffr::Change
name_change.current # => 'Tim'
name_change.previous # => 'Tom'
```

# Creating a ChangeSet
When creating a new ChangeSet you can pass in a `Hash` of named `Arrays`. The key of the hash will be used to generate the change name, and the `Array` defines the current and previous values.

```ruby
# Create the ChangeSet with Hash data
data_set   = { city: ['San Diego', 'Denver'], state: ['CA', nil] }
change_set = Pedanco::Diffr::ChangeSet.new(data_set)
change_set.state_changed? #=> true
```

You can also directly add changes using the `add_change` method.

```ruby
# Create ChangeSet and add changes directly
change_set = Pedanco::Diffr::ChangeSet.new
change_set.add_change(:city, 'San Diego', 'Denver') # => Pedanco::Diffr::Change
change_set.add_change(:state, 'CA') # => Pedanco::Diffr::Change

change_set.city_changed? #=> true
change_set.state_changed? #=> true
```

If you want to import `ActiveModel::Dirty` changes into a `ChangeSet` you can call the `parse_changes()` method passing in the data.

```ruby
# We have updated an Address Model (ActiveRecord::Base) and want to store the changes
change_set = Pedanco::Diffr::ChangeSet.new
change_set.parse_changes(address.changes)
```

# Querying the ChangeSet

Once a change has been added you can query the ChangeSet to see if the set contains a change you are looking for. You can do this by using the `_changed?` convenience method, which prepends the name of the change, such as `city_changed?`. You can can also call the `changed?` method passing in the name of the change you want to verify.

```ruby
# Create a new ChangeSet and add a change
change_set = Pedanco::Diffr::ChangeSet.new
change_set.add_change(:city, 'San Diego', 'Denver') # => Pedanco::Diffr::Change

# Using _changed?
change_set.city_changed? #=> true
change_set.address_changed? #=> false

# Using changed?()
change_set.changed?(:city) # => true
change_set.changed?(:address) # => false
```

The `changed?` method also allows you to pass in an array of names to query by. By default, if the `ChangeSet` has any of the changes requested, it will return `true`.

```ruby
# Create a new ChangeSet and add a change
change_set = Pedanco::Diffr::ChangeSet.new
change_set.add_change(:city, 'San Diego', 'Denver') # => Pedanco::Diffr::Change

# Pass an Array of names to query
change_set.changed?([:city, :address]) # => true
```

If you need to make sure that all the key names passed have changed, then you can pass the `:all` flag to `changed?` method.

```ruby
# Verify all changes exists in the ChangeSet
change_set = Pedanco::Diffr::ChangeSet.new
change_set.add_change(:city, 'San Diego', 'Denver') # => Pedanco::Diffr::Change
change_set.changed?([:city, :address], :all) # => false
```

# Using Changes
Once you have created a change set you can access the current and previous value of the change by calling `get_change`

```ruby
# Build a ChangeSet
change_set = Pedanco::Diffr::ChangeSet.new
change_set.add_change(:city, 'San Diego', 'Denver') # => Pedanco::Diffr::Change
change_set.add_change(:state, 'CA') # => Pedanco::Diffr::Change

# Extract the current and previous values for a change
change_set.get_change(:city).current # => 'San Diego'
change_set.get_change(:city).previous # => 'Denver'
```

When calling `get_change` the ChangeSet will return a `Pedanco::Diffr::Change` instance. This instance allows you to get the name, current and previous value. If the change request can not be found then an empty `Change` will be returned.

```ruby
# Requesting a non-existent change returns an empty Change
change_set = Pedanco::Diffr::ChangeSet.new
change = change_set.get_change(:age) # => Pedanco::Diffr::Change
change.name # => :age
change.current # => nil
change.previous # => nil
```

# Change values
A `Pedanco::Diffr::Change` instance's current or previous values can be any kind of data. By default both the current and previous are `nil`. This allows for empty changes, a change from empty to something or something to empty. Only the name of the change is required. The name can be a `String` or `Symbol`. By default we convert the name to a `Symbol` for lookup purposes.

```ruby
# Multiple ways to add a change
change_set = Pedanco::Diffr::ChangeSet.new
change_set.add_change('name', nil, nil) # => Empty change
change_set.add_change('field', 'Bar') # => Empty to something change
change_set.add_change(:money, nil, 'Something') # => Something to empty change
```

When calling `add_change` only a current value must be passed to the method (including `nil`). By default the previous value will be set to `nil`.

# Updating changes
When working with a ChangeSet you can remove an existing change or overwrite it. To remove a change you can call the `remove_change` method. To override a change, just call `add_change` with the same name.

```ruby
# Create a ChangeSet with some changes
change_set = Pedanco::Diffr::ChangeSet.new
change_set.add_change(:city, 'San Diego', 'Denver') # => Pedanco::Diffr::Change
change_set.add_change(:state, 'CA') # => Pedanco::Diffr::Change

# overriding a change
change_set.add_change(:state, 'CA', 'CO') # => Pedanco::Diffr::Change
change_set.get_change(:state).previous # => 'CO'

# removing a change
change_set.remove_change(:city) # => Pedanco::Diffr::Change
change_set.city_changed? # => false
```

# Why Pedanco::Diffr?
At [Pedanco](https://pedanco.com) we use [Wisper](https://github.com/krisleech/wisper) to handle global events. When these events are dispatched, they trigger cache invalidation, system wide updates, and other complex tasks that usually run in an async worker. The challenge we had was that some changes in the system trigger different actions.

For example, when a user changes their Role or name, we need to run a lot of cache updates to change access rights and views. But, if they just change their signature then we don't need to trigger these system updates.

`Pedanco::Diffr` allows us to build a `ChangeSet` that is then passed along with the Wisper event. Our global subscribers can then process the changes and trigger different actions based on what changed. We use a combination of custom change tracking in [Mutations](https://github.com/cypriss/mutations) and `ActiveRecord` changes to build out our `ChangeSet` and then dispatch them once the process of creation/updating is complete.

# License
The MIT License (MIT)

Copyright (c) 2015 DevelopmentArc

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
