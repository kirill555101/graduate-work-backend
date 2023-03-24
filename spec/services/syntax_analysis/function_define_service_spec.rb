# frozen_string_literal: true

require 'rails_helper'

describe SyntaxAnalysis::FunctionDefineService do
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
          { lexeme: 'def', type: :keyword },
          { lexeme: 'my_func', type: :identifier },
          { lexeme: '==', type: :delimiter },
          { lexeme: 'x', type: :identifier },
          { lexeme: ',', type: :delimiter },
          { lexeme: 'y', type: :identifier },
          { lexeme: '):', type: :delimiter }
        ]
      end

      it 'must raise an exception' do
        expect { service.perform }.to raise_exception(SyntaxAnalysis::ParseError, 'invalid token ==')
      end
    end

    context 'when token type is invalid' do
      let(:tokens_table) do
        [
          { lexeme: 'def', type: :example },
          { lexeme: 'my_func', type: :identifier },
          { lexeme: '(', type: :delimiter },
          { lexeme: 'x', type: :identifier },
          { lexeme: ',', type: :delimiter },
          { lexeme: 'y', type: :identifier },
          { lexeme: '):', type: :delimiter }
        ]
      end

      it 'must raise an exception' do
        expect { service.perform }.to raise_exception(SyntaxAnalysis::ParseError, 'invalid token type example')
      end
    end

    context 'when token sequence is invalid' do
      let(:tokens_table) do
        [
          { lexeme: 'def', type: :keyword },
          { lexeme: '(', type: :delimiter },
          { lexeme: 'my_func', type: :identifier },
          { lexeme: 'x', type: :identifier },
          { lexeme: ',', type: :delimiter },
          { lexeme: 'y', type: :identifier },
          { lexeme: '):', type: :delimiter }
        ]
      end

      it 'must raise an exception' do
        expect { service.perform }.to raise_exception(SyntaxAnalysis::ParseError, 'invalid token sequence')
      end
    end

    context 'when all is valid' do
      let(:tokens_table) do
        [
          { lexeme: 'def', type: :keyword },
          { lexeme: 'my_func', type: :identifier },
          { lexeme: '(', type: :delimiter },
          { lexeme: 'x', type: :identifier },
          { lexeme: ',', type: :delimiter },
          { lexeme: 'y', type: :identifier },
          { lexeme: '):', type: :delimiter }
        ]
      end

      it 'must not raise an exception' do
        expect { service.perform }.not_to raise_exception
        expect(service.current_state).to eq(described_class::STATES[:final])
      end
    end
  end
end
