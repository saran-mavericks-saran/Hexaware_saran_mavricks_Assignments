-- Excludes sensitive columns (e.g., ssn, bank_account, medical_history)
CREATE OR ALTER VIEW dbo.vw_policy_due AS
SELECT 
    p.policy_id,
    p.policy_number,
    p.policy_type,
    p.premium_amount,
    p.expiry_date,
    c.customer_id,
    c.full_name,
    c.email,
    c.phone
FROM dbo.policies p
JOIN dbo.customers c ON p.customer_id = c.customer_id
WHERE p.status = 'Active'
  AND p.expiry_date BETWEEN CAST(GETDATE() AS DATE) AND DATEADD(DAY, 30, CAST(GETDATE() AS DATE));
GO