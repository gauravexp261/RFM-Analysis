# RFM Analysis: Unlocking Customer Insights with Data

RFM (Recency, Frequency, Monetary) analysis is a powerful tool in the world of data-driven marketing and customer relationship management. It allows businesses to segment their customers based on their transactional behavior, helping them understand and target different customer groups more effectively. Let's delve into the details of RFM analysis and how it can be applied using SQL queries.

## Recency, Frequency, Monetary (RFM) Analysis

* Recency refers to how recently a customer has made a purchase. 
* Frequency measures how often a customer makes a purchase.
* Monetary represents the amount of money a customer spends. 
* By combining these three dimensions, businesses can create segments that reflect different levels of customer engagement and value.
One common approach to RFM analysis is to assign a score to each dimension for every customer. For example, customers who made a purchase more recently might receive a higher recency score, while those who spend more money might receive a higher monetary score. These scores can then be used to group customers into segments.

## SQL Analysis
* The first part of the query calculates the RFM scores for each customer, including the recency, frequency, and monetary values.
* Second part of SQL query uses the NTILE function to assign each customer a quartile for each RFM value.
* Finally, the query assigns an RFM segment to each customer based on their quartile values, such as "lost_customer" "slipping away, cannot lose", "new customers" etc.
SQL Query:
```sql
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
```
## Further more we can analyse which segement to focus, in this analysis, I conclude, more focus should be on customers who are "slipping away, cannot loose category".
Given that this category represents 24% of all customers, it is crucial for the marketing team to investigate why these customers are not purchasing products. By identifying the underlying reasons, the team can develop targeted marketing strategies to attract and engage this segment.

## Visual Analysis is in Power BI Report
