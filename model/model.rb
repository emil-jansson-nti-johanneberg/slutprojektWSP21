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

    def genre_info(genre)

        db = connect_to_db("db/db.db")
    
        db.execute("SELECT COUNT(sale.id) as sales, posts.title, posts.text, posts.id, genre.security, genre.name, users.name AS username, posts.user_id FROM genre LEFT JOIN posts ON genre.id = posts.genre LEFT JOIN users ON posts.user_id = users.id LEFT JOIN sale ON posts.id = sale.post_id WHERE genre.name = ? GROUP BY posts.id", genre) 
    
    end

    def create_post(title, text, genre, id)

        db = connect_to_db("db/db.db")
    
        db.execute("INSERT INTO posts (title, text, genre, user_id) VALUES (?,?,?,?)", title, text, genre, id)
    
    end
    
    def delete_post(id)
    
        db = connect_to_db("db/db.db")
    
        db.execute("DELETE FROM posts WHERE id = ?", id)
    
    end
    
    def update_post(text, id)
    
        db = connect_to_db("db/db.db")
    
        db.execute("UPDATE posts SET text = ? WHERE id = ?", text, id)
    
    end
    
    def sale(user_id, post_id)
    
        db = connect_to_db("db/db.db")
    
        result = db.execute("SELECT * FROM sale WHERE user_id =? AND post_id =?", user_id, post_id)
    
        db.execute("INSERT INTO sale (user_id, post_id) VALUES (?,?)", user_id, post_id)
        db.execute("UPDATE posts SET sales = sales + 1 WHERE id = ?", post_id)
    
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

    def login(password_digest)
        return BCrypt::Password.new(password_digest)
    end
        
    def digest(password)
        return BCrypt::Password.create(password)
    end

end