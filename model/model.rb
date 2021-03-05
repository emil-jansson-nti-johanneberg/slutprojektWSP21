module Model

    require 'sqlite3'
    require 'bcrypt'

    #Så jag slipper skriva detta flertalet gånger i alla modules
    def connect_to_db(path) 
        db = SQLite3::Database.new(path)
        db.results_as_hash = true
        return db
    end 

    def get_info_from_mail(login_mail)

        db = connect_to_db("db/db.db")

        db.execute("SELECT * FROM users WHERE mail = ?",login_mail).first
    end
    #Försöker få info från alla användare
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

def create_user(name, password_digest, rank, security, mail)

    db = connect_to_db("db/db.db")

    db.execute("INSERT INTO users (name, password, rank, security_level, mail) VALUES (?,?,?,?,?)", name, password_digest, rank, security, mail)

end

def delete_user(id)

    db = connect_to_db("db/db.db")

    db.execute("DELETE FROM ads WHERE user_id = ?", id)
    
    db.execute("DELETE FROM users WHERE id = ?", id)

end


