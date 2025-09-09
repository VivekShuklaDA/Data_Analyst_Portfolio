	
  --Data what i'm Using

	Select * From Project..Books
	Select * From Project..Customers
	Select * From Project..Orders

  --📊 Total Books Sold per Genre

  Select * from Project..Books
  where Genre = 'Fiction'

  --📖 Books Published After 1950

  Select * From Project..Books
  where Published_Year >= 1950
  order by Published_Year

  --🌍 Customers Located in 'India'

  Select * From Project..Customers
  where Country = 'India'

  --🗓️ Orders from November 2023

  Select * From Project..Orders
  where Order_Date Between '2023-11-01' and '2023-11-30'

  --📦 Total Stock of All Books

  Select Sum(Stock) As Total_Stock From Project..Books

  --💰 Most Expensive Book Details

  Select Max(Price) AS MOSTEXPENSIVEBOOK From Project..Books
                 --/
  Select Top 1  * from Project..Books
  order by Price desc 

  --🧾 Orders Over $20

  Select * FROM Project..Orders
  WHERE Total_Amount > 20
  ORDER BY Total_Amount

  --🎭 List of Book Genres

  Select Distinct Genre From Project..Books

  --📉 Book with Lowest Stock

  Select * From Project..Books
  Order by Stock 

  --⚠️ Books Needing Reorder (Stock < 5)

  Select * From Project..Books 
  where Stock < 5
  order by Stock

  --💵 Total Revenue from Orders

  Select Sum(Total_Amount) AS Total_revenue From Project..Orders

  --📊 Books Priced Above Average

  SELECT Title, Price
  FROM Project..Books
  WHERE Price > (SELECT AVG(Price) FROM Project..Books)
  ORDER BY Price DESC;

  --👥 Customers Ordering >1 Quantity

  Select C.Customer_ID, C.Name, C.City, B.Title, B.Genre, O.Quantity From Project..Customers C
  join Project..Orders O On C.Customer_ID = O.Customer_ID join Project..Books B on O.Book_ID = B.Book_ID
  where O.Quantity >1 
  Order by 1

  --📈 Total Books Sold per Genre

  Select  B.Genre, Sum(O.Quantity) As TOTAL_BOOKS_SOLD 
  From Project..Orders O 
  Join Project..Books B on O.Book_ID = B.Book_ID
  Group by B.Genre

  --📚 Average Price of Fantasy Books

  Select Avg(B.Price) As AVG_BOOK_PRICE From Project..Books B Where B.Genre = 'Fantasy'

  --📦 Customers with ≥ 2 Orders

  Select O.Customer_id, C.Name, Count(O.order_id) As Order_Count 
  From Project..Orders O
  Join Project..Customers C on C.Customer_ID = O.Customer_ID
  Group by O.Customer_ID, C.Name
  Having  Count(order_id) >= 2
  Order BY 3

  --🔥 Top 5 Most Frequently Ordered Books

  Select Top 5 O.Book_ID, B.Genre, B.Title, Count(Order_id) AS ORDER_Count 
  from Project..Orders O
  Join Project..Books B on B.Book_ID = O.Book_ID
  Group by O.Book_ID, B.Genre, B.Title
  Order by ORDER_Count Desc

  --💎 Top 3 Expensive Fantasy Books

  Select Top 3 Title, Author, Published_year, Price From Project..Books
  Where Genre = 'Fantasy'
  Order by Price Desc

  --🖋️ Total Books Sold per Author

  Select B.Author, Sum(O.Quantity) As TOTAL_BOOKS_SOLD From Project..Books B
  join Project..Orders O On O.Book_ID = B.Book_ID
  Group by Author
  Order By 2

  --🌆 Cities with High-Spending Customers ($30+)
  
  Select Distinct C.Customer_ID, C.Name,  C.city, O.Total_Amount From Project..Customers C 
  join Project..Orders O On O.Customer_ID = C.Customer_ID
  Where O.Total_Amount >= 30
  Group by C.Customer_ID, C.Name, C.city, O.Total_Amount
  order by City

  --🏆 Top 5 Customers by Total Spending

  Select Top 5 C.Customer_ID, C.Name, C.City, Sum(O.Total_Amount) As Total_Spent From Project..Customers C
  Join Project..Orders O on O.Customer_ID = C.Customer_ID
  Group by C.Customer_ID, C.Name, C.City
  Order By Total_Spent Desc

  --📦 Remaining Stock After Orders

   Select B.Book_ID, B.Title, B.Stock, O.Quantity,
		case 
			when  O.Quantity is null then B.Stock
			Else B.Stock - O.Quantity
		End as Remaining_Stock
	From Project..Books B
  Left join Project..Orders O On O.Book_ID = B.Book_ID
  Group by B.Book_ID, B.Title, B.Stock, O.Quantity
  Order by B.Book_ID

  --🚨 Low-Stock Books Alert

  SELECT Book_ID, Title, Stock, 
       CASE WHEN Stock < 5 THEN 'Reorder NOW' 
            ELSE 'In Stock' 
       END AS Alert
  FROM Project..Books;

 --📅 Monthly Revenue Breakdown

 WITH MonthlySales AS (
    SELECT 
        MONTH(O.Order_Date) AS Month, SUM(O.Total_Amount) AS Revenue
    FROM Project..Orders O
    GROUP BY MONTH(O.Order_Date))

 Select Month, Revenue From MonthlySales
 Order by Month;

 --🏷️ Price Ranking of Books per Genre

 SELECT 
    Title, Genre, Price,
    RANK() OVER (PARTITION BY Genre ORDER BY Price DESC) AS PriceRank
 FROM Project..Books
 ORDER BY Genre, PriceRank;

 --📋 Customer Summary: Last Order & Spending

 WITH CustomerStats AS (
    SELECT Customer_ID, MAX(Order_Date) AS LastOrderDate, SUM(Total_Amount) AS TotalSpent
    FROM Project..Orders
    GROUP BY Customer_ID)

 SELECT C.Name, CS.LastOrderDate, CS.TotalSpent,
    RANK() OVER (ORDER BY CS.TotalSpent DESC) AS SpendingRank
 FROM CustomerStats CS
 JOIN Project..Customers C ON CS.Customer_ID = C.Customer_ID;

 --📈 Cumulative Revenue by Order Date

 SELECT Order_Date, Total_Amount,
    SUM(Total_Amount) OVER (ORDER BY Order_Date) AS RunningTotal
 FROM Project..Orders
 ORDER BY Order_Date;

 --📊 Market Share by Genre (Revenue %)

 WITH GenreRevenue AS (
    SELECT Genre, SUM(Total_Amount) AS Revenue
    FROM Project..Books B
    JOIN Project..Orders O ON B.Book_ID = O.Book_ID
    GROUP BY Genre
)
SELECT Genre, Revenue, (Revenue * 100 / (SELECT SUM(Revenue) FROM GenreRevenue)) AS MarketShare
FROM GenreRevenue
ORDER BY Revenue DESC;