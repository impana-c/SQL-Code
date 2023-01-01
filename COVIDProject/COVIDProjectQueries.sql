-- COVID DEATHS
SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4 

-- Selecting data to work with.
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

-- 1. Total Cases vs Total Deaths. 
-- Shows the likelihood of death if COVID is contracted per country. 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
--Where location = 'United States'
ORDER BY 1,2

-- 2. Total Cases vs Population. 
-- Shows the percentage of population that contracted COVID per country. 
SELECT location, date, population, total_cases, (total_cases/population)*100 as PopulationPercentageInfected
FROM CovidDeaths
--Where location = 'United States'
ORDER BY 1,2

-- 3. Highest Infection Rate compared to Population
-- Shows the highest percentage of population that contracted COVID per country. 
SELECT location, population, MAX(total_cases)as HighestInfectionCount, MAX((total_cases/population))*100 as PopulationPercentageInfected
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PopulationPercentageInfected desc

-- 4. Highest Death Count
-- Shows the highest number of that died per country. 
SELECT location, population, MAX(total_deaths)as HighestDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY HighestDeathCount desc

-- 5. Highest Death Count by Continent
-- Shows the highest number of that died per continent. 
SELECT location, MAX(total_deaths) as HighestDeathCount
FROM CovidDeaths
WHERE continent IS NULL
    AND location NOT LIKE '%income'
    AND location NOT LIKE '%union'
    And location != 'World' 
    And location != 'International' 
GROUP BY location
ORDER BY HighestDeathCount desc

-- 6. Global Death Percentage for Each Date
SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--------------------------------------------
-- COVID VACCINATIONS

-- 7. Total Population vs. Vaccination
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations
, SUM(vacc.new_vaccinations) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) as RollingPeopleVaccinated
FROM CovidDeaths deaths
JOIN CovidVaccinations vacc
    ON deaths.location = vacc.location
    AND deaths.date = vacc.date
WHERE deaths.continent IS NOT NULL
ORDER BY 2,3

-- 8. Rolling Vaccination Count per Country
-- Create a rolling sum of the number of people vaccinated for every country on each date
-- Way 1. USE CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations
, SUM(vacc.new_vaccinations) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) as RollingPeopleVaccinated
FROM CovidDeaths deaths
JOIN CovidVaccinations vacc
    ON deaths.location = vacc.location
    AND deaths.date = vacc.date
WHERE deaths.continent IS NOT NULL
)

SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM PopvsVac


-- Way 2. TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime, 
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations
, SUM(vacc.new_vaccinations) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) as RollingPeopleVaccinated
FROM CovidDeaths deaths
JOIN CovidVaccinations vacc
    ON deaths.location = vacc.location
    AND deaths.date = vacc.date
WHERE deaths.continent IS NOT NULL
ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- 9. Creating View
-- CREATE View PercentPopulationVaccinated AS
-- SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations
-- , SUM(vacc.new_vaccinations) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) as RollingPeopleVaccinated
-- FROM CovidDeaths deaths
-- JOIN CovidVaccinations vacc
--     ON deaths.location = vacc.location
--     AND deaths.date = vacc.date
-- WHERE deaths.continent IS NOT NULL

-- SELECT *
-- FROM PercentPopulationVaccinated


