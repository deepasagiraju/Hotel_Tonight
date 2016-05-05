/*------------------------------------------------------------------------------------------------------------
 
 Environment : Postgres - SQL Query

------------------------------------------------------------------------------------------------------------*/


-- Number of bookings where atleast one night falls on 2015-02-21

select 
	sum(case 
		when '2015-02-21'::date between checkin_date and (checkin_date + cast(nights || 'days' as interval)) 
		then 1 
		else 0 
	end) 
from bookings
;

-- Number of bookings where atleast one night is between 2015-02-21 and 2015-02-23

with stays as (
select 
	(generate_series(checkin_date, checkin_date + cast(nights-1 || ' days' as interval), '1 day'::interval))::date as stay_date
	, * from bookings
	)
select 
	count(distinct booking_id) AS Number_of_Bookings
from stays
	where stay_date between '2015-02-21'::date and '2015-02-23'::date
;

-- For each metro between 2/3/2015 and 12/24/2015, hotel names by # of nights

with stays as (
select 
	(generate_series(checkin_date, checkin_date + cast(nights-1 || ' days' as interval), '1 day'::interval))::date as stay_date
	, * 
from bookings
	)
select metro, name, count(1) as number_of_nights
from stays S join hotels H on S.hotel_id = H.hotel_id
where stay_date between '2015-02-03'::date and '2015-12-24'::date
group by 1, 2
order by 1, 2
;


--The Busiest DOW for HotelTonight by month in 2015.
-- Busiest day of week by month in 2015

with stays as (
	select 
	(generate_series(checkin_date, checkin_date + cast(nights-1 || ' days' as interval), '1 day'::interval))::date as stay_date
	, * from bookings
	),
day_counts as (
select date_trunc('month', stay_date) as stay_month, to_char(stay_date, 'Day') as stay_day, count(1) as cnt
	from stays
	where to_char(stay_date, 'YYYY') = '2015'
	group by 1, 2
),
ranks as (
	select stay_month, stay_day, cnt, rank() over (partition by stay_month order by cnt desc) as rnk
	from day_counts
)


--Select stay_month, stay_day, * from ranks

select to_char(stay_month, 'YYYY-Month') as month, stay_day, cnt as dow_count from ranks
	where rnk = 1
	order by stay_month, rnk
;