SELECT *
FROM PortfolioProject..['COVIDDeaths$']
ORDER BY 3,4

SELECT *
FROM PortfolioProject..[COVIDVaccinations$]
ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..['COVIDDeaths$']
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths. 
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..['COVIDDeaths$']
WHERE location LIKE '%states%'
ORDER BY 1,2

-- Looking at Total Cases vs Population
SELECT Location, date, total_cases, population, (total_cases/population)*100 as InfectionRate
FROM PortfolioProject..['COVIDDeaths$']
WHERE location = 'United States'
ORDER BY 1,2

-- Countries with highest infection rate
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..['COVIDDeaths$']
-- WHERE location = 'United States'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Highest death count by country
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..['COVIDDeaths$']
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount desc

-- Highest death count by continent
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..['COVIDDeaths$']
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global numbers
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
FROM PortfolioProject..['COVIDDeaths$']
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- Total populations vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..['COVIDDeaths$'] dea
JOIN PortfolioProject..COVIDVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- TEMP Table
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
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..['COVIDDeaths$'] dea
JOIN PortfolioProject..COVIDVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL

-- Show rolling number of people vaccinated and rolling percentange of country vaccinated
SELECT *, (RollingPeopleVaccinated/Population) * 100 as PercentVaccinated
FROM #PercentPopulationVaccinated

-- Create views to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..['COVIDDeaths$'] dea
JOIN PortfolioProject..COVIDVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL;

CREATE VIEW CountryDeathRate AS 
-- Looking at Total Cases vs Total Deaths. 
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..['COVIDDeaths$']

CREATE VIEW CountryInfectionRate AS
SELECT Location, date, total_cases, population, (total_cases/population)*100 as InfectionRate
FROM PortfolioProject..['COVIDDeaths$']
