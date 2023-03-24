# frozen_string_literal: true

module SyntaxAnalysis
  module Assignment
    class ComplicatedService < StatementService
      # First letter of 'keyword | identifier | string | integer | operator | delimiter'
      STATE_MACHINE = [
        [ nil, 1,   nil, nil, nil, nil ],
        [ nil, nil, nil, nil, nil, 2   ],
        [ 3,   3,   3,   3,   nil, nil ],
        [ nil, nil, nil, nil, nil, nil ]
      ].freeze

      STATES = {
        first_identifier: 0,
        equality: 1,
        second_identifier: 2,
        final: 3
      }.freeze

      VALID_DELIMITERS = [
        '+=', '-=', '*=', '/=', '//=', '%=', '@=',
        '&=', '|=', '^=', '>>=', '<<=', '**='
      ].freeze

      VALID_IDENTIFIER_KEYWORDS = ['False', 'True', 'None'].freeze

      def initialize(tokens_table)
        super(tokens_table)
      end

      protected

      def token_for_current_state_valid?(token)
        return VALID_DELIMITERS.include?(token[:lexeme]) if current_state == STATES[:equality]
        if current_state == STATES[:second_identifier]
          return VALID_IDENTIFIER_KEYWORDS.include?(token[:lexeme]) if token[:type] == :keyword
        end
        true
      end
    end
  end
end
