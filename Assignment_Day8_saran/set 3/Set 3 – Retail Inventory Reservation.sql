-- 1. Stock Reservation Transaction (Task 1)
CREATE OR ALTER PROCEDURE sp_PlaceRetailOrder
    @CustomerID INT,
    @ProductID INT,
    @Qty INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @Price DECIMAL(10, 2), @Stock INT;
        SELECT @Price = UnitPrice, @Stock = StockQty
        FROM Products WITH (UPDLOCK)
        WHERE ProductID = @ProductID;

        IF @Stock IS NULL OR @Stock < @Qty
            THROW 52001, 'Insufficient stock; rolling back order.', 1;

        UPDATE Products SET StockQty = StockQty - @Qty WHERE ProductID = @ProductID;

        INSERT INTO RetailOrders (CustomerID, OrderDate, TotalAmount)
        VALUES (@CustomerID, GETDATE(), @Price * @Qty);

        DECLARE @NewOrderID INT = SCOPE_IDENTITY();

        INSERT INTO RetailOrderItems (OrderID, ProductID, Quantity, UnitPrice)
        VALUES (@NewOrderID, @ProductID, @Qty, @Price);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- 2. Correlated Subquery: Products below their own category's average stock (Task 2)
SELECT p1.ProductID, p1.ProductName, p1.Category, p1.StockQty
FROM Products p1
WHERE p1.StockQty < (
    SELECT AVG(CAST(p2.StockQty AS DECIMAL(10, 2)))
    FROM Products p2
    WHERE p2.Category = p1.Category
);
GO

-- 3. Top 3 Selling Products per Category using CTE + ROW_NUMBER (Task 3)
WITH CategorySalesCTE AS (
    SELECT 
        p.Category,
        p.ProductID,
        p.ProductName,
        SUM(oi.Quantity * oi.UnitPrice) AS TotalSales,
        ROW_NUMBER() OVER (
            PARTITION BY p.Category 
            ORDER BY SUM(oi.Quantity * oi.UnitPrice) DESC
        ) AS SalesRank
    FROM Products p
    INNER JOIN RetailOrderItems oi ON p.ProductID = oi.ProductID
    GROUP BY p.Category, p.ProductID, p.ProductName
)
SELECT Category, SalesRank, ProductName, TotalSales
FROM CategorySalesCTE
WHERE SalesRank <= 3;
GO

-- 4. Month-on-Month Sales Change using LAG (Task 4)
WITH MonthlyProductSales AS (
    SELECT 
        oi.ProductID,
        FORMAT(o.OrderDate, 'yyyy-MM') AS SalesMonth,
        SUM(oi.Quantity * oi.UnitPrice) AS MonthlyRevenue
    FROM RetailOrders o
    INNER JOIN RetailOrderItems oi ON o.OrderID = oi.OrderID
    GROUP BY oi.ProductID, FORMAT(o.OrderDate, 'yyyy-MM')
)
SELECT 
    ProductID,
    SalesMonth,
    MonthlyRevenue,
    LAG(MonthlyRevenue) OVER (PARTITION BY ProductID ORDER BY SalesMonth) AS PrevMonthRevenue,
    MonthlyRevenue - LAG(MonthlyRevenue) OVER (PARTITION BY ProductID ORDER BY SalesMonth) AS MoMChange
FROM MonthlyProductSales;
GO