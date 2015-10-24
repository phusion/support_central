class Users::RegistrationsController < Devise::RegistrationsController
  def create
    render status: 404, text: 'Action disabled'
  end
end
