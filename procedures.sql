BEGIN
    CREATE PROCEDURE AssignTranslatorToEducationForm(@translatorId int, @educationFormId int) AS
    BEGIN
        IF NOT EXISTS (SELECT * FROM Translators WHERE TranslatorId = @translatorId)
            BEGIN
                THROW 50000, 'Translator does not exist', 1;
            END
        IF NOT EXISTS (SELECT * FROM EducationForms WHERE EducationFormId = @educationFormId)
            BEGIN
                THROW 50000, 'Education form does not exist', 1;
            END
        ELSE
            INSERT INTO EducationFormsTranslators (TranslatorId, EducationFormId)
            VALUES (@translatorId, @educationFormId)
    END
END

BEGIN
    CREATE PROCEDURE CreateEducationForm(@specificId int, @type nvarchar(50), @price money, @wholePriceDueDate date,
                                         @advanceDueDays int, @advance money, @accessFor int) AS
    BEGIN
        DECLARE @educationFormId int = dbo.nextEducationFormId()
        INSERT INTO EducationForms (educationFormId, specificId, type)
        VALUES (@educationFormId, @specificId, @type)
        EXEC AddEducationFormPaymentsDetails @educationFormId, @advanceDueDays, @advance, @price, @accessFor,
             @wholePriceDueDate
    END
END
BEGIN
    CREATE PROCEDURE CreateCourse(@title nvarchar(50), @slotsLimit int, @price money, @wholePriceDueDate datetime,
                                  @advanceDueDays int, @advance money, @accessFor int) AS
    BEGIN
        DECLARE @courseId int = dbo.nextCourseId()

        INSERT INTO Courses (courseId, title, slotsLimit)
        VALUES (9999, @title, @slotsLimit)

        EXEC CreateEducationForm 9999, 'Course', @price, @wholePriceDueDate, @advanceDueDays, @advance,
             @accessFor
    END
END
BEGIN
    CREATE PROCEDURE CreateModule(@title nvarchar(50), @courseId int, @type varchar(20)) AS
        IF @type NOT IN ('stationary', 'onlineSync', 'onlineAsync', 'hybrid')
            BEGIN
                THROW 50000, 'Invalid module type', 1;
            END
        IF NOT EXISTS (SELECT * FROM Courses WHERE courseId = @courseId)
            BEGIN
                THROW 50000, 'Course does not exist', 1;
            END
    DECLARE @moduleId int = dbo.nextCourseModuleId()
    INSERT INTO Modules (moduleId, title, courseId)
    VALUES (@moduleId, @title, @courseId)
        IF @type = 'stationary'
            BEGIN
                INSERT INTO StationaryModules (moduleId) VALUES (@moduleId)
                RETURN
            END
        IF @type = 'onlineSync'
            BEGIN
                INSERT INTO OnlineSyncModules (moduleId) VALUES (@moduleId)
                RETURN
            END
        IF @type = 'onlineAsync'
            BEGIN
                INSERT INTO OnlineAsyncModules (moduleId) VALUES (@moduleId)
                RETURN
            END
        IF @type = 'hybrid'
            BEGIN
                INSERT INTO HybridModules (moduleId) VALUES (@moduleId)
                RETURN
            END
END
BEGIN
    CREATE PROCEDURE CreateStationaryModule(@title nvarchar(50), @courseId int) AS
    BEGIN
        EXEC CreateModule @title, @courseId, 'stationary'
    END
END
BEGIN
    CREATE PROCEDURE CreateOnlineSyncModule(@title nvarchar(50), @courseId int) AS
    BEGIN
        EXEC CreateModule @title, @courseId, 'onlineSync'
    END
END
BEGIN
    CREATE PROCEDURE CreateOnlineAsyncModule(@title nvarchar(50), @courseId int) AS
    BEGIN
        EXEC CreateModule @title, @courseId, 'onlineAsync'
    END
END
BEGIN
    CREATE PROCEDURE CreateHybridModule(@title nvarchar(50), @courseId int) AS
    BEGIN
        EXEC CreateModule @title, @courseId, 'hybrid'
    END
END
BEGIN
    CREATE PROCEDURE SaveOfflineMeeting(@moduleId int, @date datetime, @duration int, @place varchar(255),
                                        @room varchar(20)) AS
    BEGIN
        IF NOT EXISTS (SELECT * FROM Modules WHERE moduleId = @moduleId)
            BEGIN
                THROW 50000, 'Module does not exist', 1;
            END
        IF NOT EXISTS (SELECT * FROM StationaryModules WHERE moduleId = @moduleId) AND
           NOT EXISTS (SELECT * FROM HybridModules WHERE moduleId = @moduleId)
            BEGIN
                THROW 50000, 'Module is not stationary or hybrid', 1;
            END
        IF (SELECT COUNT(*)
            FROM Meetings M
                     JOIN OfflineMeetings OM ON M.meetingId = OM.meetingId
            WHERE dbo.doesDatesOverlap(M.date, M.date, DATEADD(MINUTE, duration, M.date), @date, @date,
                                       DATEADD(MINUTE, @duration, @date)) = 1) > 0
            BEGIN
                THROW 50000, 'Meeting overlaps with another meeting', 1;
            END

        DECLARE @meetingId int = dbo.nextMeetingId()
        INSERT INTO Meetings (meetingId, date, duration) VALUES (@meetingId, @date, @duration)
        INSERT INTO OfflineMeetings (meetingId, moduleId, place, room)
        VALUES (@meetingId, @moduleId, @place, @room)
    END
END
BEGIN
    CREATE PROCEDURE SaveOnlineMeeting(@moduleId int, @date datetime, @duration int, @link varchar(255)) AS
        IF NOT EXISTS (SELECT * FROM Modules WHERE moduleId = @moduleId)
            BEGIN
                THROW 50000, 'Module does not exist', 1;
            END
        IF NOT EXISTS (SELECT * FROM OnlineSyncModules WHERE moduleId = @moduleId) AND
           NOT EXISTS (SELECT * FROM HybridModules WHERE moduleId = @moduleId)
            BEGIN
                THROW 50000, 'Module is not onlineSync or hybrid', 1;
            END
        IF (SELECT COUNT(*)
            FROM Meetings M
                     JOIN OfflineMeetings OM ON M.meetingId = OM.meetingId
            WHERE dbo.doesDatesOverlap(M.date, M.date, DATEADD(MINUTE, duration, M.date), @date, @date,
                                       DATEADD(MINUTE, @duration, @date)) = 1) > 0
            BEGIN
                THROW 50000, 'Meeting overlaps with another meeting', 1;
            END
    DECLARE @meetingId int = dbo.nextMeetingId()
    INSERT INTO Meetings (meetingId, date) VALUES (@meetingId, @date)
    INSERT INTO OnlineMeetings (meetingId, moduleId, link) VALUES (@meetingId, @moduleId, @link)
END
BEGIN
    CREATE PROCEDURE AddRecording(@moduleId int, @link varchar(255)) AS
        IF NOT EXISTS (SELECT * FROM Modules WHERE moduleId = @moduleId)
            BEGIN
                THROW 50000, 'Module does not exist', 1;
            END
        IF NOT EXISTS(SELECT * FROM OnlineAsyncModules WHERE moduleId = @moduleId)
            BEGIN
                THROW 50000, 'Module is not onlineAsync', 1;
            END
    INSERT INTO Recordings (recordingId, moduleId, link) VALUES (dbo.nextRecordingId(), @moduleId, @link)
END
BEGIN
    CREATE PROCEDURE SaveUserAttendance(@meetingId int, @userId int) AS
    BEGIN
        IF NOT EXISTS (SELECT * FROM Users WHERE userId = @userId)
            BEGIN
                THROW 50000, 'User does not exist', 1;
            END
        INSERT INTO Attendance (meetingId, userId) VALUES (@meetingId, @userId)
    END
END

BEGIN
    CREATE PROCEDURE SaveMeetingAttendance(@meetingId int, @students AS usersList READONLY) AS
    BEGIN
        IF NOT EXISTS (SELECT * FROM Meetings WHERE meetingId = @meetingId)
            BEGIN
                THROW 50000, 'Meeting does not exist', 1;
            END

        DECLARE @userId int
        DECLARE student_cursor CURSOR FOR SELECT userId FROM @students
        OPEN student_cursor
        FETCH NEXT FROM student_cursor INTO @userId
        WHILE @@FETCH_STATUS = 0
            BEGIN
                EXEC SaveUserAttendance @meetingId, @userId
                FETCH NEXT FROM student_cursor INTO @userId
            END
        CLOSE student_cursor
        DEALLOCATE student_cursor
    END
END
--example
-- DELETE
-- FROM Attendance
-- WHERE meetingId = 17
-- SELECT *
-- FROM Attendance
-- WHERE meetingId = 17
--
-- DECLARE @SL usersList;
-- INSERT INTO @SL (userId) (SELECT userId
--                           FROM Users
--                           WHERE userId < 10)
-- EXEC SaveMeetingAttendance 17, @SL
--
BEGIN
    CREATE PROCEDURE SaveUserWatchedRecording(@userId int, @recordingId int) AS
    BEGIN
        IF NOT EXISTS (SELECT * FROM Users WHERE userId = @userId)
            BEGIN
                THROW 50000, 'User does not exist', 1;
            END
        IF NOT EXISTS (SELECT * FROM Recordings WHERE recordingId = @recordingId)
            BEGIN
                THROW 50000, 'Recording does not exist', 1;
            END
        INSERT INTO WatchedBy (userId, recordingId) VALUES (@userId, @recordingId)
    END
END
BEGIN
    CREATE PROCEDURE CreateWebinar(@link varchar(255), @recordingLink varchar(255), @date datetime,
                                   @title nvarchar(50),
                                   @description varchar(255), @price money, @detailsId int=NULL) AS
    BEGIN
        DECLARE @meetingId int = dbo.nextWebinarMeetingId()
        IF @detailsId IS NOT NULL
            BEGIN
                INSERT INTO Webinars (webinarId, onlineMeetingId) VALUES (@detailsId, @meetingId)
            END
        ELSE
            BEGIN
                DECLARE @webinarId int = dbo.nextWebinarId()
                INSERT INTO Webinars (webinarId, onlineMeetingId) VALUES (@webinarId, @meetingId)
                INSERT INTO WebinarDetails (webinarId, title, description, price)
                VALUES (@webinarId, @title, @description, @price)
            END
        INSERT INTO WebinarMeetings (onlineMeetingId, link, recordingLink, date)
        VALUES (@meetingId, @link, @recordingLink, @date)
    END
END
BEGIN
    CREATE PROCEDURE UpdateWebinarRecordingLink(@webinarId int, @recordingLink varchar(255)) AS
        IF NOT EXISTS (SELECT * FROM Webinars WHERE webinarId = @webinarId)
            BEGIN
                THROW 50000, 'Webinar does not exist', 1;
            END
        IF @recordingLink IS NULL
            BEGIN
                THROW 50000, 'Link cannot be null', 1;
            END
    UPDATE WebinarMeetings
    SET recordingLink = @recordingLink
    WHERE onlineMeetingId = (SELECT onlineMeetingId FROM Webinars WHERE webinarId = @webinarId)
END
BEGIN
    CREATE PROCEDURE RemoveUserRole(@userId int, @roleName varchar) AS
    BEGIN
        IF NOT EXISTS (SELECT * FROM Users WHERE userId = @userId)
            BEGIN
                THROW 50000, 'User does not exist', 1;
            END
        IF NOT EXISTS (SELECT * FROM RoleDetails WHERE roleName = @roleName)
            BEGIN
                THROW 50000, 'Role does not exist', 1;
            END
        IF NOT EXISTS (SELECT *
                       FROM Roles
                       WHERE userId = @userId
                         AND roleId = (SELECT roleId FROM RoleDetails WHERE roleName = @roleName))
            BEGIN
                THROW 50000, 'User does not have the role', 1;
            END
        DELETE
        FROM Roles
        WHERE userId = @userId
          AND roleId = (SELECT roleId FROM RoleDetails WHERE roleName = @roleName)
    END
END
BEGIN
    CREATE PROCEDURE AssignRole(@userId int, @roleName varchar) AS
    BEGIN
        IF NOT EXISTS (SELECT * FROM Users WHERE userId = @userId)
            BEGIN
                THROW 50000, 'User does not exist', 1;
            END
        IF NOT EXISTS (SELECT * FROM RoleDetails WHERE roleName = @roleName)
            BEGIN
                PRINT 'Role does not exist'
                PRINT 'Correct roles are:'
                SELECT roleName FROM RoleDetails
                THROW 50000, 'Role does not exist', 1;
            END
        IF EXISTS (SELECT *
                   FROM Roles
                   WHERE userId = @userId)
            BEGIN
                THROW 50000, 'User already has the role', 1;
            END
        DECLARE @roleId int = (SELECT roleId FROM RoleDetails WHERE roleName = @roleName)
        INSERT INTO Roles (userId, roleId) VALUES (@userId, @roleId)
    END
END
BEGIN
    CREATE PROCEDURE AddPermissionToRole(@roleName varchar, @permission varchar) AS
    BEGIN
        IF NOT EXISTS (SELECT * FROM RoleDetails WHERE roleName = @roleName)
            BEGIN
                THROW 50000, 'Role does not exist', 1;
            END
        IF EXISTS (SELECT *
                   FROM Permissions
                   WHERE roleId = (SELECT roleId FROM RoleDetails WHERE roleName = @roleName)
                     AND permission = @permission)
            BEGIN
                THROW 50000, 'Role already has the permission', 1;
            END
        INSERT INTO Permissions (permissionId, roleId, permission)
        VALUES (dbo.nextPermissionId(), (SELECT roleId FROM RoleDetails WHERE roleName = @roleName), @permission)
    END
END
BEGIN
    CREATE PROCEDURE RemovePermissionFromRole(@roleName varchar, @permission varchar) AS
    BEGIN
        IF NOT EXISTS (SELECT * FROM RoleDetails WHERE roleName = @roleName)
            BEGIN
                THROW 50000, 'Role does not exist', 1;
            END
        IF NOT EXISTS (SELECT *
                       FROM Permissions
                       WHERE roleId = (SELECT roleId FROM RoleDetails WHERE roleName = @roleName)
                         AND permission = @permission)
            BEGIN
                THROW 50000, 'Role does not have the permission', 1;
            END
        DELETE
        FROM Permissions
        WHERE roleId = (SELECT roleId FROM RoleDetails WHERE roleName = @roleName)
          AND permission = @permission
    END
END

BEGIN
    CREATE PROCEDURE CreateExam(@studiesId int, @subjectId int) AS
    BEGIN
        IF NOT EXISTS (SELECT * FROM Studies WHERE studiesId = @studiesId)
            BEGIN
                THROW 50000, 'Studies does not exist', 1;
            END
        IF NOT EXISTS (SELECT * FROM Subjects WHERE subjectId = @subjectId)
            BEGIN
                THROW 50000, 'Subject does not exist', 1;
            END
        IF NOT EXISTS (SELECT * FROM Exams WHERE studiesId = @studiesId AND subjectId = @subjectId)
            BEGIN
                THROW 50000, 'Exam already exists', 1;
            END
        DECLARE @examId int = dbo.nextExamId()
        INSERT INTO Exams (examId, studiesId, subjectId)
        VALUES (@examId, @studiesId, @subjectId)
    END
END
BEGIN
    CREATE PROCEDURE SaveStudentExamGrade(@examId int, @userId int, @grade int) AS
    BEGIN
        IF NOT EXISTS (SELECT * FROM Exams WHERE examId = @examId)
            BEGIN
                THROW 50000, 'Exam does not exist', 1;
            END
        IF NOT EXISTS (SELECT * FROM Users WHERE userId = @userId)
            BEGIN
                THROW 50000, 'User does not exist', 1;
            END
        IF NOT EXISTS (SELECT * FROM Grades WHERE gradeId = @grade)
            BEGIN
                THROW 50000, 'Grade does not exist', 1;
            END
        IF EXISTS (SELECT * FROM StudentsGrades WHERE examId = @examId AND userId = @userId)
            BEGIN
                UPDATE StudentsGrades
                SET gradeId = @grade
                WHERE examId = @examId
                  AND userId = @userId
            END
        ELSE
            INSERT INTO StudentsGrades (examId, userId, gradeId)
            VALUES (@examId, @userId, @grade)
    END
END
BEGIN
    CREATE PROCEDURE AddToCart(@userId int, @specificId int, @type varchar(50)) AS
    BEGIN
        IF NOT EXISTS (SELECT *
                       FROM Users
                       WHERE userId = @userId)
            BEGIN
                THROW 50000, 'User does not exist', 1;
            END
        IF @type NOT IN ('course', 'webinar')
            BEGIN
                THROW 50000, 'Invalid type', 1;
            END
        DECLARE @educationFormId int = (SELECT educationFormId
                                        FROM EducationForms
                                        WHERE specificId = @specificId
                                          AND type = @type)
        IF @educationFormId IS NULL
            BEGIN
                THROW 50000, 'Education form does not exist', 1;
            END
        IF EXISTS (SELECT *
                   FROM Cart
                   WHERE userId = @userId
                     AND educationFormId = @educationFormId)
            BEGIN
                THROW 50000, 'User already has the education form in cart', 1;
            END
        IF EXISTS (SELECT * FROM AssignedEducationForms WHERE userId = @userId AND educationFormId = @educationFormId)
            BEGIN
                THROW 50000, 'User already has access to that education form', 1;
            END
        INSERT INTO Cart (userId, educationFormId) VALUES (@userId, @educationFormId)
    END
END
BEGIN
    CREATE PROCEDURE RemoveFromCart(@userId int, @educationFormId int) AS
    BEGIN
        IF NOT EXISTS (SELECT *
                       FROM Users
                       WHERE userId = @userId)
            BEGIN
                THROW 50000, 'User does not exist', 1;
            END
        IF NOT EXISTS (SELECT *
                       FROM EducationForms
                       WHERE educationFormId = @educationFormId)
            BEGIN
                THROW 50000, 'Education form does not exist', 1;
            END
        IF NOT EXISTS (SELECT *
                       FROM Cart
                       WHERE userId = @userId
                         AND educationFormId = @educationFormId)
            BEGIN
                THROW 50000, 'User does not have the education form in cart', 1;
            END
        DELETE
        FROM Cart
        WHERE userId = @userId
          AND educationFormId = @educationFormId
    END
END
BEGIN
    CREATE PROCEDURE ClearCart(@userId int) AS
    BEGIN
        IF NOT EXISTS (SELECT *
                       FROM Users
                       WHERE userId = @userId)
            BEGIN
                THROW 50000, 'User does not exist', 1;
            END
        IF NOT EXISTS(SELECT * FROM Cart WHERE userId = @userId)
            BEGIN
                THROW 50000, 'User does not have any education forms in cart', 1;
            END
        DELETE
        FROM Cart
        WHERE userId = @userId
    END
END
BEGIN
    CREATE PROCEDURE AssignEducationFormToUser(@userId int, @educationFormId int) AS
    BEGIN
        IF NOT EXISTS (SELECT *
                       FROM Users
                       WHERE userId = @userId)
            BEGIN
                THROW 50000, 'User does not exist', 1;
            END
        IF NOT EXISTS (SELECT *
                       FROM EducationForms
                       WHERE educationFormId = @educationFormId)
            BEGIN
                THROW 50000, 'Education form does not exist', 1;
            END
        IF EXISTS (SELECT *
                   FROM AssignedEducationForms
                   WHERE userId = @userId
                     AND educationFormId = @educationFormId)
            BEGIN
                THROW 50000, 'User already has access to that education form', 1;
            END
        DECLARE @accessFor INT = (SELECT accessFor
                                  FROM EducationFormPrice
                                  WHERE educationFormId = @educationFormId)
        DECLARE @accessUntil date = DATEADD(DAY, @accessFor, dbo.getEducationFormEndDate(@educationFormId))
        INSERT INTO AssignedEducationForms (userId, educationFormId, accessUntil)
        VALUES (@userId, @educationFormId, @accessUntil)
    END
END
BEGIN
    CREATE PROCEDURE FinalizeCart(@userId int) AS
    BEGIN
        DECLARE @userCart userCart
        INSERT INTO @userCart
        SELECT *
        FROM dbo.getCartForUser(@userId)
        DECLARE @educationFormId int
        DECLARE cart_cursor CURSOR FOR SELECT educationFormId FROM @userCart
        OPEN cart_cursor
        FETCH NEXT FROM cart_cursor INTO @educationFormId
        WHILE @@FETCH_STATUS = 0
            BEGIN
                EXEC AssignEducationFormToUser @userId, @educationFormId
                FETCH NEXT FROM cart_cursor INTO @educationFormId
            END
        EXEC ClearCart @userId
        CLOSE cart_cursor
        DEALLOCATE cart_cursor
    END
END



