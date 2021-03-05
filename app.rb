require'slim'
require 'sinatra'
require 'sqlite3'
require 'bcrypt'
require 'byebug'

require_relative 'model/model.rb'

enable :sessions 

include Model

#VIKTIG! Om personen inte är inloggad vid varje route-change så skickas man tillbaka till "startsidan"
before do 
    if (session[:id] ==  nil) && (request.path_info != '/') && (request.path_info != '/login' && (request.path_info != '/error')) 
      redirect("/")
    end
end

#Kollar om du gjort ett error
def set_error(error)
    session[:error] = error
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
            set_error("Du måste 5 minuter tills du får försöka igen, bättre lycka till nästa gång")
            redirect("/error")
        end
    end

    login_mail = params["login_mail"]
    login_password = params["login_password"]

    result = get_info_from_mail(login_mail)

    if login_mail == nil
        set_error("Icke-godkända inloggninsuppgifter")
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
        set_error("Icke-godkända inloggninsuppgifter")
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

get("/users/new") do

    if session[:security] == 0
        result = get_all_info_from_user()
        slim(:"/users/new",locals:{users:result})
    else
        set_error("Du kunde inte komma in hit då du inte har rättigheterna att skapa en ny användare. Bara Admins kan skapa ny användare")
        redirect("/error")
    end

end

post("/users/create_user") do
    name = params[:name]
    password = params[:password]
    rank = params[:rank]
    security = params[:security]
    mail = params[:mail]
    password_digest = digest(password)

    create_user(name, password_digest, rank, security, mail)

    redirect("/users/new")
end

post("/delete_user/:id/delete") do
    id = params[:id].to_i
    delete_user(id)
    redirect("/users/new")
end