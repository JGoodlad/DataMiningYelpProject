SELECT 
	t.TestIndex as 'index',
	ISNULL(x.ReviewAverageStars, t.BusinessStars) as 'stars'
FROM
	(SELECT
		b.stars as BusinessAverageStars,
		cast(ROUND(u.average_stars * 4, 0) / 4 as decimal(10, 2)) as UserAverageStars,
		AVG(r.stars) as ReviewAverageStars,
		COUNT(*) AS TotalReviews,
		SUM(CASE WHEN r.stars = 1 THEN 1 ELSE 0 END) as OneStarReviews,
		SUM(CASE WHEN r.stars = 2 THEN 1 ELSE 0 END) as TwoStarReviews,
		SUM(CASE WHEN r.stars = 3 THEN 1 ELSE 0 END) as ThreeStarReviews,
		SUM(CASE WHEN r.stars = 4 THEN 1 ELSE 0 END) as FourStarReviews,
		SUM(CASE WHEN r.stars = 5 THEN 1 ELSE 0 END) as FiveStarReviews
	FROM Reviews r
		INNER JOIN Users u
			ON u.user_id = r.user_id
		INNER JOIN Business b
			ON b.business_id = r.business_id

	GROUP BY b.stars, cast(ROUND(u.average_stars * 4, 0) / 4 as decimal(10, 2))

	) AS x

	RIGHT JOIN (SELECT
				t.TestIndex,
				t.user_id,
				t.business_id,
				b.stars as BusinessStars,
				u.average_stars as UserStars
				FROM TestQuery t, Users u, Business b
				WHERE t.business_id = b.business_id AND t.user_id = u.user_id) AS t
	ON t.BusinessStars = x.BusinessAverageStars 
		AND cast(ROUND(t.UserStars * 4, 0) / 4 as decimal(10, 2)) = cast(ROUND(x.UserAverageStars * 4, 0) / 4 as decimal(10, 2))
ORDER BY t.TestIndex