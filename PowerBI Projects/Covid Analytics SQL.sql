/* 
Covid 19 Data Exploration

Skills Used: Joins, CTE's, Window Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


Select * 
From ['CovidDeaths$']
Where continent is not null
order by 3,4



-- Select initial data

Select location, date, total_cases, new_cases, total_deaths, population
From ['CovidDeaths$']
Where continent is not null
Order By 1,2



--Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract the disease in the US

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From ['CovidDeaths$']
Where location = 'United States'
and continent is not null
Order By 1,2



-- Same as above but shows data for all countries

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From ['CovidDeaths$']
Where continent is not null



-- Total Cases vs Population
-- Shows what percentage of the population was infected by date by country

Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From ['CovidDeaths$']
Where continent is not null




-- Countries with Highest Infection Rate Compared to Population

Select location, population, max(total_cases) as HighestInfectionCount,  max((total_cases/population))*100 as PercentPopulationInfected
From ['CovidDeaths$']
Where continent is not null
Group By location, population



-- Death Count by Country

Select location, max(cast(total_deaths as int)) as TotaltDeathCount
From ['CovidDeaths$']
Where continent is not null
Group By location



-- Death Count by Continent

Select continent, max(cast(total_deaths as int)) as TotaltDeathCount
From PortfolioProject..['CovidDeaths$']
Where continent is not null
Group By continent





--Total deaths to date

Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..['CovidDeaths$']
-- Where location = 'United States'
Where continent is not null
--Group By date



-- Total deaths to date over time

Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..['CovidDeaths$']
-- Where location = 'United States'
Where continent is not null
Group By date




-- Total Popopulation vs Vaccinations
-- Percentage of Population that has recieved at least one Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(numeric, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingVaccinationCount
From ['CovidDeaths$'] dea
Join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order By 2,3




-- Use CTE to perform Calculation on Partition in Previous Query

With popvsvac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinationCount)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingVaccinationCount
From ['CovidDeaths$'] dea
Join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingVaccinationCount/Population)*100 as PercentPopulationVaccinated
From popvsvac
Order By 2,3



-- Create view to store data for later visualizations

Create View PercentPopulationVaccinated as
With popvsvac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinationCount)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingVaccinationCount
From ['CovidDeaths$'] dea
Join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingVaccinationCount/Population)*100 as PercentPopulationVaccinated
From popvsvac