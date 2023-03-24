# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::CodeCommandsController do
  describe '#generate_tree' do
    context 'when get request' do
      context 'when code is not valid' do
        let(:code) { 'a == 55' }
        let(:message) { 'Line 1: SyntaxAnalysisError: invalid line' }

        it 'must return error' do
          post(:generate_tree, params: { code: code })
          expect(response.status).to eq(400)
          expect(response.body).to eq({ message: message }.to_json)
        end
      end

      context 'when code is valid' do
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
          get(:generate_tree, params: { code: code })
          expect(response.status).to eq(200)
          expect(response.body).to eq({ tree: tree }.to_json)
        end
      end
    end
  end

  describe '#execute' do
    context 'when post request' do
      it 'must return error' do
        post(:execute)
        # expect(response.status).to eq(501)
        # expect(response.body).to be_blank
      end
    end
  end
end
