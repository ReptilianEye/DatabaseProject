BEGIN
    CREATE TRIGGER WebinarMeetingsValidateDate
        ON WebinarMeetings
        AFTER INSERT,
        UPDATE
        AS
    BEGIN
        IF
            EXISTS (SELECT 1 FROM inserted WHERE ISDATE(date) = 0)
            BEGIN
                THROW
                    50000, 'Invalid date format. Please use the format YYYY-MM-DD HH:mm:ss.', 1;
                ROLLBACK;
            END;
        IF
            EXISTS (SELECT 1 FROM inserted WHERE date < GETDATE())
            BEGIN
                THROW
                    50000, 'Date is in the past', 1;
                ROLLBACK;
            END;
    END;
END


BEGIN
    CREATE TRIGGER CourseMeetingsValidateDate
        ON Meetings
        AFTER INSERT,
        UPDATE
        AS
    BEGIN
        IF
            EXISTS (SELECT 1 FROM inserted WHERE ISDATE(date) = 0)
            BEGIN
                THROW
                    50000, 'Invalid date format. Please use the format YYYY-MM-DD HH:mm:ss.', 1;
                ROLLBACK;
            END;
        IF
            EXISTS (SELECT 1 FROM inserted WHERE date < GETDATE())
            BEGIN
                THROW
                    50000, 'Date is in the past', 1;
                ROLLBACK;
            END;
    END;
END


BEGIN
    CREATE TRIGGER StudiesMeetingsValidateDate
        ON StudiesMeetings
        AFTER INSERT,
        UPDATE
        AS
    BEGIN
        IF
            EXISTS (SELECT 1 FROM inserted WHERE ISDATE(date) = 0)
            BEGIN
                THROW
                    50000, 'Invalid date format. Please use the format YYYY-MM-DD HH:mm:ss.', 1;
                ROLLBACK;
            END;
        IF
            EXISTS (SELECT 1 FROM inserted WHERE date < GETDATE())
            BEGIN
                THROW
                    50000, 'Date is in the past', 1;
                ROLLBACK;
            END;
    END;
END


BEGIN
    CREATE TRIGGER CourseAttendanceValidateDate
        ON Attendance
        AFTER INSERT
        AS
    BEGIN
        IF
            EXISTS (SELECT *
                    FROM inserted i
                             INNER JOIN Meetings m ON m.meetingId = i.meetingId
                    WHERE m.date > GETDATE())
            BEGIN
                THROW
                    50000, 'You can not add attendance for future meetings', 1;
            END
    END
END


BEGIN
    CREATE TRIGGER StudiesAttendanceValidateDate
        ON StudiesAttendance
        AFTER INSERT
        AS
    BEGIN
        IF
            EXISTS (SELECT *
                    FROM inserted i
                             INNER JOIN StudiesMeetings m ON m.studiesMeetingId = i.studiesMeetingId
                    WHERE m.date > GETDATE())
            BEGIN
                THROW
                    50000, 'You can not add attendance for future meetings', 1;
            END
    END
END


BEGIN
    CREATE TRIGGER CheckSlotsLimitStudies
        ON Students
        AFTER INSERT
        AS
    BEGIN
        IF
            EXISTS (SELECT s.studiesId
                    FROM Studies s
                             JOIN (SELECT studiesId, COUNT(*) AS CurrentUsage
                                   FROM inserted
                                   GROUP BY studiesId) i ON s.studiesId = i.studiesId
                    WHERE s.slotsLimit < i.CurrentUsage)
            BEGIN
                THROW
                    50000, 'Slots limit exceeded after insert into Studies table', 1;
            END
    END;
END


BEGIN
    CREATE TRIGGER ifPrepareCourseDiploma
        ON Attendance
        AFTER INSERT
        AS
    BEGIN
        DECLARE
            @meetingId int = (SELECT meetingId FROM inserted)
        DECLARE
            @courseId int = (SELECT C.courseId
                             FROM Courses C
                                      INNER JOIN dbo.Modules M ON C.courseId = M.courseId
                                      INNER JOIN OnlineMeetings OnM ON M.moduleId = OnM.moduleId
                             WHERE OnM.meetingId = @meetingId
                             UNION
                             SELECT C.courseId
                             FROM Courses C
                                      INNER JOIN dbo.Modules M ON C.courseId = M.courseId
                                      INNER JOIN OfflineMeetings OfM ON M.moduleId = OfM.moduleId
                             WHERE OfM.meetingId = @meetingId)
        DECLARE
            @userId int = (SELECT userId FROM inserted)
        IF dbo.courseAttendancePercent(@courseId, @userId) >= 0.8
            BEGIN
                EXEC diplomaInfo @userId
            END
    END
END


BEGIN
    CREATE TRIGGER NoSlotsAvailable
        ON Cart
        AFTER
            INSERT AS
    BEGIN
        DECLARE
            @educationFormId int = (SELECT educationFormId
                                    FROM inserted)
        IF dbo.areFreeSlotsAvailable(@educationFormId) = 0
            BEGIN
                THROW
                    50000, 'No free slots available', 1
                ROLLBACK TRANSACTION
            END
    END
END


BEGIN
    CREATE TRIGGER OnCartPayed
        ON PaymentsHistory
        AFTER INSERT AS
    BEGIN
        DECLARE
            @userId int = (SELECT userId
                           FROM inserted)
        EXEC FinalizeCart @userId
    END
END