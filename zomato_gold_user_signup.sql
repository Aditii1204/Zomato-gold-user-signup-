-- data exploration 
select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

-- Q1) what is the total amount each customer spent on zomato 

select s.userid ,sum(p.price)
from product as p
inner join sales as s
on s.product_id=p.product_id
group by userid;

-- Q2) how many days each customer visied zomato
select distinct count(created_date), userid
from sales 
group by userid;

-- Q3) what was the first product purchased by each customer
select product_name,userid,created_date,
rank() over (partition by userid order by created_date) as rw
from product
join sales on
product.product_id = sales.product_id;
select * 
from (
select product_name,userid,created_date,
rank() over (partition by userid order by created_date) as rw
from product
join sales on
product.product_id = sales.product_id ) as tble
where tble.rw=1;

-- Q4) what is the most purchased item on the menu and how many times was it purchased by all customers ?

select  product_id,count(product_id) 
from sales
group by product_id
order by count(product_id)  desc
limit 1
;

select userid,count(product_id) from sales where product_id =
 (
select  product_id
from sales
group by product_id
order by count(product_id)  desc
limit 1) 
group by userid
;
-- 5 which item was the most popular for each customer
use zomato;
select product_id,userid,count(product_id) as c
from sales 
group by userid,product_id
order by userid,product_id
;

select * 
from (
select g.*,(rank() over ( partition by userid order by c desc) ) as rnk
from
(  select product_id,userid,count(product_id) as c
from sales 
group by userid,product_id
order by product_id,userid
) as g) as k
where rnk = 1
;
-- part 2 advanced level concepts
-- Q6 which item was purchased first by the customer after they became a member
select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;
select *
from (SELECT 
  s.userid,
  s.created_date,
  s.product_id,
  g.gold_signup_date,
  RANK() OVER (PARTITION BY g.userid ORDER BY s.created_date) AS rank_of_them
FROM sales s
JOIN goldusers_signup g ON s.userid = g.userid
WHERE s.created_date >= g.gold_signup_date) as new
where rank_of_them = 1;

-- Q7 which item was purchased just before the customer became a member
select * 
from (
SELECT 
  s.userid,
  s.created_date,
  s.product_id,
  g.gold_signup_date,
  RANK() OVER (PARTITION BY g.userid ORDER BY s.created_date desc)  AS rank_of_them
FROM sales s
JOIN goldusers_signup g ON s.userid = g.userid
WHERE s.created_date <= g.gold_signup_date)  as yo
where rank_of_them=1;

-- 8 what is the total orders and amount spent for each member before they became a member

select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;


with my_table as (
SELECT 
  s.userid,
  s.created_date,
  s.product_id,
  g.gold_signup_date
 
FROM sales s
JOIN goldusers_signup g ON s.userid = g.userid
WHERE s.created_date <= g.gold_signup_date
) 

select userid,my_table.product_id,count(my_table.product_id),product.price,
 count(my_table.product_id) * price as final_price
 
from my_table
join product 
on my_table.product_id=product.product_id
group by product_id, userid,product.price
order by userid,product_id  



;
select userid, sum(final_price)

from (
select userid,my_table.product_id,count(my_table.product_id),product.price,
 count(my_table.product_id) * price as final_price
 
from my_table
join product 
on my_table.product_id=product.product_id
group by product_id, userid,product.price
order by userid,product_id   ) as m
group by userid
;
-- alternate solution
select userid,sum(price), count(created_date)
from (SELECT 
  s.userid,
  s.created_date,
  s.product_id,
  g.gold_signup_date
FROM sales s
JOIN goldusers_signup g ON s.userid = g.userid
WHERE s.created_date <= g.gold_signup_date 
) as a 
join product on 
a.product_id=product.product_id
group by userid
order by userid;



/*  9 if buying each product generates points for eg 5rs = 2 point 
and each product has different purchasing point 
for eg :
p1 5rs=1zomato point 
p2 5rs = 2 zomato point 
p3 5rs = 1 zomato point */ 

select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

select userid,product_id,
count(product_id)
from sales
group by userid,product_id
order by userid 
