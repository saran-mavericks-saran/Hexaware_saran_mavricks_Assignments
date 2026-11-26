-- 2. Stored Procedure: usp_RenewPolicy
CREATE OR ALTER PROCEDURE dbo.usp_RenewPolicy
    @policy_id INT,
    @no_claim_years INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @status VARCHAR(20), @base_premium DECIMAL(10,2), @new_premium DECIMAL(10,2);

        SELECT @status = status, @base_premium = premium_amount
        FROM dbo.policies WITH (UPDLOCK)
        WHERE policy_id = @policy_id;

        IF @status <> 'Active'
            THROW 51001, 'Only active policies can be renewed.', 1;

        IF EXISTS (SELECT 1 FROM dbo.claims WHERE policy_id = @policy_id AND claim_status = 'Pending')
            THROW 51002, 'Policy cannot be renewed while a claim is pending.', 1;

        SET @new_premium = dbo.fn_PremiumWithNoClaimDiscount(@base_premium, @no_claim_years);

        UPDATE dbo.policies
        SET premium_amount = @new_premium,
            expiry_date = DATEADD(YEAR, 1, expiry_date),
            last_renewed_date = GETDATE()
        WHERE policy_id = @policy_id;

        INSERT INTO dbo.policy_audit (policy_id, old_premium, new_premium, action_taken, action_date)
        VALUES (@policy_id, @base_premium, @new_premium, 'Renewed', GETDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- 3a. Scalar Function: fn_PremiumWithNoClaimDiscount
CREATE OR ALTER FUNCTION dbo.fn_PremiumWithNoClaimDiscount
(
    @base_premium DECIMAL(10,2),
    @no_claim_years INT
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @discount_pct DECIMAL(4,2) = CASE 
        WHEN @no_claim_years >= 5 THEN 0.20
        WHEN @no_claim_years >= 3 THEN 0.10
        WHEN @no_claim_years >= 1 THEN 0.05
        ELSE 0.00
    END;

    RETURN @base_premium * (1 - @discount_pct);
END;
GO

-- 3b. Table-Valued Function: Agent Renewal Quotes
CREATE OR ALTER FUNCTION dbo.fn_AgentRenewalQuotes (@agent_id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        p.policy_id,
        p.policy_number,
        c.full_name AS customer_name,
        p.premium_amount AS current_premium,
        dbo.fn_PremiumWithNoClaimDiscount(p.premium_amount, p.no_claim_years) AS quoted_renewal_premium,
        p.expiry_date
    FROM dbo.policies p
    JOIN dbo.customers c ON p.customer_id = c.customer_id
    WHERE p.agent_id = @agent_id
      AND p.status = 'Active'
      AND p.expiry_date <= DATEADD(DAY, 30, GETDATE())
);
GO