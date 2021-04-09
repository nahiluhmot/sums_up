# frozen_string_literal: true

module SumsUp
  # To parahprase Rust's std::result docs[0]:
  #
  # Result is a type used for returning and propagating errors.
  # Result.success(value) represents a success and contains a value;
  # Result.failure(error) represents an error with a propagated error.
  #
  # [0] https://doc.rust-lang.org/std/result/
  Result = SumsUp.define(failure: :error, success: :value) do
    # Yield, wrapping the result in Result.success, or wrap the raised error
    # in Result.failure.
    def self.from_block
      success(yield)
    rescue StandardError => e
      failure(e)
    end

    # Map a function across the successful value (if present).
    def map
      match do |m|
        m.success { |value| Result.success(yield(value)) }
        m.failure self
      end
    end

    # Map a function across the error (if present).
    def map_failure
      match do |m|
        m.success self
        m.failure { |error| Result.failure(yield(error)) }
      end
    end
  end
end
