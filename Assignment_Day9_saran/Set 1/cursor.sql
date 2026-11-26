-- 4a. Cursor-based procedure
CREATE OR ALTER PROCEDURE dbo.usp_FlagDelayedOrders_Cursor
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @order_id INT;

    DECLARE cur_delayed CURSOR LOCAL FAST_FORWARD FOR
        SELECT order_id
        FROM dbo.orders
        WHERE status = 'Pending'
          AND order_date < DATEADD(DAY, -3, GETDATE());

    OPEN cur_delayed;
    FETCH NEXT FROM cur_delayed INTO @order_id;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        INSERT INTO dbo.order_followups (order_id, followup_date, note)
        VALUES (@order_id, GETDATE(), 'Pending over 3 days');

        FETCH NEXT FROM cur_delayed INTO @order_id;
    END

    CLOSE cur_delayed;
    DEALLOCATE cur_delayed;
END;
GO

-- 4b. Set-based rewrite
CREATE OR ALTER PROCEDURE dbo.usp_FlagDelayedOrders_SetBased
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.order_followups (order_id, followup_date, note)
    SELECT order_id, GETDATE(), 'Pending over 3 days'
    FROM dbo.orders
    WHERE status = 'Pending'
      AND order_date < DATEADD(DAY, -3, GETDATE());
END;
GO