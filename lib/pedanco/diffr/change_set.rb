module Pedanco
  module Diffr
    #
    # A ChangeSet contains a one or more changes. Change data can be
    # passed during `new()` or can be added/removed directly from the
    # change instance.
    #
    # When a change is added, the ChangeSet provides both a direct method
    # to look up a change or a convience method with a `_changed?` prefix.
    #
    #   inst = Pedanco::Diffr::ChangeSet.new
    #   inst.add_change(:age, 40, 39)
    #
    #   inst.age_changed? # true
    #   inst.changed?(:age) # true
    #
    # When creating a ChangeSet you can also pass in ActiveModel::Dirty syntax
    # to the `parse_changes()` method to convert the data into a ChangeSet.
    #
    # @author [jpolanco]
    #
    class ChangeSet
      #
      # Initializes the Change instance. Allows for a hash of array pairs, ex:
      #
      #   { name: ['Bob', 'Tom'], age: [33, 32] }
      #
      # which represents a change set to be parsed in on creation.
      #
      # @param change_hash [Hash]
      #   (optional) hash to be converted into a ChangeSet.
      #
      def initialize(change_hash = {})
        @changes = parse_change_hash(change_hash)
      end

      #
      # Override to catch `_changed?` postfix convenience calls to
      # determine if a property has changed.
      #
      def method_missing(name, *args, &block)
        if name.to_s =~ /_changed\?/
          @changes.key?(name.to_s.gsub(/_changed\?/, '').to_sym)
        else
          super
        end
      end

      #
      # Implementation to support respond_to? lookup for
      # `_changed?` postfix convenience calls.
      #
      # @return [Boolean] true if class responds to the requested
      #   method name
      def respond_to?(name, include_private = false)
        if name.to_s =~ /_changed\?/
          true
        else
          super
        end
      end

      #
      # Adds a change to the change set. This method converts the arguments
      # into a Change object internally.
      #
      #   inst = Pedanco::Diffr::ChangeSet.new
      #   inst.add_change(:age, 40, 39)
      #
      #   inst.age_changed? # true
      #
      # @param name [String,Symbol] The name of the value that has changed
      # @param current_value [anything] The current value
      # @param previous_value [anything] (optional) The previous value,
      #   the default is nil
      #
      # @return [Change] Returns the generated change
      def add_change(name, current_value, previous_value = nil)
        sym = name.to_sym
        @changes[sym] =
          Change.new(sym, current_value, previous_value)
        @changes[sym]
      end

      #
      # Removes an existing change by the name of the change. This method
      # is safe to call if a change is not found.
      #
      #   inst = Pedanco::Diffr::ChangeSet.new
      #   inst.add_change(:age, 40, 39)
      #   inst.age_changed? # true
      #
      #   inst.remove_change(:age) # true
      #
      # @param name [String,Symbol] The name of the change to remove.
      #
      # @return [Change] The removed change,
      #   nil if no change by that name was found
      def remove_change(name)
        @changes.delete(name.to_sym)
      end

      #
      # Determines if the provided change(s) exist in the change set.
      # When the match type is set to `:any`, if any key matches at least
      # one change the method returns false.
      #
      #   inst = Pedanco::Diffr::ChangeSet.new
      #   inst.add_change(:age, 40, 39)
      #   inst.add_change(:name, 'George', 'Frank')
      #
      #   inst.changed?([:foo, :age]) # true
      #
      # If the match type is :all, all matches must exist.
      #
      #   inst = Pedanco::Diffr::ChangeSet.new
      #   inst.add_change(:age, 40, 39)
      #   inst.add_change(:name, 'George', 'Frank')
      #
      #   inst.changed?([:foo, :age], :all) # false
      #
      # @param keys [String,Symbol,Array] Defines a single or list
      #   of names to validate existence of.
      # @param match_type [Symbol] (optional) Defines how a check is
      #   made, default is :any also accepts :all
      #
      # @return [Boolean] True if matches found, false if not.
      def changed?(keys, match_type = :any)
        keys = Array.wrap(keys).map(&:to_sym)
        if match_type == :all
          (keys & @changes.keys).length == keys.length
        else
          (keys & @changes.keys).present?
        end
      end

      #
      # Looks up a change by name and returns it if found. If the
      # change is not found an empty Change instance is returned. This
      # prevents having to check for nil.
      #
      #   inst = Pedanco::Diffr::ChangeSet.new
      #   inst.add_change(:age, 40, 39)
      #
      #   # returns Pedanco::Diffr::Change(:age, current: 40, previous: 39)
      #   inst.get_change(:age)
      #
      # @param name [String,Symbol] The name of the change to lookup.
      #
      # @return [Change] The Change object by name,
      #   an empty change is returned if not found.
      def get_change(name)
        @changes.fetch(name.to_sym, Change.new(name.to_sym))
      end

      #
      # Finds and returns a ChangeSet as an array, used for legacy rendering
      # that expects changes to be in [current, previous] format.
      #
      # @param name [String,Symbol] (optional) The name of the change
      #
      # @return [Array] The Change as an array or empty if no change is found.
      def to_a(name = nil)
        if name.present?
          change = @changes[name.to_sym]
          change.present? ? change.to_a : []
        else
          @changes.map { |k, v| [k, v.to_a] }
        end
      end

      #
      # Converts the Change Set into an Hash.
      #
      #   {
      #     name: [current, previous]
      #   }
      #
      #
      # @return [Hash] The Change Set as an hash.
      def to_hash
        Hash[@changes.map { |k, v| [k, v.to_a] }]
      end

      #
      # Parses the ActiveModel::Dirty syntax to build a changeset.
      # The Dirty syntax is:
      #
      #   { 'property_name' => [old_value, new_value] }
      #
      # @param changes [Hash] An ActiveModel::Dirty changes hash
      #
      def parse_changes(changes)
        changes.each { |name, change| add_change(name, change[1], change[0]) }
      end

      private

      def parse_change_hash(hash)
        hash_array = hash.map do |k, v|
          name  = k.to_sym
          value = Array.wrap(v)
          [name, Change.new(name, value[0], value[1])]
        end
        Hash[hash_array]
      end
    end
  end
end
