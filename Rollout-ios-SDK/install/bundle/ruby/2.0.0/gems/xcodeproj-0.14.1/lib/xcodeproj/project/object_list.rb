module Xcodeproj
  class Project

    # This class represents an ordered relationship to many objects.
    #
    # It works in conjunction with the {AbstractObject} class to ensure that
    # the project is not serialized with unreachable objects by updating the
    # with reference count on modifications.
    #
    # @note Concerning the mutations methods it is safe to call only those
    #       which are overridden to inform objects reference count. Ideally all
    #       the array methods should be covered, but this is not done yet.
    #       Moreover it is a moving target because the methods of array
    #       usually are implemented in C
    #
    # @todo Cover all the mutations methods of the {Array} class.
    #
    class ObjectList < Array

      # {Xcodeproj} clients are not expected to create instances of
      # {ObjectList}, it is always initialized empty and automatically by the
      # synthesized methods generated by {AbstractObject.has_many}.
      #
      def initialize(attribute, owner)
        @attribute = attribute
        @owner = owner
      end

      # @return [Array<Class>] the attribute that generated the list.
      #
      attr_reader :attribute

      # @return [Array<Class>] the object that owns the list.
      #
      attr_reader :owner

      # @return [Array<String>]
      #   the UUIDs of all the objects referenced by this list.
      #
      def uuids
        map { |obj| obj.uuid }
      end

      # @return [Array<AbstractObject>]
      #   a new array generated with the objects contained in the list.
      #
      def objects
        to_a
      end


      public

      # @!group Notification enabled methods
      #------------------------------------------------------------------------#

      # TODO: the overridden methods are incomplete.

      # Adds an array of objects to list and updates their references count.
      #
      # @param [Array<AbstractObject, ObjectDictionary>] objects
      #   an array of objects to add to the list.
      #
      # @return [void]
      #
      def +(objects)
        perform_additions_operations(objects)
        super
      end

      # Appends an object to list the and updates its references count.
      #
      # @param  [AbstractObject, ObjectDictionary] object
      #         The object to add to the list.
      #
      # @return [void]
      #
      def <<(object)
        perform_additions_operations(object)
        super
      end

      # Adds an object to the given index of the list the and updates its
      # references count.
      #
      # @param  [AbstractObject, ObjectDictionary] object
      #         The object to add to the list.
      #
      # @return [void]
      #
      def insert(index, object)
        perform_additions_operations(object)
        super
      end

      # Prepends an object to the list and updates its references count.
      #
      # @param  [AbstractObject, ObjectDictionary] object
      #         The object to add to the list.
      #
      # @return [void]
      #
      def unshift(object)
        perform_additions_operations(object)
        super
      end

      # Removes an object to list and updates its references count.
      #
      # @param [AbstractObject, ObjectDictionary] object
      #   the object to delete from the list.
      #
      # @return [AbstractObject, ObjectDictionary, Nil] the object if found.
      #
      def delete(object)
        perform_deletion_operations(object)
        super
      end

      # Removes the object at the given index from the list and updates its
      # references count.
      #
      # @param [Fixnum] from
      #        The index of the object.
      #
      # @return [AbstractObject, ObjectDictionary, Nil] the object if found.
      #
      def delete_at(index)
        object = at(index)
        perform_deletion_operations(object)
        super
      end

      # Removes all the objects contained in the list and updates their
      # reference counts.
      #
      # @return [void]
      #
      def clear
        objects.each do |object|
          perform_deletion_operations(object)
        end
        super
      end

      # Moves the object at the given given index to the given position.
      #
      # @param [Fixnum] from
      #        The current index of the object.
      #
      # @param [Fixnum] to
      #        The new index for the object.
      #
      # @return [void]
      #
      def move(object, new_index)
        if obj = delete(object)
          insert(new_index, obj)
        else
          raise "Attempt to move object `#{object}` not present in the list `#{self.inspect}`"
        end
      end

      # Moves the object at the given given index to the given position.
      #
      # @param [Fixnum] from
      #        The current index of the object.
      #
      # @param [Fixnum] to
      #        The new index for the object.
      #
      # @return [void]
      #
      def move_from(current_index, new_index)
        if obj = delete_at(current_index)
          insert(new_index, obj)
        else
          raise "Attempt to move object from index `#{current_index}` which is beyond bounds of the list `#{self.inspect}`"
        end
      end


      private

      # @!group Notification Methods
      #------------------------------------------------------------------------#

      # Informs an object that it was added to the list. In practice it adds
      # the owner of the list as referrer to the objects. It also validates the
      # value.
      #
      # @return [void]
      #
      def perform_additions_operations(objects)
        objects = [objects] unless objects.is_a?(Array)
        objects.each do |obj|
          obj.add_referrer(owner)
          attribute.validate_value(obj) unless obj.is_a?(ObjectDictionary)
        end
      end

      # Informs an object that it was removed from to the list, so it can
      # remove its owner from its referrers and take the appropriate actions.
      #
      # @return [void]
      #
      def perform_deletion_operations(objects)
        objects = [objects] unless objects.is_a?(Array)
        objects.each do |obj|
          obj.remove_referrer(owner) unless obj.is_a?(ObjectDictionary)
        end
      end
    end
  end
end
