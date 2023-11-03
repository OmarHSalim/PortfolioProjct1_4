
SELECT *
FROM PortfolioProject..CovidDeaths
-- order by date and population
--Where continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- Select Data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
-- Order by location and date
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
-- Calculations of percentage of total deaths
SELECT location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / CONVERT(float, total_cases))*100 as DeathPercentage 
FROM PortfolioProject..CovidDeaths
-- Select United States from
WHERE location like '%states%'
-- OR, selecting Hong Kong from 
--WHERE location like '%Hong%'
-- Order by location and date
ORDER BY 1,2


--Looking at Total Cases vs Population
-- Shows what percentage of population got COVID
SELECT location, date, population, total_cases, (CONVERT(float, total_cases) / CONVERT(float, population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
-- Select United States from
WHERE location like '%states%'
-- Order by location and date
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, Max((CONVERT(float, total_cases) / CONVERT(float, population)))*100 
as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
-- Select United States from
--WHERE location like '%states%'
-- Group By must be added
Group by location,population
ORDER BY PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population
SELECT continent, MAX(CONVERT(int,total_deaths)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
-- Group By must be added
Group by continent
ORDER BY TotalDeathCount desc

--Let's break things down by continent 
SELECT location, MAX(CONVERT(int,total_deaths)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
-- Group By must be added
Group by location
ORDER BY TotalDeathCount desc


--Apply sum for global 
SELECT SUM(CONVERT(int,new_cases)) as total_cases, SUM(CONVERT(int,new_deaths)) as total_deaths
,(SUM(CONVERT(float,new_deaths)) / SUM(CONVERT(float, total_cases)))*100 AS Deathpercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
-- Group By must be added
--Group by date
ORDER BY 1,2

Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from PortfolioProject..covidDeaths
ORDER BY 1,2

Select *
From PortfolioProject..CovidVaccinations


-- Now, join two tables based location and date
Select *
-- From Deaths Table saved as dea
From PortfolioProject..covidDeaths dea
Join PortfolioProject..CovidVaccinations vac -- Table 2 saved as vac 
     On dea.location = vac.location
	 and dea.date = vac.date

-- Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as
RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100
-- From Deaths Table saved as dea
From PortfolioProject..covidDeaths dea
Join PortfolioProject..CovidVaccinations vac -- Table 2 saved as vac 
     On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
order by 2,3


---Creating CTE
With PopvsVac (continent, location, date, population, new_vaccinations,RollingPeopleVaccinated) as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as
RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
-- From Deaths Table saved as dea
From PortfolioProject..covidDeaths dea
Join PortfolioProject..CovidVaccinations vac -- Table 2 saved as vac 
     On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)

Select *,
(RollingPeopleVaccinated/population)*100 as VaccinatedPercentage 
From PopvsVac

-- 
--Using Temp Table to perform Calculation on Partition By in previous query
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for Tableau later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select *
From PercentPopulationVaccinated 