--TRAIN
SELECT
	--t.TestIndex,
	--t.user_id,
	t.UserAvgRating,
	x.*,
	y.UserAvgStar,
	y.UserReviewCount,
	t.stars as y

FROM (SELECT
		b.stars as BusinessAverageStars,
		cast(ROUND(u.average_stars * 4, 0) / 4 as decimal(10, 2)) as NearestUserAverageStars,
		AVG(r.stars + 0.0) as ReviewCategoryAverageStars,
		VAR(r.stars) as ReviewCategoryVariance,
		(COUNT(*) + 0.0) / 5996996.0  AS ReviewCategoryCount,
		(SUM(CASE WHEN r.stars = 1 THEN 1 ELSE 0 END) + 0.0) / COUNT(*) as OneStar,
		(SUM(CASE WHEN r.stars = 2 THEN 1 ELSE 0 END) + 0.0) / COUNT(*) as TwoStar,
		(SUM(CASE WHEN r.stars = 3 THEN 1 ELSE 0 END) + 0.0) / COUNT(*) as ThreeStar,
		(SUM(CASE WHEN r.stars = 4 THEN 1 ELSE 0 END) + 0.0) / COUNT(*) as FourStar,
		(SUM(CASE WHEN r.stars = 5 THEN 1 ELSE 0 END) + 0.0) / COUNT(*) as FiveStar
	FROM my_review r
		INNER JOIN my_user u
			ON u.user_id = r.user_id
		INNER JOIN my_business b
			ON b.business_id = r.business_id
		CROSS JOIN (SELECT COUNT(*) as TtlReviewCount FROM my_review) as x
	where r.stars >= 1
	GROUP BY b.stars, cast(ROUND(u.average_stars * 4, 0) / 4 as decimal(10, 2))) as x

INNER JOIN
	(SELECT 
		--r.TestIndex,
		b.business_id,
		u.user_id,
		len(u.friends) - len(replace(u.friends,',','')) as UserFriends,
		b.stars AS BusinessAvgRating,
		u.average_stars AS UserAvgRating,
		r.stars
		--NULL as stars
	 FROM Business b, Users u, 
			--TestQuery r
			validate_queries r
			WHERE r.user_id = u.user_id AND b.business_id = r.business_id ) AS  t
	ON t.BusinessAvgRating = x.BusinessAverageStars AND cast(ROUND(t.BusinessAvgRating * 4, 0) / 4 as decimal(10, 2)) = cast(ROUND(x.NearestUserAverageStars * 4, 0) / 4 as decimal(10, 2))

INNER JOIN
	(SELECT 
		mr.user_id,
		(COUNT(*) + 0.0) / 5996996.0 AS UserReviewCount ,
		AVG(mr.stars + 0.0) as UserAvgStar,
		(SUM(CASE WHEN mr.stars = 1 THEN 1 ELSE 0 END) + 0.0) / COUNT(*) as UserOneStar,
		(SUM(CASE WHEN mr.stars = 2 THEN 1 ELSE 0 END) + 0.0) / COUNT(*) as UserTwoStar,
		(SUM(CASE WHEN mr.stars = 3 THEN 1 ELSE 0 END) + 0.0) / COUNT(*) as UserThreeStar,
		(SUM(CASE WHEN mr.stars = 4 THEN 1 ELSE 0 END) + 0.0) / COUNT(*) as UserFourStar,
		(SUM(CASE WHEN mr.stars = 5 THEN 1 ELSE 0 END) + 0.0) / COUNT(*) as UserFiveStar
		FROM my_review mr
		INNER JOIN my_user mu
			ON mr.user_id = mu.user_id
		GROUP BY mr.user_id) as y
	ON y.user_id = t.user_id
INNER JOIN (SELECT
			mu.user_id,
			SUM(CASE WHEN mr.stars > mb.stars THEN 1 ELSE 0 END) * 1.0 / COUNT(*) AS UserOptimism 
		FROM my_user mu,
			my_business mb,
			my_review mr
		WHERE mr.business_id = mb.business_id AND mu.user_id = mr.user_id
		GROUP BY mu.user_id) as o
	ON o.user_id = t.user_id


--PREDICT
SELECT
	t.TestIndex,
	--t.user_id,
	t.UserAvgRating,
	x.*,
	y.UserAvgStar,
	y.UserReviewCount,
	t.stars as y

FROM (SELECT
		b.stars as BusinessAverageStars,
		cast(ROUND(u.average_stars * 4, 0) / 4 as decimal(10, 2)) as NearestUserAverageStars,
		AVG(r.stars + 0.0) as ReviewCategoryAverageStars,
		VAR(r.stars) as ReviewCategoryVariance,
		(COUNT(*) + 0.0) / 5996996.0  AS ReviewCategoryCount,
		(SUM(CASE WHEN r.stars = 1 THEN 1 ELSE 0 END) + 0.0) / COUNT(*) as OneStar,
		(SUM(CASE WHEN r.stars = 2 THEN 1 ELSE 0 END) + 0.0) / COUNT(*) as TwoStar,
		(SUM(CASE WHEN r.stars = 3 THEN 1 ELSE 0 END) + 0.0) / COUNT(*) as ThreeStar,
		(SUM(CASE WHEN r.stars = 4 THEN 1 ELSE 0 END) + 0.0) / COUNT(*) as FourStar,
		(SUM(CASE WHEN r.stars = 5 THEN 1 ELSE 0 END) + 0.0) / COUNT(*) as FiveStar
	FROM my_review r
		INNER JOIN my_user u
			ON u.user_id = r.user_id
		INNER JOIN my_business b
			ON b.business_id = r.business_id
		CROSS JOIN (SELECT COUNT(*) as TtlReviewCount FROM my_review) as x
	where r.stars >= 1
	GROUP BY b.stars, cast(ROUND(u.average_stars * 4, 0) / 4 as decimal(10, 2))) as x

INNER JOIN
	(SELECT 
		r.TestIndex,
		b.business_id,
		u.user_id,
		len(u.friends) - len(replace(u.friends,',','')) as UserFriends,
		b.stars AS BusinessAvgRating,
		u.average_stars AS UserAvgRating,
		--r.stars
		NULL as stars
	 FROM Business b, Users u, 
			TestQuery r
			--Reviews r
			WHERE r.user_id = u.user_id AND b.business_id = r.business_id ) AS  t
	ON t.BusinessAvgRating = x.BusinessAverageStars AND cast(ROUND(t.BusinessAvgRating * 4, 0) / 4 as decimal(10, 2)) = cast(ROUND(x.NearestUserAverageStars * 4, 0) / 4 as decimal(10, 2))

INNER JOIN
	(SELECT 
		mr.user_id,
		(COUNT(*) + 0.0) / 5996996.0 AS UserReviewCount ,
		AVG(mr.stars + 0.0) as UserAvgStar,
		(SUM(CASE WHEN mr.stars = 1 THEN 1 ELSE 0 END) + 0.0) / COUNT(*) as UserOneStar,
		(SUM(CASE WHEN mr.stars = 2 THEN 1 ELSE 0 END) + 0.0) / COUNT(*) as UserTwoStar,
		(SUM(CASE WHEN mr.stars = 3 THEN 1 ELSE 0 END) + 0.0) / COUNT(*) as UserThreeStar,
		(SUM(CASE WHEN mr.stars = 4 THEN 1 ELSE 0 END) + 0.0) / COUNT(*) as UserFourStar,
		(SUM(CASE WHEN mr.stars = 5 THEN 1 ELSE 0 END) + 0.0) / COUNT(*) as UserFiveStar
		FROM my_review mr
		INNER JOIN my_user mu
			ON mr.user_id = mu.user_id
		GROUP BY mr.user_id) as y
	ON y.user_id = t.user_id
INNER JOIN (SELECT
			mu.user_id,
			SUM(CASE WHEN mr.stars > mb.stars THEN 1 ELSE 0 END) * 1.0 / COUNT(*) AS UserOptimism 
		FROM my_user mu,
			my_business mb,
			my_review mr
		WHERE mr.business_id = mb.business_id AND mu.user_id = mr.user_id
		GROUP BY mu.user_id) as o
	ON o.user_id = t.user_id

ORDER BY t.TestIndex
