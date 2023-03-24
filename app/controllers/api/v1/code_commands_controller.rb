# frozen_string_literal: true

class Api::V1::CodeCommandsController < ApplicationController
  def generate_tree
    result, error = CodeParserService.new(params[:code]).perform

    if error.present?
      render json: { message: error }, status: :bad_request
    else
      render json: { tree: result }
    end
  end

  def execute
    passed, error = CodeExecuterService.new(params[:code]).perform

    if error.present?
      render json: { message: error }, status: :bad_request
    else
      render json: { passed: passed }
    end
  end
end
