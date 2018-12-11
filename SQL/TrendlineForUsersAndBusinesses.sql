SELECT
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
GROUP BY d.user_id


SELECT
	d.business_id,
	CASE WHEN  (MIN(d.n) * SUM(X*X) - SUM(X) * SUM(X)) = 0 THEN 0 ELSE
	(MIN(d.n) * SUM(X*Y) - SUM(X) * SUM(Y)) / (MIN(d.n) * SUM(X*X) - SUM(X) * SUM(X)) END AS BusinessSlopeM,
	CASE WHEN (MIN(d.n) * SUM(X*X) - SUM(X) * SUM(X)) = 0 THEN AVG(Y) ELSE
	AVG(Y) - AVG(X) * (MIN(d.n) * SUM(X*Y) - SUM(X) * SUM(Y)) / (MIN(d.n) * SUM(X*X) - SUM(X) * SUM(X)) END AS BusinessINterceptB
FROM (
	SELECT
	r.business_id,
	- 1  * ROW_NUMBER() OVER (PARTITION BY r.business_id ORDER BY r.date DESC) as X,
	COUNT(r.user_id) OVER (PARTITION BY r.business_id) as N,
	r.stars as Y
	FROM Reviews r) as d
GROUP BY d.business_id