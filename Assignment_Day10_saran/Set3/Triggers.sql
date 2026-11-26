-- 1. Trigger blocking admissions when ward occupied beds >= capacity
CREATE OR ALTER TRIGGER dbo.trg_check_ward_capacity
ON dbo.admissions
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Update occupied count based on newly inserted active admissions
    UPDATE w
    SET w.occupied_beds = w.occupied_beds + inc.new_count
    FROM dbo.wards w
    JOIN (
        SELECT ward_id, COUNT(*) AS new_count
        FROM inserted
        WHERE status = 'Admitted'
        GROUP BY ward_id
    ) inc ON w.ward_id = inc.ward_id;

    -- Block if any ward now exceeds its capacity
    IF EXISTS (
        SELECT 1 FROM dbo.wards WHERE occupied_beds > capacity
    )
    BEGIN
        THROW 55001, 'Admission blocked: Ward has reached maximum bed capacity.', 1;
    END
END;
GO

-- 2. AFTER trigger recording all INSERT, UPDATE, and DELETE events into admission_audit
CREATE OR ALTER TRIGGER dbo.trg_admission_audit
ON dbo.admissions
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.admission_audit (admission_id, patient_id, ward_id, operation_type, old_status, new_status, audited_by, audited_at)
    SELECT 
        COALESCE(i.admission_id, d.admission_id),
        COALESCE(i.patient_id, d.patient_id),
        COALESCE(i.ward_id, d.ward_id),
        CASE 
            WHEN i.admission_id IS NOT NULL AND d.admission_id IS NOT NULL THEN 'UPDATE'
            WHEN i.admission_id IS NOT NULL THEN 'INSERT'
            ELSE 'DELETE'
        END,
        d.status,
        i.status,
        ORIGINAL_LOGIN(),
        SYSDATETIME()
    FROM inserted i
    FULL OUTER JOIN deleted d ON i.admission_id = d.admission_id;
END;
GO