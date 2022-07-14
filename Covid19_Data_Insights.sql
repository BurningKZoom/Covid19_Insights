-- Looking at Total cases vs Total deaths
-- Shows likelihood of dying if contracting covid in Thailand

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location = 'Thailand'
and continent is not null
order by 1,2

--------------------------------------------------------------------------------------------------------------------------------------------
-- Looking at Total cases vs Population
-- Shows how much percentage of population got infected by Covid-19

select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
order by 1,2

--------------------------------------------------------------------------------------------------------------------------------------------
-- Looking at Countries with highest infection rate compared to population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
group by location, population
order by PercentPopulationInfected desc 

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc 

--------------------------------------------------------------------------------------------------------------------------------------------
-- Showing Countries with the highest death count per population

select location, sum(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
and location not in ('World', 'European Union', 'International', 'High income', 'Low income', 'Lower middle income', 'Upper middle income') -- Search for all country except continents and income level
group by location
order by TotalDeathCount desc 

--------------------------------------------------------------------------------------------------------------------------------------------
-- Showing continents with the highest death count per population

select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--------------------------------------------------------------------------------------------------------------------------------------------
-- Summary Global numbers (Total Cases, Total Deaths, Death Rate)

select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2 

--------------------------------------------------------------------------------------------------------------------------------------------
-- Looking at total Population vs total Vaccination
-- Choice 1 CTE

with PopVsVac (continent, location, date, population, new_vaccinations, total_vaccination)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as total_vaccination
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
select *, (total_vaccination/population)*100 as VaccinationPercentage
from PopVsVac


-- Choice 2 Temp table

drop table if exists #VaccinationPercentage
create table #VaccinationPercentage
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
total_vaccination numeric
)

insert into #VaccinationPercentage
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as total_vaccination
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date

select *, (total_vaccination/population)*100 as VaccinationPercentage
from #VaccinationPercentage
order by 2,3
