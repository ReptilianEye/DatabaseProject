CREATE PROCEDURE AddEducationFormPaymentsDetails @educationFormId int,
                                                 @advanceDue int,
                                                 @advance money,
                                                 @wholePrice money,
                                                 @accessFor int,
                                                 @wholePriceDue date
AS
BEGIN
    IF
        NOT EXISTS (SELECT * FROM EducationForms WHERE educationFormId = @educationFormId)
        BEGIN
            THROW
                50000, 'Nie istnieje taka forma edukacji', 1;
        END

    IF
        @wholePriceDue < GETDATE()
        BEGIN
            THROW
                50000, 'Błędna data płatności', 1;
        END

    IF
        @advance < 0 OR @wholePrice < 0
        BEGIN
            THROW
                50000, 'Niepoprawna cena', 1;
        END

    DECLARE
        @priceId int = dbo.nextPriceId();
    INSERT INTO EducationFormPrice (priceId, educationFormId, advanceDue, advance, wholePrice, accessFor)
    VALUES (@priceId, @educationFormId, @advanceDue, @advance, @wholePrice, @accessFor);

    DECLARE
        @advanceDueDate date;
    SET
        @advanceDueDate = DATEADD(DAY, -@advanceDue, @wholePriceDue);

    INSERT INTO EducationFormPaymentsDue (educationFormId, advanceDue, wholePriceDue)
    VALUES (@educationFormId, @advanceDueDate, @wholePriceDue);
END
GO

GRANT EXECUTE ON AddEducationFormPaymentsDetails TO studies_admin
GO

CREATE PROCEDURE AddFinishedPractice @userId INT,
                                     @nazwaStudiow VARCHAR(255),
                                     @dataRozpoczecia DATE,
                                     @dataZakonczenia DATE
AS
BEGIN
    DECLARE
        @studiesId INT;
    SELECT @studiesId = studiesId
    FROM Studies
    WHERE title = @nazwaStudiow;


    IF
        @studiesId IS NOT NULL
        BEGIN
            IF
                (@dataRozpoczecia IS NOT NULL AND @dataZakonczenia IS NOT NULL) AND
                (@dataRozpoczecia <= @dataZakonczenia)
                BEGIN
                    INSERT INTO Practices ([studiesId], [userId], [startDate], [endDate])
                    VALUES (@studiesId, @userId, @dataRozpoczecia, @dataZakonczenia);
                    PRINT
                        'Zakonczona praktyka dodana pomyslnie.';
                END
            ELSE
                BEGIN
                    THROW
                        50000, 'Nieprawidłowa data', 1;
                END
        END
    ELSE
        BEGIN
            THROW
                50000, 'Studia nie znalezione', 1;
        END
END


SELECT *
FROM Practices
GO

GRANT EXECUTE
    ON AddFinishedPractice TO practice_supervisor
GO

CREATE PROCEDURE AddGrade @UserId INT,
                          @StudiesTitle VARCHAR,
                          @SubjectTitle VARCHAR,
                          @Grade FLOAT
AS
BEGIN
    -- Sprawdzenie, czy egzamin istnieje
    IF
        NOT EXISTS (SELECT 1 FROM [Users] WHERE [userId] = @UserId)
        BEGIN
            THROW
                50000, 'Błąd: Podany użytkownik nie istnieje.', 1
        END

    -- Sprawdzenie, czy użytkownik istnieje
    IF
        NOT EXISTS (SELECT 1 FROM [Subjects] WHERE [title] = @SubjectTitle)
        BEGIN
            THROW
                50000, 'Błąd: Podany przedmiot nie istnieje.', 1
        END

    -- Sprawdzenie, czy ocena istnieje
    IF
        NOT EXISTS (SELECT 1 FROM [Grades] WHERE [grade] = @Grade)
        BEGIN
            THROW
                50000, 'Błąd: Podana ocena nie istnieje.', 1
        END

    IF
        NOT EXISTS (SELECT 1 FROM [Studies] WHERE [title] = @StudiesTitle)
        BEGIN
            THROW
                50000, 'Błąd: Nie ma takiego kierunku.', 1
        END

    -- Dodanie oceny do tabeli StudentsGrades
    INSERT INTO [StudentsGrades] (userId, examId, gradeId)
    VALUES (@UserId, (SELECT TOP 1 examId
                      FROM Exams
                      WHERE studiesId = (SELECT studiesId FROM Studies WHERE title = @StudiesTitle)
                        AND subjectId = (SELECT subjectId FROM Subjects WHERE title = @SubjectTitle)),
            (SELECT gradeId FROM Grades WHERE grade = @Grade));

END;
GO

CREATE PROCEDURE AddNewSubjectToStudies @studiesName varchar(255),
                                        @subjectName varchar(255),
                                        @semester int
AS
BEGIN
    IF
        NOT EXISTS (SELECT 1 FROM [Studies] WHERE title = @studiesName)
        BEGIN
            THROW
                50000, 'Podane studia nie istnieja', 1;
        END
    IF
        NOT EXISTS (SELECT 1 FROM [Subjects] WHERE [Subjects].title = @subjectName)
        BEGIN
            THROW
                50000, 'Nie ma takiego przedmiotu.', 1;
        END
    IF
        @semester > 10
        BEGIN
            THROW
                50000, 'Nie ma semestrów powyżej 10', 1;
        END
    BEGIN
        INSERT INTO Syllabuses (syllabusId, subjectId, semester)
        VALUES ((SELECT studiesId FROM Studies WHERE title = @studiesName),
                (SELECT subjectId FROM Subjects WHERE title = @subjectName),
                @semester)
        PRINT 'Dodano nowy przedmiot na studia';
    END
END
GO

GRANT EXECUTE ON AddNewSubjectToStudies TO studies_admin
GO

CREATE PROCEDURE AddNewTranslatedLanguage @languageID INT,
                                          @languageName VARCHAR(255)
AS
BEGIN
    IF
        NOT EXISTS (SELECT 1 FROM [LanguagesDetails] WHERE [languageId] = @languageID)
        BEGIN
            THROW
                50000, 'Błąd: Język o takim id jest juz w bazie danych.', 1
        END
    INSERT INTO [LanguagesDetails] (languageId, language)
    VALUES (@languageID, @languageName);
END;
GO

CREATE PROCEDURE AddRecording(@moduleId int, @link varchar(255)) AS
    IF NOT EXISTS (SELECT *
                   FROM Modules
                   WHERE moduleId = @moduleId)
        BEGIN
            THROW
                50000, 'Module does not exist', 1;
        END
    IF
        NOT EXISTS(SELECT *
                   FROM OnlineAsyncModules
                   WHERE moduleId = @moduleId)
        BEGIN
            THROW
                50000, 'Module is not onlineAsync', 1;
        END
INSERT INTO Recordings (recordingId, moduleId, link)
VALUES (dbo.nextRecordingId(), @moduleId, @link)
GO

CREATE PROCEDURE AddStudies @entryFee int,
                            @meetFee int,
                            @slotsLimit int,
                            @name varchar(255)
AS
BEGIN
    IF
        @entryFee < 1 OR @meetFee < 1 OR @slotsLimit < 1
        BEGIN
            THROW
                50000, 'Kwota lub ilosc miejsc nie moze byc mniejsza lub rowna 0', 1;
        END
    IF
        EXISTS(SELECT 1 FROM Studies WHERE title = @name)
        BEGIN
            THROW
                50000, 'Podane studia juz istnieja', 1;
        END
    BEGIN
        DECLARE
            @studiesId int = dbo.nextStudiesId();
        DECLARE
            @syllabusId int = dbo.nextSyllabusId();
        INSERT INTO Studies (studiesId, syllabusId, entryFee, meetFee, slotsLimit, title)
        VALUES (@studiesId, @syllabusId, @entryFee, @meetFee, @slotsLimit, @name)
    END
END
GO

CREATE PROCEDURE AddStudiesAttendance @userId int,
                                      @studiesMeetingId int
AS
BEGIN
    IF
        NOT EXISTS (SELECT * FROM Users WHERE userId = @userId)
        BEGIN
            THROW
                50000, 'Użytkownik nie istnieje', 1;
        END

    IF
        NOT EXISTS (SELECT * FROM StudiesMeetings WHERE studiesMeetingId = @studiesMeetingId)
        BEGIN
            THROW
                50000, 'Spotkanie nie istnieje', 1;
        END

    IF
        (SELECT date
         FROM StudiesMeetings
         WHERE studiesMeetingId = @studiesMeetingId) > GETDATE()
        BEGIN
            THROW
                50000, 'Nie można wpisać obecności na spotkanie, które się jeszcze nie odbyło', 1;
        END

    INSERT INTO StudiesAttendance (userId, studiesMeetingId)
    VALUES (@userId, @studiesMeetingId)
    PRINT 'Poprawnie dodano obecność użytkownika';
END
GO

GRANT EXECUTE ON AddStudiesAttendance TO studies_admin
GO

CREATE PROCEDURE AddStudiesMeetingOffline @date date,
                                          @scheduleId int,
                                          @subjectId int,
                                          @place varchar(30),
                                          @room varchar(30)
AS
BEGIN
    IF
        NOT EXISTS (SELECT * FROM Subjects WHERE subjectId = @subjectId)
        BEGIN
            THROW
                50000, 'Niepoprawny przedmiot', 1;
        END

    IF
        NOT EXISTS (SELECT * FROM StudiesSchedules WHERE scheduleId = @scheduleId)
        BEGIN
            THROW
                50000, 'Niepoprawny scheduleId', 1;
        END

    IF
        @date < GETDATE()
        BEGIN
            THROW
                50000, 'Nie można dodać spotkania, które się juz odbyło', 1;
        END
    DECLARE
        @studiesMeetingId int = dbo.nextStudiesMeetingId();
    INSERT INTO StudiesMeetings (studiesMeetingId, date, scheduleId, subjectId)
    VALUES (@studiesMeetingId, @date, @scheduleId, @subjectId)
    INSERT
    INTO OfflineStudiesMeetings (studiesMeetingId, place, room)
    VALUES (@studiesMeetingId, @place, @room)
    PRINT 'Poprawnie dodano spotkanie';
END
GO

GRANT EXECUTE ON AddStudiesMeetingOffline TO studies_admin
GO

CREATE PROCEDURE AddStudiesMeetingOnline @date date,
                                         @scheduleId int,
                                         @subjectId int,
                                         @link varchar(50)
AS
BEGIN
    IF
        NOT EXISTS (SELECT * FROM Subjects WHERE subjectId = @subjectId)
        BEGIN
            THROW
                50000, 'Niepoprawny przedmiot', 1;
        END

    IF
        NOT EXISTS (SELECT * FROM StudiesSchedules WHERE scheduleId = @scheduleId)
        BEGIN
            THROW
                50000, 'Niepoprawny scheduleId', 1;
        END

    IF
        @date < GETDATE()
        BEGIN
            THROW
                50000, 'Nie można dodać spotkania, które się juz odbyło', 1;
        END
    DECLARE
        @studiesMeetingId int = dbo.nextStudiesMeetingId();
    INSERT INTO StudiesMeetings (studiesMeetingId, date, scheduleId, subjectId)
    VALUES (@studiesMeetingId, @date, @scheduleId, @subjectId)
    INSERT
    INTO OnlineStudiesMeetings (studiesMeetingId, link)
    VALUES (@studiesMeetingId, @link)
    PRINT 'Poprawnie dodano spotkanie';
END
GO

GRANT EXECUTE ON AddStudiesMeetingOnline TO studies_admin
GO

CREATE PROCEDURE AddStudiesMeetingOnline @date date,
                                         @scheduleId int,
                                         @subjectId int,
                                         @link varchar(50)
AS
BEGIN
    IF
        NOT EXISTS (SELECT * FROM Subjects WHERE subjectId = @subjectId)
        BEGIN
            THROW
                50000, 'Niepoprawny przedmiot', 1;
        END

    IF
        NOT EXISTS (SELECT * FROM StudiesSchedules WHERE scheduleId = @scheduleId)
        BEGIN
            THROW
                50000, 'Niepoprawny scheduleId', 1;
        END

    IF
        @date < GETDATE()
        BEGIN
            THROW
                50000, 'Nie można dodać spotkania, które się juz odbyło', 1;
        END
    DECLARE
        @studiesMeetingId int = dbo.nextStudiesMeetingId();
    INSERT INTO StudiesMeetings (studiesMeetingId, date, scheduleId, subjectId)
    VALUES (@studiesMeetingId, @date, @scheduleId, @subjectId)
    INSERT
    INTO OnlineStudiesMeetings (studiesMeetingId, link)
    VALUES (@studiesMeetingId, @link)
    PRINT 'Poprawnie dodano spotkanie';
END
GO

GRANT EXECUTE ON AddStudiesMeetingOnline TO studies_admin
GO

CREATE PROCEDURE AddStudiesMeetingOnline @date date,
                                         @scheduleId int,
                                         @subjectId int,
                                         @link varchar(50)
AS
BEGIN
    IF
        NOT EXISTS (SELECT * FROM Subjects WHERE subjectId = @subjectId)
        BEGIN
            THROW
                50000, 'Niepoprawny przedmiot', 1;
        END

    IF
        NOT EXISTS (SELECT * FROM StudiesSchedules WHERE scheduleId = @scheduleId)
        BEGIN
            THROW
                50000, 'Niepoprawny scheduleId', 1;
        END

    IF
        @date < GETDATE()
        BEGIN
            THROW
                50000, 'Nie można dodać spotkania, które się juz odbyło', 1;
        END
    DECLARE
        @studiesMeetingId int = dbo.nextStudiesMeetingId();
    INSERT INTO StudiesMeetings (studiesMeetingId, date, scheduleId, subjectId)
    VALUES (@studiesMeetingId, @date, @scheduleId, @subjectId)
    INSERT
    INTO OnlineStudiesMeetings (studiesMeetingId, link)
    VALUES (@studiesMeetingId, @link)
    PRINT 'Poprawnie dodano spotkanie';
END
GO

GRANT EXECUTE ON AddStudiesMeetingOnline TO studies_admin
GO

CREATE PROCEDURE AddStudiesMeetingOnline @date date,
                                         @scheduleId int,
                                         @subjectId int,
                                         @link varchar(50)
AS
BEGIN
    IF
        NOT EXISTS (SELECT * FROM Subjects WHERE subjectId = @subjectId)
        BEGIN
            THROW
                50000, 'Niepoprawny przedmiot', 1;
        END

    IF
        NOT EXISTS (SELECT * FROM StudiesSchedules WHERE scheduleId = @scheduleId)
        BEGIN
            THROW
                50000, 'Niepoprawny scheduleId', 1;
        END

    IF
        @date < GETDATE()
        BEGIN
            THROW
                50000, 'Nie można dodać spotkania, które się juz odbyło', 1;
        END
    DECLARE
        @studiesMeetingId int = dbo.nextStudiesMeetingId();
    INSERT INTO StudiesMeetings (studiesMeetingId, date, scheduleId, subjectId)
    VALUES (@studiesMeetingId, @date, @scheduleId, @subjectId)
    INSERT
    INTO OnlineStudiesMeetings (studiesMeetingId, link)
    VALUES (@studiesMeetingId, @link)
    PRINT 'Poprawnie dodano spotkanie';
END
GO

GRANT EXECUTE ON AddStudiesMeetingOnline TO studies_admin
GO

CREATE PROCEDURE AddStudiesSchedule @studiesId INT,
                                    @semester INT
AS
BEGIN
    IF
        NOT EXISTS (SELECT 1 FROM Studies WHERE studiesId = @studiesId)
        BEGIN
            THROW
                50000, 'Niepoprawny studiesId', 1;
        END

    IF
        EXISTS (SELECT * FROM StudiesSchedules WHERE studiesId = @studiesId AND semester = @semester)
        BEGIN
            THROW
                50000, 'Terminarz już istnieje', 1;
        END

    IF
        NOT EXISTS (SELECT *
                    FROM Studies AS s
                             INNER JOIN Syllabuses AS sb ON
                        s.syllabusId = sb.syllabusId
                    WHERE s.studiesId = @studiesId
                      AND sb.semester = @semester)
        BEGIN
            THROW
                50000, 'Niepoprawny semestr', 1;
        END

    DECLARE
        @scheduleId int = dbo.nextStudiesScheduleId()
    INSERT INTO StudiesSchedules (scheduleId, studiesId, semester)
    VALUES (@scheduleId, @studiesId, @semester);
    PRINT
        'Poprawnie dodano terminarz'
END
GO

GRANT EXECUTE ON AddStudiesSchedule TO studies_admin
GO

CREATE PROCEDURE AddSubject @title varchar(255),
                            @description varchar(255),
                            @ECTS int
AS
BEGIN
    DECLARE
        @subjectId int = dbo.nextSubjectId()
    INSERT INTO Subjects (subjectId, title, description, ECTS)
    VALUES (@subjectId, @title, @description, @ECTS)
END
GO

CREATE PROCEDURE AddTeacher @teacherId INT,
                            @academicTitle VARCHAR(255)
AS
BEGIN
    IF
        NOT EXISTS (SELECT 1 FROM [Teachers] WHERE [teacherId] = @teacherId)
        BEGIN
            THROW
                50000, 'Błąd: Podany użytkownik jest już nauczycielem.', 1;
        END
    IF
        NOT EXISTS(SELECT 1 FROM [AcademicsTitles] WHERE [academicTitle] = @academicTitle)
        BEGIN
            THROW
                50000, 'Błąd: Taki tytuł naukowy nie isnieje', 1;
        END


    INSERT INTO [Teachers] (teacherId, academicTitleId)
    VALUES (@teacherId, (SELECT academicTitleId FROM AcademicsTitles WHERE academicTitle = @academicTitle));
    PRINT
        'Nauczyciel dodany poprawnie.';
END;
GO

CREATE PROCEDURE AddToCart(@userId int, @specificId int, @type varchar(50)) AS
BEGIN
    IF
        NOT EXISTS (SELECT *
                    FROM Users
                    WHERE userId = @userId)
        BEGIN
            RAISERROR
                ('User with id %d does not exist', 16, 1, @userId);
            RETURN
        END
    IF
        @type NOT IN ('course', 'webinar', 'studies')
        BEGIN
            RAISERROR
                ('Invalid type, %s', 16, 1, @type);
            RETURN
        END
    DECLARE
        @educationFormId int = (SELECT educationFormId
                                FROM EducationForms
                                WHERE specificId = @specificId
                                  AND type = @type)
    IF @educationFormId IS NULL
        BEGIN
            RAISERROR
                ('Education form with id %d does not exist', 16, 1, @specificId);
            RETURN
        END
    IF
        EXISTS (SELECT *
                FROM Cart
                WHERE userId = @userId
                  AND educationFormId = @educationFormId)
        BEGIN
            RAISERROR
                ('User already has the education with id: %d in cart', 16, 1, @educationFormId);
            RETURN
        END
    IF
        EXISTS (SELECT * FROM AssignedEducationForms WHERE userId = @userId AND educationFormId = @educationFormId)
        BEGIN
            RAISERROR
                ('User already has access to education form with id %d', 16, 1, @educationFormId);
            RETURN
        END
    IF
        @type = 'studies'
        BEGIN
            IF
                EXISTS(SELECT * FROM AwaitingStudents WHERE userId = @userId AND studiesId = @specificId)
                BEGIN
                    RAISERROR
                        ('User is already awaiting for studies with id: %d', 16, 1, @specificId);
                    RETURN
                END
            IF
                EXISTS(SELECT * FROM Students WHERE userId = @userId AND studiesId = @specificId)
                BEGIN
                    RAISERROR
                        ('User is already studying studies with id: %d', 16, 1, @specificId);
                    RETURN
                END
        END
    INSERT INTO Cart (userId, educationFormId)
    VALUES (@userId, @educationFormId)
END
GO

GRANT EXECUTE ON AddToCart TO student
GO

CREATE PROCEDURE AddTranslator @translatorID INT
AS
BEGIN
    IF
        NOT EXISTS (SELECT 1 FROM [Users] WHERE [userId] = @translatorID)
        BEGIN
            THROW
                50000, 'Błąd: Podany użytkownik nie istnieje.', 1
            RETURN;
        END
    IF
        NOT EXISTS(SELECT 1 FROM [Translators] WHERE [translatorId] = @translatorID)
        BEGIN
            THROW
                50000, 'Błąd: Taki tłumacz już istnieje', 1
        END

    -- Dodanie oceny do tabeli StudentsGrades
    INSERT INTO [Translators] (translatorId)
    VALUES (@translatorID);
END;
GO

CREATE PROCEDURE AddUser @Imie NVARCHAR(255),
                         @Nazwisko NVARCHAR(255),
                         @Email NVARCHAR(255),
                         @Miasto NVARCHAR(255) = NULL,
                         @Ulica NVARCHAR(255) = NULL,
                         @Wojewodztwo NVARCHAR(255) = NULL,
                         @KodPocztowy NVARCHAR(255),
                         @NumerDomu NVARCHAR(10),
                         @NumerKarty NVARCHAR(255)
AS
BEGIN
    IF
        @Miasto IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [Cities] WHERE [city] = @Miasto)
        BEGIN
            THROW
                50000, 'Błąd: Podane miasto nie istnieje w tabeli Cities.', 1;
        END

    IF
        @Ulica IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [Streets] WHERE [street] = @Ulica)
        BEGIN
            THROW
                50000, 'Błąd: Podana ulica nie istnieje w tabeli Streets.', 1;
        END

    IF
        @Wojewodztwo IS NOT NULL AND NOT EXISTS (SELECT 1 FROM [States] WHERE [state] = @Wojewodztwo)
        BEGIN
            THROW
                50000, 'Błąd: Podany stan nie istnieje w tabeli States.', 1;
        END

    INSERT INTO [Users] (name, surname, email, cityId, streetId, stateId, zip, houseNumber, creditCardNumber)
    VALUES (@Imie, @Nazwisko, @Email,
            CASE WHEN @Miasto IS NOT NULL THEN (SELECT cityId FROM [Cities] WHERE city = @Miasto) END,
            CASE WHEN @Ulica IS NOT NULL THEN (SELECT streetId FROM [Streets] WHERE street = @Ulica) END,
            CASE WHEN @Wojewodztwo IS NOT NULL THEN (SELECT stateId FROM [States] WHERE state = @Wojewodztwo) END,
            @KodPocztowy, @NumerDomu, @NumerKarty);

    PRINT
        'Użytkownik dodany poprawnie.';
END;
GO

CREATE PROCEDURE AreFreeSlotsInAll(@userId int) AS
BEGIN
    DECLARE
        @userCart userCart;
    INSERT INTO @userCart
    SELECT *
    FROM
        dbo.getCartForUser(@userId)
    DECLARE
        @educationFormId int
    DECLARE
        cart_cursor CURSOR FOR
            SELECT educationFormId
            FROM @userCart
    OPEN cart_cursor
    FETCH NEXT
        FROM cart_cursor
        INTO @educationFormId
    WHILE @@FETCH_STATUS = 0
        BEGIN
            IF
                dbo.areFreeSlotsAvailable(@educationFormId) = 0
                BEGIN
                    RAISERROR
                        ('No free slots available for education form %d', 16, 1, @educationFormId)
                END
            FETCH NEXT FROM cart_cursor INTO @educationFormId
        END
END
GO

CREATE PROCEDURE AssignEducationFormToUser(@userId int, @educationFormId int) AS
BEGIN
    DECLARE
        @type varchar(50) = (SELECT type
                             FROM EducationForms
                             WHERE educationFormId = @educationFormId)
    IF @type = 'studies'
        BEGIN
            INSERT INTO AwaitingStudents (userId, studiesId, semester)
            VALUES (@userId, (SELECT specificId FROM EducationForms WHERE educationFormId = @educationFormId), 1)
            RETURN
        END
    IF
        NOT EXISTS (SELECT *
                    FROM Users
                    WHERE userId = @userId)
        BEGIN
            THROW
                50000, 'User does not exist', 1;
        END
    IF
        NOT EXISTS (SELECT *
                    FROM EducationForms
                    WHERE educationFormId = @educationFormId)
        BEGIN
            THROW
                50000, 'Education form does not exist', 1;
        END
    IF
        EXISTS (SELECT *
                FROM AssignedEducationForms
                WHERE userId = @userId
                  AND educationFormId = @educationFormId)
        BEGIN
            THROW
                50000, 'User already has access to that education form', 1;
        END
    PRINT
        'Assigning education form to user'
    DECLARE
        @accessFor INT = (SELECT accessFor
                          FROM EducationFormPrice
                          WHERE educationFormId = @educationFormId)
    DECLARE
        @accessUntil date = DATEADD(DAY, @accessFor, dbo.getEducationFormEndDate(@educationFormId))
    INSERT INTO AssignedEducationForms (userId, educationFormId, accessUntil)
    VALUES (@userId, @educationFormId, @accessUntil)
END
GO

GRANT EXECUTE ON AssignEducationFormToUser TO studies_admin
GO

GRANT EXECUTE ON AssignEducationFormToUser TO teacher
GO

CREATE PROCEDURE AssignStudentToStudies AS
BEGIN
    INSERT INTO Students (userId, studiesId, semester)
    SELECT userId, studiesId, semester
    FROM AwaitingStudents
END
GO

CREATE PROCEDURE AssignTranslatorToEducationForm(@translatorId int, @educationFormId int) AS
BEGIN
    IF
        NOT EXISTS (SELECT * FROM Translators WHERE TranslatorId = @translatorId)
        BEGIN
            THROW
                50000, 'Translator does not exist', 1;
        END
    IF
        NOT EXISTS (SELECT * FROM EducationForms WHERE EducationFormId = @educationFormId)
        BEGIN
            THROW
                50000, 'Education form does not exist', 1;
        END
    ELSE
        INSERT INTO EducationFormsTranslators (TranslatorId, EducationFormId)
        VALUES (@translatorId, @educationFormId)
END
GO

CREATE PROCEDURE buySingleStudiesMeeting(@userId int, @studiesMeetingId int) AS
DECLARE
    @studiesId int = (SELECT TOP 1 studiesId
                      FROM StudiesMeetings SM
                               JOIN StudiesSchedules SS ON SM.scheduleId = SS.scheduleId
                      WHERE studiesMeetingId = @studiesMeetingId)
DECLARE
    @educationFormId int = (SELECT educationFormId
                            FROM EducationForms
                            WHERE specificId = @studiesId
                              AND type = 'studies')
INSERT INTO PaymentsHistory (paymentId, userId, paymentDate, payedFor, amount, paymentDetails)
VALUES (dbo.nextPaymentId(), @userId, GETDATE(), @educationFormId,
        dbo.getStudiesMeetingPrice(@studiesMeetingId),
        'studiesMeetingId=' + CAST(@studiesMeetingId AS varchar(255)))
GO

CREATE PROCEDURE ClearCart(@userId int) AS
BEGIN
    IF
        NOT EXISTS (SELECT *
                    FROM Users
                    WHERE userId = @userId)
        BEGIN
            THROW
                50000, 'User does not exist', 1;
        END
    IF
        NOT EXISTS(SELECT * FROM Cart WHERE userId = @userId)
        BEGIN
            THROW
                50000, 'User does not have any education forms in cart', 1;
        END
    DELETE
    FROM Cart
    WHERE userId = @userId
END
GO

GRANT EXECUTE ON ClearCart TO student
GO

CREATE PROCEDURE CreateCourse(@title nvarchar(50), @slotsLimit int, @price money, @wholePriceDueDate datetime,
                              @advanceDueDays int, @advance money, @accessFor int) AS
BEGIN
    DECLARE
        @courseId int = dbo.nextCourseId()

    INSERT INTO Courses (courseId, title, slotsLimit)
    VALUES (@courseId, @title, @slotsLimit)

    EXEC CreateEducationForm @courseId, 'Course', @price, @wholePriceDueDate, @advanceDueDays, @advance,
         @accessFor
END
GO

CREATE PROCEDURE CreateEducationForm(@specificId int, @type nvarchar(50), @price money, @wholePriceDueDate date,
                                     @advanceDueDays int, @advance money, @accessFor int) AS
BEGIN
    DECLARE
        @educationFormId int = dbo.nextEducationFormId()
    INSERT INTO EducationForms (educationFormId, specificId, type)
    VALUES (@educationFormId, @specificId, @type)
    EXEC AddEducationFormPaymentsDetails @educationFormId, @advanceDueDays, @advance, @price, @accessFor,
         @wholePriceDueDate
END
GO

CREATE PROCEDURE CreateExam(@studiesId int, @subjectId int) AS
BEGIN
    IF
        NOT EXISTS (SELECT * FROM Studies WHERE studiesId = @studiesId)
        BEGIN
            THROW
                50000, 'Studies does not exist', 1;
        END
    IF
        NOT EXISTS (SELECT * FROM Subjects WHERE subjectId = @subjectId)
        BEGIN
            THROW
                50000, 'Subject does not exist', 1;
        END
    IF
        NOT EXISTS (SELECT * FROM Exams WHERE studiesId = @studiesId AND subjectId = @subjectId)
        BEGIN
            THROW
                50000, 'Exam already exists', 1;
        END
    DECLARE
        @examId int = dbo.nextExamId()
    INSERT INTO Exams (examId, studiesId, subjectId)
    VALUES (@examId, @studiesId, @subjectId)
END
GO

GRANT EXECUTE ON CreateExam TO studies_admin
GO

GRANT EXECUTE ON CreateExam TO teacher
GO

CREATE PROCEDURE CreateHybridModule(@title nvarchar(50), @courseId int) AS
BEGIN
    EXEC CreateModule @title, @courseId, 'hybrid'
END
GO

CREATE PROCEDURE CreateModule(@title nvarchar(50), @courseId int, @type varchar(20)) AS
    IF @type NOT IN ('stationary', 'onlineSync', 'onlineAsync', 'hybrid')
        BEGIN
            THROW
                50000, 'Invalid module type', 1;
        END
    IF
        NOT EXISTS (SELECT *
                    FROM Courses
                    WHERE courseId = @courseId)
        BEGIN
            THROW
                50000, 'Course does not exist', 1;
        END
DECLARE
    @moduleId int = dbo.nextCourseModuleId()
INSERT INTO Modules (moduleId, title, courseId)
VALUES (@moduleId, @title, @courseId)
    IF @type = 'stationary'
        BEGIN
            INSERT INTO StationaryModules (moduleId)
            VALUES (@moduleId)
            RETURN
        END
    IF
        @type = 'onlineSync'
        BEGIN
            INSERT INTO OnlineSyncModules (moduleId)
            VALUES (@moduleId)
            RETURN
        END
    IF
        @type = 'onlineAsync'
        BEGIN
            INSERT INTO OnlineAsyncModules (moduleId)
            VALUES (@moduleId)
            RETURN
        END
    IF
        @type = 'hybrid'
        BEGIN
            INSERT INTO HybridModules (moduleId)
            VALUES (@moduleId)
            RETURN
        END
GO

CREATE PROCEDURE CreateOnlineAsyncModule(@title nvarchar(50), @courseId int) AS
BEGIN
    EXEC CreateModule @title, @courseId, 'onlineAsync'
END
GO

CREATE PROCEDURE CreateOnlineSyncModule(@title nvarchar(50), @courseId int) AS
BEGIN
    EXEC CreateModule @title, @courseId, 'onlineSync'
END
GO

CREATE PROCEDURE CreateStationaryModule(@title nvarchar(50), @courseId int) AS
BEGIN
    EXEC CreateModule @title, @courseId, 'stationary'
END
GO

CREATE PROCEDURE CreateWebinar(@link varchar(255), @recordingLink varchar(255), @date datetime, @title nvarchar(50),
                               @description varchar(255), @price money, @detailsId int= NULL) AS
BEGIN
    DECLARE
        @webinarId int
    DECLARE
        @meetingId int = dbo.nextWebinarMeetingId()
    IF @detailsId IS NOT NULL
        BEGIN
            INSERT INTO Webinars (webinarDetailsId, onlineMeetingId)
            OUTPUT inserted.webinarId
            VALUES (@detailsId, @meetingId)
            SET @webinarId = SCOPE_IDENTITY();
        END
    ELSE
        BEGIN
            DECLARE
                @webinarDetailsId int = dbo.nextWebinarDetailsId()
            INSERT INTO WebinarDetails (webinarDetailsId, title, description, price)
            VALUES (@webinarDetailsId, @title, @description, @price)
            INSERT INTO Webinars (webinarDetailsId, onlineMeetingId)
            OUTPUT inserted.webinarId
            VALUES (@webinarDetailsId, @meetingId)
            SET @webinarId = SCOPE_IDENTITY();
        END
    INSERT INTO WebinarMeetings (onlineMeetingId, link, recordingLink, date)
    VALUES (@meetingId, @link, @recordingLink,
            @date)
    EXEC CreateEducationForm @webinarId, 'Webinar', @price, @date, 0, 0, 999
END
GO

CREATE PROCEDURE debtors(@meetingAmount int) AS
BEGIN
    WITH dane AS (SELECT userId, SUM(entryFee + @meetingAmount * meetFee * S.semester) AS do_zaplaty
                  FROM Students S
                           INNER JOIN Studies St ON S.studiesId = St.studiesId
                  GROUP BY userId
                  UNION
                  SELECT userId, SUM(wholePrice)
                  FROM AssignedEducationForms A
                           INNER JOIN EducationFormPrice E ON E.educationFormId = A.educationFormId
                  GROUP BY userId)
    SELECT dane.userId,
           U.name,
           U.surname,
           U.email,
           SUM(do_zaplaty) - (SELECT SUM(amount) FROM PaymentsHistory WHERE userId = dane.userId) AS jeszcze_do_zaplaty
    FROM dane
             INNER JOIN Users U ON U.userId = dane.userId
    GROUP BY U.name, dane.userId, U.surname, U.email
    HAVING SUM(do_zaplaty) > (SELECT SUM(amount) FROM PaymentsHistory WHERE userId = dane.userId)
END
GO

CREATE PROCEDURE deleteCourse(@courseId int) AS
BEGIN
    IF
        NOT EXISTS(SELECT * FROM Courses WHERE courseId = @courseId)
        BEGIN
            THROW
                50000, 'Course not exists', 1;
        END
    DELETE
    FROM Courses
    WHERE courseId = @courseId


    DELETE
    FROM EducationForms
    WHERE specificId = @courseId


    DELETE
    FROM EducationForms
    WHERE specificId = @courseId


    DELETE
    FROM Modules
    WHERE courseId = @courseId


    DELETE
    FROM EducationFormPrice
    WHERE educationFormId = (SELECT educationFormId
                             FROM EducationForms
                             WHERE specificId = @courseId)


    DELETE
    FROM StationaryModules
    WHERE moduleId IN (SELECT moduleId FROM Modules WHERE courseId = @courseId)


    DELETE
    FROM HybridModules
    WHERE moduleId IN (SELECT moduleId FROM Modules WHERE courseId = @courseId)


    DELETE
    FROM OnlineSyncModules
    WHERE moduleId IN (SELECT moduleId FROM Modules WHERE courseId = @courseId)


    DELETE
    FROM OnlineAsyncModules
    WHERE moduleId IN (SELECT moduleId FROM Modules WHERE courseId = @courseId)


    DELETE
    FROM Attendance
    WHERE meetingId IN
          (SELECT meetingId FROM Meetings WHERE meetingId IN (SELECT moduleId FROM Modules WHERE courseId = @courseId))


    DELETE
    FROM Meetings
    WHERE meetingId IN
          (SELECT meetingId FROM Meetings WHERE meetingId IN (SELECT moduleId FROM Modules WHERE courseId = @courseId))


    DELETE
    FROM OfflineMeetings
    WHERE moduleId IN (SELECT moduleId FROM Modules WHERE courseId = @courseId)


    DELETE
    FROM OnlineMeetings
    WHERE moduleId IN (SELECT moduleId FROM Modules WHERE courseId = @courseId)


    DELETE
    FROM AssignedEducationForms
    WHERE educationFormId = (SELECT educationFormId
                             FROM EducationForms
                             WHERE specificId = @courseId)

    DELETE
    FROM EducationFormPaymentsDue
    WHERE educationFormId = (SELECT educationFormId
                             FROM EducationForms
                             WHERE specificId = @courseId)
END
GO

CREATE PROCEDURE deleteWebinar(@webinarId int) AS
BEGIN
    IF
        NOT EXISTS(SELECT 1 FROM Webinars WHERE webinarId = @webinarId)
        BEGIN
            THROW
                50000, 'Webinar does not exists', 1;
        END
    DELETE
    FROM WebinarMeetings
    WHERE onlineMeetingId = (SELECT onlineMeetingId FROM Webinars WHERE webinarId = @webinarId)

    DECLARE
        @webinarDetailsId int = (SELECT webinarDetailsId FROM Webinars WHERE webinarId = @webinarId)

    DELETE
    FROM Webinars
    WHERE webinarId = @webinarId
    IF (SELECT COUNT(*) FROM Webinars WHERE webinarDetailsId = @webinarDetailsId) = 0
        BEGIN
            DELETE
            FROM WebinarDetails
            WHERE webinarDetailsId = @webinarDetailsId
        END


    DELETE
    FROM EducationFormPrice
    WHERE educationFormId = (SELECT educationFormId
                             FROM EducationForms
                             WHERE specificId = @webinarId
                               AND type = 'webinar')

    DELETE
    FROM AssignedEducationForms
    WHERE educationFormId = (SELECT educationFormId
                             FROM EducationForms
                             WHERE specificId = @webinarId
                               AND type = 'webinar')

    DELETE
    FROM EducationFormPaymentsDue
    WHERE educationFormId = (SELECT educationFormId
                             FROM EducationForms
                             WHERE specificId = @webinarId
                               AND type = 'webinar')

    DELETE
    FROM EducationForms
    WHERE specificId = @webinarId
      AND type = 'webinar'


END
GO

CREATE PROCEDURE diplomaInfo(@userId int)
AS
BEGIN
    IF
        NOT EXISTS(SELECT 1 FROM Users WHERE Users.userId = @userId)
        BEGIN
            THROW
                50000, 'User not exists', 1
        END
    BEGIN
        SELECT name, surname, state, city, street, zip
        FROM Users
                 INNER JOIN Streets ON Users.streetId = Streets.streetId
                 INNER JOIN States ON Users.stateId = States.stateId
                 INNER JOIN Cities ON Users.cityId = Cities.cityId
        WHERE Users.userId = @userId
    END
END
GO

CREATE PROCEDURE FinalizeCart(@userId int) AS
BEGIN
    DECLARE
        @userCart userCart
    INSERT INTO @userCart
    SELECT *
    FROM dbo.getCartForUser(@userId)
    IF (SELECT COUNT(*) FROM @userCart) = 0
        RETURN
    DECLARE
        @educationFormId int
    DECLARE
        cart_cursor CURSOR FOR
            SELECT educationFormId
            FROM @userCart
    OPEN cart_cursor
    FETCH NEXT
        FROM cart_cursor
        INTO @educationFormId
    WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC AssignEducationFormToUser @userId, @educationFormId
            FETCH NEXT FROM cart_cursor INTO @educationFormId
        END
    EXEC ClearCart @userId
    CLOSE cart_cursor
    DEALLOCATE cart_cursor
END
GO

GRANT EXECUTE ON FinalizeCart TO student
GO

CREATE PROCEDURE generatePaymentLink(@userId int, @paymentLink varchar(255) OUTPUT) AS
BEGIN
    IF
        NOT EXISTS (SELECT * FROM dbo.getCartForUser(@userId))
        BEGIN
            RAISERROR
                ('Cart is empty', 16, 1)
        END
    EXEC AreFreeSlotsInAllFormsInCart @userId
    SELECT @paymentLink = 'https://www.paypal.com/paypalme/edusystem/'
    SELECT @paymentLink = @paymentLink + CAST(SUM(wholePrice) AS varchar(255))
    FROM dbo.getCartForUser(@userId)
END
GO

CREATE PROCEDURE income(@meetingAmount int) AS
BEGIN
    SELECT C.title, 'kurs' AS typ, SUM(amount) AS przychod
    FROM PaymentsHistory
             INNER JOIN dbo.EducationForms EF ON PaymentsHistory.payedFor = EF.educationFormId
             INNER JOIN Courses C ON courseId = specificId
    GROUP BY C.title
    UNION
    SELECT WD.title, 'webinar' AS typ, SUM(amount) AS przychod
    FROM PaymentsHistory
             INNER JOIN dbo.EducationForms E ON E.educationFormId = PaymentsHistory.payedFor
             INNER JOIN Webinars W ON webinarId = specificId
             INNER JOIN WebinarDetails WD ON W.webinarDetailsId = WD.webinarDetailsId
    GROUP BY WD.title
    UNION
    SELECT DISTINCT Studies.title,
                    'studia',
                    entryFee * (SELECT COUNT(*) FROM Students S2 WHERE S2.studiesId = S.studiesId) +
                    @meetingAmount * meetFee * (SELECT COUNT(*) FROM Students S2 WHERE S2.studiesId = S.studiesId)
    FROM Students S
             INNER JOIN Studies ON S.studiesId = Studies.studiesId
END
GO

CREATE PROCEDURE InsertPaymentHistory @userId int,
                                      @paymentDate datetime,
                                      @payedFor int,
                                      @amount money,
                                      @paymentDetails varchar(200)
AS
BEGIN
    IF
        NOT EXISTS (SELECT * FROM Users WHERE userId = @userId)
        BEGIN
            THROW
                50000, 'Użytkownik nie istnieje', 1;
        END

    IF
        NOT EXISTS (SELECT * FROM EducationForms WHERE educationFormId = @payedFor)
        BEGIN
            THROW
                50000, 'Taka forma kształcenia nie istnieje', 1;
        END

    IF
        @paymentDate > GETDATE()
        BEGIN
            THROW
                50000, 'Błędna data płatności', 1;
        END

    DECLARE
        @paymentId int = dbo.nextPaymentId();
    INSERT INTO PaymentsHistory (paymentId, userId, paymentDate, payedFor, amount, paymentDetails)
    VALUES (@paymentId, @userId, @paymentDate, @payedFor, @amount, @paymentDetails);
END
GO

CREATE PROCEDURE RemoveFromCart(@userId int, @educationFormId int) AS
BEGIN
    IF
        NOT EXISTS (SELECT *
                    FROM Users
                    WHERE userId = @userId)
        BEGIN
            THROW
                50000, 'User does not exist', 1;
        END
    IF
        NOT EXISTS (SELECT *
                    FROM EducationForms
                    WHERE educationFormId = @educationFormId)
        BEGIN
            THROW
                50000, 'Education form does not exist', 1;
        END
    IF
        NOT EXISTS (SELECT *
                    FROM Cart
                    WHERE userId = @userId
                      AND educationFormId = @educationFormId)
        BEGIN
            THROW
                50000, 'User does not have the education form in cart', 1;
        END
    DELETE
    FROM Cart
    WHERE userId = @userId
      AND educationFormId = @educationFormId
END
GO

GRANT EXECUTE ON RemoveFromCart TO student
GO

CREATE PROCEDURE RemovePermissionFromRole(@roleName varchar, @permission varchar) AS
BEGIN
    IF
        NOT EXISTS (SELECT * FROM RoleDetails WHERE roleName = @roleName)
        BEGIN
            THROW
                50000, 'Role does not exist', 1;
        END
    IF
        NOT EXISTS (SELECT *
                    FROM Permissions
                    WHERE roleId = (SELECT roleId FROM RoleDetails WHERE roleName = @roleName)
                      AND permission = @permission)
        BEGIN
            THROW
                50000, 'Role does not have the permission', 1;
        END
    DELETE
    FROM Permissions
    WHERE roleId = (SELECT roleId FROM RoleDetails WHERE roleName = @roleName)
      AND permission = @permission
END
GO

CREATE PROCEDURE RemoveUserRole(@userId int, @roleName varchar) AS
BEGIN
    IF
        NOT EXISTS (SELECT * FROM Users WHERE userId = @userId)
        BEGIN
            THROW
                50000, 'User does not exist', 1;
        END
    IF
        NOT EXISTS (SELECT * FROM RoleDetails WHERE roleName = @roleName)
        BEGIN
            THROW
                50000, 'Role does not exist', 1;
        END
    IF
        NOT EXISTS (SELECT *
                    FROM Roles
                    WHERE userId = @userId
                      AND roleId = (SELECT roleId FROM RoleDetails WHERE roleName = @roleName))
        BEGIN
            THROW
                50000, 'User does not have the role', 1;
        END
    DELETE
    FROM Roles
    WHERE userId = @userId
      AND roleId = (SELECT roleId FROM RoleDetails WHERE roleName = @roleName)
END
GO

CREATE PROCEDURE SaveMeetingAttendance(@meetingId int, @students AS usersList READONLY) AS
BEGIN
    IF
        NOT EXISTS (SELECT * FROM Meetings WHERE meetingId = @meetingId)
        BEGIN
            THROW
                50000, 'Meeting does not exist', 1;
        END

    DECLARE
        @userId int
    DECLARE
        student_cursor CURSOR FOR
            SELECT userId
            FROM @students
    OPEN student_cursor
    FETCH NEXT
        FROM student_cursor
        INTO @userId
    WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC SaveUserAttendance @meetingId, @userId
            FETCH NEXT FROM student_cursor INTO @userId
        END
    CLOSE student_cursor DEALLOCATE student_cursor
END
GO

GRANT EXECUTE ON SaveMeetingAttendance TO teacher
GO

CREATE PROCEDURE SaveOfflineMeeting(@moduleId int, @date datetime, @duration int, @place varchar(255),
                                    @room varchar(20)) AS
BEGIN
    IF
        NOT EXISTS (SELECT * FROM Modules WHERE moduleId = @moduleId)
        BEGIN
            THROW
                50000, 'Module does not exist', 1;
        END
    IF
        NOT EXISTS (SELECT * FROM StationaryModules WHERE moduleId = @moduleId) AND
        NOT EXISTS (SELECT * FROM HybridModules WHERE moduleId = @moduleId)
        BEGIN
            THROW
                50000, 'Module is not stationary or hybrid', 1;
        END
    IF
        (SELECT COUNT(*)
         FROM Meetings M
                  JOIN OfflineMeetings OM ON M.meetingId = OM.meetingId
         WHERE dbo.doesDatesOverlap(M.date, M.date, DATEADD(MINUTE, duration, M.date), @date, @date,
                                    DATEADD(MINUTE, @duration, @date)) = 1) > 0
        BEGIN
            THROW
                50000, 'Meeting overlaps with another meeting', 1;
        END

    DECLARE
        @meetingId int = dbo.nextMeetingId()
    INSERT INTO Meetings (meetingId, date, duration) VALUES (@meetingId, @date, @duration)
    INSERT INTO OfflineMeetings (meetingId, moduleId, place, room)
    VALUES (@meetingId, @moduleId, @place, @room)
END
GO

GRANT EXECUTE ON SaveOfflineMeeting TO teacher
GO

CREATE PROCEDURE SaveOnlineMeeting(@moduleId int, @date datetime, @duration int, @link varchar(255)) AS
    IF NOT EXISTS (SELECT *
                   FROM Modules
                   WHERE moduleId = @moduleId)
        BEGIN
            THROW
                50000, 'Module does not exist', 1;
        END
    IF
        NOT EXISTS (SELECT *
                    FROM OnlineSyncModules
                    WHERE moduleId = @moduleId) AND
        NOT EXISTS (SELECT *
                    FROM HybridModules
                    WHERE moduleId = @moduleId)
        BEGIN
            THROW
                50000, 'Module is not onlineSync or hybrid', 1;
        END
    IF
        (SELECT COUNT(*)
         FROM Meetings M
                  JOIN OfflineMeetings OM ON M.meetingId = OM.meetingId
         WHERE dbo.doesDatesOverlap(M.date, M.date, DATEADD(MINUTE, duration, M.date), @date, @date,
                                    DATEADD(MINUTE, @duration, @date)) = 1) > 0
        BEGIN
            THROW
                50000, 'Meeting overlaps with another meeting', 1;
        END
DECLARE
    @meetingId int = dbo.nextMeetingId()
INSERT INTO Meetings (meetingId, date)
VALUES (@meetingId, @date)
INSERT INTO OnlineMeetings (meetingId, moduleId, link)
VALUES (@meetingId, @moduleId, @link)
GO

GRANT EXECUTE ON SaveOnlineMeeting TO teacher
GO

CREATE PROCEDURE SaveStudentExamGrade(@examId int, @userId int, @grade int) AS
BEGIN
    IF
        NOT EXISTS (SELECT * FROM Exams WHERE examId = @examId)
        BEGIN
            THROW
                50000, 'Exam does not exist', 1;
        END
    IF
        NOT EXISTS (SELECT * FROM Users WHERE userId = @userId)
        BEGIN
            THROW
                50000, 'User does not exist', 1;
        END
    IF
        NOT EXISTS (SELECT * FROM Grades WHERE gradeId = @grade)
        BEGIN
            THROW
                50000, 'Grade does not exist', 1;
        END
    IF
        EXISTS (SELECT * FROM StudentsGrades WHERE examId = @examId AND userId = @userId)
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
GO

GRANT EXECUTE ON SaveStudentExamGrade TO studies_admin
GO

GRANT EXECUTE ON SaveStudentExamGrade TO teacher
GO

CREATE PROCEDURE SaveUserAttendance(@meetingId int, @userId int) AS
BEGIN
    IF
        NOT EXISTS (SELECT * FROM Meetings WHERE meetingId = @meetingId)
        BEGIN
            THROW
                50000, 'Meeting does not exist', 1;
        END
    IF
        NOT EXISTS (SELECT * FROM Users WHERE userId = @userId)
        BEGIN
            THROW
                50000, 'User does not exist', 1;
        END
    INSERT INTO Attendance (meetingId, userId)
    VALUES (@meetingId, @userId)
END
GO

GRANT EXECUTE ON SaveUserAttendance TO studies_admin
GO

GRANT EXECUTE ON SaveUserAttendance TO teacher
GO

CREATE PROCEDURE SaveUserWatchedRecording(@userId int, @recordingId int) AS
BEGIN
    IF
        NOT EXISTS (SELECT * FROM Users WHERE userId = @userId)
        BEGIN
            THROW
                50000, 'User does not exist', 1;
        END
    IF
        NOT EXISTS (SELECT * FROM Recordings WHERE recordingId = @recordingId)
        BEGIN
            THROW
                50000, 'Recording does not exist', 1;
        END
    INSERT INTO WatchedBy (userId, recordingId)
    VALUES (@userId, @recordingId)
END
GO

GRANT EXECUTE ON SaveUserWatchedRecording TO teacher
GO

CREATE PROCEDURE UpdateWebinarRecordingLink(@webinarId int, @recordingLink varchar(255)) AS
    IF NOT EXISTS (SELECT *
                   FROM Webinars
                   WHERE webinarId = @webinarId)
        BEGIN
            THROW
                50000, 'Webinar does not exist', 1;
        END
    IF
        @recordingLink IS NULL
        BEGIN
            THROW
                50000, 'Link cannot be null', 1;
        END
UPDATE WebinarMeetings
SET recordingLink = @recordingLink
WHERE onlineMeetingId = (SELECT onlineMeetingId FROM Webinars WHERE webinarId = @webinarId)
GO

