
--TRAIN
SELECT
	t.UserAvgRating,
	x.*,
	t.stars as y
FROM (SELECT
		b.stars as BusinessAverageStars,
		cast(ROUND(u.average_stars * 4, 0) / 4 as decimal(10, 2)) as NearestUserAverageStars,
		AVG(r.stars + 0.0) as ReviewCategoryAverageStars
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
		b.business_id,
		u.user_id,
		b.stars AS BusinessAvgRating,
		u.average_stars AS UserAvgRating,
		r.stars
	 FROM Business b, Users u, 
			validate_queries r
			WHERE r.user_id = u.user_id AND b.business_id = r.business_id ) AS  t
	ON t.BusinessAvgRating = x.BusinessAverageStars 
		AND cast(ROUND(t.BusinessAvgRating * 4, 0) / 4 as decimal(10, 2)) = cast(ROUND(x.NearestUserAverageStars * 4, 0) / 4 as decimal(10, 2))

--Predict
SELECT
	t.TestIndex,
	t.UserAvgRating,
	x.*,
	t.stars as y

FROM (SELECT
		b.stars as BusinessAverageStars,
		cast(ROUND(u.average_stars * 4, 0) / 4 as decimal(10, 2)) as NearestUserAverageStars,
		AVG(r.stars + 0.0) as ReviewCategoryAverageStars
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
		b.stars AS BusinessAvgRating,
		u.average_stars AS UserAvgRating,
		NULL as stars
	 FROM Business b, Users u, 
			TestQuery r
			WHERE r.user_id = u.user_id AND b.business_id = r.business_id ) AS  t
	ON t.BusinessAvgRating = x.BusinessAverageStars 
		AND cast(ROUND(t.BusinessAvgRating * 4, 0) / 4 as decimal(10, 2)) = cast(ROUND(x.NearestUserAverageStars * 4, 0) / 4 as decimal(10, 2))
ORDER BY t.TestIndex
