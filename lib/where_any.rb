# frozen_string_literal: true

require_relative 'where_any/version'

module WhereAny
  # @param name [String]
  # @return [ActiveRecord::Type::Value]
  def array_type_for_attribute(name)
    element_type = type_for_attribute(name)

    if (type = element_type.type)
      ActiveRecord::Type.lookup(type, array: true)
    else
      # For unknown types (e.g. from projected columns), use a generic array type.
      ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Array.new(element_type)
    end
  end

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
    attribute_type  = array_type_for_attribute(name)
    query_attribute = ActiveRecord::Relation::QueryAttribute.new(name.to_s, value, attribute_type)

    Arel::Nodes::BindParam.new(query_attribute)
  end

  # @param column [String, Symbol]
  # @param values [Array<Object>]
  # @return [ActiveRecord::Relation]
  def where_any(column, values)
    return none if values.blank?

    if (includes_null = values.include?(nil))
      values = values.compact
      return where(column => nil) if values.empty?
    end

    arel_column   = arel_table[column]
    any_of_values = Arel::Nodes::NamedFunction.new('ANY', [bind_array(column, values)])

    scope = where(arel_column.eq(any_of_values))
    scope = scope.or(where(column => nil)) if includes_null

    scope
  end

  # @param column [String, Symbol]
  # @param values [Array<Object>]
  # @return [ActiveRecord::Relation]
  def where_none(column, values)
    return all if values.blank?

    if (includes_null = values.include?(nil))
      values = values.compact
      return where.not(column => nil) if values.empty?
    end

    arel_column   = arel_table[column]
    all_of_values = Arel::Nodes::NamedFunction.new('ALL', [bind_array(column, values)])

    scope = where(arel_column.not_eq(all_of_values))
    scope = scope.where.not(column => nil) if includes_null

    scope
  end
end
