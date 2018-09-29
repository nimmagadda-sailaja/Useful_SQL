/* Using ordered analytical functions */

SELECT storeid, 
       yr_mnth, 
	   total_sales
  FROM 
  (
     SELECT 
	       storeid, 
		   sakes_date (FORMAT 'YYYY-MM') (CHAR(7)) yr_mnth, 
		   sum(sales_amt) total_sales
    FROM sales
    WHERE sakes_date BETWEEN add_months(current_date, -3) 
	  AND current_date 
    GROUP BY 1,2
   )a
   QUALIFY RANK() OVER(PARTITION BY yr_mnth ORDER BY total_sales desc) <=10
 
 /* Without using the ordered analytical functions */

 WITH tmp_sales
  AS (
       SELECT storeid, 
	          sakes_date (FORMAT 'YYYY-MM') (CHAR(7)) yr_mnth, 
			  sum(sales_amt) total_sales
         FROM sales a
         WHERE sakes_date BETWEEN ADD_MONTHS(current_date, -3) 
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
