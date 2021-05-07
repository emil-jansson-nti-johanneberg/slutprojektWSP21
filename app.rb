require'slim'
require 'sinatra'
require 'sqlite3'
require 'bcrypt'
require 'byebug'

require_relative 'model/model.rb'

enable :sessions 

include Model


# Checks if user is signed in everytime a route change is made and redirects to '/' if not.
before do 
    if (session[:id] ==  nil) && (request.path_info != '/') && (request.path_info != '/login' && (request.path_info != '/error')) 
      redirect("/")
    end
end

# Attempts a login and updates the session, includes a antihacker system.
#
# @param [String] login_mail, The e-mail
# @param [String] login_password, The password
#
# @see Model#login
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

    attempts = session[:attempts] 
    if attempts == nil
        attempts = 0
    end

    if  result != nil
        name = result["name"]
        user_id = result["id"]
        security = result["security_level"]
        password_digest = result["password"]  
    else
        set_error("Icke-godkända inloggninsuppgifter")
        redirect("/error")
    end

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
# Checks if user have done an error
#
# @param [String] error, the error text the user gets
def set_error(error)
    session[:error] = error
end
# Displays an error message
get("/error") do
    slim(:error)
end

# Display Landing/Start Page
#
get('/') do
    slim(:index)
end
# Route where an admin can create new users and redirects to '/error'
#
# @param [String] result, All information from the user which is required
#
# @see Model#get_all_info_from_user
get("/users/new") do

    if session[:security] == 0
        result = get_all_info_from_user()
        slim(:"/users/new",locals:{users:result})
    else
        set_error("Du är inte Admin och kommer därför inte in på denna sida")
        redirect("/error")
    end

end

#This route is used to create a new post
get("/post/new") do
    slim(:"/post/new")
end
# Creates a new post and redirects to '/post/new'
#
# @param [String] title, The title of the post
# @param [String] text, The content of the post
# @param [String] genre, The genre of the post
# @param [Integer] id, The ID of the user
#
# @see Model#create_post
post("/post/new_post") do

        title = params[:title]
        text = params[:text]
        genre = params[:genre]
        id = session[:id]
        create_post(title, text, genre, id)
        redirect("/post/new")
end
# Admin attempts to create a new user and redirects to '/users/new'
#
# @param [String] mail, The e-mail
# @param [String] name, The name of the user
# @param [String] rank, The rank
# @param [Integer] security, The security clearance
# @param [String] password, The password
# @param [String] password_digest, The password digested
#
# @see Model#digest, Model#create_user
post("/users/create_user") do
    if session[:security] == 0
        mail = params[:mail]
        name = params[:name]
        rank = params[:rank]
        security = params[:security]
        password = params[:password]
        password_digest = digest(password)
        create_user(name, password_digest, rank, security, mail)
        redirect("/users/new")
    end
end
# Route where Admin deletes an already exisiting user and then redirects to '/users/create'
#
# @param [Integer] id, The ID of the user
#
# @see Model#delete_user
post("/delete_user/:id/delete") do
    if session[:security] == 0
        id = params[:id].to_i
        delete_user(id)
        redirect("/users/new")
    end
end
# Attempts to enter a genre
#
# @param [String] result, All necessary information about the genre
#
# @see Model#genre_info
get("/genres/:genre") do |genre| 

    result = genre_info(genre) 
    if result.length == 0
        set_error("Genre not found")
        redirect("/error")
    end

    if session[:security] <= result[0]["security"]
        slim(:"/genres/show",locals:{posts:result})
    else
        set_error("För låg säkerhetsnivå för att titta på dessa annonser")
        redirect("/error")
    end
end
# Attempts to add a sale to a post
#
# @param [Integer] user_id, The ID of the user
# @param [Integer] post_id, The ID of the post
#
# @see Model#sale
post("/sales") do
    user_id = session[:id]
    post_id = params["post_id"]
    sale(user_id, post_id)
    redirect("/")
end
# Deletes an existing post and redirects to '/'
#
# @param [Integer] id, The ID of the post
#
# @see Model#delete_post
post("/delete_post/:id/delete") do 
    id = params[:id].to_i
    result = delete_post(id)
    redirect("/")
end
# Updates an existing post and redirects to '/'
#
# @param [Integer] :id, The ID of the post
# @param [String] content, The new content of the post
#
# @see Model#update_post
post("/update_post/:id/update") do
    id = params[:id].to_i
    text = params["content"]
    result = update_post(text, id)
    redirect("/")
end  
#This route is used to logout and redirects to '/'
get("/logout") do
    session[:id] = nil
    redirect("/")
end