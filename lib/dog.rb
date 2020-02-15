class Dog
require 'pry'
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(id:nil, name:, breed:)
    self.breed = breed
    self.name = name
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMNARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute('DROP TABLE IF EXISTS dogs')
  end

  def self.new_from_db(row)
    Dog.new(id:row[0],name:row[1],breed:row[2])
  end

  def save
    sql = "INSERT INTO dogs (name, breed) VALUES (?,?)"
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs')[0][0]
    self
  end

  def self.create(hash)
    self.new(hash).tap{|ins| ins.save}
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    row = DB[:conn].execute(sql, id)
    self.new_from_db(row.first)
  end

  def self.find_or_create_by(hash)
   sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
   row = DB[:conn].execute(sql,hash[:name], hash[:breed])[0]
   if row.nil?
    dog = self.create(hash)
   else
    dog = self.new_from_db(row)
   end
   dog
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    row = DB[:conn].execute(sql, name)[0]
    self.new_from_db(row)
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end



end