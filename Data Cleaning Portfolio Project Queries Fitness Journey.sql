-- Delete duplicate entries in the IronOasis table
DELETE FROM IronOasis
WHERE ctid NOT IN (
  SELECT min(ctid)
  FROM IronOasis
  GROUP BY Date, WorkoutDurationMinutes, ExercisesPerformed, IntensityLevel
);

-- Set default values for missing workout durations in IronOasis
UPDATE IronOasis
SET WorkoutDurationMinutes = 0  -- Or another default value or average
WHERE WorkoutDurationMinutes IS NULL;

-- Standardize date format 
UPDATE IronOasis
SET Date = TO_DATE(Date, 'YYYY-MM-DD')
WHERE Date IS NOT NULL AND Date !~ '^\d{4}-\d{2}-\d{2}$';

-- Identify potential outliers in workout durations
SELECT Date, WorkoutDurationMinutes
FROM IronOasis
WHERE WorkoutDurationMinutes > (SELECT AVG(WorkoutDurationMinutes) + 3 * STDDEV(WorkoutDurationMinutes) FROM IronOasis)
   OR WorkoutDurationMinutes < (SELECT AVG(WorkoutDurationMinutes) - 3 * STDDEV(WorkoutDurationMinutes) FROM IronOasis);

-- Standardize intensity levels to 'Low', 'Medium', 'High'
UPDATE IronOasis
SET IntensityLevel = CASE
  WHEN IntensityLevel ILIKE '%low%' THEN 'Low'
  WHEN IntensityLevel ILIKE '%medium%' THEN 'Medium'
  WHEN IntensityLevel ILIKE '%high%' THEN 'High'
  ELSE IntensityLevel
END;

-- Check for unrealistic WorkoutDurationMinutes values
SELECT *
FROM IronOasis
WHERE WorkoutDurationMinutes <= 0 OR WorkoutDurationMinutes > 300; 

-- Add a check constraint for positive workout durations
ALTER TABLE IronOasis
ADD CONSTRAINT positive_duration CHECK (WorkoutDurationMinutes >= 0);

-- Add a unique constraint to avoid future duplicates
ALTER TABLE IronOasis
ADD CONSTRAINT unique_workout UNIQUE(Date, ExercisesPerformed);

-- Remove duplicate hydration records
DELETE FROM HydrationHaven
WHERE ctid NOT IN (
    SELECT MIN(ctid)
    FROM HydrationHaven
    GROUP BY Date
);

--Cleaning Hydration Data
-- Correct unrealistic water intake values by setting them to NULL or a sensible default
UPDATE HydrationHaven
SET WaterIntakeOunces = NULL
WHERE WaterIntakeOunces <= 0 OR WaterIntakeOunces > 200; 

-- Eliminate duplicate walking activity entries, retaining the first instance for each date
DELETE FROM StrollStories
WHERE ctid NOT IN (
    SELECT MIN(ctid)
    FROM StrollStories
    GROUP BY Date
);

--Cleaning Walking Activity Data
-- Set negative or zero walk durations and distances to NULL for consistency
UPDATE StrollStories
SET WalkDurationMinutes = NULL
WHERE WalkDurationMinutes <= 0;

UPDATE StrollStories
SET DistanceCoveredMiles = NULL
WHERE DistanceCoveredMiles <= 0;

-- Standardize location names to ensure consistency in naming conventions
UPDATE StrollStories
SET Location = 'Central Park'  
WHERE Location IN ('central park', 'Central park', 'central Park');

--Cleaning Protein Intake Data
-- Remove duplicates in protein intake records, ensuring uniqueness by date and source
DELETE FROM ProteinPower
WHERE ctid NOT IN (
    SELECT MIN(ctid)
    FROM ProteinPower
    GROUP BY Date, ProteinSource
);


-- Adjust unrealistic protein intake values by setting them to a more plausible number or NULL
UPDATE ProteinPower
SET ProteinIntakeGrams = NULL
WHERE ProteinIntakeGrams <= 0 OR ProteinIntakeGrams > 300;  -- Assuming 300 grams as a daily maximum

--Cleaning Weekend Activities Data
-- Remove duplicate entries for weekend wellness data to maintain data integrity
DELETE FROM WeekendWellness
WHERE ctid NOT IN (
    SELECT MIN(ctid)
    FROM WeekendWellness
    GROUP BY Date
);

-- Ensure activity names are consistent to facilitate accurate analysis
UPDATE WeekendWellness
SET LeisureActivities = REPLACE(LeisureActivities, 'reading', 'Reading');  
