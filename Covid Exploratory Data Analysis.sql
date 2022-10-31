select Location, date, total_cases, new_cases, total_deaths, population
from sqlpractice..CovidDeaths
order by 1,2

--looking at Total Case and InfectedPercentage per date in indonesia

select Location, date, Population, total_cases, (total_cases/Population)*100 as InfectedPercentage
from sqlpractice..CovidDeaths
where location like '%indonesia%'
order by 1,2

-- looking at country with highest infected percentage to population
select Location, Population, max(total_cases), max(total_cases/Population)*100 as InfectedPercentage
from sqlpractice..CovidDeaths
group by Location, Population
order by InfectedPercentage desc -- in descending order

-- LOOKING at death counts per continent

select continent, max(cast(total_deaths as int)) as DeathCounts --it seems like the data type of total_deaths column is not integer
from sqlpractice..CovidDeaths
where continent is not null
group by continent
order by DeathCounts desc -- in descending order

-- GLOBAL NUMBERS
select date, max(new_cases) as TC, max(cast(new_deaths as int)) as TD --it seems like the data type of total_deaths column is not integer
from sqlpractice..CovidDeaths
where continent is not null
group by date
order by 1,2

-- UTILIZING CTE (creating new temporary table by extracting previous table information)

With Vaccinated (continent, location, date, population, new_vaccinations, cummulative_vaccinated) 
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as cummulative_vaccinated
from sqlpractice..CovidDeaths dea
join sqlpractice..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
	and vac.new_vaccinations is not null
)
--querying the new table
select *, (cummulative_vaccinated/population)*100 as vac_to_pop_rate
from Vaccinated

-- CREATING TABLE FROM SCTRACTH AND INSERT DATA TO IT
drop table if exists #percent_population_vaccinated --this is preventing error when we do several iterations in creating tables, so the former table would be deleted first before replaced by new table
create table #percent_population_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
cummulative_vaccinated numeric
)

insert into #percent_population_vaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as cummulative_vaccinated
from sqlpractice..CovidDeaths dea
join sqlpractice..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
	and vac.new_vaccinations is not null
-- querying new table
select *
from #percent_population_vaccinated


--CREATING VIEW 
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as cummulative_vaccinated
from sqlpractice..CovidDeaths dea
join sqlpractice..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
	and vac.new_vaccinations is not null

select *
from PercentPopulationVaccinated
