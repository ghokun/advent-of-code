DROP SCHEMA IF EXISTS day03 CASCADE;
CREATE SCHEMA day03;

CREATE TABLE day03.input (
  id         SERIAL,
  rucksack   TEXT NOT NULL
);

\COPY day03.input (rucksack) FROM '2022/day03/input.txt';

-- part 1
WITH compartments AS (
  SELECT i.id,
         UNNEST(REGEXP_SPLIT_TO_ARRAY(SUBSTRING(i.rucksack, 0, (LENGTH(i.rucksack)/2) + 1), '')) AS comp1,
         UNNEST(REGEXP_SPLIT_TO_ARRAY(SUBSTRING(i.rucksack, (LENGTH(i.rucksack)/2) + 1), '')) AS comp2
    FROM day03.input i
), characters AS (
  SELECT DISTINCT c1.id, c1.comp1
    FROM compartments c1
    JOIN compartments c2 ON c1.id = c2.id AND c1.comp1 = c2.comp2
   GROUP BY c1.id, c1.comp1
)
SELECT 
   sum(CASE
        WHEN ASCII(comp1) < 91 THEN ASCII(comp1) - 38
        WHEN ASCII(comp1) > 96 THEN ASCII(comp1) - 96
       END)
  FROM characters;

-- part 2
WITH rucksacks AS (
  SELECT (SELECT UNNEST(ct.one) INTERSECT SELECT UNNEST(ct.two) INTERSECT SELECT UNNEST(ct.three)) AS badge
    FROM CROSSTAB (
        $$
        WITH badges AS (
          SELECT (i.id - 1) / 3 AS _group,
                i.id,
                i.rucksack
            FROM day03.input i
        ), characters AS (
          SELECT b._group, b.id, REGEXP_SPLIT_TO_ARRAY(b.rucksack, '') AS array
            FROM badges b
        )
        SELECT * FROM characters ORDER BY _group, id ASC
        $$) AS ct(_group INT, one TEXT ARRAY, two TEXT ARRAY, three TEXT ARRAY)
)
SELECT 
   sum(CASE
        WHEN ASCII(badge) < 91 THEN ASCII(badge) - 38
        WHEN ASCII(badge) > 96 THEN ASCII(badge) - 96
       END)
  FROM rucksacks;