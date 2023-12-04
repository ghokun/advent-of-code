DROP SCHEMA IF EXISTS day04 CASCADE;
CREATE SCHEMA day04;

CREATE TABLE day04.input (
  id    SERIAL,
  cards TEXT NOT NULL
);

\COPY day04.input (cards) FROM '2023/day04/input.txt';

-- part 1
WITH
game AS (
  SELECT CAST(REPLACE(a[1], 'Card ', '') AS INT) AS iter,
         STRING_TO_ARRAY(a[2], '|')      AS cards
    FROM (SELECT STRING_TO_ARRAY(cards, ':')
            FROM day04.input
         ) AS arr(a)
),
hand AS (
  SELECT iter,
         UNNEST(REGEXP_SPLIT_TO_ARRAY(TRIM(cards[1]), '\s+')::INT[]) AS winning,
         REGEXP_SPLIT_TO_ARRAY(TRIM(cards[2]), '\s+')::INT[] AS own
    FROM game
),
result AS (
  SELECT iter, COUNT(winning) AS c
    FROM hand
   WHERE winning = ANY(own)
   GROUP BY iter
)
SELECT SUM(POWER(2, c-1))
  FROM result;

-- part 2
CREATE TABLE day04.scratch AS (
WITH
game AS (
  SELECT CAST(REPLACE(a[1], 'Card ', '') AS INT) AS iter,
         STRING_TO_ARRAY(a[2], '|')      AS cards
    FROM (SELECT STRING_TO_ARRAY(cards, ':')
            FROM day04.input
        ) AS arr(a)
),
hand AS (
  SELECT iter,
         UNNEST(REGEXP_SPLIT_TO_ARRAY(TRIM(cards[1]), '\s+')::INT[]) AS winning,
         REGEXP_SPLIT_TO_ARRAY(TRIM(cards[2]), '\s+')::INT[] AS own
    FROM game
),
result AS (
  SELECT iter, COUNT(*) AS c
    FROM hand
   WHERE winning = ANY(own)
   GROUP BY iter
)
SELECT *
  FROM result, generate_series(iter+1, iter+c) AS scratch
 ORDER BY iter
);

WITH RECURSIVE rec AS (
  SELECT scratch
    FROM day04.scratch
   UNION ALL
  SELECT s.scratch
    FROM day04.scratch s
    JOIN rec r ON s.iter = r.scratch
)
SELECT c1.count + c2.count AS part2
  FROM (SELECT COUNT(*) FROM rec) AS c1,
       (SELECT COUNT(*) FROM day04.input) AS c2;