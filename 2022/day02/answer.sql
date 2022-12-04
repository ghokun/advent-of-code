DROP SCHEMA IF EXISTS day02 CASCADE;
CREATE SCHEMA day02;

CREATE TABLE day02.input (
  id         SERIAL,
  player_one TEXT NOT NULL,
  player_two TEXT NOT NULL
);

\COPY day02.input (player_one, player_two) FROM '2022/day02/input.txt' WITH (DELIMITER ' ');

-- part 1
WITH game (alias_one, alias_two, hand_score, wins) AS (
  VALUES 
    ('A', 'X', 1, 'C'),
    ('B', 'Y', 2, 'A'),
    ('C', 'Z', 3, 'B')
)
SELECT
      SUM(CASE
            WHEN i.player_one = g.alias_one THEN 3
            WHEN i.player_one = g.wins      THEN 6
            ELSE 0
          END + g.hand_score) AS score
  FROM day02.input i
  JOIN game g ON i.player_two = g.alias_two;

-- part 2
WITH hand_score (hand, score) AS (
  VALUES 
    ('A', 1),
    ('B', 2),
    ('C', 3)
), guide (ending, score) AS (
  VALUES 
    ('X', 0),
    ('Y', 3),
    ('Z', 6)
), win_loss (hand, score, win, loss) AS (
  SELECT hs.*,
       COALESCE(LAG(hs.score, 1) OVER(ORDER BY hs.hand DESC), (SELECT w.score FROM hand_score w ORDER BY w.hand ASC LIMIT 1)) AS win,
       COALESCE(LAG(hs.score, 1) OVER(ORDER BY hs.hand ASC), (SELECT l.score FROM hand_score l ORDER BY l.hand DESC LIMIT 1)) AS loss
    FROM hand_score hs
)
SELECT
    SUM (
      CASE
        WHEN i.player_two = 'X' THEN wl.loss
        WHEN i.player_two = 'Y' THEN wl.score
        WHEN i.player_two = 'Z' THEN wl.win
      END + g.score
    )
  FROM day02.input i
  JOIN win_loss wl ON i.player_one = wl.hand
  JOIN guide g     ON i.player_two = g.ending;