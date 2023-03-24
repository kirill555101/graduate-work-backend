# frozen_string_literal: true

require 'rails_helper'

describe SyntaxAnalysis::CycleDefineService do
  describe '#perform' do
    let(:service) { described_class.new(tokens_table) }

    context 'when tokens_table is blank' do
      let(:tokens_table) { [] }

      it 'must not execute' do
        expect(service).not_to receive(:token_for_current_state_valid?)
        service.perform
      end
    end

    context 'when token lexeme is invalid' do
      let(:tokens_table) do
        [
          { lexeme: 'while', type: :keyword },
          { lexeme: 'a_1', type: :identifier },
          { lexeme: '=', type: :delimiter },
          { lexeme: '5', type: :integer },
          { lexeme: ':', type: :delimiter }
        ]
      end

      it 'must raise an exception' do
        expect { service.perform }.to raise_exception(SyntaxAnalysis::ParseError, 'invalid token =')
      end
    end

    context 'when token type is invalid' do
      let(:tokens_table) do
        [
          { lexeme: 'while', type: :example },
          { lexeme: 'a_1', type: :identifier },
          { lexeme: '>', type: :delimiter },
          { lexeme: '5', type: :integer },
          { lexeme: ':', type: :delimiter }
        ]
      end

      it 'must raise an exception' do
        expect { service.perform }.to raise_exception(SyntaxAnalysis::ParseError, 'invalid token type example')
      end
    end

    context 'when token sequence is invalid' do
      let(:tokens_table) do
        [
          { lexeme: 'while', type: :keyword },
          { lexeme: 'a_1', type: :identifier },
          { lexeme: '5', type: :integer },
          { lexeme: '>', type: :delimiter },
          { lexeme: ':', type: :delimiter }
        ]
      end

      it 'must raise an exception' do
        expect { service.perform }.to raise_exception(SyntaxAnalysis::ParseError, 'invalid token sequence')
      end
    end

    context 'when bracket count is not valid' do
      let(:tokens_table) do
        [
          { lexeme: 'while', type: :keyword },
          { lexeme: '(', type: :delimiter },
          { lexeme: '(', type: :delimiter },
          { lexeme: 'a_1', type: :identifier },
          { lexeme: '>', type: :delimiter },
          { lexeme: '5', type: :integer },
          { lexeme: '):', type: :delimiter }
        ]
      end

      it 'must raise an exception' do
        expect { service.perform }.to raise_exception(SyntaxAnalysis::ParseError, 'invalid bracket count')
      end
    end

    context 'when all is valid' do
      let(:tokens_table) do
        [
          { lexeme: 'while', type: :keyword },
          { lexeme: 'a_1', type: :identifier },
          { lexeme: '>', type: :delimiter },
          { lexeme: '5', type: :integer },
          { lexeme: ':', type: :delimiter }
        ]
      end

      it 'must not raise an exception' do
        expect { service.perform }.not_to raise_exception
        expect(service.current_state).to eq(described_class::STATES[:final])
      end
    end
  end
end
