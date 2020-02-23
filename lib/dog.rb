class Dog

attr_accessor :name, :breed, :id

    def initialize(name:, breed:, id: nil)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs(
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
        DROP TABLE dogs
        SQL

        DB[:conn].execute(sql)
    end

    def save
        sql = <<-SQL
        INSERT INTO dogs(name, breed)
        VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.create(hash)
       dog = Dog.new(name: hash[:name], breed: hash[:breed])
       dog.save
       dog
    end

    def self.new_from_db(row)
        # binding.pry
        id = row[0]
        name = row[1]
        breed = row[2]
        new_dog = Dog.new(name: name, breed: breed, id: id)
        new_dog
    end

    def self.find_by_id(num)

        sql = <<-SQL
         SELECT * FROM dogs
         WHERE id = ?
        SQL

        DB[:conn].execute(sql, num).map{|row| Dog.new_from_db(row)}.first

    end

    def self.find_or_create_by(name:, breed:)
    
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
            if dog.empty?
                dog = self.create(name:name, breed:breed)
            else
                dog_data = dog[0]
                dog = Dog.new(name: dog_data[1], breed: dog_data[2], id: dog_data[0])
            end
        dog
    end

    def self.find_by_name(name)
        sql = <<-SQL
           SELECT * FROM dogs
           WHERE name = ?
        SQL
        DB[:conn].execute(sql, name).map{|row| Dog.new_from_db(row)}.first
    end

    def update
        sql = <<-SQL
        UPDATE dogs SET name = ?, breed =? WHERE id =?        
        SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end