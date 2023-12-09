DROP SCHEMA if EXISTS day05 CASCADE;
CREATE SCHEMA day05;

CREATE TABLE day05.input (
  id      SERIAL,
  almanac TEXT NOT NULL
);

\
COPY day05.input (almanac) FROM '2023/day05/sample.txt';

-- part 1
CREATE TABLE day05.seeds AS (
  SELECT unnest(regexp_matches(almanac, '\d+', 'g')) ::int AS seed
    FROM day05.input
   WHERE id = 1);

CREATE TABLE day05.almanac AS (
    WITH
      splits   AS (
        SELECT
          row_number() AS over (ORDER BY m.id) AS idx, int4range(m.id + 2, COALESCE(lag(m.id, -1) over(ORDER BY m.id), e.id + 1)) AS window
          FROM (
                 SELECT id
                   FROM day05.input
                  WHERE almanac = '') AS m,
               (
                 SELECT MAX(id) AS id
                   FROM day05.input) AS e),
      maps_raw AS (
        SELECT
          s.idx,
          array(SELECT ARRAY_TO_STRING(REGEXP_MATCHES(i.almanac, '\d+', 'g'), ''))::int[] AS val
          FROM day05.input i, splits s
         WHERE s.window @ > i.id)
  SELECT
    idx,
    val[1] AS destination,
    int4range(val[2], val[2] + val[3]) AS source,
    val[3] AS range_length
    FROM maps_raw);

SELECT *
  FROM day05.almanac;
