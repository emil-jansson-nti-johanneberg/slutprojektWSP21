#
# Handles databaseinteraction, validation and authentication
#
module Model

    require 'sqlite3'
    require 'bcrypt'

    # Connects to the database
    # 
    # @return [SQLite3::Database] containing the database
    #
    def connect_to_db(path) 
        db = SQLite3::Database.new(path)
        db.results_as_hash = true
        return db
    end 
    # Attempts to recieve information from a particular mail
    #
    # @option params [String] login_mail The e-mail
    #
    def get_info_from_mail(login_mail)

        db = connect_to_db("db/db.db")

        db.execute("SELECT * FROM users WHERE mail = ?",login_mail).first
    end
    # Attempts to recieve all information from all users
    def get_all_info_from_user()

        db = connect_to_db("db/db.db")

        db.execute("SELECT * FROM users")
    end
    # Attempts to connect to a genre
    #
    # @option params [Integer] genre the genre
    #
    def genre_info(genre)

        db = connect_to_db("db/db.db")
    
        db.execute("SELECT COUNT(sale.id) as sales, posts.title, posts.text, posts.id, genre.security, genre.name, users.name AS username, posts.user_id FROM genre LEFT JOIN posts ON genre.id = posts.genre LEFT JOIN users ON posts.user_id = users.id LEFT JOIN sale ON posts.id = sale.post_id WHERE genre.name = ? GROUP BY posts.id", genre) 
    
    end
    # Attemps to create post
    #
    # @option params [String] title the title
    # @option params [Text] text the text
    # @option params [Integer] genre the genre
    # @option params [Integer] id id of the post
    #
    def create_post(title, text, genre, id)

        db = connect_to_db("db/db.db")
    
        db.execute("INSERT INTO posts (title, text, genre, user_id) VALUES (?,?,?,?)", title, text, genre, id)
    
    end
    # Attempts to delete a post
    #
    # @option params [Integer] id The id of the person which post will be deleted
    #
    def delete_post(id)
    
        db = connect_to_db("db/db.db")
    
        db.execute("DELETE FROM posts WHERE id = ?", id)
    
    end
    # Attempts to update post
    #
    # @option params [String] text The text that will be updated
    # @option params [Integer] id The id of the user
    #
    def update_post(text, id)
    
        db = connect_to_db("db/db.db")
    
        db.execute("UPDATE posts SET text = ? WHERE id = ?", text, id)
    
    end
    # Attempts to update post with one extra sale
    #
    # @option params [Integer] user_id The id of the user
    # @option params [Integer] post_id The id of the post
    #
    def sale(user_id, post_id)
    
        db = connect_to_db("db/db.db")
    
        result = db.execute("SELECT * FROM sale WHERE user_id =? AND post_id =?", user_id, post_id)
    
        db.execute("INSERT INTO sale (user_id, post_id) VALUES (?,?)", user_id, post_id)
        db.execute("UPDATE posts SET sales = sales + 1 WHERE id = ?", post_id)
    
    end
    # Attempts to create a new user
    #
    # @option params [String] name The name of the account
    # @option params [String] mail The e-mail
    # @option params [String] password_digest The password
    # @option params [String] rank The rank of the person
    # @option params [Integer] security The security level of the person
    #
    def create_user(name, password_digest, rank, security, mail)

        db = connect_to_db("db/db.db")

        db.execute("INSERT INTO users (name, password, rank, security_level, mail) VALUES (?,?,?,?,?)", name, password_digest, rank, security, mail)

    end
    # Attempts to delete a user
    #
    # @option params [Integer] id The id of the user that will be deleted
    #
    def delete_user(id)

        db = connect_to_db("db/db.db")

        db.execute("DELETE FROM ads WHERE user_id = ?", id)
    
        db.execute("DELETE FROM users WHERE id = ?", id)

    end
    # Attempts to login
    #
    # @option params [String] password_digest The user's password hash
    #
    def login(password_digest)
        return BCrypt::Password.new(password_digest)
    end
    # Attempts to digest password
    #
    # @option params [Password] password The User's password
    # 
    def digest(password)
        return BCrypt::Password.create(password)
    end

end