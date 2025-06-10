SELECT *
FROM netflix_titles;

-- Business Problems and Solutions

-- 1. Count the Number of Movies vs TV Shows

SELECT type, COUNT(type) AS no_of_movie_or_shows
FROM netflix_titles
GROUP BY type;

-- 2 2. Find the Most Common Rating for Movies and TV Shows

SELECT
		type,
		rating
FROM
(SELECT 
	type,
	rating,
	COUNT(*),
	RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as ranking
FROM netflix_titles
GROUP BY 1,2 ) as t1
WHERE
	ranking = 1;


-- 3. List All Movies Released in a Specific Year (e.g., 2020)

SELECT *
FROM netflix_titles
WHERE 
	release_year = 2020 
	AND 
	type = 'Movie';

-- 4. Find the Top 5 Countries with the Most Content on Netflix

SELECT 
	UNNEST(STRING_TO_ARRAY(country,',')) as new_country,
	COUNT(show_id) total_content
FROM netflix_titles
GROUP BY 1
ORDER BY total_content DESC
LIMIT 5;

-- 5. Identify the Longest Movie

SELECT 
	title,
	CAST(REPLACE(duration, 'min','') AS INTEGER) AS duration_min
FROM netflix_titles
WHERE 
	type = 'Movie'
	AND
	duration IS NOT NULL
ORDER BY duration_min DESC
LIMIT 1;


-- 6. Find Content Added in the Last 5 Years

SELECT 
    *
FROM 
    netflix_titles
WHERE 
    TO_DATE(date_added, 'Month DD, YYYY') >= DATE '2016-01-01'
    AND TO_DATE(date_added, 'Month DD, YYYY') <= DATE '2021-12-31';

-- 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

SELECT *
FROM netflix_titles
WHERE director ILIKE '%Rajiv Chilaka%';

-- 8. List All TV Shows with More Than 5 Seasons

SELECT *
FROM netflix_titles
WHERE
	type = 'TV Show' 
	AND
	SPLIT_PART(duration, ' ', 1)::numeric > 5

-- 9. Count the Number of Content Items in Each Genre

SELECT 
	TRIM(UNNEST(STRING_TO_ARRAY(listed_in,','))) as Genre,
	COUNT(show_id) total_content
FROM netflix_titles
GROUP BY 1
ORDER BY total_content DESC;


-- 10.Find each year and the average numbers of content release in India on netflix.



SELECT
	EXTRACT(YEAR FROM TO_DATE(date_added, 'MONTH DD, YYYY')) as year,
	COUNT(*) no_of_content,
	ROUND(COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix_titles WHERE country = 'India')::numeric* 100, 2) AS avg_content_per_year
FROM netflix_titles
WHERE country ILIKE 'India'
GROUP BY 1
ORDER BY 1;

-- 11. List All Movies that are Documentaries

SELECT 
	title,
	listed_in as Genre
FROM netflix_titles
WHERE type = 'Movie' AND listed_in ILIKE '%documentaries%';


-- 12. Find All Content Without a Director
SELECT *
FROM netflix_titles
WHERE director IS NULL;

-- 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years 

SELECT *
FROM netflix_titles
WHERE 
	casts ILIKE '%salman khan%'
	AND
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;


-- 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

SELECT
	actor,
	COUNT(*) AS movie_count
FROM(
SELECT
	TRIM(UNNEST(STRING_TO_ARRAY(casts,','))) as actor
FROM netflix_titles
WHERE type = 'Movie'
	AND country ILIKE '%India') AS actor_list
GROUP BY actor
ORDER BY movie_count DESC
LIMIT 10;

-- 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
WITH new_table
AS
(
SELECT 
*,
	CASE
	WHEN 
		description ILIKE '%kill%' OR 
		description ILIKE '%violence%' 
		THEN 'Bad_content'
		ELSE 'Good_content'
	END category
FROM netflix_titles
)
SELECT 
	category,
	COUNT(*) AS total_content
FROM new_table
GROUP BY 1;	