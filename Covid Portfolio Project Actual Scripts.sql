Select*from dbo.CovidDeaths where continent is not null order by 3,4;

Select*from dbo.CovidVaccinations where continent is not null order by 3,4;


Select location, date, total_cases, new_cases, total_Deaths, population from dbo.CovidDeaths  where continent is not null order by 1,2;

-- Looking at Total Cases Vs Total Deaths
-- Shows likelihood of dying if you contact to covid in your country

Select location, date, total_cases, total_Deaths, (total_deaths/total_cases)*100 as Death_Percentage from dbo.CovidDeaths
where location= 'india' order by 1,2;

--Looking at Total Cases Vs Population
-- Shows what percentage of population got covid
Select location, date, population, total_cases,(total_cases/population)*100 as Pecent_Population_Infected from dbo.CovidDeaths
where location= 'india' order by 1,2;


--Looking at Countries with Highest Infection Rate compared to Population

Select location,SUM(population) As Population, MAX(total_cases) as Highest_Infection_Count, Max((total_cases/population)*100)
as Pecent_Population_Infected from dbo.CovidDeaths  where continent is not null
group by location,Population order by Pecent_Population_Infected desc;


--Showing Countries with Highest Death Count Per Population

Select location,Max(cast(Total_deaths as int)) as Total_Death_Count from dbo.CovidDeaths  where continent is not null
group by location order by Total_Death_Count desc;


--Showing Continent with Highest Death Count Per Population

Select continent,Max(cast(Total_deaths as int)) as Total_Death_Count from dbo.CovidDeaths  where continent is not null
group by continent order by Total_Death_Count desc;

--Global Numbers

Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_Deaths, sum(cast(new_deaths as int)) /sum(new_cases) *100 as Death_Percentage_Globally from dbo.CovidDeaths 
where continent is not null group by date order by 1,2;

--Overall Numbers;

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_Deaths, sum(cast(new_deaths as int)) /sum(new_cases) *100 as Death_Percentage_Globally from dbo.CovidDeaths 
where continent is not null order by 1,2;

--Looking at Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as percent_people_vaccinated
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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


select *from PercentPopulationVaccinated;