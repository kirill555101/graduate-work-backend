# frozen_string_literal: true

require 'rails_helper'

describe SyntaxAnalysis::StatementService do
  describe '#perform' do
    let(:service) { described_class.new(tokens_table) }

    context 'when tokens_table is blank' do
      let(:tokens_table) { [] }

      it 'must not execute' do
        expect(service).not_to receive(:token_for_current_state_valid?)
        service.perform
      end
    end

    context 'when blank' do
      let(:tokens_table) do
        [
          { lexeme: 'abc', type: :identifier },
          { lexeme: '=', type: :delimiter },
          { lexeme: '12345', type: :integer }
        ]
      end

      it 'must execute' do
        expect(service).not_to receive(:token_for_current_state_valid?)
        service.perform
      end
    end
  end
end
