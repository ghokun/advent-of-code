DROP SCHEMA IF EXISTS _202305 CASCADE;
CREATE SCHEMA _202305;

CREATE TABLE _202305.input (
  id      SERIAL,
  almanac TEXT NOT NULL
);

\COPY _202305.input (almanac) FROM '2023/_202305/input.txt';

-- common
CREATE TABLE _202305.almanac AS (
    WITH
      splits   AS (
        SELECT
          ROW_NUMBER() OVER (ORDER BY m.id) AS idx,
          INT4RANGE(m.id + 2, COALESCE(LAG(m.id, -1) OVER (ORDER BY m.id), e.id + 1)) AS window
          FROM (
                 SELECT id
                   FROM _202305.input
                  WHERE almanac = '') AS m,
               (
                 SELECT MAX(id) AS id
                   FROM _202305.input) AS e),
      maps_raw AS (
        SELECT
          s.idx,
          ARRAY(SELECT ARRAY_TO_STRING(REGEXP_MATCHES(i.almanac, '\d+', 'g'), ''))::INT8[] AS val
          FROM _202305.input i, splits s
         WHERE s.window @> i.id)
  SELECT
    idx,
    val[1] AS destination,
    INT8RANGE(val[2], val[2] + val[3]) AS source,
    val[1] - val[2] AS diff,
    val[3] AS range_length
    FROM maps_raw);

-- part 1
CREATE TABLE _202305.seeds AS (
  SELECT UNNEST(REGEXP_MATCHES(almanac, '\d+', 'g'))::INT8 AS seed
    FROM _202305.input
   WHERE id = 1);

  WITH
    RECURSIVE
    rec (seed, idx) AS (
      SELECT seed, 1
        FROM _202305.seeds
       UNION ALL
      SELECT
        r.seed + (
          SELECT
            CASE
              WHEN EXISTS(
                SELECT diff FROM _202305.almanac a WHERE a.source @> r.seed AND r.idx = a.idx)
                THEN (
                SELECT diff FROM _202305.almanac a WHERE a.source @> r.seed AND r.idx = a.idx)
              ELSE 0
            END), r.idx + 1
        FROM rec r
       WHERE r.idx <= (
         SELECT DISTINCT(MAX(idx))
           FROM _202305.almanac))
SELECT MIN(seed) AS part1
  FROM rec
 WHERE idx = (
               SELECT DISTINCT(MAX(idx))
                 FROM _202305.almanac) + 1
 GROUP BY idx;

-- part 2
CREATE TABLE _202305.ranged_seeds AS (
    WITH
      raw_seed AS (
        SELECT UNNEST(REGEXP_MATCHES(almanac, '\d+ \d+', 'g')) AS seed
          FROM _202305.input
         WHERE id = 1)
  SELECT
    SPLIT_PART(seed, ' ', 1)::INT8 AS start,
    SPLIT_PART(seed, ' ', 2)::INT8 AS length
    FROM raw_seed);

SELECT INT8RANGE(ranged_seeds.start, ranged_seeds.start + ranged_seeds.length)
  FROM _202305.ranged_seeds;