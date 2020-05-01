module SingleCarePages
  class Login < SCPage

    button 'login', css("button[type='submit']")

    text 'user_id', id('usrname')
    text 'login_password', id('psw')

    def log_in
      login()
    end

  end
end
