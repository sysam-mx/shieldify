class SessionsController < ApplicationController
  before_action :authenticate_user!, only: [:show]

  def create; end
  def index; end
  def show; end
end