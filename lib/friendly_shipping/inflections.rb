# frozen_string_literal: true

# Make autoloading of R&L classes work in Rails
if Object.const_defined?('ActiveSupport::Inflector')
  ActiveSupport::Inflector.inflections(:en) do |inflect|
    inflect.acronym 'RL'
  end
end
