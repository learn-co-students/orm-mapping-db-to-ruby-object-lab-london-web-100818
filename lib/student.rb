class Student
  attr_accessor :id, :name, :grade

  @@all = []

  def self.new_from_db(row)
    student = self.new
    student.id = row[0]
    student.name = row[1]
    student.grade = row[2]
    student
  end

  def self.all
    sql = <<-SQL
      SELECT * FROM students
    SQL

    DB[:conn].execute(sql).map do |row|
      self.new_from_db(row)
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql,name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def save
    sql = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.grade)
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end

  def self.all_students_in_grade_9
    DB[:conn].execute("SELECT * FROM students WHERE grade = 9")
  end

  def self.first_student_in_grade_10
    first = DB[:conn].execute("SELECT * FROM students WHERE grade = 10 LIMIT 1").flatten
    first_10 = self.new_from_db(first)
    first_10
  end

  def self.students_below_12th_grade
    onetoeleven = DB[:conn].execute("SELECT * FROM students WHERE grade < 12").flatten
    data = []
    data << self.new_from_db(onetoeleven)
  end

  def self.first_X_students_in_grade_10(x)
    sql = <<-SQL
        SELECT *
        FROM students
        WHERE grade = 10
        LIMIT ?
        SQL

      DB[:conn].execute(sql, x)
  end

  def self.all_students_in_grade_X(x)
    in_grade = DB[:conn].execute("SELECT * FROM students WHERE grade = ?", x)
    grade_group = []
    in_grade.each {|student|
      grade_group << self.new_from_db(student)
    }
    grade_group
  end

end
