class UsersController < ApplicationController
  before_action :authorize!

  def complete_tour_guide
    current_user.update!(tour_guide_completed: true)

    render(json: 200)
  end
end
