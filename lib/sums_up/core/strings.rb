# frozen_string_literal: true

module SumsUp
  module Core
    # Helpers for Strings.
    module Strings
      module_function

      def snake_to_class(snake_case_name)
        snake_case_name
          .split("_")
          .map(&:capitalize)
          .join
      end
    end
  end
end
