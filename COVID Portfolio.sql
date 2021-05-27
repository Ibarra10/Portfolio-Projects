Select * 
From PortfolioProject..CovidDeaths
Order By 3,4

--Select * 
--From PortfolioProject..CovidVaccinations
--Order By 3,4

Select Location, Date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order By 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths	
Where location like '%states%'
and continent is not null
Order By 1,2


--Looking at the Total Cases vs Population
--Shows what percentage of population got covid

Select Location, Date, population, total_cases, (total_cases/population) * 100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths	
Where continent is not null
--Where location like '%states%'
Order By 1,2

--Looking at Countries with Highest Infection Rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths	
Where continent is not null
--Where location like '%states%'
Group By Location, population
Order By PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths	
--Where location like '%states%'
Where continent is not null
Group By Location
Order By TotalDeathCount desc


--BREAKING IT DOWN BY CONTINENT


--Showing the Continents with Highest Death count per Population

Select continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths	
--Where location like '%states%'
Where continent is not null
Group By continent
Order By TotalDeathCount desc


Select location, MAX(CAST(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths	
--Where location like '%states%'
Where continent is null
Group By location
Order By TotalDeathCount desc

--GLOBAL NUMBERS

Select Date, SUM(new_cases) as Total_cases, SUM(CAST(new_deaths as INT)) as TotalDeaths, 
SUM(CAST(new_deaths as INT))/SUM(new_cases) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths	
--Where location like '%states%'
Where continent is not null
Group By Date
Order By 1,2


--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) * 100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null
Order By 2,3


--USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
As
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) * 100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
--Where dea.continent is not null
--Order By 2,3
)
Select *, (RollingPeopleVaccinated/population) * 100
From PopvsVac



--USE TEMP TABLE

DROP Table If Exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) * 100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
--Where dea.continent is not null
--Order By 2,3

Select *, (RollingPeopleVaccinated/population) * 100
From #PercentPopulationVaccinated



--Creating View to store data for later visualizations


Create View PercentPopulationVaccinated As
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population) * 100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null
--Order By 2,3


Select * 
From PercentPopulationVaccinated


Create View DeathCountByContinent As
Select continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths	
--Where location like '%states%'
Where continent is not null
Group By continent
--Order By TotalDeathCount desc


Select *
From DeathCountByContinent