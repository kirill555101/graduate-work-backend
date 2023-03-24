# frozen_string_literal: true

class Api::V1::CertificatesController < ApplicationController
  def index
    render json: { certificates: StudentCourse.where(student_id: student&.id) }
  end

  def show
    render json: { certificate: resource }
  end

  private

  def student
    @student ||= Student.find_by(id: session[:user_id])
  end

  def resource
    @resource ||= StudentCourse.find_by(id: params[:id])
  end
end
