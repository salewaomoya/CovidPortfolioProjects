/*
    Covid-19 DATA EXPLORATION

    Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Type
*/

SELECT*
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT*
FROM PortfolioProject..CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY 3,4

-- Select data we are going to be using 
SELECT [location], [date], total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


--Looking at Total Cases vs Total Death
--Shows likelihood of dying if you contract covid in your country

SELECT [location], [date], total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE [location] LIKE 'africa%'
ORDER BY 1,2

--Looking at the Total cases vs the population
--Shows what percentage of population that got covid-19

SELECT [location], [date], total_cases,population, (total_cases/population)*100 AS TotalCasesPercentage
FROM PortfolioProject..CovidDeaths
--WHERE [location] LIKE 'africa%'
ORDER BY 1,2

--Looking at countries with highest infection rate comapred to population

SELECT [location], population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PopulationInfectedPercentage
FROM PortfolioProject..CovidDeaths
--WHERE [location] LIKE 'africa%'
WHERE continent IS NOT NULL
GROUP BY population,[location]
ORDER BY PopulationInfectedPercentage DESC

--Showing countries with Highest Death Count per Population

SELECT [location],MAX(cast(total_deaths as int)) AS TotalDeathsCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY [location]
ORDER BY TotalDeathsCount DESC

--FILTERING BY CONTINENT

--Showing continents with highest Death Count per Population

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathsCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathsCount DESC

--GLOBAL NUMBERS

-- SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 
--     AS DeathPercentage
-- FROM PortfolioProject..CovidDeaths
-- --WHERE [location] LIKE 'africa%'
-- WHERE continent IS NOT NULL
-- --GROUP BY [date]
-- ORDER BY 1,2

SELECT [date], SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 
    AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE [location] LIKE 'africa%'
WHERE continent IS NOT NULL
GROUP BY [date]
ORDER BY 1,2

--Looking at Total Population vs Vaccination 

--Partioning(BREAKING IT UP) it by Location and date because everytime it get to a new location
--I want the count to start over instead of it continue running

SELECT dea.continent, dea.[location], dea.date, dea.population, 
vac.new_vaccinations, SUM(cast(vac.new_vaccinations AS int)) OVER (PARTITION by dea.location ORDER BY dea.location, dea.date)
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac 
    ON dea.[location] = vac.[location]
    AND dea.[date] = vac.[date]
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- Using CTE to perform Calculation on Partition By in previous query

WITH PopVsVacPercent (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS(
SELECT dea.continent, dea.[location], dea.date, dea.population, 
vac.new_vaccinations, SUM(vac.new_vaccinations) 
OVER (PARTITION by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac 
    ON dea.[location] = vac.[location]
    AND dea.[date] = vac.[date]
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT*, (RollingPeopleVaccinated/population)*100
FROM PopVsVacPercent

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS #PercentPopulationVaccination
CREATE TABLE #PercentPopulationVaccination
(
    continent NVARCHAR(50),
    location NVARCHAR(50),
    date date,
    population NUMERIC, 
    new_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccination
SELECT dea.continent, dea.[location], dea.date, dea.population, 
vac.new_vaccinations, SUM(vac.new_vaccinations) 
OVER (PARTITION by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac 
    ON dea.[location] = vac.[location]
    AND dea.[date] = vac.[date]
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT*, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccination

/*
    Creating a view to store data later for Data Visualisation
*/

Create VIEW PercentPopulationVaccination AS
SELECT dea.continent, dea.[location], dea.date, dea.population, 
vac.new_vaccinations, SUM(vac.new_vaccinations) 
OVER (PARTITION by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac 
    ON dea.[location] = vac.[location]
    AND dea.[date] = vac.[date]
WHERE dea.continent IS NOT NULL

