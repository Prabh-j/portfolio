USE COVID_19;

-- Selecting all records from the covid_deaths table with a limit of 1000
SELECT *
FROM covid_deaths
LIMIT 1000;

-- to convert empty cells to null 
SET SQL_SAFE_UPDATES = 0;
UPDATE covid_deaths
SET continent = NULLIF(continent , '');

UPDATE covid_vacination
SET new_vaccinations= NULLIF(new_vaccinations, '');


-- Total Cases vs Total Deaths, Mortality rate fluctuation over the months for Canada
SELECT
  date,
  location,
  CAST(total_cases AS SIGNED) AS total_cases,
  CAST(total_deaths AS SIGNED) AS total_deaths,
  (CAST(total_deaths AS DECIMAL) / CAST(total_cases AS DECIMAL)) * 100 AS percentage
FROM covid_deaths
WHERE
  continent IS NOT NULL
  AND location = 'Canada';

-- Comparing total cases and total deaths at their peak for each country
SELECT
  location,
  MAX(CAST(total_cases AS SIGNED)) AS total_case,
  MAX(CAST(total_deaths AS SIGNED)) AS total_death,
  (MAX(CAST(total_deaths AS DECIMAL)) / MAX(CAST(total_cases AS DECIMAL))) * 100 AS percentage
FROM covid_deaths
WHERE
  continent IS NOT NULL
GROUP BY
  location
ORDER BY
  total_case DESC;

-- Total Cases vs Population, Checking the spread of virus over the months for Canada
SELECT
  date,
  location,
  CAST(total_cases AS SIGNED) AS total_cases,
  CAST(population AS SIGNED) AS population,
  (CAST(total_cases AS DECIMAL) / CAST(population AS DECIMAL)) * 100 AS infected_population
FROM covid_deaths
WHERE
  continent IS NOT NULL
  AND location = 'Canada';

-- Checking the total infected cases compared to population of each country
SELECT
  location,
  MAX(CAST(total_cases AS SIGNED)) AS total_case,
  CAST(population AS SIGNED) AS population,
  (MAX(CAST(total_cases AS DECIMAL)) / CAST(population AS DECIMAL)) * 100 AS percentage
FROM covid_deaths
WHERE
  continent IS NOT NULL
GROUP BY
  location,
  population
ORDER BY
  percentage DESC;

-- Checking the total death cases compared to population for each country
SELECT
  location,
  SUM(CAST(new_deaths AS SIGNED)) AS total_death,
  CAST(population AS SIGNED) AS population,
  (SUM(CAST(new_deaths AS DECIMAL)) / CAST(population AS DECIMAL)) * 100 AS death_percentage
FROM covid_deaths
WHERE
  continent IS NOT NULL
GROUP BY
  location,
  population
ORDER BY
  death_percentage DESC;

-- Breaking down by continent, Deaths vs Population
SELECT
  continent,
  SUM(CAST(new_deaths AS SIGNED)) AS total_death,
  SUM(CAST(population AS SIGNED)) AS total_population,
  (SUM(CAST(new_deaths AS DECIMAL)) / SUM(CAST(population AS DECIMAL))) * 100 AS death_percentage
FROM covid_deaths
WHERE
  continent IS NOT NULL
GROUP BY
  continent
ORDER BY
  death_percentage DESC;

-- Looking at the whole world
SELECT
  SUM(CAST(population AS SIGNED)) AS total_population,
  SUM(CAST(new_deaths AS SIGNED)) AS total_death,
  SUM(CAST(new_cases AS SIGNED)) AS total_cases,
  (SUM(CAST(new_deaths AS DECIMAL)) / SUM(CAST(new_cases AS DECIMAL))) * 100 AS death_percentage
FROM covid_deaths
WHERE
  continent IS NOT NULL;

-- Vaccinations
SELECT
  location,
  population AS SIGNED,
  MAX(CAST(people_vaccinated AS SIGNED)) AS total_vaccinateds,
  (MAX(CAST(people_vaccinated AS DECIMAL)) / CAST(population AS DECIMAL)) * 100 AS population_vaccinated
FROM covid_vacination
WHERE
  continent IS NOT NULL
GROUP BY
  location,
  population
ORDER BY
  1,2;

-- Using Common Table Expressions (CTE) for total_vacci
WITH total_vacci AS (
    SELECT
        DEA.continent,
        DEA.location,
        DEA.date,
        DEA.population,
        VAC.new_vaccinations,
        SUM(CAST(VAC.new_vaccinations AS DECIMAL)) OVER (PARTITION BY DEA.location ORDER BY DEA.date) AS total_vaccination
    FROM
        covid_deaths AS DEA
    JOIN
        covid_vacination AS VAC 
        ON DEA.location = VAC.location 
        AND DEA.date = VAC.date
	WHERE
        DEA.continent IS NOT NULL
)
SELECT *, (total_vaccination/population)*100 AS vaccinated_percentage
FROM total_vacci;

-- TEMP TABLE

DROP TEMPORARY TABLE  IF EXISTS total_vacci;
CREATE TEMPORARY TABLE total_vacci
    SELECT
        DEA.continent,
        DEA.location,
        DEA.date,
        DEA.population,
        VAC.new_vaccinations,
        SUM(CAST(VAC.new_vaccinations AS DECIMAL)) OVER (PARTITION BY DEA.location ORDER BY DEA.date) AS total_vaccination
    FROM
        covid_deaths AS DEA
    JOIN
        covid_vacination AS VAC 
        ON DEA.location = VAC.location 
        AND DEA.date = VAC.date
	WHERE
        DEA.continent IS NOT NULL;

SELECT *, (total_vaccination/population)*100 AS vaccinated_percentage
FROM total_vacci;

-- Creating views for visualization
DROP VIEW IF EXISTS people_vaccinated;
CREATE VIEW people_vaccinated as
SELECT
  location,
  MAX(CAST(total_cases AS SIGNED)) AS total_case,
  CAST(population AS SIGNED) AS population,
  (MAX(CAST(total_cases AS DECIMAL)) / CAST(population AS DECIMAL)) * 100 AS percentage
FROM covid_deaths
WHERE
  continent IS NOT NULL
GROUP BY
  location,
  population








