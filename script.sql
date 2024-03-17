
-- Inspecting 
select * from [dbo].[sales_data_sample];

-- Checking Null Values
select distinct status from sales_data_sample
select distinct YEAR_ID from sales_data_sample
select distinct PRODUCTLINE from sales_data_sample
select distinct COUNTRY from sales_data_sample
select distinct DEALSIZE from sales_data_sample
select distinct TERRITORY from sales_data_sample;

-- Analysis

-- Grouping Sales by productline

select PRODUCTLINE, sum(sales) as Revenue
from sales_data_sample
group by PRODUCTLINE
order by 2 desc;

select YEAR_ID, sum(sales) as Revenue
from sales_data_sample
group by YEAR_ID
order by 2 desc;

--select distinct month_id from sales_data_sample
--where YEAR_ID = 2005

select DEALSIZE, sum(sales) as Revenue
from sales_data_sample
group by DEALSIZE
order by 2 desc;

-- best month for sales for each year 

with ct as (select year_id, month_id, sum(sales) as Revenue, rank() over (partition by year_id order by sum(sales) desc) as rn
from sales_data_sample
group by year_id ,MONTH_ID) 
select year_id ,MONTH_ID ,Revenue
from ct
where rn =1
;


-- Recency (last ordered date), Frequency (count of total orders), Monetory Analysis (total spend)

drop table if exists #rfm;
with rfm as (
	select 
		customername, sum(sales) MonetoryValue,
		avg(sales) AvgMonetaryValue, 
		count(ordernumber) Frequency, 
		max(orderdate) last_order_date, 
		(select max(orderdate) from sales_data_sample) maxorderdate,
		DATEDIFF(DD, max(orderdate), (select max(orderdate) from sales_data_sample)) Recency
	from sales_data_sample
	group by CUSTOMERNAME
	),
rmf_calc as (
	select r.*, 
		NTILE(4) over(order by Recency desc) rfm_recency,
		NTILE(4) over(order by Frequency) rfm_frequency,
		NTILE(4) over(order by MonetoryValue) rfm_monetory
	from rfm r
)
	select c.*, rfm_recency+ rfm_frequency +rfm_monetory as rfm_cell,
	cast(rfm_recency as varchar) + cast(rfm_frequency as varchar) + cast(rfm_monetory as varchar) as rfm_cell_string
	into #rfm -- crearting temp table
	from rmf_calc c;

select CUSTOMERNAME, rfm_recency,rfm_frequency, rfm_monetory,
		case
			when rfm_cell_string in (111,112,121,122,123,132,211,212,114, 141) then 'lost_customer'
			when rfm_cell_string in (133,134,143,244,334,343,344,144) then 'slipping away, cannot lose'
			when rfm_cell_string in (311,411,331) then 'new customers'
			when rfm_cell_string in (222,223,233,322) then 'potential customers'
			when rfm_cell_string in (323,333,321,422,332,432) then 'active customers'
			when rfm_cell_string in (433,434,443,444) then 'loyal customers'
		end rfm_segment
			from #rfm;

select MIN(orderdate)
from sales_data_sample;








