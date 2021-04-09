# frozen_string_literal: true

module SumsUp
  module Core
    # Helpers for functions.
    module Functions
      module_function

      def const(value)
        proc { value }
      end
    end
  end
end
