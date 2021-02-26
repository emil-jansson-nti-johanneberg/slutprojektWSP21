module Model

    require 'sqlite3'
    require 'bcrypt'

    #This functions makes it so I don't have to repeat myself in module with these two lines of code
    def connect_to_db(path) 
        db = SQLite3::Database.new(path)
        db.results_as_hash = true
        return db
    end 
    # Attempts to recieve information from a particular mail
    #
    # @option params [String] mail The e-mail
    #
    def get_info_from_mail(login_mail)

        db = connect_to_db("db/db.db")

        db.execute("SELECT * FROM users WHERE mail=?", [login_mail]).first
    end
    # Attempts to recieve all information from all users
    def get_all_info_from_user()

        db = connect_to_db("db/db.db")

        db.execute("SELECT * FROM users")
    end

    def login(password_digest)
        return BCrypt::Password.new(password_digest)
    end
    
    def digest(password)
        return BCrypt::Password.create(password)
    end

end