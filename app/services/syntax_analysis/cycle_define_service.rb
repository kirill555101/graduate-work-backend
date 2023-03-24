# frozen_string_literal: true

module SyntaxAnalysis
  class CycleDefineService < StatementService
    # First letter of 'keyword | identifier | string | integer | operator | delimiter'
    STATE_MACHINE = [
      [ 1, nil, nil, nil, nil, nil ],
      [ 4, 2,   2,   2,   nil, 1   ],
      [ 3, nil, nil, nil, 3,   3   ],
      [ 4, 4,   4,   4,   nil, nil ],
      [ 1, nil, nil, nil, nil, 4   ]
    ].freeze

    STATES = {
      keyword: 0,
      start_condition: 1,
      symbol: 2,
      last_identifier: 3,
      end_condition: 4
    }.freeze

    VALID_START_KEYWORDS = ['while'].freeze

    VALID_IDENTIFIER_KEYWORDS = ['False', 'True', 'None'].freeze

    VALID_SYMBOL_KEYWORDS = ['is', 'in'].freeze

    VALID_SYMBOL_OPERATORS = ['<', '>', '<=', '>=', '==', '!='].freeze

    VALID_BETWEEN_KEYWORDS = ['or', 'and'].freeze

    # VALID_END_DELIMITERS = [')', '):', ':'].freeze

    def initialize(tokens_table)
      super(tokens_table)
    end

    def perform
      raise ParseError, 'invalid bracket count' if start_bracket_count != end_bracket_count
      super
    end

    protected

    def token_for_current_state_valid?(token)
      return VALID_START_KEYWORDS.include?(token[:lexeme]) if current_state == STATES[:keyword]
      if current_state == STATES[:start_condition]
        return VALID_IDENTIFIER_KEYWORDS.include?(token[:lexeme]) if token[:type] == :keyword
        return token[:lexeme] == '(' if token[:type] == :delimiter
      end
      if current_state == STATES[:symbol]
        return VALID_SYMBOL_KEYWORDS.include?(token[:lexeme]) if token[:type] == :keyword
        if token[:type] == :operator || token[:type] == :delimiter
          return VALID_SYMBOL_OPERATORS.include?(token[:lexeme])
        end
      end
      if current_state == STATES[:last_identifier]
        return VALID_IDENTIFIER_KEYWORDS.include?(token[:lexeme]) if token[:type] == :keyword
      end
      if current_state == STATES[:end_condition]
        return VALID_BETWEEN_KEYWORDS.include?(token[:lexeme]) if token[:type] == :keyword
        if token[:type] == :delimiter
          if token[:lexeme] == '):' || token[:lexeme] == ':'
            @current_state = STATES[:final]
            return true
          end
          return token[:lexeme] == ','
        end
        # return VALID_END_DELIMITERS.include?(token[:lexeme]) if token[:type] == :delimiter
      end
      true
    end

    def start_bracket_count
      @start_bracket_count ||= tokens_table.filter { |token| token[:lexeme] == '(' }.count
    end

    def end_bracket_count
      @end_bracket_count ||= tokens_table.filter do |token|
        token[:lexeme] == ')' || token[:lexeme].starts_with?(')')
      end.count
    end
  end
end
