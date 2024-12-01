DROP SCHEMA IF EXISTS _202401 CASCADE;
CREATE SCHEMA _202401;

CREATE TABLE _202401.input (
  id       SERIAL,
  location TEXT NOT NULL
);

\COPY _202401.input (location) FROM '2024/day01/input.txt';

-- part 1
  WITH
    left_locations  AS (
      SELECT left_location, ROW_NUMBER() OVER () AS left_row_num
        FROM (
          SELECT
            SPLIT_PART(location, '  ', 1)::INT AS left_location
            FROM _202401.input
           ORDER BY left_location) AS ordered_left),
    right_locations AS (
      SELECT right_location, ROW_NUMBER() OVER () AS right_row_num
        FROM (
          SELECT
            SPLIT_PART(location, '  ', 2)::INT AS right_location
            FROM _202401.input
           ORDER BY right_location) AS ordered_right)
SELECT SUM(ABS(left_location - right_location))
  FROM left_locations ll
  JOIN right_locations rl ON ll.left_row_num = rl.right_row_num;

-- part 2
  WITH
    left_locations  AS (
      SELECT
        id,
        SPLIT_PART(location, '  ', 1)::INT AS left_location
        FROM _202401.input),
    right_locations AS (
      SELECT
        SPLIT_PART(location, '  ', 2)::INT AS right_location
        FROM _202401.input)
SELECT SUM(similarity)
  FROM (
    SELECT ll.id, ll.left_location, COUNT(rl.right_location) * left_location AS similarity
      FROM left_locations ll
      JOIN right_locations rl ON ll.left_location = rl.right_location
     GROUP BY ll.id, ll.left_location) AS scores;