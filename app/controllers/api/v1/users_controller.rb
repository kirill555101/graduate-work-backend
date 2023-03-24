# frozen_string_literal: true

class Api::V1::UsersController < ApplicationController
  around_action :require_admin, only: %i[index update destroy]

  def index
    render json: { users: Student.all + CoursesAuthor.all }
  end

  def register
    resource.attributes = update_params
    if resource.save
      session[:user_id] = resource.id
      session[:user_type] = params[:type]

      render json: { user: resource }
    else
      render json: { message: resource.errors.full_messages.join("\n") }, status: :unprocessable_entity
    end
  end

  def login
    user_class =
      case params[:type]
      when 'admin'
        Admin
      when 'courses_author'
        CoursesAuthor
      else
        Student
      end

    user = user_class&.find_by(login: params[:login])
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      session[:user_type] = params[:type]

      render json: { user: user }
    else
      render json: { message: 'Неверный логин или пароль' }, status: :bad_request
    end
  end

  def logout
    remove_session
    head :no_content
  end

  def current_user
    if session[:user_id].blank? || session[:user_type].blank?
      return render json: { message: 'Пользователь не авторизован' }, status: :unauthorized
    end

    user_class =
      case session[:user_type]
      when 'admin'
        Admin
      when 'courses_author'
        CoursesAuthor
      else
        Student
      end

    user = user_class&.find_by(id: params[:login])
    render json: { user: user }
  end

  def show
    render json: { user: resource }
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
    @resource ||= class_type.find_by(id: params[:id]) || class_type.new
  end

  def class_type
    if params[:type] == 'courses_author'
      CoursesAuthor
    else
      Student
    end
  end

  def update_params
    params.require(:user).permit(:login, :email, :password, :full_name)
  end

  def require_admin
    unless session[:user_type] == 'admin'
      return render json: { message: 'Пользователь не является админом' }, status: :unauthorized
    end
    yield
  end

  def remove_session
    session[:user_id] = nil
    session[:user_type] = nil
  end
end
