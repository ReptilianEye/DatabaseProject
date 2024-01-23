BEGIN
    CREATE TRIGGER NoSlotsAvailable
        ON Cart
        AFTER
            INSERT AS
    BEGIN
        DECLARE @educationFormId int = (SELECT educationFormId
                                        FROM inserted)
        IF dbo.areFreeSlotsAvailable(@educationFormId) = 0
            BEGIN
                THROW 50000, 'No free slots available', 1
                ROLLBACK TRANSACTION
            END
    END
END
BEGIN
    CREATE TRIGGER OnCartPayed
        ON PaymentsHistory
        AFTER INSERT AS
    BEGIN
        DECLARE @userId int = (SELECT userId
                               FROM inserted)
        EXEC FinalizeCart @userId
    END
END
