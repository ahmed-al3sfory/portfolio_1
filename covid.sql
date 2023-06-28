select*
from portfolio_1..covid_deaths


select*
from covid_deaths
order by 3,4



select*
from covid_vaccines
order by 3,4

--select data that we are going to be using

select location,date,total_cases,new_cases,total_deaths,population
from covid_deaths 
where continent is not null
order by 1,2

--looking at total cases vs total deaths
alter table covid_deaths
alter column total_cases int 

alter table covid_deaths
alter column total_deaths int 

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
from covid_deaths 
where location ='Egypt'
and continent is not null
order by 1,2

--looking at total cases vs population
select location,date,total_cases,population,(total_cases/population)*100 as cases_percentage 
from covid_deaths 
where location ='Egypt'
order by 1,2

--looking at countries with highest infection rate compared to population
select location,max(cast(total_cases as int))as max_cases,population,max((total_cases/population))*100 as infection_percentage
from portfolio_1..covid_deaths
where continent is not null
GROUP BY location,population
order by 2 desc

--showing countries with highrst death count compared to population
select location,max(cast(total_deaths as int))as max_deaths,population,max((total_deaths/population))*100 as death_percentage
from portfolio_1..covid_deaths
where continent is not null
GROUP BY location,population
order by 2 desc
 
-- let's break things down by continent

select location,max(cast(total_deaths as int))as max_deaths
from portfolio_1..covid_deaths
where continent is  null
GROUP BY location
order by 2 desc

--showing the continent with highest death rate to population
select location,max(cast(total_deaths as int))as max_deaths,max(cast(total_deaths as int)/population)*100 as death_rate_to_population
from portfolio_1..covid_deaths
where continent is  null
GROUP BY location
order by 3 desc

--Global_Numbers

--daily changes

select date,sum(new_deaths) as death ,sum(new_cases) as cases
from  portfolio_1..covid_deaths
where continent is not null
GROUP BY date
order by 1


 select sum(new_cases)as total_cases ,sum(new_deaths) as total_deaths ,(sum(new_deaths)/ sum(new_cases)) as death_percentage
from  portfolio_1..covid_deaths
where continent is not null

--looking at total population vs vaccinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as float))
over (partition by dea.location order by dea.date) as total_vaccination
from portfolio_1..covid_vaccines vac join portfolio_1..covid_deaths dea
on dea.location =vac.location 
and dea.date=vac.date
where dea.continent is not null
order by 1,2,3

--use cte (to use acreated column)

with helped_table (continent,location,date,population,new_vaccination,total_vaccination)
as (
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as float))
over (partition by dea.location order by dea.date) as total_vaccination
--(total_vaccination/dea.population)*100 as vaccinated_percentage
from portfolio_1..covid_vaccines vac join portfolio_1..covid_deaths dea
on dea.location =vac.location 
and dea.date=vac.date
where dea.continent is not null
--order by 1,2,3
)
select* ,(total_vaccination/population)*100 as vaccinated_percentage
from helped_table



--another solution
--temp table
drop table if exists vaccinated
create table vaccinated
(continent nvarchar(255)
,location nvarchar(255) 
,date datetime
,population  numeric
,new_vaccinations  numeric
,total_vaccination numeric)
insert into vaccinated 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float))
over (partition by dea.location order by dea.date) as total_vaccination
from portfolio_1..covid_vaccines vac join portfolio_1..covid_deaths dea
on dea.location =vac.location 
and dea.date=vac.date
where dea.continent is not null

select* ,(total_vaccination/population)*100 as vaccinated_percentage
from vaccinated

--creating view to store data for later visualizations

CREATE VIEW vaccinated_view as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float))
over (partition by dea.location order by dea.date) as total_vaccination
from portfolio_1..covid_vaccines vac join portfolio_1..covid_deaths dea
on dea.location =vac.location 
and dea.date=vac.date
where dea.continent is not null

