-- 1a. View hiding postpaid users (row-level filtering)
CREATE OR ALTER VIEW dbo.vw_prepaid_subscribers AS
SELECT 
    subscriber_id,
    msisdn,
    full_name,
    balance,
    plan_expiry_date
FROM dbo.subscribers
WHERE plan_type = 'Prepaid'
WITH CHECK OPTION;
GO

-- 1b. Recharge summary view
CREATE OR ALTER VIEW dbo.vw_recharge_summary AS
SELECT 
    s.subscriber_id,
    s.msisdn,
    COUNT(r.recharge_id) AS total_recharges,
    ISNULL(SUM(r.amount), 0) AS total_amount_recharged,
    MAX(r.recharge_date) AS last_recharge_date
FROM dbo.subscribers s
LEFT JOIN dbo.recharge_history r ON s.subscriber_id = r.subscriber_id
WHERE s.plan_type = 'Prepaid'
GROUP BY s.subscriber_id, s.msisdn;
GO