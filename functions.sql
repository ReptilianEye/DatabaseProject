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

CREATE FUNCTION nextWebinarMeeting() RETURNS int AS
BEGIN
    DECLARE @nextId int;
    SELECT @nextId = MAX(onlineMeetingId) + 1 FROM WebinarMeetings;
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
--
CREATE FUNCTION nextSyllabusId() RETURNS INT AS
BEGIN
    DECLARE @nextId int;
    SELECT @nextId = MAX(syllabusId) + 1 FROM Syllabuses;
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