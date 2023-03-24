# frozen_string_literal: true

module SyntaxAnalysis
  class ParseError < StandardError
    def initialize(msg)
      super(msg)
    end
  end

  class StatementService
    # First letter of 'keyword | identifier | string | integer | operator | delimiter'
    INPUT_DATA = 'kisiod'

    STATE_MACHINE = [].freeze

    attr_reader :tokens_table, :current_state

    def initialize(tokens_table)
      @tokens_table = tokens_table
    end

    def perform
      return if tokens_table.blank? || self.class::STATE_MACHINE.blank?

      @current_state = 0
      tokens_table.each_with_index do |token, index|
        raise ParseError, "invalid token #{token[:lexeme]}" unless token_for_current_state_valid?(token)

        first_letter = token[:type].to_s.chr
        input = INPUT_DATA.index(first_letter)
        raise ParseError, "invalid token type #{token[:type]}" if input.blank?

        if current_state == self.class::STATES[:final]
          raise ParseError, 'invalid token sequence' if index != tokens_table.length - 1
          break
        end
        @current_state = self.class::STATE_MACHINE[current_state][input]
        raise ParseError, 'invalid token sequence' if current_state.blank?
      end
    end

    protected

    def token_for_current_state_valid?(token)
      true
    end
  end
end
