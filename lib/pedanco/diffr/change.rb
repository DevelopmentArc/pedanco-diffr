module Pedanco
  module Diffr
    #
    # A Change represents a current and previous state for specifc piece of
    # data. These states can represent any kind of information and are linked
    # by the name of the data they represent.
    #
    #   Pedanco::Diffr::Change.new(:first_name, 'Jim', 'James')
    #
    # @!attribute [rw] name
    #   @return [String,Symbol] the name identifier for the change set
    # @!attribute [rw] current
    #   @return [Any] the current state of the change
    # @!attribute [rw] previous
    #   @return [Any] the previous state of the change
    #
    # @author [jpolanco]
    #
    class Change
      attr_accessor :name, :current, :previous

      #
      # Initializes the data when passed via new().
      #
      # @param name [String/Symbol] (required) The name of the data
      # @param current: nil [Any] (optional) The current value for the
      #   change, defaults to nil.
      # @param previous: nil [Any] (optional) The previous value for the
      #   change, defaults to nil.
      #
      # @raise [RuntimeError] if name is nil or ''
      def initialize(name, current: nil, previous: nil)
        fail 'Name is required for a Change.' if name.blank?
        @name     = name
        @current  = current
        @previous = previous
      end

      #
      # Converts the Change into an array, following the ActiveRecord
      # changes syntax. The first position is the previous value, the
      # second is the current value.
      #
      # @return [Array] The array version of the Change
      def to_a
        [@previous, @current]
      end
    end
  end
end
