DROP SCHEMA IF EXISTS _202302 CASCADE;
CREATE SCHEMA _202302;

CREATE TABLE _202302.input (
  id   SERIAL,
  game TEXT NOT NULL
);

\COPY _202302.input (game) FROM '2023/_202302/input.txt';

-- part 1 & 2
  WITH
    game                           AS (
      SELECT
        CAST(REPLACE(a[1], 'Game ', '') AS INT) AS iter,
        UNNEST(STRING_TO_ARRAY(a[2], ';')) AS pick
        FROM (
          SELECT STRING_TO_ARRAY(game, ':')
            FROM _202302.input) AS arr(a)),
    cubes (iter, red, blue, green) AS (
      SELECT
        iter,
        CAST(UNNEST(REGEXP_MATCHES(pick, '(\d+)(?=\sr)')) AS INT) AS red,
        CAST(UNNEST(REGEXP_MATCHES(pick, '(\d+)(?=\sb)')) AS INT) AS blue,
        CAST(UNNEST(REGEXP_MATCHES(pick, '(\d+)(?=\sg)')) AS INT) AS green
        FROM game)
SELECT part1.answer, part2.answer
  FROM (
         SELECT SUM(DISTINCT (iter)) AS answer
           FROM cubes
          WHERE iter NOT IN (
            SELECT iter
              FROM cubes
             WHERE red > 12
                OR green > 13
                OR blue > 14)) AS part1,
       (
         SELECT SUM(power.result) AS answer
           FROM (
             SELECT MAX(red) * MAX(blue) * MAX(green) AS result
               FROM cubes
              GROUP BY iter) AS power) AS part2;