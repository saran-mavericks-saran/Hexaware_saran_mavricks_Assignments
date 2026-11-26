------CREATE DATABASE BankPracticeDB;

------USE BankPracticeDB;

------CREATE TABLE Accounts (
------    AccountID INT PRIMARY KEY,
------    HolderName NVARCHAR(100) NOT NULL,
------    Balance DECIMAL(12, 2) NOT NULL CHECK (Balance >= 0),
------    Status NVARCHAR(20) NOT NULL DEFAULT 'ACTIVE' -- 'ACTIVE' or 'FROZEN'
------);

------CREATE TABLE AccountTransactions (
------    TxnID INT IDENTITY(1,1) PRIMARY KEY,
------    AccountID INT NOT NULL FOREIGN KEY REFERENCES Accounts(AccountID),
------    TxnDate DATETIME2 NOT NULL DEFAULT GETDATE(),
------    TxnType NVARCHAR(20) NOT NULL, -- 'DEBIT', 'CREDIT', 'FEE'
------    Amount DECIMAL(12, 2) NOT NULL,
------    BalanceAfter DECIMAL(12, 2) NOT NULL
------);

------INSERT INTO Accounts (AccountID, HolderName, Balance, Status) VALUES
------(101, 'Aarav Sharma', 5000.00, 'ACTIVE'),
------(102, 'Priya Patel', 2000.00, 'ACTIVE'),
------(103, 'Rohan Verma', 1500.00, 'FROZEN');

------INSERT INTO AccountTransactions (AccountID, TxnDate, TxnType, Amount, BalanceAfter) VALUES
------(101, DATEADD(DAY, -10, GETDATE()), 'CREDIT', 6000.00, 6000.00),
------(101, DATEADD(DAY, -5, GETDATE()),  'DEBIT',  1000.00, 5000.00),
------(102, DATEADD(DAY, -8, GETDATE()),  'CREDIT', 2000.00, 2000.00);

----USE BankPracticeDB;
----GO

------ TASK 1: Atomic Funds Transfer with Validation
----CREATE OR ALTER PROCEDURE sp_TransferFunds
----    @FromAccount INT,
----    @ToAccount INT,
----    @Amount DECIMAL(12, 2),
----    @SimulateCrashAfterDebit BIT = 0, -- Used for Task 2
----    @FeeAmount DECIMAL(12, 2) = 0,    -- Used for Task 3
----    @FailFeeStep BIT = 0              -- Used for Task 3
----AS
----BEGIN
----    SET NOCOUNT ON;
----    SET XACT_ABORT ON;

----    BEGIN TRY
----        BEGIN TRANSACTION;

----        -- 1. Validate source account status and balance
----        DECLARE @FromBalance DECIMAL(12, 2), @FromStatus NVARCHAR(20);
----        SELECT @FromBalance = Balance, @FromStatus = Status
----        FROM Accounts WITH (UPDLOCK) -- Locks row to prevent concurrent double-spend
----        WHERE AccountID = @FromAccount;

----        IF @FromStatus IS NULL
----            THROW 50001, 'Source account does not exist.', 1;
----        IF @FromStatus <> 'ACTIVE'
----            THROW 50002, 'Source account is not ACTIVE.', 1;
----        IF @FromBalance < @Amount
----            THROW 50003, 'Insufficient balance in source account.', 1;

----        -- 2. Validate destination account status
----        DECLARE @ToStatus NVARCHAR(20);
----        SELECT @ToStatus = Status FROM Accounts WITH (UPDLOCK) WHERE AccountID = @ToAccount;
----        IF @ToStatus IS NULL OR @ToStatus <> 'ACTIVE'
----            THROW 50004, 'Destination account is invalid or inactive.', 1;

----        -- 3. Debit source account
----        UPDATE Accounts SET Balance = Balance - @Amount WHERE AccountID = @FromAccount;
----        INSERT INTO AccountTransactions (AccountID, TxnType, Amount, BalanceAfter)
----        SELECT @FromAccount, 'DEBIT', @Amount, Balance FROM Accounts WHERE AccountID = @FromAccount;

----        -- TASK 2: Deliberate failure after debit to prove full rollback
----        IF @SimulateCrashAfterDebit = 1
----            THROW 50005, 'Simulated network/system failure after debit!', 1;

----        -- 4. Credit destination account
----        UPDATE Accounts SET Balance = Balance + @Amount WHERE AccountID = @ToAccount;
----        INSERT INTO AccountTransactions (AccountID, TxnType, Amount, BalanceAfter)
----        SELECT @ToAccount, 'CREDIT', @Amount, Balance FROM Accounts WHERE AccountID = @ToAccount;

----        -- TASK 3: Savepoint for optional fee-posting step
----        IF @FeeAmount > 0
----        BEGIN
----            SAVE TRANSACTION FeeSavepoint;
----            BEGIN TRY
----                UPDATE Accounts SET Balance = Balance - @FeeAmount WHERE AccountID = @FromAccount;
----                INSERT INTO AccountTransactions (AccountID, TxnType, Amount, BalanceAfter)
----                SELECT @FromAccount, 'FEE', @FeeAmount, Balance FROM Accounts WHERE AccountID = @FromAccount;

----                IF @FailFeeStep = 1
----                    THROW 50006, 'Fee posting service unavailable.', 1;
----            END TRY
----            BEGIN CATCH
----                -- Roll back ONLY to the savepoint; keep the main transfer intact
----                ROLLBACK TRANSACTION FeeSavepoint;
----                PRINT 'Warning: Fee step failed and rolled back to savepoint; transfer preserved.';
----            END CATCH
----        END

----        COMMIT TRANSACTION;
----        PRINT 'Transfer committed successfully.';
----    END TRY
----    BEGIN CATCH
----        IF @@TRANCOUNT > 0
----            ROLLBACK TRANSACTION;
----        PRINT 'Transaction rolled back due to error: ' + ERROR_MESSAGE();
----        THROW; -- Re-throw error to caller
----    END CATCH
----END;
----GO

------ === EXECUTION & EVIDENCE ===
------ A. Task 2 Proof: Run with @SimulateCrashAfterDebit = 1
----SELECT * FROM Accounts WHERE AccountID IN (101, 102); -- Before: 5000.00 and 2000.00
----BEGIN TRY
----    EXEC sp_TransferFunds @FromAccount = 101, @ToAccount = 102, @Amount = 500.00, @SimulateCrashAfterDebit = 1;
----END TRY
----BEGIN CATCH
----    PRINT 'Caught expected failure: ' + ERROR_MESSAGE();
----END CATCH
----SELECT * FROM Accounts WHERE AccountID IN (101, 102); -- After: Still 5000.00 and 2000.00!

------ B. Task 3 Proof: Transfer 500.00 succeeds, 25.00 fee fails and rolls back to savepoint
----EXEC sp_TransferFunds @FromAccount = 101, @ToAccount = 102, @Amount = 500.00, @FeeAmount = 25.00, @FailFeeStep = 1;
----SELECT * FROM Accounts WHERE AccountID IN (101, 102); -- Result: 4500.00 and 2500.00 (no 25.00 fee deducted)
----GO


--USE BankPracticeDB;
--GO

--WITH MonthlyStatementCTE AS (
--    SELECT 
--        t.AccountID,
--        a.HolderName,
--        t.TxnID,
--        t.TxnDate,
--        t.TxnType,
--        t.Amount,
--        -- Look back 1 row within the same AccountID ordered by TxnDate/TxnID
--        LAG(t.BalanceAfter, 1, 0.00) OVER (
--            PARTITION BY t.AccountID 
--            ORDER BY t.TxnDate, t.TxnID
--        ) AS PreviousBalance,
--        t.BalanceAfter AS ClosingBalance,
--        ROW_NUMBER() OVER (
--            PARTITION BY t.AccountID 
--            ORDER BY t.TxnDate, t.TxnID
--        ) AS StatementLineNo
--    FROM AccountTransactions t
--    INNER JOIN Accounts a ON t.AccountID = a.AccountID
--    WHERE t.TxnDate >= DATEADD(MONTH, -1, GETDATE())
--)
--SELECT 
--    AccountID,
--    HolderName,
--    StatementLineNo,
--    TxnDate,
--    TxnType,
--    PreviousBalance,
--    Amount,
--    ClosingBalance
--FROM MonthlyStatementCTE
--ORDER BY AccountID, StatementLineNo;
--GO











