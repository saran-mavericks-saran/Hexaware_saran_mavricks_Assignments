-- 2. Stored Procedure: usp_PlaceOrder
CREATE OR ALTER PROCEDURE dbo.usp_PlaceOrder
    @customer_id INT,
    @product_id INT,
    @quantity INT,
    @new_order_id INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @current_stock INT, @unit_price DECIMAL(10,2);

        SELECT @current_stock = stock_qty, @unit_price = selling_price
        FROM dbo.products WITH (UPDLOCK, HOLDLOCK)
        WHERE product_id = @product_id;

        IF @current_stock IS NULL
            THROW 50001, 'Product does not exist.', 1;

        IF @current_stock < @quantity
            THROW 50002, 'Insufficient stock available.', 1;

        INSERT INTO dbo.orders (customer_id, order_date, status)
        VALUES (@customer_id, GETDATE(), 'Pending');

        SET @new_order_id = SCOPE_IDENTITY();

        INSERT INTO dbo.order_lines (order_id, product_id, quantity, unit_price)
        VALUES (@new_order_id, @product_id, @quantity, @unit_price);

        UPDATE dbo.products
        SET stock_qty = stock_qty - @quantity
        WHERE product_id = @product_id;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- 3a. Scalar Function: fn_OrderTotalWithTax
CREATE OR ALTER FUNCTION dbo.fn_OrderTotalWithTax
(
    @order_id INT,
    @tax_rate DECIMAL(5,4)
)
RETURNS DECIMAL(12,2)
AS
BEGIN
    DECLARE @total DECIMAL(12,2);
    SELECT @total = SUM(quantity * unit_price) * (1 + @tax_rate)
    FROM dbo.order_lines
    WHERE order_id = @order_id;

    RETURN ISNULL(@total, 0.00);
END;
GO

-- 3b. Inline Table-Valued Function (iTVF)
CREATE OR ALTER FUNCTION dbo.fn_GetCustomerOrders (@customer_id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        order_id,
        order_date,
        status,
        dbo.fn_OrderTotalWithTax(order_id, 0.08) AS total_with_tax
    FROM dbo.orders
    WHERE customer_id = @customer_id
);
GO