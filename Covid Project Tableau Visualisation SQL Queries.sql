/*
    Queries used for Tableau Project
*/

--1. 

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 
    AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE [location] LIKE 'africa%'
WHERE continent IS NOT NULL
--GROUP BY [date]
ORDER BY 1,2

--2.

-- We take these out as they are not included in the above queries and want to stay consistent
-- European Union is part of Europe

SELECT [location], SUM(cast(total_deaths as int)) AS TotalDeathsCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL AND [location] not in ('World', 'European Union', 'International')
GROUP BY [location]
ORDER BY TotalDeathsCount DESC

--3

--Looking at countries with highest infection rate comapred to population

SELECT [location], population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PopulationInfectedPercentage
FROM PortfolioProject..CovidDeaths
--WHERE [location] LIKE 'africa%'
GROUP BY population,[location]
ORDER BY PopulationInfectedPercentage DESC

--4. 

SELECT TOP 79000 [location], population, date, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PopulationInfectedPercentage
FROM PortfolioProject..CovidDeaths
--WHERE [location] LIKE 'africa%'
GROUP BY population,[location], date
ORDER BY PopulationInfectedPercentage DESC

