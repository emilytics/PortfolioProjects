--1. Comparing total number of cases, deaths, and vaccination rates across different countries
	-- Exclude continents from locations
	-- Visualization: Map
		
SELECT 
	dea.location, 
	MAX(CAST(dea.total_cases AS INT)) AS TotalCases, 
	MAX(CAST(dea.total_deaths AS INT)) AS TotalDeaths, 
	ROUND((MAX(CAST(dea.total_deaths AS FLOAT)) / NULLIF(MAX(CAST(dea.total_cases AS FLOAT)), 0)) * 100, 2) AS DeathPercentage,
	MAX(vac.people_vaccinated/dea.population)*100 AS PercentPopulationVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac 
	ON dea.location=vac.location AND dea.date=vac.date
WHERE dea.location NOT IN ('World', 'High income', 'European Union', 'Low income', 'Upper middle income', 'Lower middle income', 'Asia', 'Europe', 'North America', 'South America', 'Oceania', 'Africa', 'United Kingdom')
GROUP BY dea.location
ORDER BY TotalCases DESC, TotalDeaths DESC


--2. The daily new cases and deaths globally while including a moving average to observe trends better.
	--Visualization: Line graph

SELECT 
	date, 
	CASE WHEN total_cases IS NULL THEN 0 ELSE total_cases END AS TotalCases, 
	CASE WHEN total_deaths IS NULL THEN 0 ELSE total_deaths END AS TotalDeaths,
	total_cases/population*100 AS PercentPopulationInfected,
	CASE WHEN total_cases = 0 THEN 0 ELSE TRY_CAST(total_deaths AS DECIMAL(18, 2)) * 100.0 / TRY_CAST(total_cases AS DECIMAL(18, 2)) END AS DeathPercentage
FROM CovidDeaths$
WHERE location='World' AND date <= '2023-08-02' AND total_deaths<total_cases
ORDER BY date


--3. Rollout of vaccinations by the total vaccinated, people fully vaccinated, and booster doses over time.
	--Visualization: Trend lines

SELECT 
	DISTINCT vac.date, 
	dea.population, 
	vac.total_vaccinations, 
	vac.people_vaccinated, 
	vac.people_fully_vaccinated, 
	vac.total_boosters,
	vac.people_vaccinated/dea.population*100 AS PercentPopulationVaccinated,
	vac.people_fully_vaccinated/dea.population*100 AS PercentPopulationFullyVaccinated
FROM CovidVaccinations$ vac
INNER JOIN CovidDeaths$ dea
	ON dea.location=vac.location AND dea.date=vac.date
WHERE vac.location='World'
ORDER BY date


--4. Median age, population density, GDP per capita correlation with COVID-19 impact
	--Scatter plot?

SELECT 
	vac.median_age, 
	vac.population_density, 
	vac.gdp_per_capita, 
	dea.total_cases/dea.population*100 AS PercentPopulationInfected,
	CASE WHEN dea.total_cases = 0 THEN 0 ELSE TRY_CAST(dea.total_deaths AS DECIMAL(18, 2)) * 100.0 / TRY_CAST(dea.total_cases AS DECIMAL(18, 2)) END AS DeathPercentage
FROM CovidVaccinations$ vac
INNER JOIN CovidDeaths$ dea
	ON dea.location=vac.location AND dea.date=vac.date
WHERE median_age IS NOT NULL AND population_density IS NOT NULL AND gdp_per_capita IS NOT NULL
GROUP BY vac.median_age, vac.population_density, vac.gdp_per_capita, dea.total_cases, dea.total_deaths, dea.population


--5. Stringency index alongside new cases to observe any correlations between US government measures and case numbers
	--Scatter plot? Animated time series?

SELECT vac.date, vac.stringency_index, dea.new_cases
FROM CovidVaccinations$ vac
JOIN CovidDeaths$ dea
	ON dea.location=vac.location AND dea.date=vac.date
WHERE vac.location='United States' AND vac.stringency_index IS NOT NULL
ORDER BY date


--6. Compare COVID-19 data health indicators: diabetes prevalence, cardiovascular death rate

SELECT 
	vac.diabetes_prevalence, 
	vac.cardiovasc_death_rate,
	dea.total_cases/dea.population*100 AS PercentPopulationInfected,
	CASE WHEN dea.total_cases = 0 THEN 0 ELSE TRY_CAST(dea.total_deaths AS DECIMAL(18, 2)) * 100.0 / TRY_CAST(dea.total_cases AS DECIMAL(18, 2)) END AS DeathPercentage
FROM CovidVaccinations$ vac
INNER JOIN CovidDeaths$ dea
	ON dea.location=vac.location AND dea.date=vac.date
WHERE vac.diabetes_prevalence IS NOT NULL AND vac.cardiovasc_death_rate IS NOT NULL AND total_cases IS NOT NULL AND total_deaths IS NOT NULL


--7. How countries with different levels of human development index (HDI) have been affected differently

SELECT 
	dea.location,
	vac.human_development_index, 
	MAX(dea.total_cases/dea.population)*100 AS PercentPopulationInfected,
	MAX(CASE WHEN dea.total_cases = 0 THEN 0 ELSE TRY_CAST(dea.total_deaths AS DECIMAL(18, 2)) * 100.0 / TRY_CAST(dea.total_cases AS DECIMAL(18, 2)) END) AS DeathPercentage
FROM CovidVaccinations$ vac
INNER JOIN CovidDeaths$ dea
	ON dea.location=vac.location AND dea.date=vac.date
WHERE 
	vac.human_development_index IS NOT NULL AND 
	dea.total_cases IS NOT NULL AND dea.total_deaths IS NOT NULL AND 
	dea.location NOT IN ('World', 'High income', 'European Union', 'Low income', 'Upper middle income', 'Lower middle income', 'Asia', 'Europe', 'North America', 'South America', 'Oceania', 'Africa', 'United Kingdom')
GROUP BY dea.location, vac.human_development_index
ORDER BY vac.human_development_index DESC