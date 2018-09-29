/* Using ordered analytical functions and filters */
WITH tmp_sales
AS
(
  SELECT storeid,
                SUM(CASE WHEN sales_date BETWEEN '2018-01-01' and '2018-01-31' 
				                  THEN sales_amt 
								  ELSE 0 end) jan_2018_sales_amt,
				SUM(CASE WHEN sales_date BETWEEN '2018-02-01' and '2018-02-28' 
				                  THEN sales_amt 
								  ELSE 0 end) Feb_2018_sales_amt,
				Feb_2018_sales_amt - Jan_2018_sales_amt diff_in_sales
	 FROM sales 
	WHERE sales_date between '2018-01-01' and '2018-02-28'
	GROUP BY storeid
	)
	SELECT tmp_sales.*
	   FROM tmp_sales
	qualify rank() over(partition by 1 order by diff_in_sales desc) <=10  OR rank() over(partition by 1 order by diff_in_sales asc) <=10;
	
/* Without ordered analytical functions but subqueries*/
WITH tmp_sales
AS
(
  SELECT storeid,
                SUM(CASE WHEN sales_date BETWEEN '2018-01-01' and '2018-01-31' 
				                  THEN sales_amt 
								  ELSE 0 end) jan_2018_sales_amt,
				SUM(CASE WHEN sales_date BETWEEN '2018-02-01' and '2018-02-28' 
				                  THEN sales_amt 
								  ELSE 0 end) Feb_2018_sales_amt,
				Feb_2018_sales_amt - Jan_2018_sales_amt diff_in_sales
	 FROM sales 
	WHERE sales_date between '2018-01-01' and '2018-02-28'
	GROUP BY storeid
	)
SELECT a.*
    FROM tmp_sales a
	 WHERE diff_in_sales IN (SELECT min(diff_in_sales) FROM tmp_sales
	                                       UNION 
										   SELECT max(diff_in_sales) FROM tmp_sales
										   )
;

/* Using co-rrelated subqueries */
WITH tmp_sales
AS
(
  SELECT storeid,
                SUM(CASE WHEN sales_date BETWEEN '2018-01-01' and '2018-01-31' 
				                  THEN sales_amt 
								  ELSE 0 end) jan_2018_sales_amt,
				SUM(CASE WHEN sales_date BETWEEN '2018-02-01' and '2018-02-28' 
				                  THEN sales_amt 
								  ELSE 0 end) Feb_2018_sales_amt,
				Feb_2018_sales_amt - Jan_2018_sales_amt diff_in_sales
	 FROM sales 
	WHERE sales_date between '2018-01-01' and '2018-02-28'
	GROUP BY storeid
	)
SELECT a.*
    FROM tmp_sales a
	 WHERE  10> (SELECT count(*) 
	                         FROM tmp_sales  b
							WHERE a.diff_in_sales <b.diff_in_sales
							)
	OR 10>(SELECT count(*) 
	                         FROM tmp_sales  c
							WHERE a.diff_in_sales > c.diff_in_sales
							)
