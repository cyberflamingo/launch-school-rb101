def get_grade(grade1, grade2, grade3)
  mean = (grade1 + grade2 + grade3) / 3

  case mean
  when 90..Float::INFINITY then 'A'
  when 80..89              then 'B'
  when 70..79              then 'C'
  when 60..69              then 'D'
  else                          'F'
  end
end

p get_grade(95, 90, 93) == "A"
p get_grade(50, 50, 95) == "D"
p get_grade(104, 95, 111) == "A"
