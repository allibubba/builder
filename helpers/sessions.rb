helpers do
  def current_user
    !session[:uid].nil?
  end
end
