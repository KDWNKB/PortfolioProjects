use [Portfolio Project ]
Select*
From [Portfolio Project ]..CovidDeaths
Where continent is not null
order by 3,4 

--Select*
--From [Portfolio Project ]..CovidVaccinations
--order by 3,4

--Selecting the Data that I will be using

Select Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project ]..CovidDeaths
order by 1,2


--Looking at Total Cases vs Total Deaths 
--Shows the likelihod of dying if you contract COVID in the US. This can be done for every country around the world
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project ]..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2


-- Looking at the Total Cases vs Population
--Shows what percentage of population contracted COVID

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentofPopulationInfected
From [Portfolio Project ]..CovidDeaths
--Where location like '%states%'
order by 1,2

--Looking at countries with the Highest Infection Rate Compared to Population 

Select Location, population, MAX(total_cases)as HighestInfectionCount, Max((total_cases/population))*100 as PercentofPopulationInfected
From [Portfolio Project ]..CovidDeaths
--Where location like '%states%'
Group by location, population
order by PercentofPopulationInfected desc


--Showing the Countries with the Highest Death Count per Population 

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Project ]..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by location, population
order by TotalDeathCount desc


--Breaking things down by Continent 

--Showing continents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Portfolio Project ]..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc



--Global Numbers 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio Project ]..CovidDeaths
--Where location like '%states%'
where continent is not null
--Group by date
order by 1,2


--Looking at Total Population vs Vaccinations 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated)/population)*100
From [Portfolio Project ]..CovidDeaths dea
Join [Portfolio Project ]..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null
order by 2,3


--USING CTE 

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated)/population)*100
From [Portfolio Project ]..CovidDeaths dea
Join [Portfolio Project ]..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



--TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
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
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated)/population)*100
From [Portfolio Project ]..CovidDeaths dea
Join [Portfolio Project ]..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to Store data for later Visualizations 


Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated)/population)*100
From [Portfolio Project ]..CovidDeaths dea
Join [Portfolio Project ]..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null
--order by 2,3


Select * 
From PercentPopulationVaccinated
