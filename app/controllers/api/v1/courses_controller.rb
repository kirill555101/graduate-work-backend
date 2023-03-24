# frozen_string_literal: true

class Api::V1::CoursesController < ApplicationController
  def index
    courses = Course.all
    courses = courses.where(courses_author_id: params[:author_id]) if params[:author_id].present?
    courses = courses.sort_by(&:stars) if params[:filter] == 'rating'
    render json: { courses: courses }
  end

  def create
    resource.attributes = update_params
    if resource.save
      render json: { course: resource }
    else
      render json: { message: resource.errors.full_messages.join("\n") }, status: :unprocessable_entity
    end
  end

  def start
    student_course = StudentCourse.find_or_create_by(course_id: resource.id, student_id: session[:user_id]&.to_i)
    if student_course.present?
      render json: { student_course: student_course }
    else
      render json: { message: student_course.errors.full_messages.join("\n") }, status: :unprocessable_entity
    end
  end

  def progress
    render json: { progress: StudentCourse.where(course_id: resource.id).group(:passed).count }
  end

  def show
    render json: { course: resource }
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

  def resource
    @resource ||= Course.find_by(id: params[:id]) || Course.new
  end

  def update_params
    params.require(:course).permit(:name, :description)
  end
end
