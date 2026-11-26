-- Setup ward with capacity 2 and 1 occupied bed (1 bed remaining)
INSERT INTO dbo.wards (ward_id, ward_name, capacity, occupied_beds)
VALUES (10, 'ICU', 2, 1);

-- Multi-row insert of 2 patients into Ward 10 (total becomes 3 > capacity 2)
BEGIN TRY
    INSERT INTO dbo.admissions (admission_id, patient_id, ward_id, status)
    VALUES 
        (1001, 501, 10, 'Admitted'),
        (1002, 502, 10, 'Admitted');
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS ErrorCode, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;

-- Verify rollback: occupied_beds remains 1, and neither 1001 nor 1002 exists in admissions or admission_audit
SELECT * FROM dbo.wards WHERE ward_id = 10;
SELECT * FROM dbo.admissions WHERE ward_id = 10;