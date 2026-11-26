-- Setup sample data
INSERT INTO dbo.product_price (product_id, cost_price, selling_price)
VALUES (1, 50.00, 80.00), (2, 100.00, 150.00), (3, 30.00, 45.00);

-- Test 1: Single-row valid update
UPDATE dbo.product_price SET selling_price = 85.00 WHERE product_id = 1;

-- Test 2: Multi-row valid update
UPDATE dbo.product_price SET selling_price = selling_price + 5.00 WHERE product_id IN (2, 3);

-- Verify audit table (shows 3 rows logged with old/new prices)
SELECT * FROM dbo.price_audit;

-- Test 3: Multi-row update where one row violates cost price (cost = 100, new price = 90)
BEGIN TRY
    UPDATE dbo.product_price 
    SET selling_price = CASE WHEN product_id = 2 THEN 90.00 ELSE 95.00 END
    WHERE product_id IN (1, 2);
END TRY
BEGIN CATCH
    PRINT ERROR_MESSAGE(); -- Prints error 53001; entire batch rolled back
END CATCH;