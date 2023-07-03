
-- GLOBAL NUMBERS

Select
SUM(cast(new_cases as bigint)) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as float))/SUM(cast(new_cases as float)) * 100 as DeathPercentage
From [covid-deaths]
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

--looking at total cases vs total deaths
SELECT location,
	   continent,
       date,
       total_cases,
       new_cases,
       total_deaths,
       ( Cast(total_deaths AS FLOAT) / NULLIF(Cast(total_cases AS FLOAT), 0) ) *
       100 AS
       deathpercentage
FROM   [dbo].[covid-deaths]
--WHERE  continent = 'Europe'
ORDER  BY 1,
          2 

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, vac.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [covid-deaths] dea
Join [covid-vaccination] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent <> ''
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [covid-deaths] dea
Join [covid-vaccination] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent <> ''
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 AS PercentageofVaccinatedPeople
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

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
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [covid-deaths] dea
Join [covid-vaccination] vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent <> ''
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [covid-deaths] dea
Join [covid-vaccination] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


-- Percentage of population into covid
SELECT location,
       date,
       total_cases,
       new_cases,
       total_deaths,
       ( Cast(total_cases AS FLOAT) / NULLIF(Cast(population AS FLOAT), 0) ) *
       100 AS
       peoplepercentageinfected
FROM   [dbo].[covid-deaths]
--WHERE  location = 'India'
ORDER  BY 1,2


-- formatted version
SELECT location,
       date,
       total_cases,
       new_cases,
       total_deaths,
       ( Cast(total_deaths AS FLOAT) / NULLIF(Cast(total_cases AS FLOAT), 0) ) *
       100 AS
       deathpercentage,
       ( Cast(total_cases AS FLOAT) / NULLIF(Cast(population AS FLOAT), 0) ) *
       100   AS
       peoplepercentage
FROM   [dbo].[covid-deaths]
--WHERE  location = 'India'
ORDER  BY 1,2

--Infection Rate in the world       
SELECT location,
       population,
       Max(total_cases) AS [Highest Infection Count],
       --MAX(( Cast(total_deaths AS FLOAT) / NULLIF(Cast(total_cases AS FLOAT), 0) )) * 100 AS [Percentage of Population Died],
       Max(( Cast(total_cases AS FLOAT) / NULLIF(Cast(population AS FLOAT), 0) )
       ) * 100
                        AS [Percentage of Population Infected]
FROM   [dbo].[covid-deaths]
--WHERE  location = 'United States'
GROUP  BY location,
          population
ORDER  BY [percentage of population infected] DESC 


-- Highest Death Count (the data for nations of UK is solely mentioned in location = 'United Kingdom')
SELECT location, 
	   continent,
       population,
	   --MAX(Date),
       Max(Cast(total_deaths AS INT)) AS [Highest Death Count]
FROM   [dbo].[covid-deaths]
WHERE  continent <> ''
       AND continent IS NOT NULL
GROUP  BY location,
          population,
		  continent
ORDER  BY [highest death count] DESC 

-- Continent wise
SELECT location,
       Max(Cast(total_deaths AS INT)) AS [Highest Death Count]
FROM   [dbo].[covid-deaths]
WHERE  continent = ''
GROUP  BY location
ORDER  BY [highest death count] DESC 


select date,SUM(CAST(new_cases as int)) as [Total Cases], SUM(CAST(new_deaths as Int)) as [Total Deaths]--,SUM(CAST(new_deaths as Int))/SUM(new_cases) * 100 as [Death Percentage]
from [covid-deaths]
where continent<>''
group by date
order by 1,2




--Note:
--1) Nations included in United Kingdom i.e. England, Scotland, Wales and Northern Ireland have their values as 0 and the whole data is 
--included in location = 'United Kingdom'
-- 2) European Union is part of Europe
--3) You can use these queries for making up views for data visualisation.
