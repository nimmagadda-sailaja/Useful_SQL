/* Using ordered analytical functions */

SELECT storeid, 
       yr_mnth, 
	   total_sales
  FROM 
  (
     SELECT 
	       storeid, 
		   sales_date (FORMAT 'YYYY-MM') (CHAR(7)) yr_mnth, 
		   sum(sales_amt) total_sales
    FROM sales
    WHERE sales_date BETWEEN add_months(current_date, -3) 
	  AND current_date 
    GROUP BY 1,2
   )a
   QUALIFY RANK() OVER(PARTITION BY yr_mnth ORDER BY total_sales desc) <=10
 
 /* Without using the ordered analytical functions but using correlated subquery*/

 WITH tmp_sales
  AS (
       SELECT storeid, 
	          sales_date (FORMAT 'YYYY-MM') (CHAR(7)) yr_mnth, 
			  sum(sales_amt) total_sales
         FROM sales a
         WHERE sales_date BETWEEN ADD_MONTHS(current_date, -3) 
		   AND current_date 
         GROUP BY 1,2
 )
 SELECT a.*
   FROM tmp_sales a
  WHERE 10 > (SELECT count(*) 
	            FROM tmp_sales b
               WHERE a.yr_mnth = b.yr_mnth
			     AND a.total_sales < b.total_sales
				)
;
/* Without corrleated subquery and rank functions */
WITH total_by_mth AS
(SELECT storeid, 
        sales_date (FORMAT 'YYYY-MM') (CHAR(7)) year_mth,
        SUM(sales_amt) total_sales
   FROM sales
  WHERE sales_date BETWEEN ADD_MONTHS(current_date, -3) 
		   AND current_date
GROUP BY 1,2
)
SELECT a.storeid, 
       a.year_mth, 
	   a.total_sales, 
	   count( case when a.total_sales <= b.total_sales then a.sls_tran_loc_id end) as rnk
  FROM total_by_mth a
       join total_by_mth b
    ON a.year_mth = b.year_mth 
	
GROUP BY 1,2,3
HAVING rnk <=10
