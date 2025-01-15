Select *
FROM PortfolioProject.coviddeaths
ORDER by 3,4;

Select *
FROM PortfolioProject.covidvaccinations
ORDER by 3,4;

Select location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.coviddeaths
Order by 1,2;

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.coviddeaths
Where location like '%states%'
Order by 1,2;

-- Total Cases vs Population

Select location, date, total_cases, population, (total_cases/population)*100 as PercentagePopulationInfected
FROM PortfolioProject.coviddeaths
Where location like '%states%'
Order by 1,2;

-- Countries with Highest Infection Rate

Select location,population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM PortfolioProject.coviddeaths

-- Where location like '%states%'

Group by location, population
Order by PercentagePopulationInfected desc;

-- Countries with Highest Death Rate

Select location, Max(cast(total_deaths as Signed)) as TotalDeathCount
FROM PortfolioProject.coviddeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc;

UPDATE PortfolioProject.coviddeaths
SET continent = NULL
WHERE continent = '';

-- Breaking things down by Continent

Select continent, Max(cast(total_deaths as Signed)) as TotalDeathCount
FROM PortfolioProject.coviddeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc;

-- Global Numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as signed)) as total_deaths, SUM(cast(new_deaths as signed))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject.coviddeaths
where continent is not null
-- group by date
Order by 1,2;

-- Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as signed)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPopulationVaccinated
from PortfolioProject.coviddeaths dea
Join PortfolioProject.covidvaccinations vac
	ON dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 2,3;

-- Use CTE

With PopVsVax (continent, location, date, population, new_vaccinations, RollingPopulationVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as signed)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPopulationVaccinated
from PortfolioProject.coviddeaths dea
Join PortfolioProject.covidvaccinations vac
	ON dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
)
Select * , (RollingPopulationVaccinated/Population)*100
from PopVsVax;

-- Temp Table

DROP Table if exists PercentPopulationVaccinated;

Create Table PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPopulationVaccinated numeric
);

Insert into PercentPopulationVaccinated
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(Ifnull(vac.new_vaccinations, 0)as signed)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPopulationVaccinated
From PortfolioProject.coviddeaths dea
Join PortfolioProject.covidvaccinations vac
 On dea.location = vac.location
 and dea.date = vac.date
Where dea.continent is not null
 and vac.new_vaccinations REGEXP '^[0-9]+$';

Select *, (RollingPopulationVaccinated/Population)*100
from PercentPopulationVaccinated;

-- Creating view for later visualizations

Create View PercentPopulationVaccinated as
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(Ifnull(vac.new_vaccinations, 0)as signed)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPopulationVaccinated
From PortfolioProject.coviddeaths dea
Join PortfolioProject.covidvaccinations vac
 On dea.location = vac.location
 and dea.date = vac.date
Where dea.continent is not null
 and vac.new_vaccinations REGEXP '^[0-9]+$';
