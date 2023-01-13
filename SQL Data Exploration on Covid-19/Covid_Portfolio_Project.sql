/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

-- select * 
-- from "CovidDeaths"
-- Where continent is not null 
-- order by 3,4


-- Select Data that we are going to be starting with

-- select location, date, total_cases, new_cases, total_deaths,population
-- from "CovidDeaths"
-- Where continent is not null 
-- order by 1,2

-- Compare Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in UK

-- #Note need to put the "100*" in front of equation and "::int" or "::float" for the calculation to work


-- select location, date, total_cases, total_deaths, population
-- , (100*total_deaths::float/total_cases::float) as DeathPercentage
-- from "CovidDeaths"
-- Where LOCATION like '%Kingdom%'
-- order by 1, 2


-- Looking at the total cases vs population in UK
-- Shows what precentage of population got Covid

-- select location, date, total_cases, population
-- , (100*total_cases::float/population::float) as Population_Percentage
-- from "CovidDeaths"
-- Where LOCATION like '%Kingdom%'
-- order by 1, 2
-- #Note: people can be infected again, so the total % should be lower


-- Looking at Countries with the highest infection rate compared with population

-- select location, population,max(total_cases) as highest_infection_count, max((100*total_cases::float/population::float)) as population_infection_percentage 
-- from "CovidDeaths"
-- where total_cases is not null and population is not null and continent is not null
-- group by location, population
-- order by population_infection_percentage DESC
 
 
-- Showing Countries with Highest Death Count per population
 
-- select location, max(cast(total_deaths as int)) as total_death_count
-- from "CovidDeaths"
-- where total_deaths is not null and continent is not null
-- group by location
-- order by total_death_count DESC 

-- Let's break things by continent

-- select continent, max(cast(total_deaths as int)) as total_death_count
-- from "CovidDeaths"
-- where total_deaths is not null and continent is not null
-- group by continent
-- order by total_death_count DESC 

-- Shows it by location

-- select location, max(cast(total_deaths as int)) as total_death_count
-- from "CovidDeaths"
-- where continent is null and location not in ('High income', 'Upper middle income', 'Lower middle income', 'Low income')
-- group by location
-- order by total_death_count DESC 


-- Gobal numbers

-- select date, sum(cast(new_cases as int)) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (100*sum(cast(new_deaths as float))/sum(cast(new_cases as int))) as DeathPercentage
-- from "CovidDeaths"
-- where continent is not null and new_cases is not NULL
-- group by date
-- order by 1, 2


-- Gobal total numbers

-- select sum(cast(new_cases as int)) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (100*sum(cast(new_deaths as float))/sum(cast(new_cases as int))) as DeathPercentage
-- from "CovidDeaths"
-- where continent is not null and new_cases is not NULL
-- order by 1, 2


-- Join table with CovidVaccinations data and 
-- Looking at total population vs Vaccination

-- select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
-- , sum(cast(new_vaccinations as int)) over (PARTITION by cd.location order by cd.location, cd.date) as rolling_vaccinated
-- from "CovidDeaths" as cd
-- join "CovidVaccinations" as cv
-- on cd.location = cv.location and cd.date = cv.date
-- where cd.continent is not null
-- order by 2, 3

-- Use CTE

-- With PopvsVac 
-- (cointinent, location, date, population, new_vaccinations, rolling_vaccinated) -- should be the same as below selected data
-- AS
-- (
-- select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
-- , sum(cast(new_vaccinations as int)) over (PARTITION by cd.location order by cd.location, cd.date) as rolling_vaccinated
-- from "CovidDeaths" as cd
-- join "CovidVaccinations" as cv
-- on cd.location = cv.location and cd.date = cv.date
-- where cd.continent is not null
-- order by 2, 3
-- )
-- select *, (rolling_vaccinated::float / population::bigint)*100 as vac_vs_pop
-- from PopvsVac


-- Temp table

-- drop table if exist PopulationVaccinatedPercent
-- Create TABLE PopulationVaccinatedPercent
-- (
-- Continent nvarchar(255),
-- Location nvarchar(255),
-- Date datetime,
-- Population BIGINT,
-- New_vaccinations numeric,
-- Rolling_vaccinated numeric
-- )
-- insert into PopulationVaccinatedPercent
-- as (
-- select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
-- , sum(cast(new_vaccinations as int)) over (PARTITION by cd.location order by cd.location, cd.date) as rolling_vaccinated
-- from "CovidDeaths" as cd
-- join "CovidVaccinations" as cv
-- on cd.location = cv.location and cd.date = cv.date
-- where cd.continent is not null
-- order by 2, 3
-- )

-- select *, (rolling_vaccinated::float / population::bigint)*100 as vac_vs_pop
-- from PopulationVaccinatedPercent


-- Creating view to store data for later visualizations

CREATE VIEW PopulationVaccinated AS 
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, sum(CAST(new_vaccinations AS INT)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_vaccinated
FROM "CovidDeaths" AS cd
JOIN "CovidVaccinations" AS cv
ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2, 3


