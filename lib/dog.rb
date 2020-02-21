class Dog 
  attr_accessor :name, :breed, :id 
  
  def initialize (name, breed, id = nil)
    @name = name
    @breed = breed 
    @id = id
  end   
  
  def self.create_table
    sql =  <<-SQL 
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
    
  def self.new_from_db(row)
    new_dog = self.new  # self.new is the same as running Dog.new
    new_dog.id = row[0]
    new_dog.name =  row[1]
    new_dog.breed = row[2]
    new_dog  # return the newly created instance
  end   
  
  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    result = DB[:conn].execute(sql, name)[0]
    Dog.new(result[0], result[1], result[2])
  end 
  
  def update 
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end 
  
  def save 
    if self.id 
      self.update 
    else 
      sql = <<-SQL
      INSERT INTO songs (name, breed)
      VALUES (?, ?)
      SQL
   
      DB[:conn].execute(sql, self.name, self.album)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end 
  end   
    
    
end 