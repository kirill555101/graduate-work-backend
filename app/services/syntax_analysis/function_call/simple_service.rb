# frozen_string_literal: true

module SyntaxAnalysis
  module FunctionCall
    class SimpleService < StatementService
      # First letter of 'keyword | identifier | string | integer | operator | delimiter'
      STATE_MACHINE = [
        [ nil, 1,   nil, nil, nil, nil ],
        [ nil, nil, nil, nil, nil, 2   ],
        [ 3,   3,   3,   3,   nil, 4   ],
        [ nil, nil, nil, nil, nil, 2   ],
        [ nil, nil, nil, nil, nil, nil ]
      ].freeze

      STATES = {
        name: 0,
        start_arguments: 1,
        argument: 2,
        comma: 3,
        final: 4
      }.freeze

      VALID_IDENTIFIER_KEYWORDS = ['False', 'True', 'None'].freeze

      # VALID_END_DELIMITERS = [',', ')'].freeze

      def initialize(tokens_table)
        super(tokens_table)
      end

      protected

      def token_for_current_state_valid?(token)
        return token[:lexeme] == '(' if current_state == STATES[:start_arguments]
        if current_state == STATES[:argument]
          return VALID_IDENTIFIER_KEYWORDS.include?(token[:lexeme]) if token[:type] == :keyword
          return token[:lexeme] == ')' if token[:type] == :delimiter
        end
        if current_state == STATES[:comma]
          if token[:lexeme] == ')'
            @current_state = STATES[:final]
            return true
          end
          return token[:lexeme] == ','
        end
        # return VALID_END_DELIMITERS.include?(token[:lexeme]) if current_state == STATES[:comma]
        true
      end
    end
  end
end
