-- create the first query that filters for matches where Manchester United played as the home team.

SELECT 
    m.id, 
	t.team_long_name,
    -- Identify matches as home/away wins or ties
	CASE WHEN m.home_goal > m.away_goal THEN 'MU Win'
		 WHEN m.home_goal < m.away_goal THEN 'MU Loss' 
         ELSE 'Tie' END AS outcome
FROM match AS m
-- Left join team on the home team ID and team API id
LEFT JOIN team AS t 
ON m.hometeam_id = t.team_api_id
WHERE 
	-- Filter for 2014/2015 and Manchester United as the home team
	m.season = '2014/2015'
	AND t.team_long_name = 'Manchester United';

-- identify matches as a win or loss for Manchester United. 
SELECT 
    m.id, 
    t.team_long_name,
    -- Identify matches as home/away wins or ties
    CASE 
        WHEN m.home_goal > m.away_goal THEN 'MU Loss'
        WHEN m.home_goal < m.away_goal THEN 'MU Win'
        ELSE 'Tie' 
    END AS outcome
-- Join team table to the match table
FROM match AS m
LEFT JOIN team AS t 
ON m.awayteam_id = t.team_api_id
WHERE 
    -- Filter for 2014/2015 and Manchester United as the away team
    m.season = '2014/2015'
    AND t.team_long_name = 'Manchester United';

-- here's a query that extracted data from two common table expressions.
WITH home AS (
  SELECT m.id, t.team_long_name,
    CASE WHEN m.home_goal > m.away_goal THEN 'MU Win'
         WHEN m.home_goal < m.away_goal THEN 'MU Loss' 
         ELSE 'Tie' END AS outcome
  FROM match AS m
  LEFT JOIN team AS t ON m.hometeam_id = t.team_api_id),
-- Set up the away team CTE
away AS (
  SELECT m.id, t.team_long_name,
    CASE WHEN m.home_goal > m.away_goal THEN 'MU Loss'
         WHEN m.home_goal < m.away_goal THEN 'MU Win' 
         ELSE 'Tie' END AS outcome
  FROM match AS m
  LEFT JOIN team AS t ON m.awayteam_id = t.team_api_id)
-- Select team names, the date and goals
SELECT DISTINCT
    m.date,
    home.team_long_name AS home_team,
    away.team_long_name AS away_team,
    m.home_goal,
    m.away_goal
-- Join the CTEs onto the match table
FROM match AS m
LEFT JOIN home ON m.id = home.id
LEFT JOIN away ON m.id = away.id
WHERE m.season = '2014/2015'
      AND (home.team_long_name = 'Manchester United' 
           OR away.team_long_name = 'Manchester United');

-- how badly did Manchester United lose in each match?

-- Set up the home team CTE
WITH home AS (
  SELECT m.id, t.team_long_name,
    CASE WHEN m.home_goal > m.away_goal THEN 'MU Win'
         WHEN m.home_goal < m.away_goal THEN 'MU Loss' 
         ELSE 'Tie' END AS outcome
  FROM match AS m
  LEFT JOIN team AS t ON m.hometeam_id = t.team_api_id),
-- Set up the away team CTE
away AS (
  SELECT m.id, t.team_long_name,
    CASE WHEN m.home_goal > m.away_goal THEN 'MU Loss'
         WHEN m.home_goal < m.away_goal THEN 'MU Win' 
         ELSE 'Tie' END AS outcome
  FROM match AS m
  LEFT JOIN team AS t ON m.awayteam_id = t.team_api_id)
-- Select columns and rank the matches by goal difference
SELECT DISTINCT
    m.date,
    home.team_long_name AS home_team,
    away.team_long_name AS away_team,
    m.home_goal, 
    m.away_goal,
    RANK() OVER(ORDER BY ABS(m.home_goal - m.away_goal) DESC) as match_rank
-- Join the CTEs onto the match table
FROM match AS m
LEFT JOIN home ON m.id = home.id
LEFT JOIN away ON m.id = away.id
WHERE m.season = '2014/2015'
      AND ((home.team_long_name = 'Manchester United' AND home.outcome = 'MU Loss')
      OR (away.team_long_name = 'Manchester United' AND away.outcome = 'MU Loss'));
