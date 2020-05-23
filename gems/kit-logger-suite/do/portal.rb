module DoPortal

  def login(user_id, password)
    @sc.login.user_id = user_id
    @sc.login.login_password = password
    @sc.login.login
  end

end

