# frozen_string_literal: true

require 'rails_helper'

describe CodeParserService do
  describe '#perform' do
    let(:service) { described_class.new(code) }

    context 'when code is blank' do
      let(:code) { '' }

      it 'must not execute' do
        expect_any_instance_of(LexicalAnalysisService).not_to receive(:delimiter_regex)
        service.perform
      end
    end

    context 'when code contains lexical error' do
      let(:code) { "print('some_not_valid_string)" }

      it 'must return an error' do
        result, error = service.perform
        expect(result).to be_blank
        expect(error).to eq("Line 1: LexicalAnalysisError: invalid token 'some_not_valid_string")
      end
    end

    context 'when code contains syntax error' do
      let(:code) { 'a == 55' }

      it 'must return an error' do
        result, error = service.perform
        expect(result).to be_blank
        expect(error).to eq('Line 1: SyntaxAnalysisError: invalid line')
      end
    end

    context 'when all is valid' do
      let(:code) do
        <<~CODE
          a = 0
          while a < 5:
          \tif a > 2:
          \t\ta = a + 2
          \telse:
          \t\ta = a + 1
          \t\tprint(a)
        CODE
      end
      let(:tree) do
        {
          main: {
            params: '',
            lines: [
              {
                type: :block,
                value: 'a = 0'
              },
              {
                type: :cycle,
                value: 'a < 5',
                lines: [
                  {
                    type: :condition,
                    subtype: 'if',
                    value: 'a > 2',
                    lines: [
                      {
                        type: :block,
                        value: 'a = a + 2'
                      }
                    ]
                  },
                  {
                    type: :condition,
                    subtype: 'else',
                    value: '',
                    lines: [
                      {
                        type: :block,
                        value: 'a = a + 1'
                      },
                      {
                        type: :print,
                        value: 'a'
                      }
                    ]
                  }
                ]
              },
              {
                type: :function_return,
                value: ''
              }
            ]
          }
        }
      end

      it 'must return correct tree' do
        result, error = service.perform
        expect(result).to eq(tree)
        expect(error).to be_blank
      end
    end
  end
end
