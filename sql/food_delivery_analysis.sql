1 - Which restaurants generate the highest revenue?

select
	restaurant_name,
	round(sum(total),2) as revenue
from clean_orders_final
group by restaurant_name
order by revenue desc;


2 - Does customer satisfaction change as delivery distance increases?

select
	case
		when distance_numeric < 2 then '0-2 km'
		when distance_numeric < 5 then '2-5 km'
		when distance_numeric < 8 then '5-8 km'
		else '8+ km'
	end as distance_group,
	round(avg(rating),2) as avg_rating,
	count (*) as total_orders
from (select
		case
			when distance = '<1km' then 0.5
			else replace (distance, 'km', ''):: NUMERIC
		end as distance_numeric,
		rating
		from clean_orders_final) t
group by distance_group
order by distance_group;


3 - How does weather affect customer ratings?

select
	w.weather_code,
	round(avg(o.rating),2) as avg_rating
from clean_orders_final o
join weather_daily_final w
	on date(o.order_placed_at) = w.date
group by w.weather_code
order by avg_rating;


4 - Which restaurants generate more revenue than the average restaurant?

with restaurant_revenue as (
	select 
		restaurant_name,
		round(sum(total),2) as revenue
		from clean_orders_final
		group by restaurant_name)
select 
	restaurant_name,
	revenue
from restaurant_revenue
where revenue > (select avg(revenue) from restaurant_revenue)
order by revenue;


5 - do bigger orders receive better ratings?
Shows whether larger baskets correlate with higher customer satisfaction

SELECT
    CASE
		WHEN item_count = 1 THEN ' 1 item'
		WHEN item_count BETWEEN 2 AND 3 THEN '2-3 items'
		ELSE '4+ items'
	END AS order_size,
	COUNT(*) AS total_orders,
	ROUND(AVG(rating),2) AS avg_rating
FROM clean_orders_final
GROUP BY order_size
ORDER BY total_orders DESC;

6 - which customers are the most valuable?
Provides a customer leaderboard

WITH customer_spend AS (
SELECT
	customer_id,
	SUM(total) AS revenue
FROM clean_orders_final
GROUP BY customer_id
)
SELECT
	customer_id,
	revenue,
	RANK() OVER (ORDER BY revenue DESC) AS spending_rank
FROM customer_spend
Limit 20;

7 - which restarants are responsible for 80% of revenue?

WITH revenue_table AS (
SELECT
	restaurant_name,
    SUM(total) AS revenue
FROM clean_orders_final
GROUP BY restaurant_name
)
SELECT
    restaurant_name,
    revenue,
    ROUND(SUM(revenue) OVER(ORDER BY revenue DESC),2) AS cumulative_revenue,
	round(100.0 * revenue / sum(revenue) over(), 2) as revenue_pct,
	round(100.0 * sum(revenue) over (order by revenue desc) / sum(revenue) over(),2) as cumulative_pct
FROM revenue_table
ORDER BY revenue DESC;

