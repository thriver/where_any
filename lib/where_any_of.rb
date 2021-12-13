# frozen_string_literal: true

require_relative 'where_any_of/version'

require 'active_support/concern'

module WhereAnyOf
  include ActiveSupport::Concern

  class_methods do
    # @param name [String]
    # @param value [Object]
    # @return [Arel::Nodes::Node]
    def bind_param(name, value)
      attribute_type  = type_for_attribute(name)
      query_attribute = ActiveRecord::Relation::QueryAttribute.new(name.to_s, value, attribute_type)

      Arel::Nodes::BindParam.new(query_attribute)
    end

    # @param name [String]
    # @param value [Object]
    # @return [Arel::Nodes::Node]
    def bind_array(name, value)
      element_type    = type_for_attribute(name)
      attribute_type  = ActiveRecord::Type.lookup(element_type.type, array: true)
      query_attribute = ActiveRecord::Relation::QueryAttribute.new(name.to_s, value, attribute_type)

      Arel::Nodes::BindParam.new(query_attribute)
    end
  end

  included do
    scope :where_any_of, lambda { |column, values|
      return none if values.blank?

      arel_column   = arel_table[column]
      any_of_values = Arel::Nodes::NamedFunction.new('ANY', [bind_array(column, values)])

      where(arel_column.eq(any_of_values))
    }

    scope :where_not_any_of, lambda { |column, values|
      return all if values.blank?

      arel_column   = arel_table[column]
      any_of_values = Arel::Nodes::NamedFunction.new('ANY', [bind_array(column, values)])

      where(arel_column.not_eq(any_of_values))
    }
  end
end
