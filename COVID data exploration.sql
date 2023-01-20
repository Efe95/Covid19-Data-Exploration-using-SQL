select *
from portfolioproject..coviddeaths
order by 3,4

select *
from portfolioproject..covidvaccinations
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from portfolioproject..coviddeaths
where continent is not null
order by 1,2

--looking at total cases vs total deaths
-- shows likelihood of dying in your own country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from portfolioproject..coviddeaths
where location like '%states%'
order by 1,2

--looking at total cases vs population
--shows what percentage of population got covid
select location, date, population, total_cases,(total_cases/population)*100 as deathpercentage
from portfolioproject..coviddeaths
where continent is not null
and location like '%states%'
order by 1,2

--looking at the countries with highest infection rate compared to population
select location, population, max(total_cases) as highestinfectioncount, max((total_cases/population))*100 as percentpopulationinfected
from portfolioproject..coviddeaths
--where location like '%states%'
where continent is not null
group by location, population
order by percentpopulationinfected desc

-- showing countries with highest death count per population
select location, max(cast(total_deaths as int)) as totaldeathcount
from portfolioproject..coviddeaths
--where location like '%states%'
where continent is not null
group by location
order by totaldeathcount desc

-- breaking down by continent
--showing continents with the highest death count per population
select continent, max(cast(total_deaths as int)) as totaldeathcount
from portfolioproject..coviddeaths
--where location like '%states%'
where continent is not null
group by continent
order by totaldeathcount desc

-- global numbers

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from portfolioproject..coviddeaths
--where location like '%states%'
where continent is not null and total_cases is not NULL
group by date
order by 1,2

-- global numbers death percentage

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from portfolioproject..coviddeaths
--where location like '%states%'
where continent is not null and total_cases is not NULL
--group by date
order by 1,2

-- looking at toatal population vs vaccinations
with popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from portfolioproject..coviddeaths dea 
join portfolioproject..covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rollingpeoplevaccinated/population)*100 as vaccinatedpercentage
from popvsvac

--temp table
drop table if exists #poppervac
create table #poppervac
( 
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)
insert into #poppervac
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from portfolioproject..coviddeaths dea 
join portfolioproject..covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
select *, (rollingpeoplevaccinated/population)*100 as vaccinatedpercentage
from #poppervac

-- creating view to store data for visualiastion
create view percentpopvac as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from portfolioproject..coviddeaths dea 
join portfolioproject..covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * 
from percentpopvac