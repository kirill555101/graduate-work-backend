# frozen_string_literal: true

class IndentationError < StandardError
  def initialize(msg)
    super(msg)
  end
end

class StatementError < StandardError
  def initialize(msg)
    super(msg)
  end
end

class SyntaxAnalysisError < StandardError
  def initialize(msg)
    super(msg)
  end
end

class CodeParserError < StandardError
  def initialize(msg)
    super(msg)
  end
end

class CodeParserService
  TAB = "\t"

  SYNTAX_ANALYSIS_CLASSES = [
    SyntaxAnalysis::Assignment::SimpleService,
    SyntaxAnalysis::Assignment::ComplicatedService,
    SyntaxAnalysis::Assignment::ArrayService,
    SyntaxAnalysis::Assignment::ArrayIndexService,
    SyntaxAnalysis::FunctionCall::SimpleService,
    SyntaxAnalysis::FunctionCall::ComplicatedService,
    SyntaxAnalysis::FunctionDefineService,
    SyntaxAnalysis::ConditionDefineService,
    SyntaxAnalysis::CycleDefineService,
    SyntaxAnalysis::FunctionReturnService
  ].freeze

  attr_reader :code, :indent, :diagram_creator, :tokens_table

  def initialize(code, indent = 0, diagram_creator = DiagramCreatorService.new)
    @code = code
    @indent = indent
    @diagram_creator = diagram_creator
  end

  def perform
    return if code.blank?

    temp_code_array = code.clone.gsub("\r\n", "\n").gsub("\r", "\n").split("\n")
    code.gsub("\r\n", "\n").gsub("\r", "\n").split("\n").each_with_index do |line, index|
      next if line.blank? || line.start_with?('#') || temp_code_array.first != line

      temp_code_array.delete(line)
      raise IndentationError, 'unexpected indent' unless valid_indent?(line, indent)
      loop do
        break unless line.start_with?(TAB)
        line.sub!(TAB, '')
      end

      @tokens_table = LexicalAnalysisService.new(line).perform

      # statement_service =
      #   case true
      #   when simple_assignment_line?(tokens_table)
      #     SyntaxAnalysis::Assignment::SimpleService.new(tokens_table)
      #   when complicated_assignment_line?(tokens_table)
      #     SyntaxAnalysis::Assignment::ComplicatedService.new(tokens_table)
      #   when array_assignment_line?(tokens_table)
      #     SyntaxAnalysis::Assignment::ArrayService.new(tokens_table)
      #   when array_index_assignment_line?(tokens_table)
      #     SyntaxAnalysis::Assignment::ArrayIndexService.new(tokens_table)
      #   when simple_function_call_line?(tokens_table)
      #     SyntaxAnalysis::FunctionCall::SimpleService.new(tokens_table)
      #   when complicated_function_call_line?(tokens_table)
      #     SyntaxAnalysis::FunctionCall::ComplicatedService.new(tokens_table)
      #   when function_define_line?(tokens_table)
      #     SyntaxAnalysis::FunctionDefineService.new(tokens_table)
      #   when condition_define_line?(tokens_table)
      #     SyntaxAnalysis::ConditionDefineService.new(tokens_table)
      #   when cycle_define_line?(tokens_table)
      #     SyntaxAnalysis::CycleDefineService.new(tokens_table)
      #   when function_return_line?(tokens_table)
      #     SyntaxAnalysis::FunctionReturnService.new(tokens_table)
      #   end

      # raise StatementError, 'invalid statement' if statement_service.blank?
      # statement_service.perform

      syntax_analysis_perform

      unless need_to_create_block?
        type, args =
          case true
          when print_line?
            [:print, print_args]
          when function_call_line?
            [:function_call, { value: line }]
          when function_return_line?
            [:function_return, { value: line }]
          else
            [:block, { value: line }]
          end
        next diagram_creator.add_line(type, args)
      end

      type, args =
        case true
        when function_define_line?
          [:function, function_args]
        when condition_define_line?
          [:condition, condition_args]
        when cycle_define_line?
          [:cycle, cycle_args]
        end

      raise StatementError, 'invalid new block' if type.blank?
      diagram_creator.create_block(type, args)

      next_index = temp_code_array.index do |line_to_find|
        indent == 0 && !line_to_find.start_with?(TAB) ||
          indent > 0 && line_to_find.start_with?(TAB * indent) && !line_to_find.start_with?(TAB * (indent + 1))
      end || temp_code_array.length

      sliced_array = temp_code_array.slice(0, next_index)
      CodeParserService.new(sliced_array.join("\n"), indent + 1, diagram_creator).perform

      diagram_creator.end_block
      temp_code_array = temp_code_array - sliced_array
    rescue => e
      raise CodeParserError, "Line #{index + 1}: #{e.class}: #{e.message}"
    end
    diagram_creator.add_return if indent <= 1
    [diagram_creator.diagram, nil]
  rescue CodeParserError => e
    [{}, e.message]
  end

  private

  def valid_indent?(line, indent)
    indent == 0 && !line.start_with?(TAB) || indent > 0 && line.start_with?(TAB * indent)
  end

  def syntax_analysis_perform
    analysis_result = []
    SYNTAX_ANALYSIS_CLASSES.each do |class_name|
      class_name.new(tokens_table).perform
      analysis_result.push(true)
    rescue
      analysis_result.push(false)
    end
    analysis_bad_result = analysis_result.filter { |res| res == false }
    raise SyntaxAnalysisError, 'invalid line' if analysis_bad_result.count == SYNTAX_ANALYSIS_CLASSES.count
  end

  # def simple_assignment_line?(tokens_table)
  #   tokens_table.first[:type] == :identifier && tokens_table.find { |token| token[:lexeme] == '=' }.present?
  # end

  # def complicated_assignment_line?(tokens_table)
  #   tokens_table.first[:type] == :identifier &&
  #     tokens_table.find { |token| token[:lexeme].end_with?('=') && token[:lexeme] != '=' }.present?
  # end

  # def array_assignment_line?(tokens_table)
  #   tokens_table.first[:type] == :identifier &&
  #     tokens_table[1][:lexeme] == '=' &&
  #     tokens_table.find { |token| token[:lexeme].end_with?('(') || token[:lexeme].end_with?('[') }.present? &&
  #     tokens_table.find { |token| token[:lexeme] == ')' || token[:lexeme] == ']' }.present?
  # end

  # def array_index_assignment_line?(tokens_table)
  #   tokens_table.first[:type] == :identifier &&
  #     tokens_table[1][:lexeme] == '=' && tokens_table[2][:type] == :identifier &&
  #     tokens_table.find { |token| token[:lexeme] == '(' || token[:lexeme] == '[' }.present? &&
  #     tokens_table.find { |token| token[:lexeme] == ')' || token[:lexeme] == ']' }.present?
  # end

  def simple_function_call_line?
    tokens_table.first[:type] == :identifier && tokens_table.find { |token| token[:lexeme] == '=' }.blank? &&
      tokens_table.find { |token| token[:lexeme] == '(' }.present? &&
      tokens_table.find { |token| token[:lexeme] == ')' }.present?
  end

  def complicated_function_call_line?
    tokens_table.first[:type] == :identifier && tokens_table.find { |token| token[:lexeme] == '=' }.present? &&
      tokens_table.find { |token| token[:lexeme] == '(' }.present? &&
      tokens_table.find { |token| token[:lexeme] == ')' }.present?
  end

  def function_define_line?
    tokens_table.first[:lexeme] == 'def'
  end

  def condition_define_line?
    tokens_table.first[:lexeme] == 'if' || tokens_table.first[:lexeme] == 'elsif' ||
      tokens_table.first[:lexeme] == 'else'
  end

  def cycle_define_line?
    tokens_table.first[:lexeme] == 'while'
  end

  def function_return_line?
    tokens_table.first[:lexeme] == 'return'
  end

  def need_to_create_block?
    tokens_table.last[:lexeme].end_with?(':')
  end

  def print_line?
    simple_function_call_line? && tokens_table.first[:lexeme] == 'print'
  end

  def function_call_line?
    simple_function_call_line? || complicated_function_call_line?
  end

  def print_args
    temp_tokens_table = tokens_table.clone
    temp_tokens_table.shift(2)
    temp_tokens_table.pop
    value = temp_tokens_table.map { |token| token[:lexeme] }.join(' ')
    {
      value: value
    }
  end

  # def function_return_args
  #   temp_tokens_table = tokens_table.clone
  #   temp_tokens_table.shift
  #   value = temp_tokens_table.map { |token| token[:lexeme] }.join(' ')
  #   {
  #     value: value
  #   }
  # end

  def function_args
    name = tokens_table[1][:lexeme]
    temp_tokens_table = tokens_table.clone
    temp_tokens_table.shift(3)
    temp_tokens_table.pop
    value = temp_tokens_table.map { |token| token[:lexeme] }.join(' ')
    {
      name: name,
      value: value
    }
  end

  def condition_args
    subtype = tokens_table.first[:lexeme]
    temp_tokens_table = tokens_table.clone
    temp_tokens_table.shift
    temp_tokens_table.shift if temp_tokens_table.first[:lexeme] == '('
    temp_tokens_table.pop
    value = temp_tokens_table.map { |token| token[:lexeme] }.join(' ')
    {
      subtype: subtype,
      value: value
    }
  end

  def cycle_args
    temp_tokens_table = tokens_table.clone
    temp_tokens_table.shift
    temp_tokens_table.shift if temp_tokens_table.first[:lexeme] == '('
    temp_tokens_table.pop
    value = temp_tokens_table.map { |token| token[:lexeme] }.join(' ')
    {
      value: value
    }
  end
end
