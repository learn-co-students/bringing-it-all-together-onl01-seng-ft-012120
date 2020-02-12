require 'pry'
class Dog 

    attr_reader :id
    attr_accessor :name, :breed 

    def initialize(dog, id=nil)
        @name = dog[:name]
        @breed = dog[:breed]
        @id = id
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs")
    end

    def save
        sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
        SQL

        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.create(dog_hash)
        dog = Dog.new(dog_hash)
        dog.save
        dog
    end

    def self.new_from_db(row)
        dog_hash = {:name => row[1], :breed => row[2]}
        dog = Dog.new(dog_hash, row[0])
        dog
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE id = ?
        SQL

        DB[:conn].execute(sql, id).map do |row|
            self.new_from_db(row)
        end.first
    end 

    def self.find_or_create_by(x)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", x[:name], x[:breed])
        if !dog.empty?
        dog_data = {:name => dog[0][1], :breed => dog[0][2]}
        new_dog = Dog.new(dog_data, dog[0][0])
        else 
            new_dog = self.create(x)
        end
        new_dog
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ?
        SQL

       DB[:conn].execute(sql, name).map do |row|
        self.new_from_db(row)
       end.first
       
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end