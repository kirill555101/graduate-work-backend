# frozen_string_literal: true

module SyntaxAnalysis
  class FunctionReturnService < StatementService
    # First letter of 'keyword | identifier | string | integer | operator | delimiter'
    STATE_MACHINE = [
      [ 1,   nil, nil, nil, nil, nil ],
      [ 2,   2,   2,   2,   nil, nil ],
      [ nil, nil, nil, nil, nil, nil ]
    ].freeze

    STATES = {
      keyword: 0,
      identifier: 1,
      final: 2
    }.freeze

    VALID_IDENTIFIER_KEYWORDS = ['False', 'True', 'None'].freeze

    def initialize(tokens_table)
      super(tokens_table)
    end

    protected

    def token_for_current_state_valid?(token)
      return token[:lexeme] == 'return' if current_state == STATES[:keyword]
      if current_state == STATES[:identifier]
        return VALID_IDENTIFIER_KEYWORDS.include?(token[:lexeme]) if token[:type] == :keyword
      end
      true
    end
  end
end
