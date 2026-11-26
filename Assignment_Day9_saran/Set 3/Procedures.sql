-- 2. Stored Procedure: usp_Recharge
CREATE OR ALTER PROCEDURE dbo.usp_Recharge
    @subscriber_id INT,
    @plan_id INT,
    @amount DECIMAL(10,2),
    @new_balance DECIMAL(10,2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @plan_price DECIMAL(10,2), @validity_days INT;

        SELECT @plan_price = price, @validity_days = validity_days
        FROM dbo.recharge_plans
        WHERE plan_id = @plan_id AND is_active = 1;

        IF @plan_price IS NULL
            THROW 52001, 'Invalid or inactive recharge plan.', 1;

        IF @amount <> @plan_price OR @amount <= 0
            THROW 52002, 'Recharge amount does not match the selected plan price.', 1;

        UPDATE dbo.subscribers
        SET balance = balance + @amount,
            plan_expiry_date = DATEADD(DAY, @validity_days, 
                CASE WHEN plan_expiry_date > GETDATE() THEN plan_expiry_date ELSE GETDATE() END)
        WHERE subscriber_id = @subscriber_id AND plan_type = 'Prepaid';

        IF @@ROWCOUNT = 0
            THROW 52003, 'Prepaid subscriber not found.', 1;

        SELECT @new_balance = balance FROM dbo.subscribers WHERE subscriber_id = @subscriber_id;

        INSERT INTO dbo.recharge_history (subscriber_id, plan_id, amount, recharge_date)
        VALUES (@subscriber_id, @plan_id, @amount, GETDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- 3a. Scalar Function: fn_ValidityDaysLeft
CREATE OR ALTER FUNCTION dbo.fn_ValidityDaysLeft (@subscriber_id INT)
RETURNS INT
AS
BEGIN
    DECLARE @days INT;
    SELECT @days = DATEDIFF(DAY, GETDATE(), plan_expiry_date)
    FROM dbo.subscribers
    WHERE subscriber_id = @subscriber_id;

    RETURN CASE WHEN @days < 0 OR @days IS NULL THEN 0 ELSE @days END;
END;
GO

-- 3b. Table-Valued Function: Last 5 Recharges
CREATE OR ALTER FUNCTION dbo.fn_LastFiveRecharges (@subscriber_id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT TOP (5)
        recharge_id,
        plan_id,
        amount,
        recharge_date
    FROM dbo.recharge_history
    WHERE subscriber_id = @subscriber_id
    ORDER BY recharge_date DESC
);
GO