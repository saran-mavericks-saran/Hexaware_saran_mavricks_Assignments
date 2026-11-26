-- 1. AFTER UPDATE trigger (Set-based, multi-row safe)
CREATE OR ALTER TRIGGER dbo.trg_product_price_audit
ON dbo.product_price
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT UPDATE(selling_price) RETURN;

    INSERT INTO dbo.price_audit (product_id, old_price, new_price, changed_by, changed_at)
    SELECT 
        i.product_id,
        d.selling_price,
        i.selling_price,
        ORIGINAL_LOGIN(),
        SYSDATETIME()
    FROM inserted i
    JOIN deleted d ON i.product_id = d.product_id
    WHERE i.selling_price <> d.selling_price;
END;
GO

-- 2. INSTEAD OF UPDATE trigger blocking prices below cost and logging attempts
CREATE OR ALTER TRIGGER dbo.trg_product_price_guard
ON dbo.product_price
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Log any rejected attempts where new selling_price < cost_price
    IF EXISTS (SELECT 1 FROM inserted WHERE selling_price < cost_price)
    BEGIN
        INSERT INTO dbo.rejected_price_attempts (product_id, attempted_price, cost_price, attempted_by, attempted_at)
        SELECT product_id, selling_price, cost_price, ORIGINAL_LOGIN(), SYSDATETIME()
        FROM inserted
        WHERE selling_price < cost_price;

        THROW 53001, 'Price update rejected: selling price cannot be lower than cost price.', 1;
    END

    -- Apply valid updates
    UPDATE pp
    SET pp.selling_price = i.selling_price,
        pp.cost_price = i.cost_price
    FROM dbo.product_price pp
    JOIN inserted i ON pp.product_id = i.product_id;
END;
GO