--Viewing the data 
select * 
from covid19deaths
where continent != ' '


select * 
from covidvaccines

--viewing data needed for this analysis from the data based on location and date
select location, date, total_cases, new_cases, total_deaths, population
from covid19deaths
where continent != ' '
order by 1,2;

alter table covid19deaths
alter column total_cases float;

alter table covid19deaths
alter column total_deaths float;

alter table covid19deaths
alter column population float;

alter table covid19deaths
alter column new_cases float;

alter table covid19deaths
alter column new_deaths float;

alter table covidvaccines
alter column new_vaccinations float;


--looking at the number total number of cases in United kingdom over the total number of deaths
--shows the percentage likelihood of death if an individual contracts covid
select location, date, total_cases, new_cases, total_deaths, (total_deaths/nullif (total_cases, 0))*100 as DeathPercentage
from covid19deaths
where location like '%kingdom'
order by 1,2;

--looking at the number total number of cases in United kingdom over the population
--shows the percentage of populatiion that contracted covid
select location, date, total_cases, population, (total_cases/nullif (population, 0))*100 as PopulationPercentage
from covid19deaths
where location like '%kingdom'
order by 1,2;

-- looking at the position of United Kingdom among all countries in the world with the highest infection rate compared by population
select location, population, max(total_cases) as MaximumInfectionCount, max((total_cases/nullif (population, 0)))*100 as PopulationPercentage
from covid19deaths
--where location like '%kingdom' 
where continent != ' '
group by  location, population
order by PopulationPercentage desc;

-- looking at the position of United Kingdom among all countries in the world with the highest death rate compared by population
select location, max(total_deaths) as Maximumtotal_deathsCount
from covid19deaths
--where location like '%kingdom' 
where continent != ' '
group by  location
order by Maximumtotal_deathsCount desc;

-- looking at the position of United Kingdom among all countries in the world with the highest new cases compared by population
select location, max(new_cases) as Maximumtotal_newcases
from covid19deaths
--where location like '%kingdom' 
where continent != ' '
group by  location
order by Maximumtotal_newcases desc;

--Total deaths count by continent
select continent, max(total_deaths) as Maximumtotal_deathsCount
from covid19deaths
--where location like '%kingdom' 
where continent != ' '
group by  continent
order by Maximumtotal_deathsCount desc;

--Global death percentage
Select  sum(new_cases) as total_cases, sum(new_deaths) total_deaths, (sum(new_deaths)/sum(nullif (new_cases, 0)))*100 as globaldeathpercentage
from Covid19Deaths
where continent != ' '
--group by date
order by 1,2;

--Global death percentage by date
Select date, sum(new_cases) as total_cases, sum(new_deaths) total_deaths, (sum(new_deaths)/sum(nullif (new_cases, 0)))*100 
as globaldeathpercentage
from Covid19Deaths
where continent != ' '
group by date
order by 1,2;

--Analysing the total population vs the total vaccinations
--Joinning the Covid19Deaths and CovidVaccines tables  
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from Covid19Deaths as Dea join
covidvaccines as Vac on Dea.date = Vac.date and Dea.location = Vac.location 
where dea.continent != ' '
order by 2,3;



--doing a rolling count adding up the new vaccinations on every given date and partitioning by location to refresh count after every location
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinationCount
from Covid19Deaths as Dea join
covidvaccines as Vac on Dea.date = Vac.date and Dea.location = Vac.location 
where dea.continent != ' '
order by 2,3;

--doing population vs Vaccination count to see how many people are vaccinated in a particular country 

--USING CTEs
with PopVsVac (continent, location, date, population, new_vaccinations, RollingVaccinationCount)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date)
from Covid19Deaths as Dea join
covidvaccines as Vac on Dea.date = Vac.date and Dea.location = Vac.location 
where dea.continent != ' '
)
select *, (RollingVaccinationCount/nullif (population,0))*100 as PercentageOfPopulationVaccinated
from PopVsVac

--CREATING VIEWS TO STORE DATA FOR VISUALIZATION

--VIEW1
CREATE VIEW UK_DEATH_PERCENTAGE_OF_INFECTED_PERSONS
AS
select location, date, total_cases, new_cases, total_deaths, (total_deaths/nullif (total_cases, 0))*100 as DeathPercentage
from covid19deaths
where location like '%kingdom'

SELECT * 
FROM UK_DEATH_PERCENTAGE_OF_INFECTED_PERSONS



--VIEW2
CREATE VIEW UK_PERCENTAGE_OF_INFECTED_POPULATION
AS
select location, date, total_cases, population, (total_cases/nullif (population, 0))*100 as PopulationPercentage
from covid19deaths
where location like '%kingdom'

SELECT * 
FROM UK_PERCENTAGE_OF_INFECTED_POPULATION



--VIEW3
-- looking at the position of United Kingdom among all countries in the world with the highest infection rate compared by population
CREATE VIEW INFECTION_RATE_BY_COUNTRY
AS
select location, population, max(total_cases) as MaximumInfectionCount, max((total_cases/nullif (population, 0)))*100 as PopulationPercentage
from covid19deaths
--where location like '%kingdom' 
where continent != ' '
group by  location, population

SELECT *
FROM INFECTION_RATE_BY_COUNTRY



--VIEW4
-- looking at the position of United Kingdom among all countries in the world with the highest death rate compared by population
CREATE VIEW DEATH_RATE_BY_COUNTRY
AS
select location, max(total_deaths) as Maximumtotal_deathsCount
from covid19deaths
--where location like '%kingdom' 
where continent != ' '
group by  location

SELECT *
FROM DEATH_RATE_BY_COUNTRY



--VIEW5
--Total deaths count by continent
CREATE VIEW DEATH_RATE_BY_CONTINENT
AS
select continent, max(total_deaths) as Maximumtotal_deathsCount
from covid19deaths
--where location like '%kingdom' 
where continent != ' '
group by  continent

SELECT *
FROM DEATH_RATE_BY_CONTINENT


--VIEW6
--Global death percentage
CREATE VIEW GLOBAL_DEATH_PERCENTAGE
AS
Select location, sum(new_cases) as total_cases, sum(new_deaths) total_deaths, (sum(new_deaths)/sum(nullif (new_cases, 0)))*100 as globaldeathpercentage
from Covid19Deaths
where continent != ' '
group by location

SELECT *
FROM GLOBAL_DEATH_PERCENTAGE


--VIEW7
--doing a rolling count adding up the new vaccinations on every given date and partitioning by location to refresh count after every location
CREATE VIEW ROLLING_COUNT_OF_NEW_VACCINATIONS
AS 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinationCount
from Covid19Deaths as Dea join
covidvaccines as Vac on Dea.date = Vac.date and Dea.location = Vac.location 
where dea.continent != ' '

SELECT *
FROM ROLLING_COUNT_OF_NEW_VACCINATIONS