-- SELECT [location], [date], total_cases, new_cases, total_deaths, population 
-- from CovidDeaths 
-- order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Show the percentage of dying in Vietnam if people got affected by Covid-19
-- SELECT location, date, total_cases, total_deaths, CONVERT(decimal, total_deaths) / CONVERT(decimal, total_cases)*100 as PercentagePopulationInfected
-- from CovidDeaths
-- where [location] like '%Vietnam%'
-- order by 1, 2

--Looking at total cases vs population
-- SELECT location, date, total_cases, population , CONVERT(decimal, total_cases) / CONVERT(decimal, population)*100 as DeathPercentage
-- from CovidDeaths
-- where [location] like '%Vietnam%'
-- order by 1, 2

-- Looking at Countries with highest infection rate compared to population
SELECT Location, Population , MAX(total_cases) as HighestInfectionCount, MAX(CONVERT(decimal, total_cases) / CONVERT(decimal, Population))*100 as PercentagePopulationInfected
from CovidDeaths
-- where [location] like '%Vietnam%'
GROUP by Location, Population
order by PercentagePopulationInfected DESC

-- Showing Countries with Highest Death Count
SELECT Location, MAX(total_deaths) as TotalDeathCount
From CovidDeaths
where continent is not null
group by Location
order by TotalDeathCount DESC

select * 
from CovidDeaths 
where continent is not null

select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is NULL
group by location
order by TotalDeathCount DESC

-- Showing conitinents with the highest death count per population
select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not NULL
group by continent
order by TotalDeathCount DESC

-- Global Numbers
-- SELECT date, total_cases, total_deaths, CONVERT(decimal, total_deaths) / CONVERT(decimal, total_cases)*100 as DeathPercentage
SELECT date, SUM(new_cases) total_cases, SUM(new_deaths) total_deaths, CONVERT(decimal,SUM(new_deaths))/CONVERT(decimal,SUM(new_cases))*100 as DeathPercentage
from CovidDeaths
-- where Location like '%Vietnam%'
where continent is not null
group by date
order by 1, 2


-- looking at total population vs vaccinations
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(integer ,cv.new_vaccinations)) over (Partition by cd.Location order by cd.Location, cd.Date) as RollingPeopleVaccinated,
()
from CovidVaccinations cv
JOIN CovidDeaths cd
    on cv.location=cd.location
    AND cv.date=cd.date
where cd.continent is not null 
order by 2,3

--Use CTE
WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(integer ,cv.new_vaccinations)) over (Partition by cd.Location order by cd.Location, cd.Date) as RollingPeopleVaccinated
from CovidVaccinations cv
JOIN CovidDeaths cd
    on cv.location=cd.location
    AND cv.date=cd.date
where cd.continent is not null 
-- order by 2,3
)
select *, (CONVERT(decimal, RollingPeopleVaccinated)/Population)*100
from PopvsVac

-- Tempt Table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date datetime,
    Population numeric,
    New_vaccinations numeric,
    RollingPeopleVaccinated numeric
)


insert into #PercentPopulationVaccinated 
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(integer ,cv.new_vaccinations)) over (Partition by cd.Location order by cd.Location, cd.Date) as RollingPeopleVaccinated
from CovidVaccinations cv
JOIN CovidDeaths cd
    on cv.location=cd.location
    AND cv.date=cd.date
where cd.continent is not null 
-- order by 2,3

select *, (CONVERT(decimal, RollingPeopleVaccinated)/Population)*100
from #PercentPopulationVaccinated

-- Creating View to store date for later visulization
create VIEW PercentPopulationVaccinated as
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(integer ,cv.new_vaccinations)) over (Partition by cd.Location order by cd.Location, cd.Date) as RollingPeopleVaccinated
from CovidVaccinations cv
JOIN CovidDeaths cd
    on cv.location=cd.location
    AND cv.date=cd.date
where cd.continent is not null 

select *
FROM PercentPopulationVaccinated

