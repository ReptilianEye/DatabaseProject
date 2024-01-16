-- functions in that file:
-- nextUserId()
-- nextEducationFormId()
-- nextCourseId()
-- nextCourseModuleId()
-- nextWebinarId()
-- nextMeetingId()
-- nextWebinarMeeting()
-- nextStudiesId()
-- nextStudiesMeetingId()
-- nextStudiesScheduleId()
-- nextSyllabusId()
-- nextRecordingId()
-- nextRoleId()
-- nextPermissionId()
-- nextExamId()
-- nextAcademicsTitleId()

CREATE FUNCTION nextUserId() RETURNS int AS
BEGIN
    DECLARE @nextId int;
    SELECT @nextId = MAX(userId) + 1 FROM Users;
    IF @nextId IS NULL
        SET @nextId = 1;
    RETURN @nextId;
END;
CREATE FUNCTION nextEducationFormId() RETURNS int AS
BEGIN
    DECLARE @nextId int;
    SELECT @nextId = MAX(educationFormId) + 1 FROM EducationForms;
    IF @nextId IS NULL
        SET @nextId = 1;
    RETURN @nextId;
END;
CREATE FUNCTION nextCourseId() RETURNS int AS
BEGIN
    DECLARE @nextId int;
    SELECT @nextId = MAX(courseId) + 1 FROM Courses;
    IF @nextId IS NULL
        SET @nextId = 1;
    RETURN @nextId;
END;

CREATE FUNCTION nextCourseModuleId() RETURNS int AS
BEGIN
    DECLARE @nextId int;
    SELECT @nextId = MAX(moduleId) + 1 FROM Modules;
    IF @nextId IS NULL
        SET @nextId = 1;
    RETURN @nextId;
END;

CREATE FUNCTION nextWebinarId() RETURNS int AS
BEGIN
    DECLARE @nextId int;
    SELECT @nextId = MAX(webinarId) + 1 FROM Webinars;
    IF @nextId IS NULL
        SET @nextId = 1;
    RETURN @nextId;
END;


CREATE FUNCTION nextMeetingId() RETURNS int AS
BEGIN
    DECLARE @nextId int;
    SELECT @nextId = MAX(meetingId) + 1 FROM Meetings;
    IF @nextId IS NULL
        SET @nextId = 1;
    RETURN @nextId;
END;
CREATE FUNCTION nextRecordingId() RETURNS INT AS
BEGIN
    DECLARE @nextId int;
    SELECT @nextId = MAX(recordingId) + 1 FROM Recordings;
    IF @nextId IS NULL
        SET @nextId = 1;
    RETURN @nextId;
END;

CREATE FUNCTION nextWebinarMeeting() RETURNS int AS
BEGIN
    DECLARE @nextId int;
    SELECT @nextId = MAX(onlineMeetingId) + 1 FROM WebinarMeetings;
    IF @nextId IS NULL
        SET @nextId = 1;
    RETURN @nextId;
END;
CREATE FUNCTION nextStudiesId() RETURNS int AS
BEGIN
    DECLARE @nextId int;
    SELECT @nextId = MAX(studiesId) + 1 FROM Studies;
    IF @nextId IS NULL
        SET @nextId = 1;
    RETURN @nextId;
END;
CREATE FUNCTION nextStudiesMeetingId() RETURNS int AS
BEGIN
    DECLARE @nextId int;
    SELECT @nextId = MAX(studiesMeetingId) + 1 FROM StudiesMeetings;
    IF @nextId IS NULL
        SET @nextId = 1;
    RETURN @nextId;
END;

CREATE FUNCTION nextStudiesScheduleId() RETURNS int AS
BEGIN
    DECLARE @nextId int;
    SELECT @nextId = MAX(scheduleId) + 1 FROM StudiesSchedules;
    IF @nextId IS NULL
        SET @nextId = 1;
    RETURN @nextId;
END;

CREATE FUNCTION nextSyllabusId() RETURNS INT AS
BEGIN
    DECLARE @nextId int;
    SELECT @nextId = MAX(syllabusId) + 1 FROM Syllabuses;
    IF @nextId IS NULL
        SET @nextId = 1;
    RETURN @nextId;
END;
CREATE FUNCTION nextRoleId() RETURNS INT AS
BEGIN
    DECLARE @nextId int;
    SELECT @nextId = MAX(roleId) + 1 FROM RoleDetails;
    IF @nextId IS NULL
        SET @nextId = 1;
    RETURN @nextId;
END;
CREATE FUNCTION nextPermissionId() RETURNS INT AS
BEGIN
    DECLARE @nextId int;
    SELECT @nextId = MAX(permissionId) + 1 FROM Permissions;
    IF @nextId IS NULL
        SET @nextId = 1;
    RETURN @nextId;
END;
CREATE FUNCTION nextExamId() RETURNS INT AS
BEGIN
    DECLARE @nextId int;
    SELECT @nextId = MAX(examId) + 1 FROM Exams;
    IF @nextId IS NULL
        SET @nextId = 1;
    RETURN @nextId;
END;
CREATE FUNCTION nextAcademicsTitleId() RETURNS INT AS
BEGIN
    DECLARE @nextId int;
    SELECT @nextId = MAX(academicTitleId) + 1 FROM AcademicsTitles;
    IF @nextId IS NULL
        SET @nextId = 1;
    RETURN @nextId;
END;
CREATE FUNCTION nextStateId() RETURNS INT AS
BEGIN
    DECLARE @nextId int;
    SELECT @nextId = MAX(stateId) + 1 FROM States;
    IF @nextId IS NULL
        SET @nextId = 1;
    RETURN @nextId;
END;
CREATE FUNCTION nextCityId() RETURNS INT AS
BEGIN
    DECLARE @nextId int;
    SELECT @nextId = MAX(cityId) + 1 FROM Cities;
    IF @nextId IS NULL
        SET @nextId = 1;
    RETURN @nextId;
END;
CREATE FUNCTION nextStreetId() RETURNS INT AS
BEGIN
    DECLARE @nextId int;
    SELECT @nextId = MAX(streetId) + 1 FROM Streets;
    IF @nextId IS NULL
        SET @nextId = 1;
    RETURN @nextId;
END;
CREATE FUNCTION studentsWhichDidntFulfillPractices(@studiesId int)
    RETURNS TABLE as return
            (
                SELECT S.userId, COUNT(*) AS practicesCount
                FROM Students S
                         JOIN Practices P ON S.userId = P.userId AND P.studiesId = @studiesId
                WHERE S.studiesId = @studiesId
                GROUP BY S.userId
                HAVING COUNT(*) < 2
            )
-- SELECT * from dbo.studentsWhichDidntFulfillPractices(4)
CREATE FUNCTION getStudentGrades(@userId int, @studiesId int)
    RETURNS TABLE RETURN
            (
                SELECT name AS studiesName, title AS subjectTitle, grade
                FROM StudentsGrades SG
                         JOIN Exams E ON SG.examId = E.examId
                         JOIN Grades G ON SG.gradeId = G.gradeId
                         JOIN Subjects S ON E.subjectId = S.subjectId
                         JOIN Studies ST ON E.studiesId = ST.studiesId
                WHERE SG.userId = @userId
                  AND (@studiesId IS NULL OR E.studiesId = @studiesId)
            )

-- SELECT * FROM dbo.getStudentGrades(8, NULL)
-- SELECT * FROM dbo.getStudentGrades(8, 1)

CREATE FUNCTION getUnwatchedRecording(@userId int, @courseId int)
    RETURNS TABLE RETURN
            (
                SELECT recordingId, C.title AS courseTitle, M.title AS moduleTitle
                FROM AssignedEducationForms AEF
                         JOIN EducationForms EF ON AEF.educationFormId = EF.educationFormId
                         JOIN Courses C ON EF.specificId = C.courseId AND type = 'course'
                         JOIN Modules M ON C.courseId = M.courseId
                         JOIN Recordings R ON M.moduleId = R.moduleId
                WHERE userId NOT IN (SELECT userId FROM WatchedBy WHERE recordingId = R.recordingId)
                  AND AEF.userId = @userId
                  AND (@courseId IS NULL OR C.courseId = @courseId)
            )

-- SELECT *
-- FROM dbo.getUnwatchedRecording(35, NULL)

CREATE FUNCTION getFreeSlots(@courseId int) RETURNS int AS
BEGIN
    DECLARE @enrolledUsers int
    SELECT @enrolledUsers = COUNT(userId)
    FROM Courses C
             JOIN EducationForms EF ON C.courseId = EF.specificId AND EF.type = 'course'
             JOIN AssignedEducationForms AEF ON EF.educationFormId = AEF.educationFormId
    WHERE courseId = 1002
    GROUP BY EF.educationFormId
    DECLARE @slotsLimit int
    SELECT @slotsLimit = slotsLimit FROM Courses WHERE courseId = @courseId
    RETURN @slotsLimit - @enrolledUsers
END
-- SELECT dbo.getFreeSlots(1002) AS freeSlots


CREATE FUNCTION upcomingEducationFormForUser(@userId int)
    RETURNS TABLE RETURN
            (
                WITH T AS (SELECT title, 'course' AS type, startDate
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
                                    JOIN WebinarDetails WD ON W.webinarId = WD.webinarId
                                    JOIN WebinarMeetings WM ON W.onlineMeetingId = WM.onlineMeetingId
                                    JOIN EducationForms EF ON W.webinarId = EF.specificId AND EF.type = 'webinar'
                                    JOIN AssignedEducationForms AEF ON EF.educationFormId = AEF.educationFormId
                           WHERE userId = @userId)
                SELECT title,
                       type,
                       startDate
                FROM T
            )
-- SELECT * FROM dbo.upcomingEducationFormForUser(15)

CREATE FUNCTION doesDatesOverlap(@date1 date, @startTime1 time, @endTime1 time, @date2 date, @startTime2 time,
                                 @endTime2 time)
    RETURNS bit AS
BEGIN
    DECLARE @overlap bit
    SET @overlap = 0
    IF @date1 = @date2
        IF (@startTime1 BETWEEN @startTime2 AND @endTime2
            OR @endTime1 BETWEEN @startTime2 AND @endTime2
            OR @startTime2 BETWEEN @startTime1 AND @endTime1
            OR @endTime2 BETWEEN @startTime1 AND @endTime1)
            SET @overlap = 1
    RETURN @overlap
END
CREATE FUNCTION emptyRooms(@date date, @startTime time, @endTime time)
    RETURNS TABLE RETURN
            (
                SELECT place, room
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
                                                                DATEADD(MINUTE, duration, date)) = 1)
            )

-- SELECT *
-- FROM dbo.emptyRooms('2023-07-25', '19:00', '20:00')
-- WHERE room='3'
-- SELECT * from OfflineStudiesMeetings
-- join dbo.StudiesMeetings SM ON OfflineStudiesMeetings.studiesMeetingId = SM.studiesMeetingId
-- WHERE cast(date as date)  ='2023-07-25'

