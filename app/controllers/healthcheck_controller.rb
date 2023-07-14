class HealthcheckController < ApplicationController
  def index
    render(status: 200)
  end

  def scylla
    Rails.logger.info(Scylla.session)
    render(status: 200)
  rescue StandardError => e
    Rails.logger.info(e)
    render(status: 200)
  end
end
