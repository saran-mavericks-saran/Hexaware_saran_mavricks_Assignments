-- 1. Atomic Seat Booking Procedure
CREATE OR ALTER PROCEDURE sp_BookSeat
    @FlightID INT,
    @SeatNo VARCHAR(5),
    @PassengerName NVARCHAR(100),
    @Fare DECIMAL(10, 2)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (
            SELECT 1 FROM Seats WITH (UPDLOCK, HOLDLOCK)
            WHERE FlightID = @FlightID AND SeatNo = @SeatNo AND Status = 'AVAILABLE'
        )
            THROW 51001, 'Seat is already booked or does not exist.', 1;

        UPDATE Seats
        SET Status = 'BOOKED'
        WHERE FlightID = @FlightID AND SeatNo = @SeatNo;

        INSERT INTO Bookings (FlightID, SeatNo, PassengerName, Fare, BookingDate)
        VALUES (@FlightID, @SeatNo, @PassengerName, @Fare, GETDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- 2. Ranked Report + Running Total via CTE (Tasks 3 & 4)
WITH FlightFareCTE AS (
    SELECT 
        FlightID,
        PassengerName,
        Fare,
        BookingDate,
        RANK() OVER (PARTITION BY FlightID ORDER BY Fare DESC) AS FareRank,
        DENSE_RANK() OVER (PARTITION BY FlightID ORDER BY Fare DESC) AS DenseFareRank,
        SUM(Fare) OVER (
            PARTITION BY FlightID 
            ORDER BY BookingDate, BookingID 
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS RunningFlightRevenue
    FROM Bookings
)
SELECT * FROM FlightFareCTE
ORDER BY FlightID, FareRank;
GO