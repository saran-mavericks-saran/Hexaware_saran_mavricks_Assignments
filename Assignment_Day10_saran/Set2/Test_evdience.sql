-- Seed 5 savings accounts
INSERT INTO dbo.accounts (account_id, account_type, balance)
VALUES (101, 'Savings', 500), (102, 'Savings', 300), (103, 'Savings', 100), (104, 'Savings', 800), (105, 'Savings', 400);

-- Batch update deducting 150 from all 5 accounts (Account 103 becomes -50, violating the rule)
BEGIN TRY
    UPDATE dbo.vw_accounts
    SET balance = balance - 150
    WHERE account_id IN (101, 102, 103, 104, 105);
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS ErrNum, ERROR_MESSAGE() AS ErrMsg;
END CATCH;

-- Outcome check: All 5 accounts retain their original balances (500, 300, 100, 800, 400)
-- because SQL Server statements are atomic and THROW aborts the entire batch.
SELECT * FROM dbo.accounts;