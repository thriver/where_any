# frozen_string_literal: true

require 'spec_helper'

RSpec.describe WhereAny do
  before(:all) do
    @model_class = Class.new(ActiveRecord::Base) do
      self.table_name = 'test_models'
      extend WhereAny
    end

    ActiveRecord::Schema.define do
      create_table :test_models, temporary: true, force: true do |t|
        t.string :name
        t.string :reference, index: true, null: true
        t.timestamps
      end
    end

    @record1 = @model_class.create!(name: 'one', reference: '1')
    @record2 = @model_class.create!(name: 'two', reference: '2')
    @record3 = @model_class.create!(name: 'three', reference: '3')
    @record_null = @model_class.create!(name: nil, reference: nil)
  end

  it 'has a version number' do
    expect(WhereAny::VERSION).not_to be_nil
  end

  describe '#where_any' do
    it 'finds records matching any value in the array' do
      result = @model_class.where_any(:reference, %w[1 2])
      expect(result).to contain_exactly(@record1, @record2)
    end

    it 'returns none for empty array' do
      result = @model_class.where_any(:reference, [])
      expect(result).to be_empty
    end

    it 'handles null values' do
      result = @model_class.where_any(:reference, ['1', nil])
      expect(result).to contain_exactly(@record1, @record_null)
    end

    it 'handles array with only null' do
      result = @model_class.where_any(:reference, [nil])
      expect(result).to contain_exactly(@record_null)
    end

    it 'generates SQL using ANY' do
      query = @model_class.where_any(:reference, %w[1 2]).to_sql
      expect(query).to include('= ANY')
    end

    it 'matches ActiveRecord where behavior for non-null values' do
      ar_result = @model_class.where(reference: %w[1 2]).to_a
      where_any_result = @model_class.where_any(:reference, %w[1 2]).to_a
      expect(where_any_result).to match_array(ar_result)
    end

    it 'matches ActiveRecord where behavior with null values' do
      ar_result = @model_class.where(reference: ['1', nil]).to_a
      where_any_result = @model_class.where_any(:reference, ['1', nil]).to_a
      expect(where_any_result).to match_array(ar_result)
    end
  end

  describe '#where_none' do
    it 'matches ActiveRecord where behavior for non-null values' do
      ar_result = @model_class.where.not(reference: %w[1 2]).to_a
      where_none_result = @model_class.where_none(:reference, %w[1 2]).to_a
      expect(where_none_result).to match_array(ar_result)
    end

    it 'matches ActiveRecord where behavior with null values' do
      ar_result = @model_class.where.not(reference: ['1', nil]).to_a
      where_none_result = @model_class.where_none(:reference, ['1', nil]).to_a
      expect(where_none_result).to match_array(ar_result)
    end

    it 'returns all records for empty array' do
      result = @model_class.where_none(:reference, [])
      expect(result).to contain_exactly(@record1, @record2, @record3, @record_null)
    end

    it 'handles null values' do
      result = @model_class.where_none(:reference, ['1', nil])
      expect(result).to contain_exactly(@record2, @record3)
    end

    it 'handles array with only null' do
      result = @model_class.where_none(:reference, [nil])
      expect(result).to contain_exactly(@record1, @record2, @record3)
    end

    it 'generates SQL using ALL' do
      query = @model_class.where_none(:reference, %w[1 2]).to_sql
      expect(query).to include('!= ALL')
    end
  end
end
