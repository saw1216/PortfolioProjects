
Select * 
From PortfolioProject..coviddeaths_Jul2021
where continent is not null
order by 3, 4

--Select * 
--From PortfolioProject..covidvaccination_Jul2021
--order by 3, 4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..coviddeaths_Jul2021
order by 1, 2

--total cases vs total deaths
--% of dying if infected with covid
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..coviddeaths_Jul2021
where location like '%malaysia%'
order by 1, 2

--total cases vs population
--% of population infected covid
Select location, date, population, total_cases,  (total_cases/population)*100 as PercentPopulatinInfected
From PortfolioProject..coviddeaths_Jul2021
--where location like '%malaysia%'
order by 1, 2

--country with highest infection rate 

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulatinInfected
From PortfolioProject..coviddeaths_Jul2021
--where location like '%Malaysia%'
Group by location, population
order by PercentPopulatinInfected desc

-- countries with the highest deaths count per population

Select location, MAX(CAST(total_deaths as int)) as TotalDeathCount
From PortfolioProject..coviddeaths_Jul2021
where continent is not null
--where location like '%Malaysia%'
Group by location
order by TotalDeathCount desc

-- by continent 

Select location, MAX(CAST(total_deaths as int)) as TotalDeathCount
From PortfolioProject..coviddeaths_Jul2021
where continent is null
--where location like '%Malaysia%'
Group by location
order by TotalDeathCount desc 


Select continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
From PortfolioProject..coviddeaths_Jul2021
where continent is not null
--where location like '%Malaysia%'
Group by continent
order by TotalDeathCount desc 

-- showing the continent with the highest death count

Select continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
From PortfolioProject..coviddeaths_Jul2021
where continent is not null
--where location like '%Malaysia%'
Group by continent
order by TotalDeathCount desc 

-- global numbers 

Select SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/Sum(new_cases))*100 as DeathPercentage
From PortfolioProject..coviddeaths_Jul2021
--where location like '%malaysia%'
where continent is not null
--Group by date
order by 1, 2


--total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as  RollingPeopleVaccinated
From PortfolioProject..coviddeaths_Jul2021 dea
Join PortfolioProject..covidvaccination_Jul2021 vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as  RollingPeopleVaccinated
From PortfolioProject..coviddeaths_Jul2021 dea
Join PortfolioProject..covidvaccination_Jul2021 vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/population)*100 
From PopvsVac 

-- TEMP table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255), 
location nvarchar(255), 
Date datetime,
Population numeric, 
new_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as  RollingPeopleVaccinated
From PortfolioProject..coviddeaths_Jul2021 dea
Join PortfolioProject..covidvaccination_Jul2021 vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100 
From #PercentPopulationVaccinated 

--create view to store data for visulaization 

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as  RollingPeopleVaccinated
From PortfolioProject..coviddeaths_Jul2021 dea
Join PortfolioProject..covidvaccination_Jul2021 vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

--
Select * 
From PercentPopulationVaccinated
