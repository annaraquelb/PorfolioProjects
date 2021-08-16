select * from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

select * from PortfolioProject..CovidVaccinations
order by 3,4

--select the data i will use

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--looking after total cases vs total deaths
-- show the probability of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null and location like '%brazil%'
order by 1,2

--looking at total cases vs population
--shows what percentage of population got covid

select location, date, total_cases, population, (total_cases/population)*100 as 
PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%brazil%'
where continent is not null
order by 1,2

--looking at countries with highest infection rates compared to population

select location, max(total_cases) as HighestInfectionCount, population, 
(max(total_cases)/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by PercentPopulationInfected desc

-- showing the countries with the highest death count per population

select location, max(cast(total_deaths as int)) as TotalDeathCount, population, 
(max(total_deaths)/population)*100 as PercentPopulationDied
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by TotalDeathCount desc

-- break this down by continent
--showing continents with highest death counts

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc

--global numbers

select date,sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths,
(sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths,
(sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Looking at total popuation vs vaccinations


--use cte
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location
,cast(dea.date as date)) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/dea.population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location 
	and	dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100 from PopvsVac

-- temp table
drop table if exists  #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(Continent nvarchar(250), 
Location nvarchar(250),
Date date, 
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated 
select dea.continent, dea.location, cast(dea.date as date), dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location
,cast(dea.date as date)) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/dea.population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location 
	and	dea.date=vac.date
where dea.continent is not null
order by 2,3
select *, (RollingPeopleVaccinated/population)*100 from #PercentPopulationVaccinated 

-- create view to store data for later visualisations


create view PercentPopulationVaccinated as
select dea.continent, dea.location, cast(dea.date as date) as Date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location
,cast(dea.date as date)) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/dea.population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location 
	and	dea.date=vac.date
where dea.continent is not null

select * from PercentPopulationVaccinated
