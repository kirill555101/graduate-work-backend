# frozen_string_literal: true

require 'rails_helper'

describe DiagramCreatorService do
  let(:service) { described_class.new }

  describe '#create_block' do
    context 'when type is invalid' do
      it 'must do nothing' do
        expect(service).not_to receive(:send)
        service.create_block(:some_type, {})
      end
    end

    context 'when type is function' do
      let(:args) do
        {
          name: 'sum',
          value: ''
        }
      end
      let(:diagram) do
        {
          sum: {
            params: '',
            lines: []
          }
        }
      end
      let(:route) { [:sum, :lines] }

      it 'must create function block' do
        service.create_block(:function, args)
        expect(service.diagram).to eq(diagram)
      end
    end

    context 'when type is condition' do
      let(:args) do
        {
          subtype: 'if',
          value: 'a > b'
        }
      end
      let(:diagram) do
        {
          main: {
            params: '',
            lines: [
              {
                type: :condition,
                subtype: 'if',
                value: 'a > b',
                lines: []
              }
            ]
          }
        }
      end
      let(:route) { [:main, :lines, 0, :lines] }

      it 'must create function block' do
        service.create_block(:condition, args)
        expect(service.diagram).to eq(diagram)
      end
    end

    context 'when type is cycle' do
      let(:args) do
        {
          value: 'a > b'
        }
      end
      let(:diagram) do
        {
          main: {
            params: '',
            lines: [
              {
                type: :cycle,
                value: 'a > b',
                lines: []
              }
            ]
          }
        }
      end
      let(:route) { [:main, :lines, 0, :lines] }

      it 'must create function block' do
        service.create_block(:cycle, args)
        expect(service.diagram).to eq(diagram)
      end
    end
  end

  describe '#add_line' do
    context 'when route is blank' do
      context 'when condition and cycle are not set' do
        let(:diagram) do
          {
            main: {
              params: '',
              lines: [
                {
                  type: :block,
                  value: 'some_line'
                }
              ]
            }
          }
        end
        let(:route) { [:main, :lines] }

        it 'must create default route and add line' do
          service.add_line(:block, { value: 'some_line' })
          expect(service.diagram).to eq(diagram)
          expect(service.route).to eq(route)
        end
      end

      context 'when condition or cycle is set' do
        let(:args) do
          {
            subtype: 'if',
            value: 'a > b'
          }
        end
        let(:diagram) do
          {
            main: {
              params: '',
              lines: [
                {
                  type: :condition,
                  subtype: 'if',
                  value: 'a > b',
                  lines: [
                    {
                      type: :block,
                      value: 'some_line'
                    }
                  ]
                }
              ]
            }
          }
        end
        let(:route) { [:main, :lines, 0, :lines] }

        it 'must create default route and add line' do
          service.create_block(:condition, args)
          service.add_line(:block, { value: 'some_line' })
          expect(service.diagram).to eq(diagram)
          expect(service.route).to eq(route)
        end
      end
    end

    context 'when route is not blank' do
      context 'when end_block is blank' do
        let(:args) do
          {
            name: 'max',
            value: ''
          }
        end
        let(:diagram) do
          {
            max: {
              params: '',
              lines: [
                {
                  type: :block,
                  value: 'some_line'
                }
              ]
            }
          }
        end
        let(:route) { [:max, :lines] }

        it 'must and add line' do
          service.create_block(:function, args)
          service.add_line(:block, { value: 'some_line' })
          expect(service.diagram).to eq(diagram)
          expect(service.route).to eq(route)
        end
      end

      context 'when end_block is present' do
        let(:function_args) do
          {
            name: 'max',
            value: ''
          }
        end
        let(:condition_args) do
          {
            subtype: 'if',
            value: 'a > b'
          }
        end
        let(:diagram) do
          {
            max: {
              params: '',
              lines: [
                {
                  type: :condition,
                  subtype: 'if',
                  value: 'a > b',
                  lines: [
                    {
                      type: :block,
                      value: 'some_line'
                    }
                  ]
                },
                {
                  type: :block,
                  value: 'some_line2'
                }
              ]
            }
          }
        end
        let(:first_route) { [:max, :lines, 0, :lines] }
        let(:route) { [:max, :lines] }

        it 'must and add line' do
          service.create_block(:function, function_args)
          service.create_block(:condition, condition_args)
          service.add_line(:block, { value: 'some_line' })

          expect(service.route).to eq(first_route)
          service.end_block
          service.add_line(:block, { value: 'some_line2' })

          expect(service.diagram).to eq(diagram)
          expect(service.route).to eq(route)
        end
      end
    end
  end
end
