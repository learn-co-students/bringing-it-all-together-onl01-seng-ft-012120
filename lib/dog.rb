class Dog 
  attr_accessor :name, :breed 
  attr_reader :id 
  
  def initialize(id: nil, name:, breed:)
    @name = name 
    @breed = breed 
    @id = id 
  end 
  
  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT 
      )
    SQL
    
    DB[:conn].execute(sql)
  end 
  
  def self.drop_table
    sql = "DROP TABLE dogs"
    DB[:conn].execute(sql)
  end 
  
  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    
    new_dog = Dog.new(id: id, name: name, breed: breed)
    
    new_dog
  end 
  
  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1"
    
    DB[:conn].execute(sql, name).collect do |row|
      self.new_from_db(row)
    end.first
  end 
  
  def save 
    if self.id 
      self.update
    end 
    
    sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    
    self
  end 
  
  def update 
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end 
  
  def self.create(name:, breed:)
    new_dog = Dog.new(name: name, breed: breed)
    new_dog.save
    
    new_dog
  end 
  
  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ? LIMIT 1"
    
    DB[:conn].execute(sql, id).collect {|row| self.new_from_db(row)}.first
  end
  
  def self.find_or_create_by(name:, breed:)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
    dog = DB[:conn].execute(sql, name, breed)
    
    if !dog.empty?
      dog_info = dog[0]
      dog = Dog.new(id: dog_info[0], name: dog_info[1], breed: dog_info[2])
    
    else 
      dog = self.create(name: name, breed: breed)
    end 
    
    dog
  end 
end 