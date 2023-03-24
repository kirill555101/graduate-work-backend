# frozen_string_literal: true

class CodeExecuterError < StandardError
  def initialize(msg)
    super(msg)
  end
end

class CodeExecuterService
  attr_reader :code

  def initialize(code)
    @code = code
  end

  def perform
    return if code.blank?

    code.gsub("\r\n", "\n").gsub("\r", "\n").split("\n").each_with_index do |line, index|
      next if line.blank? || line.start_with?('#')

      raise IndentationError, 'unexpected indent' unless valid_indent?(line, indent)
      loop do
        break unless line.start_with?(TAB)
        line.sub!(TAB, '')
      end

      tokens_table = LexicalAnalysisService.new(line).perform
    rescue => e
      raise CodeExecuterError, "Line #{index + 1}: #{e.class}: #{e.message}"
    end

    [true, nil]
  rescue CodeExecuterError => e
    [false, e.message]
  end
end
