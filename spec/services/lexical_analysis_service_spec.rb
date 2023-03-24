# frozen_string_literal: true

require 'rails_helper'

describe LexicalAnalysisService do
  describe '#perform' do
    let(:service) { described_class.new(line) }

    context 'when line is blank' do
      let(:line) { '' }

      it 'must not execute' do
        expect(service).not_to receive(:delimiter_regex)
        service.perform
      end
    end

    context 'when line is a comment' do
      let(:line) { '# some_code' }

      it 'must not execute' do
        expect(service).not_to receive(:delimiter_regex)
        service.perform
      end
    end

    context 'when line contains tokens' do
      context 'when identifier token is not valid' do
        let(:line) { '1a = 5' }

        it 'must raise an exception' do
          expect { service.perform }.to raise_exception(LexicalAnalysisError)
        end
      end

      context 'when string token is not valid' do
        let(:line) { 'a = "string' }

        it 'must raise an exception' do
          expect { service.perform }.to raise_exception(LexicalAnalysisError)
        end
      end

      context 'when integer token is not valid' do
        let(:line) { 'a = 125q' }

        it 'must raise an exception' do
          expect { service.perform }.to raise_exception(LexicalAnalysisError)
        end
      end

      context 'when tokens are valid' do
        tests = [
          {
            input: 'def my_func(x, y):',
            expected: [
              { lexeme: 'def', type: :keyword },
              { lexeme: 'my_func', type: :identifier },
              { lexeme: '(', type: :delimiter },
              { lexeme: 'x', type: :identifier },
              { lexeme: ',', type: :delimiter },
              { lexeme: 'y', type: :identifier },
              { lexeme: '):', type: :delimiter }
            ]
          },
          {
            input: 'abc = 12345',
            expected: [
              { lexeme: 'abc', type: :identifier },
              { lexeme: '=', type: :delimiter },
              { lexeme: '12345', type: :integer },
            ]
          },
          {
            input: 'if _a == "string" and hidden is False:',
            expected: [
              { lexeme: 'if', type: :keyword },
              { lexeme: '_a', type: :identifier },
              { lexeme: '==', type: :delimiter },
              { lexeme: '"string"', type: :string },
              { lexeme: 'and', type: :keyword },
              { lexeme: 'hidden', type: :identifier },
              { lexeme: 'is', type: :keyword },
              { lexeme: 'False', type: :keyword },
              { lexeme: ':', type: :delimiter }
            ]
          },
          {
            input: 'while a_1 > 5:',
            expected: [
              { lexeme: 'while', type: :keyword },
              { lexeme: 'a_1', type: :identifier },
              { lexeme: '>', type: :delimiter },
              { lexeme: '5', type: :integer },
              { lexeme: ':', type: :delimiter }
            ]
          },
          {
            input: 'variable = my_func(5, 10)',
            expected: [
              { lexeme: 'variable', type: :identifier },
              { lexeme: '=', type: :delimiter },
              { lexeme: 'my_func', type: :identifier },
              { lexeme: '(', type: :delimiter },
              { lexeme: '5', type: :integer },
              { lexeme: ',', type: :delimiter },
              { lexeme: '10', type: :integer },
              { lexeme: ')', type: :delimiter }
            ]
          }
        ]

        tests.each do |test|
          it 'must return expected tokens table' do
            tokens_table = described_class.new(test[:input]).perform
            expect(tokens_table).to eq(test[:expected])
          end
        end
      end
    end
  end
end
