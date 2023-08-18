SELECT * FROM CovidDeaths;
SELECT * FROM CovidVac;


SELECT 
    Location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM
    CovidDeaths
ORDER BY 1 , 2;


SELECT
    Location,
    Date,
    total_cases,
    population,
    (total_cases / population) * 100 AS DeathPercentage
FROM
    CovidDeaths
WHERE
    Location LIKE '%states%'
ORDER BY
    Location,
    Date;



SELECT Location, Population, date,  MAX(cast(total_cases as signed)) AS HighestInfectionCount, MAX((total_cases / population)) * 100 AS PercentagePopInfection 
FROM CovidDeaths
GROUP BY Location, population, Date
ORDER BY PercentagePopInfection DESC;

SELECT Location, Population,  MAX(cast(total_cases as signed)) AS HighestInfectionCount, MAX((total_cases / population)) * 100 AS PercentagePopInfection 
FROM CovidDeaths
GROUP BY Location, population
ORDER BY PercentagePopInfection DESC;

SELECT Location, MAX(CAST(total_deaths AS SIGNED)) AS TotalDeathCount
FROM CovidDeaths
GROUP BY contident  
ORDER BY TotalDeathCount DESC;



Select location, SUM(CAST(new_deaths as signed)) as TotalDeathCount 
From CovidDeaths
Group by location
order by TotalDeathCount desc;

SELECT 
    continent,
    MAX(CAST(total_deaths AS SIGNED)) AS TotalDeathCount
FROM
    CovidDeaths
GROUP BY continent
ORDER BY TotalDeathCount DESC;



SELECT 
    date,
    SUM(total_cases) AS total_cases,
    SUM(CAST(new_deaths AS SIGNED)) AS total_deaths,
    SUM(CAST(new_deaths AS SIGNED)) / SUM(new_cases) * 100 AS DeathPercentage
FROM
    CovidDeaths
WHERE
    continent IS NOT NULL
GROUP BY date
ORDER BY 1 , 2;

SELECT 
    SUM(total_cases) AS total_cases,
    SUM(CAST(new_deaths AS SIGNED)) AS total_deaths,
    SUM(CAST(new_deaths AS SIGNED)) / SUM(new_cases) * 100 AS DeathPercentage
FROM
    CovidDeaths
WHERE
    continent IS NOT NULL
ORDER BY 1 , 2;

###Total pop vs vac 
SELECT dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as signed)) OVER (PARTITION by dea.location Order by dea.location, dea.date) as RollingPeopleVac
FROM CovidDeaths dea join CovidVac vac
ON dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
order by 2,3;




SELECT
    Location,
    Population,
    MAX(CAST(total_cases AS SIGNED)) AS HighestInfectionCount,
    MAX((total_cases / Population)) * 100 AS PercentagePopInfection
FROM
    CovidDeaths 
GROUP BY
    Location,
    population
ORDER BY
    PercentagePopInfection DESC;


###CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVac)
as
(
SELECT dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as signed)) OVER (PARTITION by dea.location Order by dea.location, dea.date) as RollingPeopleVac
FROM CovidDeaths dea join CovidVac vac
ON dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
)

SELECT *, (RollingPeopleVac/population)*100
FROM PopvsVac


-- Drop the existing temporary table if it exists
DROP TABLE IF EXISTS PercentPopVaccinated;

-- Create the temporary table
CREATE TEMPORARY TABLE PercentPopVaccinated
(
    Continent nvarchar(255),
    Location nvarchar(255),
    Date datetime,
    Population numeric,
    new_vaccinations numeric, 
    RollingPeopleVac numeric
)

INSERT INTO PercentPopVaccinated
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations, 
    (
        SELECT SUM(CAST(vac_sub.new_vaccinations AS SIGNED))
        FROM CovidVac vac_sub
        WHERE dea.location = vac_sub.location AND dea.date >= vac_sub.date
    ) AS RollingPeopleVac
FROM CovidDeaths dea
JOIN CovidVac vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT *, (RollingPeopleVac/population)*100
FROM PercentPopVaccinated;

CREATE VIEW PercentPopVaccinated_New AS 
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations, 
    SUM(CAST(vac.new_vaccinations AS signed)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVac
FROM CovidDeaths dea
JOIN CovidVac vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;


SELECT * FROM PercentPopVaccinated_New 





Create View DeathView as 
SELECT Location, MAX(cast(total_deaths as SIGNED)) as TotalDeathCount
FROM CovidDeaths

Select * from DeathView 


Create View TotalDeath as
SELECT SUM(total_cases) AS total_cases, SUM(cast(new_deaths as signed)) as total_deaths, SUM(cast(new_deaths as signed))/SUM(new_cases)*100 as DeathPercentage
From CovidDeaths

Select * from TotalDeath




















