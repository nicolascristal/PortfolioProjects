DELETE FROM deaths;

ALTER TABLE covid.deaths MODIFY COLUMN total_cases int NULL;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM deaths
ORDER BY 1, 2;

SELECT location, date, total_cases, total_deaths, ROUND(((total_deaths/total_cases) * 100), 2) as fatality_rate
FROM deaths
WHERE date = '2024-03-31'
AND continent LIKE '%ameri%'
ORDER BY fatality_rate DESC
LIMIT 20;

SELECT location, date, population, total_cases, ((total_cases/population) * 100) as infection_rate
FROM deaths
WHERE location = 'United States'
ORDER BY 2 DESC;

SELECT location, population, MAX(total_cases) as max_total_cases, MAX(((total_cases/population) * 100)) as infection_rate
FROM deaths
WHERE date LIKE '%2021%'
AND continent LIKE '%america'
GROUP BY population, location
ORDER BY infection_rate DESC;

SELECT location, MAX(total_deaths) as total_death_count
FROM deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC;

SELECT continent, MAX(total_deaths) as total_death_count
FROM deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC;

SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/ SUM(new_cases) * 100 as fatality_rate
FROM deaths
WHERE continent IS NOT NULL
AND new_cases > 0
GROUP BY date
ORDER BY 1, 2;

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/ SUM(new_cases) * 100 as fatality_rate
FROM deaths
WHERE continent IS NOT NULL
AND new_cases > 0
ORDER BY 1, 2;

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS total_vaccinations
FROM deaths AS d
JOIN vaccinations AS v
	ON d.location = v.location
    AND d.date = v.date
WHERE d.continent IS NOT NULL
AND d.location = "United States"
ORDER BY 2, 3;

WITH pop_vs_vac (continent, location, date, population, new_vaccinations, total_vaccinations)
AS (SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS total_vaccinations
FROM deaths AS d
JOIN vaccinations AS v
	ON d.location = v.location
    AND d.date = v.date
WHERE d.continent IS NOT NULL
)
SELECT *, ROUND((total_vaccinations/population) * 100, 2) AS vaccination_rate
FROM pop_vs_vac;

-- TEMP TABLE

SET GLOBAL max_allowed_packet=1073741824;

DROP TABLE IF EXISTS population_vaccinated_percentage;
CREATE TABLE population_vaccinated_percentage (
	continent CHAR(255),
    location CHAR(255),
    date DATE,
    population BIGINT,
    new_vaccinations BIGINT,
    total_vaccinations BIGINT
);
INSERT INTO population_vaccinated_percentage
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS total_vaccinations
FROM deaths AS d, vaccinations AS v
WHERE d.continent IS NOT NULL;
SELECT *, ROUND((total_vaccinations/population) * 100, 2) AS vaccination_rate
FROM population_vaccinated_percentage;

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS total_vaccinations
FROM deaths AS d, vaccinations AS v
WHERE d.continent IS NOT NULL;

-- CREATE VIEW

CREATE VIEW population_vaccinated_percentage AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS total_vaccinations
FROM deaths AS d 
JOIN vaccinations AS v ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL;
