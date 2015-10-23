class Users::RegistrationsController < Devise::RegistrationsController
  def new
    render status: 404, text: 'Action disabled'
  end

  def create
    render status: 404, text: 'Action disabled'
  end
end
