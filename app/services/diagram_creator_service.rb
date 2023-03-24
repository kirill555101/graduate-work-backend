# frozen_string_literal: true

class DiagramCreatorService
  BLOCKS_TYPES = %i[function condition cycle].freeze

  attr_reader :diagram, :route

  def initialize
    @diagram = {}
    @route = []
  end

  def create_block(type, args)
    send("add_#{type}", args) if BLOCKS_TYPES.include?(type)
  end

  def add_return
    return if route.blank? || diagram.dig(*route).last[:type] == :function_return
    diagram.dig(*route).push({
      type: :function_return,
      value: ''
    })
  end

  def end_block
    route.pop(2)
  end

  def add_line(type, args)
    return if args[:value].blank?
    create_default_route if route.blank?
    diagram.dig(*route).push({
      type: type,
      value: args[:value]
    })
  end

  private

  def add_function(args)
    name = args[:name].to_sym
    @diagram[name] = {
      params: args[:value],
      lines: []
    }
    @route = [name, :lines]
  end

  def add_condition(args)
    create_default_route if route.blank?
    diagram.dig(*route).push({
      type: :condition,
      subtype: args[:subtype],
      value: args[:value],
      lines: []
    })
    @route = @route.push(diagram.dig(*route).length - 1, :lines)
  end

  def add_cycle(args)
    create_default_route if route.blank?
    diagram.dig(*route).push({
      type: :cycle,
      value: args[:value],
      lines: []
    })
    @route = @route.push(diagram.dig(*route).length - 1, :lines)
  end

  def create_default_route
    @diagram[:main] = {
      params: '',
      lines: []
    }
    @route = [:main, :lines]
  end
end
