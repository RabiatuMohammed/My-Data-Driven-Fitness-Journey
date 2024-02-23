-- Retrieve total count of workout sessions and average duration
SELECT COUNT(*) AS total_sessions, AVG(WorkoutDurationMinutes) AS avg_duration
FROM IronOasis;

-- Calculate the average daily water intake
SELECT AVG(WaterIntakeOunces) AS avg_daily_intake
FROM HydrationHaven;

-- Find the top 3 most frequented walking locations
SELECT Location, COUNT(*) AS visit_count
FROM StrollStories
GROUP BY Location
ORDER BY visit_count DESC
LIMIT 3;

-- Summarize total workout minutes and session count by month
SELECT DATE_TRUNC('month', Date) AS month, COUNT(*) AS session_count, SUM(WorkoutDurationMinutes) AS total_minutes
FROM IronOasis
GROUP BY month
ORDER BY month;

-- Compare average daily water intake on days with high-intensity workouts vs. other days
SELECT
  io.IntensityLevel,
  AVG(hh.WaterIntakeOunces) AS avg_water_intake
FROM IronOasis io
JOIN HydrationHaven hh ON io.Date = hh.Date
GROUP BY io.IntensityLevel;

-- Calculate monthly average protein intake
SELECT DATE_TRUNC('month', Date) AS month, AVG(ProteinIntakeGrams) AS avg_protein_intake
FROM ProteinPower
GROUP BY month
ORDER BY month;

-- Analyze average workout duration on weekends vs. weekdays
SELECT
  CASE
    WHEN EXTRACT(ISODOW FROM Date) IN (6, 7) THEN 'Weekend'
    ELSE 'Weekday'
  END AS day_type,
  AVG(WorkoutDurationMinutes) AS avg_duration
FROM IronOasis
GROUP BY day_type;

-- Compare average weekend rest hours on days after long walks vs. shorter walks
WITH WalkStats AS (
  SELECT Date, DistanceCoveredMiles,
    LEAD(Date, 1) OVER (ORDER BY Date) AS NextDay
  FROM StrollStories
)
SELECT
  CASE
    WHEN ws.DistanceCoveredMiles > (SELECT AVG(DistanceCoveredMiles) FROM StrollStories) THEN 'Long Walks'
    ELSE 'Short Walks'
  END AS walk_length,
  AVG(ww.RestfulHoursSat + ww.RestfulHoursSun) AS avg_rest_hours
FROM WalkStats ws
JOIN WeekendWellness ww ON ws.NextDay = ww.Date
GROUP BY walk_length;

-- Determine the top 5 protein sources based on overall intake
SELECT ProteinSource, SUM(ProteinIntakeGrams) AS total_intake
FROM ProteinPower
GROUP BY ProteinSource
ORDER BY total_intake DESC
LIMIT 5;


