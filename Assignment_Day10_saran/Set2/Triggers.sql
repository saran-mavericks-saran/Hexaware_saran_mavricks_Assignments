-- 1. AFTER INSERT/UPDATE/DELETE audit trigger on account_transaction
CREATE OR ALTER TRIGGER dbo.trg_account_transaction_audit
ON dbo.account_transaction
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.transaction_audit (txn_id, account_id, action_type, old_amount, new_amount, changed_by, changed_at)
    SELECT 
        COALESCE(i.txn_id, d.txn_id),
        COALESCE(i.account_id, d.account_id),
        CASE 
            WHEN i.txn_id IS NOT NULL AND d.txn_id IS NOT NULL THEN 'UPDATE'
            WHEN i.txn_id IS NOT NULL THEN 'INSERT'
            ELSE 'DELETE'
        END,
        d.amount,
        i.amount,
        ORIGINAL_LOGIN(),
        SYSDATETIME()
    FROM inserted i
    FULL OUTER JOIN deleted d ON i.txn_id = d.txn_id;
END;
GO

-- View on accounts
CREATE OR ALTER VIEW dbo.vw_accounts AS
SELECT account_id, account_type, balance FROM dbo.accounts;
GO

-- 2. INSTEAD OF UPDATE trigger on vw_accounts preventing negative savings balance
CREATE OR ALTER TRIGGER dbo.trg_vw_accounts_balance_guard
ON dbo.vw_accounts
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1 
        FROM inserted 
        WHERE account_type = 'Savings' AND balance < 0
    )
    BEGIN
        THROW 54001, 'Transaction blocked: Savings account balance cannot go negative.', 1;
    END

    UPDATE a
    SET a.balance = i.balance,
        a.account_type = i.account_type
    FROM dbo.accounts a
    JOIN inserted i ON a.account_id = i.account_id;
END;
GO