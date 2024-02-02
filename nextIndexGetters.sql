CREATE FUNCTION nextAcademicsTitleId() RETURNS INT AS
BEGIN
    DECLARE @nextId int;
    SELECT @nextId = MAX(academicTitleId) + 1 FROM AcademicsTitles;
    IF @nextId IS NULL
        SET @nextId = 1;
    RETURN @nextId;
END
GO

CREATE FUNCTION nextCityId() RETURNS INT AS
BEGIN
    DECLARE @nextId int;
    SELECT @nextId = MAX(cityId) + 1 FROM Cities;
    IF @nextId IS NULL
        SET @nextId = 1;
    RETURN @nextId;
END
GO

CREATE FUNCTION nextCourseId() RETURNS int AS
BEGIN
    DECLARE @nextId int;
    SELECT @nextId = MAX(courseId) + 1 FROM Courses;
    IF @nextId IS NULL
        SET @nextId = 1;
    RETURN @nextId;
END
GO

CREATE FUNCTION nextCourseModuleId() RETURNS int AS
BEGIN
    DECLARE @nextId int;
    SELECT @nextId = MAX(moduleId) + 1 FROM Modules;
    IF @nextId IS NULL
        SET @nextId = 1;
    RETURN @nextId;
END
GO

CREATE FUNCTION nextEducationFormId() RETURNS int AS
BEGIN
    DECLARE @nextId int;
    SELECT @nextId = MAX(educationFormId) + 1 FROM EducationForms;
    IF @nextId IS NULL
        SET @nextId = 1;
    RETURN @nextId;
END
GO

CREATE FUNCTION nextExamId() RETURNS INT AS
BEGIN
    DECLARE @nextId int;
    SELECT @nextId = MAX(examId) + 1 FROM Exams;
    IF @nextId IS NULL
        SET @nextId = 1;
    RETURN @nextId;
END
GO

CREATE FUNCTION nextMeetingId() RETURNS int AS
BEGIN
    DECLARE @nextId int;
    SELECT @nextId = MAX(meetingId) + 1 FROM Meetings;
    IF @nextId IS NULL
        SET @nextId = 1;
    RETURN @nextId;
END
GO

CREATE FUNCTION nextPaymentId() RETURNS INT AS
BEGIN
    DECLARE @nextId int;
    SELECT @nextId = MAX(paymentId) + 1 FROM PaymentsHistory;
    IF @nextId IS NULL
        SET @nextId = 1;
    RETURN @nextId;
END
GO

CREATE FUNCTION nextPermissionId() RETURNS INT AS
BEGIN
    DECLARE @nextId int;
    SELECT @nextId = MAX(permissionId) + 1 FROM Permissions;
    IF @nextId IS NULL
        SET @nextId = 1;
    RETURN @nextId;
END
GO

CREATE FUNCTION nextPriceId() RETURNS INT AS
BEGIN
    DECLARE @nextId int;
    SELECT @nextId = MAX(priceId) + 1 FROM EducationFormPrice;
    IF @nextId IS NULL
        SET @nextId = 1;
    RETURN @nextId;
END
GO

CREATE FUNCTION nextRecordingId() RETURNS INT AS
BEGIN
    DECLARE @nextId int;
    SELECT @nextId = MAX(recordingId) + 1 FROM Recordings;
    IF @nextId IS NULL
        SET @nextId = 1;
    RETURN @nextId;
END
GO

CREATE FUNCTION nextRoleId() RETURNS INT AS
BEGIN
    DECLARE @nextId int;
    SELECT @nextId = MAX(roleId) + 1 FROM RoleDetails;
    IF @nextId IS NULL
        SET @nextId = 1;
    RETURN @nextId;
END
GO

CREATE FUNCTION nextStateId() RETURNS INT AS
BEGIN
    DECLARE @nextId int;
    SELECT @nextId = MAX(stateId) + 1 FROM States;
    IF @nextId IS NULL
        SET @nextId = 1;
    RETURN @nextId;
END
GO

CREATE FUNCTION nextStudiesId() RETURNS int AS
BEGIN
    DECLARE @nextId int;
    SELECT @nextId = MAX(studiesId) + 1 FROM Studies;
    IF @nextId IS NULL
        SET @nextId = 1;
    RETURN @nextId;
END
GO

CREATE FUNCTION nextStudiesMeetingId() RETURNS int AS
BEGIN
    DECLARE @nextId int;
    SELECT @nextId = MAX(studiesMeetingId) + 1 FROM StudiesMeetings;
    IF @nextId IS NULL
        SET @nextId = 1;
    RETURN @nextId;
END
GO

CREATE FUNCTION nextStudiesScheduleId() RETURNS int AS
BEGIN
    DECLARE @nextId int;
    SELECT @nextId = MAX(scheduleId) + 1 FROM StudiesSchedules;
    IF @nextId IS NULL
        SET @nextId = 1;
    RETURN @nextId;
END
GO

CREATE FUNCTION nextSubjectId() RETURNS int AS
BEGIN
    DECLARE @nextId int;
    SELECT @nextId = MAX(subjectId) + 1 FROM Subjects;
    IF @nextId IS NULL
        BEGIN
            SET @nextId = 1;
        END
    RETURN @nextId;
END
GO

CREATE FUNCTION nextSyllabusId() RETURNS INT AS
BEGIN
    DECLARE @nextId int;
    SELECT @nextId = MAX(syllabusId) + 1 FROM Syllabuses;
    IF @nextId IS NULL
        SET @nextId = 1;
    RETURN @nextId;
END
GO

CREATE FUNCTION nextUserId() RETURNS int AS
BEGIN
    DECLARE @nextId int;
    SELECT @nextId = MAX(userId) + 1 FROM Users;
    IF @nextId IS NULL
        SET @nextId = 1;
    RETURN @nextId;
END
GO

CREATE FUNCTION nextWebinarDetailsId() RETURNS int AS
BEGIN
    DECLARE @nextId int;
    SELECT @nextId = MAX(webinarDetailsId) + 1 FROM WebinarDetails;
    IF @nextId IS NULL
        SET @nextId = 1;
    RETURN @nextId;
END
GO

CREATE FUNCTION nextWebinarMeeting() RETURNS int AS
BEGIN
    DECLARE @nextId int;
    SELECT @nextId = MAX(onlineMeetingId) + 1 FROM WebinarMeetings;
    IF @nextId IS NULL
        SET @nextId = 1;
    RETURN @nextId;
END
GO

