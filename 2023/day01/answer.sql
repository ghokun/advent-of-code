DROP SCHEMA IF EXISTS _202301 CASCADE;
CREATE SCHEMA _202301;

CREATE TABLE _202301.input (
  id          SERIAL,
  calibration TEXT NOT NULL
);

\COPY _202301.input (calibration) FROM '2023/_202301/input.txt';

-- part 1
  WITH
    calibration_values AS (
      SELECT ARRAY(SELECT ARRAY_TO_STRING(REGEXP_MATCHES(calibration, '\d', 'g'), '')) AS digit
        FROM _202301.input)
SELECT SUM(CAST(digit[1] || digit[ARRAY_UPPER(digit, 1)] AS INT))
  FROM calibration_values;

-- part 2
  WITH
    calibration_values AS (
      SELECT
        ARRAY(SELECT
          ARRAY_TO_STRING(
          REGEXP_MATCHES(calibration, '((?=\d)\w|(?=(one|two|three|four|five|six|seven|eight|nine))\w{2})', 'g'),
          '')) AS digit, calibration
        FROM _202301.input)
SELECT
  SUM(CAST((CASE digit[1]
              WHEN 'on' THEN '1'
              WHEN 'tw' THEN '2'
              WHEN 'th' THEN '3'
              WHEN 'fo' THEN '4'
              WHEN 'fi' THEN '5'
              WHEN 'si' THEN '6'
              WHEN 'se' THEN '7'
              WHEN 'ei' THEN '8'
              WHEN 'ni' THEN '9'
              ELSE digit[1]
            END) ||
           (CASE digit[ARRAY_UPPER(digit, 1)]
              WHEN 'on' THEN '1'
              WHEN 'tw' THEN '2'
              WHEN 'th' THEN '3'
              WHEN 'fo' THEN '4'
              WHEN 'fi' THEN '5'
              WHEN 'si' THEN '6'
              WHEN 'se' THEN '7'
              WHEN 'ei' THEN '8'
              WHEN 'ni' THEN '9'
              ELSE digit[ARRAY_UPPER(digit, 1)]
            END) AS INT))
  FROM calibration_values;