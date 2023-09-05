-- 5 State with the highest number of return
create table state_Return(customerID varchar(40), state varchar (40));
insert into state_Return (customerID , state)

select t.CustomerID, state from transaction t
join returns r on t.TransactionID = r.TransactionID
join customer c on t.CustomerID = c.customerID;
select state, count(customerID) as Total_returns from state_Return
group by state
order by Total_returns desc
limit 5;

-- TOTAL STOCK VALUE OF ALL NORTHERN SATES
create table State_Stock(store_code int , Stock_value double);
insert into state_stock(store_code, stock_value)
select store_location_code, stock_quantity_left * unit_price as Stock_value from product_profile;
select * from state_stock
where store_code =3 or store_code = 2 or store_code = 4;
select sum(stock_value) as Total_Northern_Stock from state_stock ;

-- GROSS SALES
create table Gross_sales as
with Gross_sales_profile as(
select unit_price, t.Quantity_supplied from transaction t
join product_profile r on t.ProductID = r.ProductID)
select unit_price * Quantity_supplied as Transaction_Gross_sales from gross_sales_profile;
select * from gross_sales;

-- DISCOUNT VALUE AND REVENUE
create table discounted_transaction as
select t.ProductID, t.Quantity_Supplied, Unit_Price, unit_price * Quantity_supplied as Transaction_Gross_sales , discount * 0.01 as discount_rate from transaction t
join product_profile r on t.ProductID = r.ProductID;

create table Discount_Value as
select ProductID, Discount_rate, Transaction_gross_sales, Discount_rate * Transaction_gross_sales as Discount_value from discounted_transaction;

create table Product_Revenue as 
select ProductID, transaction_gross_sales - discount_value as Revenue from discount_value;
select * from product_revenue;

-- TOP 10 PRODUCT BY REVENUE
select ProductID, sum(revenue) from product_revenue
group by ProductID
order by revenue desc
limit 10;

-- PRODUCT CATEGORY BY REVENUE
select Product_Category, Revenue from product_profile t
join product_revenue r on t.ProductID = r.ProductID
group by Product_Category
order by Revenue desc;

-- TOP 10 CUSTOMER BY REVENUE
create table customer_revenue as 
select CustomerID, Revenue from transaction t
join product_revenue r on t.ProductID = r.ProductID
group by CustomerID
order by Revenue desc;

select Customers_Name, t.CustomerID, Revenue from customer t
join customer_revenue r on t.CustomerID = r.CustomerID
limit 10;

-- TAX AND PROFIT BEFORE TAX
create table Manufacturing_cost as 
select t.ProductID, production_price * Quantity_supplied as Manufacturing_cost, Revenue from transaction t
join product_profile r on t.ProductID = r.ProductID
join product_revenue c on t.ProductID = c.ProductID;

create table Profit_before_tax as
select ProductID, Revenue, Manufacturing_Cost, Revenue - manufacturing_cost as Profit_before_tax from manufacturing_cost;

create table Product_Taxation (Product_ID varchar(40), Revenue double, Profit_before_tax double, Tax double );
insert into Product_Taxation (ProductID, Revenue, Profit_before_tax, Tax)
select ProductID,Revenue, Profit_before_tax, Profit_before_tax * 0.05 as Tax from profit_before_tax;

drop table profit;
create table Profit as 
select ProductID, Revenue, Tax, Profit_before_tax- Tax as profit from product_taxation;
select * from profit;

-- SUPPLYING TO STORES WITH 5 BEST SELLING PRODUCT
create table best_product as 
select t.ProductID, Product_name, Store_Location_Code, Revenue from product_profile t
join profit_before_tax r where t.ProductID = r.ProductID;
select * from best_product;

select Store_Location_Code, Product_name, revenue from best_product
group by Store_Location_Code
order by Revenue desc;

select product_name, Store_Location_Code, revenue from best_product
group by Product_name
order by Revenue desc;

-- TOP 10 CHURNED CUSTOMER BETWEEN 2019 AND 2022
set sql_safe_updates = 1; -- To Temporary disable(0) / enable(1) safe updates
alter table transaction
add transaction_date date; -- Adding new column with the date datatype
update transaction
set transaction_date = str_to_date(order_date, '%m/%d/%Y');

select Customers_Name, t.CustomerID, max(transaction_date) as last_transaction_date from transaction t
join customer r on t.CustomerID = r.CustomerID
group by CustomerID
order by last_transaction_date asc
limit 10;

-- QUANTITY OF PRODUCT SUPPLIED AGAINST THE STORE LOCATION
select Store_location_code, sum(Quantity_Supplied) as Quantity_Supplied_per_Store from transaction t
join product_profile r on t.ProductID = r.ProductID
group by Store_Location_Code
order by Quantity_Supplied_per_store desc;

-- TOP 15 PRODUCT WITH WITH THEIR FREQUENCY OF TRANSACTION AND PROFIT
select t.ProductID, profit_before_tax as Product_Profit,TransactionID from profit_before_tax t
join transaction r on t.ProductID = r.ProductID
order by sum(Product_Profit) desc;