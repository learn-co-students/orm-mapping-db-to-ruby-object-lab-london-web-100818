class Student
  attr_accessor :id, :name, :grade

  @@all = []

  def self.new_from_db(row)
    # create a new Student object given a row from the database
    student = self.new
    attributes = { :id => row[0], :name => row[1], :grade => row[2] }
    student.id = attributes[:id]
    student.name = attributes[:name]
    student.grade = attributes[:grade]
    student
  end

  def self.all
    # retrieve all the rows from the "Students" database
    # remember each row should be a new instance of the Student class
    all_students = DB[:conn].execute("SELECT * FROM students")
    all_students.each {|row|
      @@all << self.new_from_db(row)
    }
    @@all
  end

  def self.find_by_name(name)
    # find the student in the database given a name
    # return a new instance of the Student class
    student_row = DB[:conn].execute("SELECT * FROM students WHERE name = ?", name).flatten
    self.new_from_db(student_row)

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

  def self.students_below_12th_grade
    youngsters = DB[:conn].execute("SELECT * FROM students WHERE grade < 12").flatten
    below_twelve = []
    below_twelve << self.new_from_db(youngsters)
  end

  def self.first_X_students_in_grade_10(num)
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE grade = 10
      LIMIT ?
      SQL

    DB[:conn].execute(sql, num)
  end

  def self.first_student_in_grade_10
    first = DB[:conn].execute("SELECT * FROM students WHERE grade = 10 LIMIT 1").flatten
    first_10 = self.new_from_db(first)
    first_10
  end

  def self.all_students_in_grade_X(num)
    in_grade = DB[:conn].execute("SELECT * FROM students WHERE grade = ?", num)
    grade_group = []
    in_grade.each {|student|
      grade_group << self.new_from_db(student)
    }
    grade_group
  end


end
