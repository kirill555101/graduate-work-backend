# frozen_string_literal: true

class Api::V1::ReviewsController < ApplicationController
  def index
    render json: { reviews: course.reviews.all }
  end

  def create
    resource.attributes = update_params
    if resource.save
      render json: { review: resource }
    else
      render json: { message: resource.errors.full_messages.join("\n") }, status: :unprocessable_entity
    end
  end

  def show
    render json: { review: resource }
  end

  def update
    if resource.update(update_params)
      head :no_content
    else
      render json: { message: resource.errors.full_messages.join("\n") }, status: :unprocessable_entity
    end
  end

  def destroy
    resource.destroy
    head :no_content
  end

  private

  def course
    @course ||= Course.find_by(id: params[:course_id])
  end

  def resource
    @resource ||= course.reviews.find_by(id: params[:id]) || course.reviews.new
  end

  def update_params
    params.require(:review).permit(:description, :stars)
  end
end
