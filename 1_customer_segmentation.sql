WITH customer_ltv as(
SELECT
customerkey,
cleaned_name,
sum(total_net_revenue) AS total_ltv
FROM cohort_analysis
GROUP BY 
customerkey ,
cleaned_name 
),customer_segment AS (
SELECT 
PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY total_ltv) AS ltv_25th_percentile,
PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_ltv) AS ltv_75th_percentile
FROM customer_ltv 
),segment_values AS (
SELECT 
c.*,
CASE 
	WHEN c.total_ltv <cs.ltv_25th_percentile  THEN '1-Low-value'
	WHEN c.total_ltv <=cs.ltv_75th_percentile  THEN '2-Mid-value'
	ELSE
	'3-High-value'
END AS customer_segment

FROM customer_ltv c,
customer_segment cs
)
SELECT 
customer_segment ,
sum(total_ltv ) AS total_ltv ,
count(customerkey )AS customer_count,
sum(total_ltv )/count(customerkey ) AS avg_ltv
FROM
segment_values 
GROUP BY 
customer_segment 
ORDER BY 
customer_segment desc