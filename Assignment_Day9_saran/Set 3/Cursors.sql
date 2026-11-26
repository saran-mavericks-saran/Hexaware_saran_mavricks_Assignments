SET STATISTICS TIME ON;

-- 4a. Cursor approach
DECLARE @sub_id INT, @bal DECIMAL(10,2);
DECLARE cur_low_bal CURSOR LOCAL FAST_FORWARD FOR
    SELECT subscriber_id, balance
    FROM dbo.subscribers
    WHERE plan_type = 'Prepaid' AND balance < 50;

OPEN cur_low_bal;
FETCH NEXT FROM cur_low_bal INTO @sub_id, @bal;

WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO dbo.notifications (subscriber_id, message, is_read, created_at)
    VALUES (@sub_id, CONCAT('Low balance alert: ', @bal, ' remaining.'), 0, GETDATE());

    FETCH NEXT FROM cur_low_bal INTO @sub_id, @bal;
END
CLOSE cur_low_bal;
DEALLOCATE cur_low_bal;

-- 4b. Set-based INSERT...SELECT
INSERT INTO dbo.notifications (subscriber_id, message, is_read, created_at)
SELECT 
    subscriber_id,
    CONCAT('Low balance alert: ', balance, ' remaining.'),
    0,
    GETDATE()
FROM dbo.subscribers
WHERE plan_type = 'Prepaid' AND balance < 50;

SET STATISTICS TIME OFF;
GO