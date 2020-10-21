#Instructions
use sakila;

#1. How many copies of the film Hunchback Impossible exist in the inventory system?
select title, count(*) as copies from sakila.film as f
join sakila.inventory as i 
on f.film_id=i.film_id
where title="Hunchback Impossible";



#2. List all films longer than the average.
select avg(length) from sakila.film;

select title, length from sakila.film
where length>(select avg(length) from sakila.film);



#3. Use subqueries to display all actors who appear in the film Alone Trip.
select title, film_id from sakila.film
where title="Alone Trip";

-- Mix
select a.actor_id, concat(first_name," ",last_name) from sakila.actor as a
join sakila.film_actor as fa
on a.actor_id=fa.actor_id
where film_id=(select film_id from sakila.film
where title="Alone Trip")
group by actor_id;

-- Only subqueries
select actor_id, concat(first_name," ",last_name) as Actor from sakila.actor
where actor_id in (select actor_id from sakila.film_actor
where film_id=(select film_id from (select title, film_id from sakila.film
where title="Alone Trip") movie));

#4. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
select title, name as category from sakila.film as f
join sakila.film_category as fc
on f.film_id=fc.film_id
join sakila.category as c 
on fc.category_id=c.category_id
where name="family";



#5. Get name and email from customers from Canada using subqueries. Do the same with joins.

-- Subqueries
select concat(first_name," ", last_name), email, address_id from sakila.customer
where address_id in (select address_id from sakila.address
where city_id in (select city_id from sakila.city 
where country_id in (select country_id from sakila.country 
where country="Canada")));


-- Mix of joins and subqueries
select concat(first_name," ", last_name), email, country_id from sakila.customer as cust
join sakila.address as a
on cust.address_id=a.address_id
join sakila.city as ci
on a.city_id=ci.city_id
where country_id=(select country_id from sakila.country 
where country="Canada");


-- Joins
select concat(first_name," ", last_name), email, country from sakila.customer as cust
join sakila.address as a
on cust.address_id=a.address_id
join sakila.city as ci
on a.city_id=ci.city_id
join sakila.country as co
on ci.country_id=co.country_id
where country="Canada";



#6. Which are films starred by the most prolific actor?

#actor_id=107 is the most prolific actor - child query
select actor_id, count(*) as films_starred from sakila.film_actor
group by actor_id
order by count(*) desc
limit 1;

select f.film_id, f.title, concat(first_name," ", last_name) as actor from sakila.film as f
join sakila.film_actor as fa
on f.film_id=fa.film_id
join sakila.actor as a 
on fa.actor_id=a.actor_id
where a.actor_id = (select actor_id from (select actor_id, count(*) as films_starred from sakila.film_actor
group by actor_id
order by count(*) desc
limit 1) as prolific_actor);




#7. Films rented by most profitable customer (customer that pays the most - amount).
select customer_id, sum(amount) as money_spent from sakila.payment
group by customer_id
order by sum(amount) desc
limit 1;

select f.film_id, f.title, c.customer_id, concat(first_name," ", last_name) from sakila.film as f
join sakila.inventory as i
on f.film_id=i.film_id
join sakila.rental as r 
on i.inventory_id=r.inventory_id
join sakila.customer as c
on r.customer_id=c.customer_id
where c.customer_id=(select customer_id from (select customer_id, sum(amount) as money_spent from sakila.payment
group by customer_id
order by sum(amount) desc
limit 1) profitable_customer);



#8. Customers who spent more than the average.

-- Amount spent by customer
select customer_id, sum(amount) as amount_spent from sakila.payment
group by customer_id;

-- Amount spent by customer more pretty (names...)
select p.customer_id, concat(first_name," ", last_name) as Customer, sum(amount) as amount_spent from sakila.payment as p
join sakila.customer as c
on p.customer_id=c.customer_id
group by customer_id;

-- Average amount spent
select avg(amount_spent) from (select customer_id, sum(amount) as amount_spent from sakila.payment
group by customer_id)amount_by_customer;

-- Customers spending more than the average
select customer_id, sum(amount) as amount_spent from sakila.payment
group by customer_id
having sum(amount) > (select avg(amount_spent) from (select customer_id, sum(amount) as amount_spent from sakila.payment
group by customer_id)amount_by_customer);

-- Customers spending more than the average more pretty (names...)
select p.customer_id, concat(first_name," ", last_name) as Customer, sum(amount) as amount_spent from sakila.payment as p
join sakila.customer as c
on p.customer_id=c.customer_id
group by customer_id
having sum(amount) > (select avg(amount_spent) from (select customer_id, sum(amount) as amount_spent from sakila.payment
group by customer_id)amount_by_customer);