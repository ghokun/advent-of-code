DROP SCHEMA IF EXISTS day03 CASCADE;
CREATE SCHEMA day03;

CREATE TABLE day03.input (
  id   SERIAL,
  game TEXT NOT NULL
);

\COPY day03.input (game) FROM '2023/day03/input.txt';

-- part 1 & 2
