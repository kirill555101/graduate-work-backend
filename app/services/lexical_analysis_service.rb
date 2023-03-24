# frozen_string_literal: true

class LexicalAnalysisError < StandardError
  def initialize(msg)
    super(msg)
  end
end

class LexicalAnalysisService
  KEYWORDS = %w[False None True and def del elif else for if in is not or return while].freeze

  IDENTIFIER_REGEX = /^[a-zA-Z_]+\w*$/

  STRING_REGEX = /^['"]\w*['"]$/

  INTEGER_REGEX = /^([+-]?[1-9]\d*|0)$/

  OPERATORS = [
    '+', '-', '*', '**', '/', '//', '%', '@', '<<', '>>', '&', '|', '^', '~',
    '<', '>', '<=', '>=', '==', '!='
  ].freeze

  DELIMITERS = [
    '\(', '\)', '\[', '\]', '\{', '\}', ' ', '\,' '\:', '\.', ';', '@', '=', '+=',
    '-=', '*=', '/=', '//=','%=', '@=', '&=', '|=', '^=', '>>=', '<<=', '**='
  ].freeze

  attr_reader :line

  def initialize(line)
    @line = line
  end

  def perform
    return if line.blank? || line.start_with?('#')

    current_line = line.clone.gsub('  ', '')
    tokens_table = []

    loop do
      break if current_line.blank?

      delimiter_index = current_line =~ delimiter_regex
      lexeme =
        if delimiter_index.present?
          current_line.slice(0, delimiter_index)
        else
          current_line.dup
        end

      if lexeme.present?
        type =
          case true
          when valid_keyword?(lexeme)
            :keyword
          when valid_identifier?(lexeme)
            :identifier
          when valid_string?(lexeme)
            :string
          when valid_integer?(lexeme)
            :integer
          when valid_operator?(lexeme)
            :operator
          end

        raise LexicalAnalysisError, "invalid token #{lexeme}" if type.blank?
        tokens_table.push({ lexeme: lexeme, type: type })
      end

      next current_line.clear if delimiter_index.blank?
      current_line = current_line.slice(delimiter_index, current_line.length)

      not_delimiter_index = current_line =~ delimiter_regex(match: false)
      delimiter =
        if not_delimiter_index.present?
          current_line.slice(0, not_delimiter_index)
        else
          current_line.dup
        end

      lexeme = delimiter.delete(' ')
      tokens_table.push({ lexeme: lexeme, type: :delimiter }) if lexeme.present?

      next current_line.clear if not_delimiter_index.blank?
      current_line = current_line.slice(not_delimiter_index, current_line.length)
    end

    tokens_table
  end

  private

  def delimiter_regex(match: true)
    if match
      /[#{DELIMITERS.join}]/
    else
      /[^#{DELIMITERS.join}]/
    end
  end

  def valid_keyword?(token)
    KEYWORDS.include?(token)
  end

  def valid_identifier?(token)
    IDENTIFIER_REGEX.match(token).present?
  end

  def valid_string?(token)
    STRING_REGEX.match(token).present? && \
      (token.start_with?('\'') && token.end_with?('\'') || token.start_with?('"') && token.end_with?('"'))
  end

  def valid_integer?(token)
    INTEGER_REGEX.match(token).present?
  end

  def valid_operator?(token)
    OPERATORS.include?(token)
  end
end
