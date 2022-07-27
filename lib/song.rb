class Song
  attr_accessor :name, :album, :id
  def initialize(name:, album:, id: nil)
    @id = id
    @name = name
    @album = album
  end
  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS songs")
  end
  def self.create_table
    DB[:conn].execute("CREATE TABLE IF NOT EXISTS songs (id INTEGER PRIMARY KEY, name TEXT, album TEXT)")
  end
  def save
    # insert the song
    DB[:conn].execute(
      "INSERT INTO songs (name, album) VALUES ('#{self.name}', '#{self.album}')"
    )
    # get the song ID from the database and save it to the Ruby instance
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM songs")[0][0]
    # return the Ruby instance
    self
  end
  def self.create(name:, album:)
    # self.new is equivalent to Song.new
    self.new(name: name, album: album).save
  end
  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], album: row[2])
  end
  def self.all
    DB[:conn].execute("SELECT * FROM songs").map { |row| self.new_from_db(row) }
  end
  def self.find_by_name(name)
    DB[:conn].execute("SELECT * FROM songs WHERE name = '#{name}' LIMIT 1").map { |row| self.new_from_db(row) }.first
  end
end
