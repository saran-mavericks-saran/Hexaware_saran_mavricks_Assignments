-- 4a. Cursor approach
DECLARE @policy_id INT;
DECLARE cur_lapsed CURSOR LOCAL FAST_FORWARD FOR
    SELECT policy_id FROM dbo.policies
    WHERE status = 'Active' AND expiry_date < CAST(GETDATE() AS DATE);

OPEN cur_lapsed;
FETCH NEXT FROM cur_lapsed INTO @policy_id;

WHILE @@FETCH_STATUS = 0
BEGIN
    UPDATE dbo.policies SET status = 'Lapsed' WHERE policy_id = @policy_id;

    INSERT INTO dbo.policy_audit (policy_id, action_taken, action_date)
    VALUES (@policy_id, 'Marked Lapsed', GETDATE());

    FETCH NEXT FROM cur_lapsed INTO @policy_id;
END
CLOSE cur_lapsed;
DEALLOCATE cur_lapsed;
GO

-- 4b. Set-based rewrite using OUTPUT clause
UPDATE dbo.policies
SET status = 'Lapsed'
OUTPUT inserted.policy_id, 'Marked Lapsed', GETDATE()
INTO dbo.policy_audit (policy_id, action_taken, action_date)
WHERE status = 'Active'
  AND expiry_date < CAST(GETDATE() AS DATE);
GO