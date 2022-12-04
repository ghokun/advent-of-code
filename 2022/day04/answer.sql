DROP SCHEMA IF EXISTS day04 CASCADE;
CREATE SCHEMA day04;

CREATE TABLE day04.input (
  id    SERIAL,
  pair1 TEXT NOT NULL,
  pair2 TEXT NOT NULL
);

\COPY day04.input (pair1, pair2) FROM '2022/day04/input.txt' WITH (DELIMITER ',');

-- part 1
SELECT COUNT(*)
  FROM (
    SELECT 
      REGEXP_SPLIT_TO_ARRAY(i.pair1, '-')::INT[] AS elf1, 
      REGEXP_SPLIT_TO_ARRAY(i.pair2, '-')::INT[] AS elf2
      FROM day04.input i
  ) splits
 WHERE (INT4RANGE(elf1[1], elf1[2]+1) @> elf2[1] AND INT4RANGE(elf1[1], elf1[2]+1) @> elf2[2])
    OR (INT4RANGE(elf2[1], elf2[2]+1) @> elf1[1] AND INT4RANGE(elf2[1], elf2[2]+1) @> elf1[2]);

-- part 2
SELECT COUNT(*)
  FROM (
    SELECT 
      REGEXP_SPLIT_TO_ARRAY(i.pair1, '-')::INT[] AS elf1, 
      REGEXP_SPLIT_TO_ARRAY(i.pair2, '-')::INT[] AS elf2
      FROM day04.input i
  ) splits
 WHERE INT4RANGE(elf1[1], elf1[2]+1) && INT4RANGE(elf2[1], elf2[2]+1);