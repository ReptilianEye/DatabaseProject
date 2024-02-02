CREATE FUNCTION absenceFromUser(@userId int)
    RETURNS table
        return(SELECT *
               FROM (SELECT 'Studia'                                          AS forma_kształcenia,
                            u.userId,
                            u.name,
                            u.surname,
                            sm.date,
                            su.title,
                            IIF(sa.userId IS NOT NULL, 'Obecny', 'Nieobecny') AS Obecnosc
                     FROM Users AS u
                              INNER JOIN Students AS s ON u.userId = s.userId
                              INNER JOIN Studies AS st ON s.studiesId = st.studiesId
                              INNER JOIN StudiesSchedules AS ss ON st.studiesId = ss.studiesId
                              INNER JOIN StudiesMeetings AS sm ON ss.scheduleId = sm.scheduleId
                              INNER JOIN Subjects su ON sm.subjectId = su.subjectId
                              LEFT JOIN StudiesAttendance AS sa
                                        ON u.userId = sa.userId AND sa.studiesMeetingId = sm.studiesMeetingId) AS result
               WHERE Obecnosc = 'Nieobecny'
                 AND userId = @userId)
GO

CREATE FUNCTION areFreeSlotsAvailable(@educationFormId int) RETURNS bit AS
BEGIN
    DECLARE
        @type varchar(255) = (SELECT type
                              FROM EducationForms
                              WHERE educationFormId = @educationFormId)
    DECLARE
        @specificId int = (SELECT specificId
                           FROM EducationForms
                           WHERE educationFormId = @educationFormId)
    IF @type = 'webinar'
        RETURN 1
    IF @type = 'course'
        RETURN (SELECT dbo.canJoinCourse(@specificId))
    IF @type = 'studies'
        RETURN (SELECT dbo.canJoinStudies(@specificId))
    RETURN 1
END
GO

CREATE FUNCTION canJoinCourse(@courseId int) RETURNS bit AS
BEGIN
    DECLARE
        @freeSlots int
    SELECT @freeSlots = dbo.getFreeCourseSlots(@courseId)
    IF @freeSlots > 0
        RETURN 1
    RETURN 0
END
GO

CREATE FUNCTION canJoinStudies(@studiesId int) RETURNS bit AS
BEGIN
    DECLARE
        @freeSlots int
    SELECT @freeSlots = dbo.getFreeStudiesSlots(@studiesId)
    IF @freeSlots > 0
        RETURN 1
    RETURN 0
END
GO

CREATE FUNCTION courseAttendancePercent(@courseId int, @userId int) RETURNS float
AS
BEGIN
    DECLARE
        @percentage float = (SELECT ROUND(CAST(COUNT(*) * 1.0 / (SELECT COUNT(*)
                                                                 FROM (SELECT meetingId
                                                                       FROM OnlineMeetings
                                                                       WHERE moduleId IN (SELECT moduleId FROM Modules WHERE courseId = @courseId)
                                                                       UNION
                                                                       SELECT meetingId
                                                                       FROM OfflineMeetings
                                                                       WHERE moduleId IN (SELECT moduleId FROM Modules WHERE courseId = @courseId)) AS OMmIOMmI) AS float),
                                          2)
                             FROM Attendance
                             WHERE userId = @userId)
    RETURN @percentage
END
GO

-- SELECT * FROM dbo.upcomingEducationFormForUser(15)
CREATE FUNCTION doesDatesOverlap(@date1 date, @startTime1 time, @endTime1 time, @date2 date, @startTime2 time,
                                 @endTime2 time)
    RETURNS bit AS
BEGIN
    DECLARE
        @overlap bit
    SET @overlap = 0
    IF @date1 = @date2
        IF (@startTime1 BETWEEN @startTime2 AND @endTime2
            OR @endTime1 BETWEEN @startTime2 AND @endTime2
            OR @startTime2 BETWEEN @startTime1 AND @endTime1
            OR @endTime2 BETWEEN @startTime1 AND @endTime1)
            SET @overlap = 1
    RETURN @overlap
END
GO

CREATE FUNCTION doesUserHasAccessToSingleStudiesMeeting(@userId int, @studiesMeetingId int) RETURNS bit AS
BEGIN
    DECLARE
        @studiesId int = (SELECT TOP 1 studiesId
                          FROM StudiesMeetings SM
                                   JOIN StudiesSchedules SS ON SM.scheduleId = SS.scheduleId
                          WHERE studiesMeetingId = @studiesMeetingId)
    IF EXISTS(SELECT * FROM Students WHERE userId = @userId AND studiesId = @studiesId)
        RETURN 1
    IF EXISTS(SELECT *
              FROM PaymentsHistory
              WHERE userId = @userId
                AND paymentDetails LIKE '%studiesMeetingId=' + CAST(@studiesMeetingId AS varchar(255)) + '%')
        RETURN 1
    RETURN 0
END
GO

CREATE FUNCTION emptyRooms(@date date, @startTime time, @endTime time)
    RETURNS TABLE
        RETURN(SELECT place, room
               FROM Rooms R
               WHERE R.room NOT IN (SELECT OM.room
                                    FROM OfflineMeetings OM
                                             JOIN Meetings M ON OM.meetingId = M.meetingId
                                    WHERE dbo.doesDatesOverlap(@date, @startTime, @endTime, date, date,
                                                               DATEADD(MINUTE, duration, date)) = 1
                                    UNION
                                    SELECT room
                                    FROM OfflineStudiesMeetings OSM
                                             JOIN StudiesMeetings SM ON OSM.studiesMeetingId = SM.studiesMeetingId
                                    WHERE dbo.doesDatesOverlap(@date, @startTime, @endTime, date, date,
                                                               DATEADD(MINUTE, duration, date)) = 1))
GO

CREATE FUNCTION getCartForUser(@userId int)
    RETURNS TABLE
        RETURN(WITH educationFormsWithPrices
                        AS (SELECT EF.educationFormId, specificId, type, advance, advanceDue, wholePrice
                            FROM Cart C
                                     JOIN EducationForms EF ON C.educationFormId = EF.educationFormId
                                     LEFT JOIN EducationFormPrice EFP ON EF.educationFormId = EFP.educationFormId
                            WHERE userId = @userId)
               SELECT educationFormId, specificId, title, type, advance, advanceDue, wholePrice
               FROM educationFormsWithPrices EFP
                        JOIN Courses CO ON EFP.specificId = CO.courseId AND EFP.type = 'course'
               UNION
               SELECT educationFormId, specificId, title, type, advance, advanceDue, wholePrice
               FROM educationFormsWithPrices EFP
                        JOIN Webinars W ON EFP.specificId = W.webinarId AND EFP.type = 'webinar'
                        JOIN WebinarDetails WD ON W.webinarDetailsId = WD.webinarDetailsId
               UNION
               SELECT educationFormId, specificId, title, type, advance, advanceDue, entryFee AS wholePrice
               FROM educationFormsWithPrices EFP
                        JOIN Studies ON EFP.specificId = Studies.studiesId AND EFP.type = 'studies')
GO

CREATE FUNCTION getEducationFormEndDate(@educationFormId int) RETURNS date AS
BEGIN
    DECLARE
        @type varchar(255) = (SELECT type
                              FROM EducationForms
                              WHERE educationFormId = @educationFormId)
    DECLARE
        @specificId int = (SELECT specificId
                           FROM EducationForms
                           WHERE educationFormId = @educationFormId)

    IF @specificId IS NULL
        RETURN NULL
    IF @type = 'course'
        RETURN (SELECT finishDate
                FROM coursesStartEnd
                WHERE courseId = @specificId)
    IF @type = 'webinar'
        RETURN (SELECT date
                FROM Webinars W
                         JOIN WebinarMeetings WM ON W.onlineMeetingId = WM.onlineMeetingId
                WHERE W.webinarId = @specificId)
    RETURN NULL
END
GO

GRANT EXECUTE ON getEducationFormEndDate TO student
GO

GRANT EXECUTE ON getEducationFormEndDate TO studies_admin
GO

GRANT EXECUTE ON getEducationFormEndDate TO teacher
GO

CREATE FUNCTION getFreeCourseSlots(@courseId int) RETURNS int AS
BEGIN
    DECLARE
        @enrolledUsers int
    SELECT @enrolledUsers = COUNT(userId)
    FROM Courses C
             JOIN EducationForms EF ON C.courseId = EF.specificId AND EF.type = 'course'
             JOIN AssignedEducationForms AEF ON EF.educationFormId = AEF.educationFormId
    WHERE courseId = @courseId
    GROUP BY EF.educationFormId
    DECLARE
        @slotsLimit int
    SELECT @slotsLimit = slotsLimit
    FROM Courses
    WHERE courseId = @courseId
    RETURN @slotsLimit - @enrolledUsers
END
GO

CREATE FUNCTION getFreeStudiesSlots(@studiesId int) RETURNS int AS
BEGIN
    DECLARE
        @enrolledUsers int
    SELECT @enrolledUsers = COUNT(userId)
    FROM AwaitingStudents
    WHERE studiesId = @studiesId
    DECLARE
        @slotsLimit int
    SELECT @slotsLimit = slotsLimit
    FROM Studies
    WHERE studiesId = @studiesId
    RETURN @slotsLimit - @enrolledUsers
END
GO

CREATE FUNCTION getStudentGrades(@userId int, @studiesId int)
    RETURNS TABLE
        RETURN(SELECT ST.title AS studiesName, S.title AS subjectTitle, grade
               FROM StudentsGrades SG
                        JOIN Exams E ON SG.examId = E.examId
                        JOIN Grades G ON SG.gradeId = G.gradeId
                        JOIN Subjects S ON E.subjectId = S.subjectId
                        JOIN Studies ST ON E.studiesId = ST.studiesId
               WHERE SG.userId = @userId
                 AND (@studiesId IS NULL OR E.studiesId = @studiesId))
GO

CREATE FUNCTION getStudiesMeetingPrice(@studiesMeetingId int) RETURNS money AS
BEGIN
    DECLARE
        @studiesId int = (SELECT TOP 1 studiesId
                          FROM StudiesMeetings SM
                                   JOIN StudiesSchedules SS ON SM.scheduleId = SS.scheduleId
                          WHERE studiesMeetingId = @studiesMeetingId)
    RETURN (SELECT meetFee
            FROM Studies
            WHERE studiesId = @studiesId)
END
GO

CREATE FUNCTION getUnwatchedRecording(@userId int, @courseId int)
    RETURNS TABLE
        RETURN(SELECT recordingId, C.title AS courseTitle, M.title AS moduleTitle
               FROM AssignedEducationForms AEF
                        JOIN EducationForms EF ON AEF.educationFormId = EF.educationFormId
                        JOIN Courses C ON EF.specificId = C.courseId AND type = 'course'
                        JOIN Modules M ON C.courseId = M.courseId
                        JOIN Recordings R ON M.moduleId = R.moduleId
               WHERE userId NOT IN (SELECT userId FROM WatchedBy WHERE recordingId = R.recordingId)
                 AND AEF.userId = @userId
                 AND (@courseId IS NULL OR C.courseId = @courseId))
GO

CREATE FUNCTION getUserEducationForms(@userId INT)
    RETURNS TABLE AS
        RETURN(SELECT aef.educationFormId
               FROM AssignedEducationForms aef
                        INNER JOIN Users u ON aef.userId = u.userId
               WHERE aef.userId = @userId
                 AND aef.accessUntil >= GETDATE())
GO

CREATE FUNCTION getUsersUnpayedEducationForms(@userId INT)
    RETURNS TABLE AS
        RETURN(SELECT *
               FROM (SELECT ef2.educationFormId,
                            (SELECT SUM(efp.wholePrice)
                             FROM Users u
                                      INNER JOIN AssignedEducationForms aef
                                                 ON aef.userId = u.userId
                                      INNER JOIN EducationForms ef
                                                 ON ef.educationFormId = aef.educationFormId
                                      INNER JOIN EducationFormPrice efp
                                                 ON efp.educationFormId = ef.educationFormId
                                      INNER JOIN EducationFormPaymentsDue efpd
                                                 ON efpd.educationFormId = ef.educationFormId
                             WHERE (efpd.advanceDue > GETDATE() OR efpd.advanceDue IS NULL)
                               AND u.userId = @userId
                               AND ef.educationFormId = ef2.educationFormId
                             GROUP BY u.userId) - (SELECT SUM(amount)
                                                   FROM PaymentsHistory ph
                                                   WHERE ph.userId = @userId
                                                     AND ef2.educationFormId = ph.payedFor
                                                   GROUP BY ph.userId) AS amoutToPay
                     FROM EducationForms ef2
                              INNER JOIN AssignedEducationForms aef
                                         ON aef.educationFormId = ef2.educationFormId
                              INNER JOIN users u
                                         ON u.userId = aef.userId
                     WHERE u.userId = @userId) AS result
               WHERE amoutToPay > 0)
GO

CREATE FUNCTION studentsWhichDidntFulfillPractices(@studiesId int)
    RETURNS TABLE as return(SELECT S.userId, COUNT(*) AS practicesCount
                            FROM Students S
                                     JOIN Practices P ON S.userId = P.userId AND P.studiesId = @studiesId
                            WHERE S.studiesId = @studiesId
                            GROUP BY S.userId
                            HAVING COUNT(*) < 2)
GO

CREATE FUNCTION upcomingEducationFormForUser(@userId int)
    RETURNS TABLE
        RETURN(WITH T AS (SELECT title, 'course' AS type, startDate
                          FROM Courses C
                                   JOIN upcomingCourses UC ON C.courseId = UC.courseId
                                   JOIN coursesStartEnd CSE ON C.courseId = CSE.courseId
                                   JOIN EducationForms EF ON C.courseId = EF.specificId AND EF.type = 'course'
                                   JOIN AssignedEducationForms AEF ON EF.educationFormId = AEF.educationFormId
                          WHERE userId = @userId
                          UNION
                          SELECT title, 'webinar' AS type, date AS startDate
                          FROM Webinars W
                                   JOIN upcomingWebinars UW ON W.webinarId = UW.webinarId
                                   JOIN WebinarDetails WD ON W.webinarDetailsId = WD.webinarDetailsId
                                   JOIN WebinarMeetings WM ON W.onlineMeetingId = WM.onlineMeetingId
                                   JOIN EducationForms EF ON W.webinarId = EF.specificId AND EF.type = 'webinar'
                                   JOIN AssignedEducationForms AEF ON EF.educationFormId = AEF.educationFormId
                          WHERE userId = @userId)
               SELECT title,
                      type,
                      startDate
               FROM T)
GO

CREATE FUNCTION usersWithRole(@role varchar(255))
    RETURNS table as
        return(SELECT users.name, users.surname, RoleDetails.roleName
               FROM roles
                        INNER JOIN Users ON Users.userId = Roles.userId
                        INNER JOIN RoleDetails ON roles.roleId = RoleDetails.roleId
               WHERE roleName = @role)
GO


