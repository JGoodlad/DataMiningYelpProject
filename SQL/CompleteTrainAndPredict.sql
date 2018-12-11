--TRAIN
SELECT
	DISTINCT
	(t.BusinessReviewCount + 0.0) / bc.BusinessCount AS BusinessReviewCount,
	(t.UserReviewCount + 0.0) / uc.UserCount AS UserReviewCount,


	u.average_stars AS RealUserAverageStars,
	ISNULL(x.BusinessAverageStars, 0) AS BusinessAverageStars,


	ISNULL(x.NearestUserAverageStars, 0) AS NearestUserAverageStars,
	ISNULL(x.ReviewCategoryAverageStars, 0) AS ReviewCategoryAverageStars,
	ISNULL(x.ReviewCategoryVariance, 0) AS ReviewCategoryVariance ,
	ISNULL(x.OneStar, 0) AS OneStar,
	ISNULL(x.TwoStar, 0) AS TwoStar,
	ISNULL(x.ThreeStar, 0) AS ThreeStar,
	ISNULL(x.FourStar, 0) AS FourStar,
	ISNULL(x.FiveStar, 0) AS FiveStar,

	ISNULL(ur.UserSlopeM, 0) AS UserSlopeM,
	ISNULL(ur.UserInterceptB, 0) AS UserInterceptB,

	ISNULL(br.BusinessSlopeM, 0) AS BusinessSlopeM,
	ISNULL(br.BusinessInterceptB, 0) AS BusinessInterceptB,


	ISNULL(urc.UserEqualratedPercent, 0) AS UserEqualratedPercent,
	ISNULL(urc.UserOverunderratedReviewPercent, 0) AS UserOverunderratedReviewPercent,
	ISNULL(urc.UserOverratedPercent, 0) AS UserOverratedPercent,
	ISNULL(urc.UserUnderratedPercent, 0) AS UserUnderratedPercent,

	ISNULL(brc.BusinessEqualratedPercent, 0) AS BusinessEqualratedPercent,
	ISNULL(brc.BusinessOverunderratedReviewPercent, 0) AS BusinessOverunderratedReviewPercent,
	ISNULL(brc.BusinessOverratedPercent, 0) AS BusinessOverratedPercent,
	ISNULL(brc.BusinessUnderratedPercent, 0) AS BusinessUnderratedPercent,


	--Y values... who would have thought after all that

	t.ReviewStars as y

	FROM (SELECT
			b.stars as BusinessAverageStars,
			cast(ROUND(u.average_stars * 4, 0) / 4 as decimal(10, 2)) as NearestUserAverageStars,
			AVG(r.stars) as ReviewCategoryAverageStars,
			VAR(r.stars) as ReviewCategoryVariance,
			(COUNT(*) + 0.0) AS ReviewCategoryCount,
			(SUM(CASE WHEN r.stars = 1 THEN 1 ELSE 0 END) + 0.0) / COUNT(*) as OneStar,
			(SUM(CASE WHEN r.stars = 2 THEN 1 ELSE 0 END) + 0.0) / COUNT(*) as TwoStar,
			(SUM(CASE WHEN r.stars = 3 THEN 1 ELSE 0 END) + 0.0) / COUNT(*) as ThreeStar,
			(SUM(CASE WHEN r.stars = 4 THEN 1 ELSE 0 END) + 0.0) / COUNT(*) as FourStar,
			(SUM(CASE WHEN r.stars = 5 THEN 1 ELSE 0 END) + 0.0) / COUNT(*) as FiveStar
		FROM Reviews r
			INNER JOIN Users u
				ON u.user_id = r.user_id
			INNER JOIN Business b
				ON b.business_id = r.business_id
		GROUP BY b.stars, cast(ROUND(u.average_stars * 4, 0) / 4 as decimal(10, 2))) AS x
	RIGHT JOIN (SELECT
				t.stars as ReviewStars ,
				t.user_id,
				t.business_id,
				b.review_count as BusinessReviewCount,
				u.review_count as UserReviewCount,
				b.stars as BusinessStars,
				u.average_stars as UserStars
				FROM  Users u, Business b, 
					validate_queries t
				WHERE t.business_id = b.business_id AND t.user_id = u.user_id) AS t
		ON t.BusinessStars = x.BusinessAverageStars 
			AND cast(ROUND(t.UserStars * 4, 0) / 4 as decimal(10, 2)) = cast(ROUND(x.NearestUserAverageStars * 4, 0) / 4 as decimal(10, 2))
	CROSS JOIN (SELECT COUNT(*) as ReviewCount FROM Reviews r) as rc
	CROSS JOIN (SELECT COUNT(*) AS BusinessCount FROM Business) AS bc
	CROSS JOIN (SELECT COUNT(*) AS UserCount FROM Users) AS uc
	INNER JOIN Business b
		ON b.business_id = t.business_id
	INNER JOIN Users u
		ON u.user_id = t.user_id
	LEFT JOIN (SELECT
					d.business_id,
					CASE WHEN  (MIN(d.n) * SUM(X*X) - SUM(X) * SUM(X)) = 0 THEN 0 ELSE
					(MIN(d.n) * SUM(X*Y) - SUM(X) * SUM(Y)) / (MIN(d.n) * SUM(X*X) - SUM(X) * SUM(X)) END AS BusinessSlopeM,
					CASE WHEN (MIN(d.n) * SUM(X*X) - SUM(X) * SUM(X)) = 0 THEN AVG(Y) ELSE
					AVG(Y) - AVG(X) * (MIN(d.n) * SUM(X*Y) - SUM(X) * SUM(Y)) / (MIN(d.n) * SUM(X*X) - SUM(X) * SUM(X)) END AS BusinessInterceptB
				FROM (
					SELECT
					r.business_id,
					- 1  * ROW_NUMBER() OVER (PARTITION BY r.business_id ORDER BY r.date DESC) as X,
					COUNT(r.user_id) OVER (PARTITION BY r.business_id) as N,
					r.stars as Y
					FROM Reviews r) as d
				GROUP BY d.business_id) AS br
		ON t.business_id = br.business_id
	LEFT JOIN (SELECT
					d.user_id,
					CASE WHEN  (MIN(d.n) * SUM(X*X) - SUM(X) * SUM(X)) = 0 THEN 0 ELSE
					(MIN(d.n) * SUM(X*Y) - SUM(X) * SUM(Y)) / (MIN(d.n) * SUM(X*X) - SUM(X) * SUM(X)) END AS UserSlopeM,
					CASE WHEN (MIN(d.n) * SUM(X*X) - SUM(X) * SUM(X)) = 0 THEN AVG(Y) ELSE
					AVG(Y) - AVG(X) * (MIN(d.n) * SUM(X*Y) - SUM(X) * SUM(Y)) / (MIN(d.n) * SUM(X*X) - SUM(X) * SUM(X)) END AS UserInterceptB
				FROM (
					SELECT
					r.user_id,
					- 1  * ROW_NUMBER() OVER (PARTITION BY r.user_id ORDER BY r.date DESC) as X,
					COUNT(r.user_id) OVER (PARTITION BY r.user_id) as N,
					r.stars as Y
					FROM Reviews r) as d
				GROUP BY d.user_id) AS ur
		ON t.user_id = ur.user_id
	LEFT JOIN (SELECT
					rc.user_id,
					1.0 * rc.NonMatchingReviewCount / rc.TotalReviewCount AS UserOverunderratedReviewPercent,
					1.0 * rc.EqualratedCount / rc.TotalReviewCount AS UserEqualratedPercent,
					1.0 * rc.UnderratedCount / rc.TotalReviewCount AS UserUnderratedPercent,
					1.0 * rc.OverratedCount / rc.TotalReviewCount AS UserOverratedPercent
					FROM
					(SELECT
						r.user_id,
						COUNT(*) AS TotalReviewCount,	
						SUM(CASE WHEN r.stars <> b.stars THEN 1 ELSE 0 END) AS NonMatchingReviewCount,
						SUM(CASE WHEN r.stars = b.stars THEN 1 ELSE 0 END) AS EqualratedCount,
						SUM(CASE WHEN r.stars < b.stars THEN 1 ELSE 0 END) AS UnderratedCount,
						SUM(CASE WHEN r.stars > b.stars THEN 1 ELSE 0 END) AS OverratedCount
					FROM Reviews r
					INNER JOIN Business b
						ON r.business_id = b.business_id
					GROUP BY r.user_id) as rc) AS urc
		ON urc.user_id = t.user_id
	LEFT JOIN (SELECT
					rc.business_id,
					1.0 * rc.NonMatchingReviewCount / rc.TotalReviewCount AS BusinessOverunderratedReviewPercent,
					1.0 * rc.EqualratedCount / rc.TotalReviewCount AS BusinessEqualratedPercent,
					1.0 * rc.UnderratedCount / rc.TotalReviewCount AS BusinessUnderratedPercent,
					1.0 * rc.OverratedCount / rc.TotalReviewCount AS BusinessOverratedPercent
					FROM
					(SELECT
						r.business_id,
						COUNT(*) AS TotalReviewCount,	
						SUM(CASE WHEN r.stars <> u.average_stars THEN 1 ELSE 0 END) AS NonMatchingReviewCount,
						SUM(CASE WHEN r.stars = u.average_stars THEN 1 ELSE 0 END) AS EqualratedCount,
						SUM(CASE WHEN r.stars < u.average_stars THEN 1 ELSE 0 END) AS UnderratedCount,
						SUM(CASE WHEN r.stars > u.average_stars THEN 1 ELSE 0 END) AS OverratedCount
					FROM Reviews r
					INNER JOIN Users u
						ON r.user_id = u.user_id
					GROUP BY r.business_id) as rc) AS brc
		ON brc.business_id = t.business_id


	WHERE t.business_id IS NOT NULL AND t.user_id IS NOT NULL


--PREDICT
SELECT
	t.TestIndex,
	(t.BusinessReviewCount + 0.0) / bc.BusinessCount AS BusinessReviewCount,
	(t.UserReviewCount + 0.0) / uc.UserCount AS UserReviewCount,


	u.average_stars AS RealUserAverageStars,
	ISNULL(x.BusinessAverageStars, 0) AS BusinessAverageStars,


	ISNULL(x.NearestUserAverageStars, 0) AS NearestUserAverageStars,
	ISNULL(x.ReviewCategoryAverageStars, 0) AS ReviewCategoryAverageStars,
	ISNULL(x.ReviewCategoryVariance, 0) AS ReviewCategoryVariance ,
	ISNULL(x.OneStar, 0) AS OneStar,
	ISNULL(x.TwoStar, 0) AS TwoStar,
	ISNULL(x.ThreeStar, 0) AS ThreeStar,
	ISNULL(x.FourStar, 0) AS FourStar,
	ISNULL(x.FiveStar, 0) AS FiveStar,

	ISNULL(ur.UserSlopeM, 0) AS UserSlopeM,
	ISNULL(ur.UserInterceptB, 0) AS UserInterceptB,

	ISNULL(br.BusinessSlopeM, 0) AS BusinessSlopeM,
	ISNULL(br.BusinessInterceptB, 0) AS BusinessInterceptB,


	ISNULL(urc.UserEqualratedPercent, 0) AS UserEqualratedPercent,
	ISNULL(urc.UserOverunderratedReviewPercent, 0) AS UserOverunderratedReviewPercent,
	ISNULL(urc.UserOverratedPercent, 0) AS UserOverratedPercent,
	ISNULL(urc.UserUnderratedPercent, 0) AS UserUnderratedPercent,

	ISNULL(brc.BusinessEqualratedPercent, 0) AS BusinessEqualratedPercent,
	ISNULL(brc.BusinessOverunderratedReviewPercent, 0) AS BusinessOverunderratedReviewPercent,
	ISNULL(brc.BusinessOverratedPercent, 0) AS BusinessOverratedPercent,
	ISNULL(brc.BusinessUnderratedPercent, 0) AS BusinessUnderratedPercent,


	--Y values... who would have thought after all that

	t.ReviewStars as y

	FROM (SELECT
			b.stars as BusinessAverageStars,
			cast(ROUND(u.average_stars * 4, 0) / 4 as decimal(10, 2)) as NearestUserAverageStars,
			AVG(r.stars) as ReviewCategoryAverageStars,
			VAR(r.stars) as ReviewCategoryVariance,
			(COUNT(*) + 0.0) AS ReviewCategoryCount,
			(SUM(CASE WHEN r.stars = 1 THEN 1 ELSE 0 END) + 0.0) / COUNT(*) as OneStar,
			(SUM(CASE WHEN r.stars = 2 THEN 1 ELSE 0 END) + 0.0) / COUNT(*) as TwoStar,
			(SUM(CASE WHEN r.stars = 3 THEN 1 ELSE 0 END) + 0.0) / COUNT(*) as ThreeStar,
			(SUM(CASE WHEN r.stars = 4 THEN 1 ELSE 0 END) + 0.0) / COUNT(*) as FourStar,
			(SUM(CASE WHEN r.stars = 5 THEN 1 ELSE 0 END) + 0.0) / COUNT(*) as FiveStar
		FROM Reviews r
			INNER JOIN Users u
				ON u.user_id = r.user_id
			INNER JOIN Business b
				ON b.business_id = r.business_id
		GROUP BY b.stars, cast(ROUND(u.average_stars * 4, 0) / 4 as decimal(10, 2))) AS x
	RIGHT JOIN (SELECT
				NULL AS ReviewStars, t.TestIndex ,
				t.user_id,
				t.business_id,
				b.review_count as BusinessReviewCount,
				u.review_count as UserReviewCount,
				b.stars as BusinessStars,
				u.average_stars as UserStars
				FROM  Users u, Business b, 
					--validate_queries t
					--Reviews t
					TestQuery t
				WHERE t.business_id = b.business_id AND t.user_id = u.user_id) AS t
		ON t.BusinessStars = x.BusinessAverageStars 
			AND cast(ROUND(t.UserStars * 4, 0) / 4 as decimal(10, 2)) = cast(ROUND(x.NearestUserAverageStars * 4, 0) / 4 as decimal(10, 2))
	CROSS JOIN (SELECT COUNT(*) as ReviewCount FROM Reviews r) as rc
	CROSS JOIN (SELECT COUNT(*) AS BusinessCount FROM Business) AS bc
	CROSS JOIN (SELECT COUNT(*) AS UserCount FROM Users) AS uc
	INNER JOIN Business b
		ON b.business_id = t.business_id
	INNER JOIN Users u
		ON u.user_id = t.user_id
	LEFT JOIN (SELECT
					d.business_id,
					CASE WHEN  (MIN(d.n) * SUM(X*X) - SUM(X) * SUM(X)) = 0 THEN 0 ELSE
					(MIN(d.n) * SUM(X*Y) - SUM(X) * SUM(Y)) / (MIN(d.n) * SUM(X*X) - SUM(X) * SUM(X)) END AS BusinessSlopeM,
					CASE WHEN (MIN(d.n) * SUM(X*X) - SUM(X) * SUM(X)) = 0 THEN AVG(Y) ELSE
					AVG(Y) - AVG(X) * (MIN(d.n) * SUM(X*Y) - SUM(X) * SUM(Y)) / (MIN(d.n) * SUM(X*X) - SUM(X) * SUM(X)) END AS BusinessInterceptB
				FROM (
					SELECT
					r.business_id,
					- 1  * ROW_NUMBER() OVER (PARTITION BY r.business_id ORDER BY r.date DESC) as X,
					COUNT(r.user_id) OVER (PARTITION BY r.business_id) as N,
					r.stars as Y
					FROM Reviews r) as d
				GROUP BY d.business_id) AS br
		ON t.business_id = br.business_id
	LEFT JOIN (SELECT
					d.user_id,
					CASE WHEN  (MIN(d.n) * SUM(X*X) - SUM(X) * SUM(X)) = 0 THEN 0 ELSE
					(MIN(d.n) * SUM(X*Y) - SUM(X) * SUM(Y)) / (MIN(d.n) * SUM(X*X) - SUM(X) * SUM(X)) END AS UserSlopeM,
					CASE WHEN (MIN(d.n) * SUM(X*X) - SUM(X) * SUM(X)) = 0 THEN AVG(Y) ELSE
					AVG(Y) - AVG(X) * (MIN(d.n) * SUM(X*Y) - SUM(X) * SUM(Y)) / (MIN(d.n) * SUM(X*X) - SUM(X) * SUM(X)) END AS UserInterceptB
				FROM (
					SELECT
					r.user_id,
					- 1  * ROW_NUMBER() OVER (PARTITION BY r.user_id ORDER BY r.date DESC) as X,
					COUNT(r.user_id) OVER (PARTITION BY r.user_id) as N,
					r.stars as Y
					FROM Reviews r) as d
				GROUP BY d.user_id) AS ur
		ON t.user_id = ur.user_id
	LEFT JOIN (SELECT
					rc.user_id,
					1.0 * rc.NonMatchingReviewCount / rc.TotalReviewCount AS UserOverunderratedReviewPercent,
					1.0 * rc.EqualratedCount / rc.TotalReviewCount AS UserEqualratedPercent,
					1.0 * rc.UnderratedCount / rc.TotalReviewCount AS UserUnderratedPercent,
					1.0 * rc.OverratedCount / rc.TotalReviewCount AS UserOverratedPercent
					FROM
					(SELECT
						r.user_id,
						COUNT(*) AS TotalReviewCount,	
						SUM(CASE WHEN r.stars <> b.stars THEN 1 ELSE 0 END) AS NonMatchingReviewCount,
						SUM(CASE WHEN r.stars = b.stars THEN 1 ELSE 0 END) AS EqualratedCount,
						SUM(CASE WHEN r.stars < b.stars THEN 1 ELSE 0 END) AS UnderratedCount,
						SUM(CASE WHEN r.stars > b.stars THEN 1 ELSE 0 END) AS OverratedCount
					FROM Reviews r
					INNER JOIN Business b
						ON r.business_id = b.business_id
					GROUP BY r.user_id) as rc) AS urc
		ON urc.user_id = t.user_id
	LEFT JOIN (SELECT
					rc.business_id,
					1.0 * rc.NonMatchingReviewCount / rc.TotalReviewCount AS BusinessOverunderratedReviewPercent,
					1.0 * rc.EqualratedCount / rc.TotalReviewCount AS BusinessEqualratedPercent,
					1.0 * rc.UnderratedCount / rc.TotalReviewCount AS BusinessUnderratedPercent,
					1.0 * rc.OverratedCount / rc.TotalReviewCount AS BusinessOverratedPercent
					FROM
					(SELECT
						r.business_id,
						COUNT(*) AS TotalReviewCount,	
						SUM(CASE WHEN r.stars <> u.average_stars THEN 1 ELSE 0 END) AS NonMatchingReviewCount,
						SUM(CASE WHEN r.stars = u.average_stars THEN 1 ELSE 0 END) AS EqualratedCount,
						SUM(CASE WHEN r.stars < u.average_stars THEN 1 ELSE 0 END) AS UnderratedCount,
						SUM(CASE WHEN r.stars > u.average_stars THEN 1 ELSE 0 END) AS OverratedCount
					FROM Reviews r
					INNER JOIN Users u
						ON r.user_id = u.user_id
					GROUP BY r.business_id) as rc) AS brc
		ON brc.business_id = t.business_id


	WHERE t.business_id IS NOT NULL AND t.user_id IS NOT NULL

	ORDER BY t.TestIndex