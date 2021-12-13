# frozen_string_literal: true

require_relative 'where_any/version'

require 'active_support/concern'

module WhereAny
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
    # @!method where_any(column, values)
    #   @param column [String, Symbol]
    #   @param values [Array<Object>]
    #   @return [ActiveRecord::Relation]
    scope :where_any, lambda { |column, values|
      return none if values.blank?

      arel_column   = arel_table[column]
      any_of_values = Arel::Nodes::NamedFunction.new('ANY', [bind_array(column, values)])

      where(arel_column.eq(any_of_values))
    }

    # @!method where_none(column, values)
    #   @param column [String, Symbol]
    #   @param values [Array<Object>]
    #   @return [ActiveRecord::Relation]
    scope :where_none, lambda { |column, values|
      return all if values.blank?

      arel_column   = arel_table[column]
      all_of_values = Arel::Nodes::NamedFunction.new('ALL', [bind_array(column, values)])

      where(arel_column.not_eq(all_of_values))
    }
  end
end