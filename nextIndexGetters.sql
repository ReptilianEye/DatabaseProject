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

create function nextCourseId() returns int as
begin
    declare @nextId int;
    select @nextId = max(courseId) + 1 from Courses;
    if @nextId is null
        set @nextId = 1;
    return @nextId;
end
GO

create function nextCourseModuleId() returns int as
begin
    declare @nextId int;
    select @nextId = max(moduleId) + 1 from Modules;
    if @nextId is null
        set @nextId = 1;
    return @nextId;
end
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

create function nextMeetingId() returns int as
    begin
        declare @nextId int;
        select @nextId = max(meetingId) + 1 from Meetings;
        if @nextId is null
            set @nextId = 1;
        return @nextId;
    end
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

create function nextStudiesMeetingId() returns int as
    begin
        declare @nextId int;
        select @nextId = max(studiesMeetingId) + 1 from StudiesMeetings;
        if @nextId is null
            set @nextId = 1;
        return @nextId;
    end
GO

create function  nextStudiesScheduleId() returns int as
    begin
        declare @nextId int;
        select @nextId = max(scheduleId) + 1 from StudiesSchedules;
        if @nextId is null
            set @nextId = 1;
        return @nextId;
    end
GO

create function nextSubjectId() returns int as
begin
    declare @nextId int;
    select @nextId = max(subjectId) + 1 from Subjects;
    if @nextId is null
    begin
        set @nextId = 1;
    end
    return @nextId;
end
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

CREATE function nextWebinarDetailsId() returns int as
begin
    declare @nextId int;
    select @nextId = max(webinarDetailsId) + 1 from WebinarDetails;
    if @nextId is null
        set @nextId = 1;
    return @nextId;
end
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

