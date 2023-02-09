/*
Data Exploration Project
*/

-- Selecting all the data we have in our CovidDeaths file

SELECT *
FROM Portfolio_Projects.dbo.CovidDeaths
ORDER BY 3, 4



-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio_Projects.dbo.CovidDeaths
ORDER BY 1, 2



-- Looking at Total Cases vs Total Deaths
-- Continent is null of world, null contains dublicate value of location
-- Don't bring NULL Value
-- Use LIKE to contract covid in your country
-- Shows the Death percentage

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM Portfolio_Projects.dbo.CovidDeaths
WHERE location LIKE '%India%' AND total_deaths IS NOT NULL AND continent IS NOT NULL
ORDER BY 1, 2



-- Looking at Total Cases VS Populations
-- Shows what percentage of population got Covid
-- not null

SELECT location, date, population, total_cases, (total_cases/population)*100 AS Affected_Percentage
FROM Portfolio_Projects.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2



-- Looking at Countries with Highest Infection Rate compared to Population
-- Used having clause where data should not be null
-- Shows affected population percentage
-- Order by highest
-- Used Max to get maximum value of cases and population while grouping

SELECT location, population, MAX(total_cases) AS Highest_Infection, MAX((total_cases/population)*100) AS Highest_Affected_Percentage
FROM Portfolio_Projects.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
Having MAX((total_cases/population)*100) IS NOT NULL
ORDER BY Highest_Affected_Percentage DESC



-- Showing Countries with Highest Death Count per Population
-- Use casting to convert nvarchar(255) to Integer

SELECT location, MAX(CAST(total_deaths AS INT)) AS Total_Deaths_Count
FROM Portfolio_Projects.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
Having MAX(CAST(total_deaths AS INT)) IS NOT NULL
ORDER BY Total_Deaths_Count DESC



-- Break Things Down by Continent
-- Showing Continents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths AS INT)) AS Total_Deaths_Count
FROM Portfolio_Projects.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Deaths_Count DESC



-- Global Numbers

SELECT SUM(new_cases) AS Global_cases, SUM(CAST(new_deaths AS INT)) AS Global_Deaths, SUM(CAST(new_deaths AS INT)) / SUM(new_cases)*100 AS Global_Percentage
FROM Portfolio_Projects.dbo.CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2



-- Looking at total Population VS Vaccinations
-- Used casting to convert into interger
-- Used partition by to get rid of group by

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated, 
(SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)/dea.population)*100 AS Vacinated -- This looks lots conjusted we can't use our alies so we use CTE OR #TEMP Table
FROM Portfolio_Projects.dbo.CovidDeaths AS dea
JOIN Portfolio_Projects.dbo.CovidVaccinations AS vac
    ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3 



--we use CTE (common table expressions) for above division with the help of alies

WITH PopVSVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vacinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
FROM Portfolio_Projects.dbo.CovidDeaths AS dea
JOIN Portfolio_Projects.dbo.CovidVaccinations AS vac
    ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3 -- We Can't use order by under the CTE
)
SELECT *, (Rolling_People_Vacinated/Population)*100 AS Vacinated -- Getting the percentage
FROM PopVSVac
ORDER BY 2,3



-- #Temp Table
-- Created temporary table similar result but here is the inserting

DROP TABLE IF EXISTS #Percent_of_Vaccinated_Population
CREATE TABLE #Percent_of_Vaccinated_Population
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_People_Vaccinated numeric
)

INSERT INTO #Percent_of_Vaccinated_Population
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
--(SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)/dea.population)*100
FROM Portfolio_Projects.dbo.CovidDeaths AS dea
JOIN Portfolio_Projects.dbo.CovidVaccinations AS vac
    ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

SELECT *, (Rolling_People_Vaccinated/Population)*100 AS Vaccinated -- Getting the percentage
FROM #Percent_of_Vaccinated_Population
ORDER BY 1,2,3



-- Creating View to store data for later Visualizations
CREATE VIEW Percent_of_Vaccinated_Population AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
FROM Portfolio_Projects.dbo.CovidDeaths AS dea
JOIN Portfolio_Projects.dbo.CovidVaccinations AS vac
    ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- We Can't use Order by in our View Table



-- Selecting our view

SELECT *
FROM Percent_of_Vaccinated_Population



-- Deleting our view we created

DROP VIEW Percent_of_Vaccinated_Population