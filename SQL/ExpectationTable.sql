SELECT
		b.stars as BusinessAverageStars,
		cast(ROUND(u.average_stars * 4, 0) / 4 as decimal(10, 2)) as UserAverageStars,
		AVG(r.stars + 0.0) as ExpectedStars,
		ISNULL(VAR(r.stars + 0.0), 0) as VarStars
	FROM Reviews r
		INNER JOIN Users u
			ON u.user_id = r.user_id
		INNER JOIN Business b
			ON b.business_id = r.business_id
	GROUP BY b.stars, cast(ROUND(u.average_stars * 4, 0) / 4 as decimal(10, 2))

--ORDER BY ONLY FOR DEMO PURPOSES
ORDER BY BusinessAverageStars, UserAverageStars

	