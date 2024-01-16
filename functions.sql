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

