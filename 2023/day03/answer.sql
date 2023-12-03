DROP SCHEMA IF EXISTS day03 CASCADE;
CREATE SCHEMA day03;

CREATE TABLE day03.input (
  id     SERIAL,
  engine TEXT NOT NULL
);

\COPY day03.input (engine) FROM '2023/day03/input.txt';

-- part 1
WITH
colsize AS (
  SELECT DISTINCT(LENGTH(engine)) AS val
    FROM day03.input
),
numbers AS (
  SELECT generate_series                     AS size,
         generate_series + 2                 AS dots,
         colsize.val - (generate_series + 2) AS fill,
         colsize.val                         AS colsize
    FROM colsize,
         generate_series(1, colsize.val)
),
joined AS (
  SELECT STRING_AGG(engine, '') AS engine
    FROM day03.input
),
nonadjacent AS (
  SELECT UNNEST(REGEXP_MATCHES(engine, '(?<=^|^[\d|\.]{0,'||colsize-2||'}\.|\.{'||dots||'}.{'||fill||'}\.)\d{'||size||'}(?=$|\.[\d|\.]{0,'||colsize-2||'}$|\..{'||fill||'}\.{'||dots||'})', 'g')::INT[]) AS nonadjacent
    FROM joined, numbers
),
every AS (
  SELECT UNNEST(REGEXP_MATCHES(engine, '\d+', 'g')::INT[]) AS every
    FROM joined
)
SELECT sum1 - sum2 AS part1
  FROM (SELECT SUM(every) AS sum1 FROM every),
       (SELECT SUM(nonadjacent) AS sum2 FROM nonadjacent);

-- part 2
WITH
colsize AS (
  SELECT DISTINCT(LENGTH(engine)) AS val
    FROM day03.input
),
joined AS (
  SELECT STRING_AGG(engine, '') AS engine
    FROM day03.input
),
stars AS (
  SELECT  a.nr AS index, LENGTH(a.elem) + 1 AS pos
    FROM joined AS g
    LEFT JOIN LATERAL UNNEST(STRING_TO_ARRAY(g.engine, '*'))
    WITH ORDINALITY AS a(elem, nr) ON true
),
indexes AS (
  SELECT index,
       pos,
       (SUM(pos) OVER (ORDER BY index))::INT AS idx
  FROM stars
 WHERE index NOT IN (SELECT MAX(index) FROM stars)
),
rect AS (
  SELECT SUBSTRING(engine, idx-3-val, 7) AS t,
         SUBSTRING(engine, idx-3, 7) AS m,
         SUBSTRING(engine, idx-3+val, 7) AS b
    FROM joined, indexes, colsize
),
digit_rect AS (
  SELECT REGEXP_REPLACE(t, '[^\d\.\*]', '.', 'g') AS t,
         REGEXP_REPLACE(m, '[^\d\.\*]', '.', 'g') AS m,
         REGEXP_REPLACE(b, '[^\d\.\*]', '.', 'g') AS b
    FROM rect
),
rect_clean AS (
  SELECT REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(t, '(?<=.{1})\d(?=\..{4})', '.'), '\d(?=\..{5})', '.'), '(?<=.{4}\.)\d(?=.{1})', '.'), '(?<=.{5}\.)\d', '.') AS t1,
         REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(m, '(?<=.{1})\d(?=\..{4})', '.'), '\d(?=\..{5})', '.'), '(?<=.{4}\.)\d(?=.{1})', '.'), '(?<=.{5}\.)\d', '.') AS m1,
         REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(b, '(?<=.{1})\d(?=\..{4})', '.'), '\d(?=\..{5})', '.'), '(?<=.{4}\.)\d(?=.{1})', '.'), '(?<=.{5}\.)\d', '.') AS b1
    FROM digit_rect
),
matches AS (
  SELECT ARRAY(SELECT ARRAY_TO_STRING(REGEXP_MATCHES(t1, '\d+', 'g'),'')) ||
         ARRAY(SELECT ARRAY_TO_STRING(REGEXP_MATCHES(m1, '\d+', 'g'),'')) ||
         ARRAY(SELECT ARRAY_TO_STRING(REGEXP_MATCHES(b1, '\d+', 'g'),'')) AS match
    FROM rect_clean
)
SELECT SUM(match[1]::INT * match[2]::INT)
  FROM matches
 WHERE ARRAY_LENGTH(match, 1) > 1;
