# frozen_string_literal: true

require 'rails_helper'

describe SyntaxAnalysis::FunctionReturnService do
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
          { lexeme: 'return1', type: :keyword },
          { lexeme: 'a', type: :identifier }
        ]
      end

      it 'must raise an exception' do
        expect { service.perform }.to raise_exception(SyntaxAnalysis::ParseError, 'invalid token return1')
      end
    end

    context 'when token type is invalid' do
      let(:tokens_table) do
        [
          { lexeme: 'return', type: :example },
          { lexeme: 'a', type: :identifier }
        ]
      end

      it 'must raise an exception' do
        expect { service.perform }.to raise_exception(SyntaxAnalysis::ParseError, 'invalid token type example')
      end
    end

    context 'when token sequence is invalid' do
      let(:tokens_table) do
        [
          { lexeme: 'return', type: :keyword },
          { lexeme: '=', type: :delimiter }
        ]
      end

      it 'must raise an exception' do
        expect { service.perform }.to raise_exception(SyntaxAnalysis::ParseError, 'invalid token sequence')
      end
    end

    context 'when all is valid' do
      let(:tokens_table) do
        [
          { lexeme: 'return', type: :keyword },
          { lexeme: 'a', type: :identifier }
        ]
      end

      it 'must not raise an exception' do
        expect { service.perform }.not_to raise_exception
        expect(service.current_state).to eq(described_class::STATES[:final])
      end
    end
  end
end
