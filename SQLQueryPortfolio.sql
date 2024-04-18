--30 April 2021 Covid Sats
SELECT*
FROM [PortfolioProject].[dbo].[CovidDeaths]
Where continent is not null
Order By 3,4

--SELECT*
--FROM [PortfolioProject].[dbo].[CovidVaccinations]
--Order By 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [PortfolioProject].[dbo].[CovidDeaths]
Where continent is not null
Order By 1,2

--Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM [PortfolioProject].[dbo].[CovidDeaths]
WHERE location = 'South Africa'
Order By 1,2

--Looking at Total Cases vs Population

SELECT location, date, total_cases, population,(total_cases/population)*100 as InfectedPopulationPercentage
FROM [PortfolioProject].[dbo].[CovidDeaths]
WHERE location = 'South Africa'
Order By 1,2

--Looking at countries with highest Infection Rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as InfectedPopulationPercentage
FROM [PortfolioProject].[dbo].[CovidDeaths]
--WHERE location = 'South Africa'
Where continent is null
Group By location, population 
Order By InfectedPopulationPercentage DESC

--Looking at HighestDeath Count per Population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [PortfolioProject].[dbo].[CovidDeaths]
--WHERE location = 'South Africa'
Where continent is null
Group By location
Order By TotalDeathCount DESC

--Looking at Continents
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [PortfolioProject].[dbo].[CovidDeaths]
--WHERE location = 'South Africa'
Where continent is null
Group By location
Order By TotalDeathCount DESC

--Showing continents with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [PortfolioProject].[dbo].[CovidDeaths]
--WHERE location = 'South Africa'
Where continent is not null
Group By continent
Order By TotalDeathCount DESC


--Global Numbers

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
FROM [PortfolioProject].[dbo].[CovidDeaths]
--WHERE location = 'South Africa'
Where continent is not null
Group By date
Order By 1,2 

--Total Global Numbers

SELECT  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
FROM [PortfolioProject].[dbo].[CovidDeaths]
--WHERE location = 'South Africa'
Where continent is not null
--Group By date
Order By 1,2 

--Looking at Total Population vs Total Vaccination

With PopvsVac (Continent, location, date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
 dea.date) as RollingPeopleVaccinated

FROM [PortfolioProject].[dbo].[CovidDeaths] AS dea
Join [PortfolioProject].[dbo].[CovidVaccinations] AS vac
     ON dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3
)
SELECT*, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--TEMP TABLE

DROP Table if exists #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,
 dea.date) as RollingPeopleVaccinated

FROM [PortfolioProject].[dbo].[CovidDeaths] AS dea
Join [PortfolioProject].[dbo].[CovidVaccinations] AS vac
     ON dea.location = vac.location
	 and dea.date = vac.date
--Where dea.continent is not null
--Order By 2,3

SELECT*, (RollingPeopleVaccinated/Population)*100
FROM #PercentagePopulationVaccinated


--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW PercentagePopulationVaccinated
AS
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM 
    [PortfolioProject].[dbo].[CovidDeaths] AS dea
JOIN 
    [PortfolioProject].[dbo].[CovidVaccinations] AS vac
ON 
    dea.location = vac.location
    AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL;

SELECT*
FROM PercentagePopulationVaccinated
