require'slim'
require 'sinatra'
require 'sqlite3'
require 'bcrypt'

require_relative 'model/model.rb'

enable :sessions 

include Model

#VIKTIG! Om personen inte är inloggad vid varje route-change så skickas man tillbaka till
before do 
    if (session[:id] ==  nil) && (request.path_info != '/') && (request.path_info != '/login' && (request.path_info != '/error')) 
      redirect("/")
    end
end

#Visar error sidan om något går snett
get("/error") do
    slim(:error)
end

# Visar första sidan
get('/') do
    slim(:index)
end
#Route som används för att logga, anti-hacker skydd dessutom.
  post("/login") do

    if session[:now]
        time = session[:now].split("_")
        if Time.new(time[0], time[1], time[2], time[3], time[4], time[5]) > (Time.now - 300)
            set_error("You have to wait 5 minutes until you try again")
            redirect("/error")
        end
    end

    login_mail = params["login_mail"]
    login_password = params["login_password"]

    result = get_info_from_mail(login_mail)

    if login_mail == nil
        set_error("Invalid login details")
        redirect("/error")
    end

    attempts = session[:attempts] 
    if attempts == nil
        attempts = 0
    end

    name = result["name"]
    user_id = result["id"]
    security = result["security_level"]
    password_digest = result["password"]
    if login(password_digest) == login_password 
        session[:id] = user_id
        session[:name] = name
        session[:security] = security
        redirect("/")
    else
        set_error("Invalid login details")
        attempts += 1
        session[:attempts] = attempts

        if attempts >= 3
            session[:now] = Time.now().strftime('%Y_%m_%d_%H_%M_%S')
        end

        redirect("/error")
    end
end
#Route som används för att logga ut
get("/logout") do
    session[:id] = nil
    redirect("/")
end