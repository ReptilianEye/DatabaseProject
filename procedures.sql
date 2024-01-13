BEGIN
    CREATE PROCEDURE AssignTranslatorToEducationForm(@translatorId int, @educationFormId int) AS
    BEGIN
        IF EXISTS (SELECT * FROM Translators WHERE TranslatorId = @translatorId)
            BEGIN
                THROW 50000, 'Translator does not exist', 1;
            END
        IF EXISTS (SELECT * FROM EducationForms WHERE EducationFormId = @educationFormId)
            BEGIN
                THROW 50000, 'Education form does not exist', 1;
            END
        ELSE
            INSERT INTO EducationFormsTranslators (TranslatorId, EducationFormId)
            VALUES (@translatorId, @educationFormId)
    END
END

BEGIN
    CREATE PROCEDURE CreateEducationForm(@specificId int, @type nvarchar(50)) AS
    BEGIN
        INSERT INTO EducationForms (educationFormId, specificId, type)
        VALUES (dbo.nextEducationFormId(), @specificId, @type)
    END
END

BEGIN
    CREATE PROCEDURE CreateCourse(@title nvarchar(50), @slotsLimit int) AS
    BEGIN
        DECLARE @courseId int = dbo.nextCourseId()

        INSERT INTO Courses (courseId, title, slotsLimit)
        VALUES (courseId, @title, @slotsLimit)

        EXEC CreateEducationForm @courseId, 'Course'
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
    VALUES (moduleId, @title, @courseId)
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
    CREATE PROCEDURE CreateWebinar(@link varchar(255), @recordingLink varchar(255), @date datetime, @title nvarchar(50),
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