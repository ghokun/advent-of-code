DROP SCHEMA IF EXISTS day01 CASCADE;
CREATE SCHEMA day01;

CREATE TABLE day01.input (
  id       SERIAL,
  calories TEXT NOT NULL
);

\COPY day01.input (calories) FROM '2022/day01/input.txt';

-- part 1
WITH elves AS (
  SELECT NULLIF(calories, '')::INT AS calories,
         (SUM(CASE WHEN calories = '' THEN 1 ELSE 0 END) OVER (ORDER BY id)) + 1 AS elf
    FROM day01.input
)
SELECT elf, SUM(calories) AS total_calories
  FROM elves
 WHERE calories IS NOT NULL
 GROUP BY elf
 ORDER BY total_calories DESC
 LIMIT 1;

-- part 2
WITH elves AS (
  SELECT NULLIF(calories, '')::INT AS calories,
         (SUM(CASE WHEN calories = '' THEN 1 ELSE 0 END) OVER (ORDER BY id)) + 1 AS elf
    FROM day01.input
)
SELECT SUM(top_3.total_calories) AS top_3
  FROM (
    SELECT SUM(calories) AS total_calories
      FROM elves
    WHERE calories IS NOT NULL
    GROUP BY elf
    ORDER BY total_calories DESC
    LIMIT 3
  ) AS top_3 ;