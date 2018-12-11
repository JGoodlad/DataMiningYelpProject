WITH ReviewCountQ (TotalReviewCount) AS (SELECT COUNT(*) as ReviewCount FROM Reviews)
SELECT
		b.stars as BusinessAverageStars,
		cast(ROUND(u.average_stars * 4, 0) / 4 as decimal(10, 2)) as UserAverageStars,
		AVG(r.stars + 0.0) as ExpectedStars,
		ISNULL(VAR(r.stars + 0.0), 0) as VarStars,
		1.0 * COUNT(*) / MIN(ReviewCountQ.TotalReviewCount)  AS TotalReviews,
		AVG(CASE WHEN r.stars = 1 THEN 1.0 ELSE 0.0 END) as OneStarReviews,
		AVG(CASE WHEN r.stars = 2 THEN 1.0 ELSE 0.0 END) as TwoStarReviews,
		AVG(CASE WHEN r.stars = 3 THEN 1.0 ELSE 0.0 END) as ThreeStarReviews,
		AVG(CASE WHEN r.stars = 4 THEN 1.0 ELSE 0.0 END) as FourStarReviews,
		AVG(CASE WHEN r.stars = 5 THEN 1.0 ELSE 0.0 END) as FiveStarReviews
	FROM Reviews r
		INNER JOIN Users u
			ON u.user_id = r.user_id
		INNER JOIN Business b
			ON b.business_id = r.business_id
		CROSS JOIN ReviewCountQ
	GROUP BY b.stars, cast(ROUND(u.average_stars * 4, 0) / 4 as decimal(10, 2))

--ORDER BY ONLY FOR DEMO PURPOSES
ORDER BY BusinessAverageStars, UserAverageStars

	