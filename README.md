# Netflix Movies and TV Shows Data Analysis using SQL

![](https://github.com/Shounakkapoor/sql_netflix_project/blob/main/logo%20(1).png)

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
SELECT type, COUNT(type) AS no_of_movie_or_shows
FROM netflix_titles
GROUP BY type;
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
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
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
SELECT *
FROM netflix_titles
WHERE 
	release_year = 2020 
	AND 
	type = 'Movie';
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
SELECT 
	UNNEST(STRING_TO_ARRAY(country,',')) as new_country,
	COUNT(show_id) total_content
FROM netflix_titles
GROUP BY 1
ORDER BY total_content DESC
LIMIT 5;
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
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
```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql
SELECT 
    *
FROM 
    netflix_titles
WHERE 
    TO_DATE(date_added, 'Month DD, YYYY') >= DATE '2016-01-01'
    AND TO_DATE(date_added, 'Month DD, YYYY') <= DATE '2021-12-31';
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
SELECT *
FROM (
    SELECT 
        *,
        UNNEST(STRING_TO_ARRAY(director, ',')) AS director_name
    FROM netflix
) AS t
WHERE director_name = 'Rajiv Chilaka';
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
SELECT *
FROM netflix_titles
WHERE
	type = 'TV Show' 
	AND
	SPLIT_PART(duration, ' ', 1)::numeric > 5;
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
SELECT 
	TRIM(UNNEST(STRING_TO_ARRAY(listed_in,','))) as Genre,
	COUNT(show_id) total_content
FROM netflix_titles
GROUP BY 1
ORDER BY total_content DESC;
```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql
SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id)::numeric /
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;
```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
SELECT 
	title,
	listed_in as Genre
FROM netflix_titles
WHERE type = 'Movie' AND listed_in ILIKE '%documentaries%';

```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
SELECT * 
FROM netflix
WHERE director IS NULL;
```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
SELECT *
FROM netflix_titles
WHERE 
	casts ILIKE '%salman khan%'
	AND
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
SELECT
	actor,
	COUNT(*) AS movie_count
FROM
(
SELECT
	TRIM(UNNEST(STRING_TO_ARRAY(casts,','))) as actor
FROM netflix_titles
WHERE type = 'Movie'
	AND country ILIKE '%India') AS actor_list
GROUP BY actor
ORDER BY movie_count DESC
LIMIT 10;
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
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
```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.



## Author - Shounak Kapoor

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions, feedback, or would like to collaborate, feel free to get in touch!

