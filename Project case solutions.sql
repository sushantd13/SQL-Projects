Create Database Pizza;

use pizza;

select * from orders;
select * from pizzas;
select * from pizza_types;
select * from order_details;

-- Task 1:  Retrieve the total number of orders placed.

select count(order_id) as total_orders from orders;

-- 21350

-- Task 2: Calculate the total revenue generated from pizza sales.

select round(sum(quantity * price),2) as total_sales
from order_details o
inner join pizzas p on o.pizza_id = p.pizza_id;

-- 817860.05

-- Task 3: Identify the highest-priced pizza.

select pizza_id, price from 
pizzas 
order by price desc
limit 1;

-- the_greek_xxl 35.95

-- Task 4: Identify the most common pizza size ordered.

select p.size, count(od.order_details_id) as total_orders
from pizzas as p
inner join order_details as od on p.pizza_id = od.pizza_id
group by size
order by total_orders desc;

-- Size L 18526 pizzas

-- Task : List the top 5 most ordered pizza types along with their quantities

select pt.name, pt.pizza_type_id, sum(od.quantity) as pizza_quantity
from pizza_types as pt
inner join pizzas as p on pt.pizza_type_id = p.pizza_type_id
inner join order_details as od on p.pizza_id = od.pizza_id
group by pt.name
order by pizza_quantity desc
limit 5;

-- The Classic Deluxe Pizza	classic_dlx	2453
-- The Barbecue Chicken Pizza	bbq_ckn	2432
-- The Hawaiian Pizza	hawaiian	2422
-- The Pepperoni Pizza	pepperoni	2418
-- The Thai Chicken Pizza	thai_ckn	2371

-- Task 2: Determine the distribution of orders by hour of the day.

select *
, sum(hourly_orders) over () as total_orders
, hourly_orders/ sum(hourly_orders) over () as contri_orders
from
    (
    select hour(time) as hr, count(order_id) as hourly_orders
    from orders 
    group by hour(time)
    order by 2 desc ) as a;
    
-- Task 3: Determine the top 3 most ordered pizza types based on revenue.
    
select pt.name, sum(od.quantity * p.price) as rev
from order_details as od
inner join pizzas as p on p.pizza_id = od.pizza_id
inner join pizza_types as pt on pt.pizza_type_id = p.pizza_type_id
group by pt.name
order by rev desc
limit 3;

-- The Thai Chicken Pizza	43434.25
-- The Barbecue Chicken Pizza	42768
-- The California Chicken Pizza	41409.5

-- Task: Calculate the percentage contribution of each pizza type to total revenue.

with contri_rev as (
select pt.name, sum(od.quantity * p.price) as rev
from pizza_types as pt
inner join pizzas as p on p.pizza_type_id = pt.pizza_type_id
inner join order_details as od on od.pizza_id = p.pizza_id
group by pt.name
order by rev desc
)

select *
, sum(rev) over () as total_rev
, round(rev*100.00/sum(rev) over () , 2) as revenue_contribution
from contri_rev;

-- The Thai Chicken Pizza	43434.25	817860.0500000006	5.31
-- The Barbecue Chicken Pizza	42768	817860.0500000006	5.23
-- The California Chicken Pizza	41409.5	817860.0500000006	5.06
-- The Classic Deluxe Pizza	38180.5	817860.0500000006	4.67
-- The Spicy Italian Pizza	34831.25	817860.0500000006	4.26

-- Task:  Analyze the cumulative revenue generated over time

select * 
from
(
select * 
, round(sum(rev) over (order by date asc), 0) as cumm_rev
from 
(
select o.date
, round(sum(p.price * od.quantity),0) as rev
from order_details as od
inner join pizzas as p on od.pizza_id = p.pizza_id 
inner join orders as o on o.order_id = od.order_id 
group by o.date
) as a

-- Task: Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select *
from (
select * 
, dense_rank() over (partition by category order by rev desc) as rn
from 
(
select pt.category, pt.name, sum(od.quantity* p.price) as rev
from pizza_types as pt
inner join pizzas as p on pt.pizza_type_id = p.pizza_type_id
inner join order_details as od on p.pizza_id = od.pizza_id
group by pt.category, pt.name
order by rev desc
) as a 
) as b
where rn<=3 ;


-- Task : Join the necessary tables to find the total quantity of each pizza category ordered.

select pt.category, sum(od.quantity) as total_cat_quantity
from pizza_types as pt
inner join pizzas as p on pt.pizza_type_id = p.pizza_type_id
inner join order_details as od on od.pizza_id = p.pizza_id
group by pt.category;

-- Task join relevant tables to find the category-wise distribution of pizzas.

select category, count(distinct name) as pizza_type_distr, count(distinct p.pizza_id) as pizza_distri
from pizza_types as pt
inner join pizzas as p on p.pizza_type_id = pt.pizza_type_id
group by category;


-- Task: Group the orders by the date and calculate the average number of pizzas ordered per day.
select avg(quantity) as avg
from
(
select o.date as order_date, sum(quantity) as quantity
from orders as o
inner join order_details as od on o.order_id = od.order_id
group by o.date
) as a

-- 138.474