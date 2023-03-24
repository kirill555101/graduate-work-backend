# frozen_string_literal: true

module SyntaxAnalysis
  class FunctionDefineService < StatementService
    # First letter of 'keyword | identifier | string | integer | operator | delimiter'
    STATE_MACHINE = [
      [ 1,   nil, nil, nil, nil, nil ],
      [ nil, 2,   nil, nil, nil, nil ],
      [ nil, nil, nil, nil, nil, 3   ],
      [ 4,   4,   4,   4,   nil, 5   ],
      [ nil, nil, nil, nil, nil, 3   ],
      [ nil, nil, nil, nil, nil, nil ]
    ].freeze

    STATES = {
      keyword: 0,
      name: 1,
      start_arguments: 2,
      argument: 3,
      comma: 4,
      final: 5
    }.freeze

    VALID_IDENTIFIER_KEYWORDS = ['False', 'True', 'None'].freeze

    # VALID_END_DELIMITERS = [',', '):'].freeze

    def initialize(tokens_table)
      super(tokens_table)
    end

    protected

    def token_for_current_state_valid?(token)
      return token[:lexeme] == 'def' if current_state == STATES[:keyword]
      return token[:lexeme] == '(' || token[:lexeme] == '():' if current_state == STATES[:start_arguments]
      if current_state == STATES[:argument]
        return VALID_IDENTIFIER_KEYWORDS.include?(token[:lexeme]) if token[:type] == :keyword
        return token[:lexeme] == '):' if token[:type] == :delimiter
      end
      if current_state == STATES[:comma]
        if token[:lexeme] == '):'
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
