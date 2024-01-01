CREATE TABLE [Users]
(
    [userId]           int PRIMARY KEY NOT NULL,
    [name]             nvarchar(255)   NOT NULL,
    [surname]          nvarchar(255)   NOT NULL,
    [email]            nvarchar(255)   NOT NULL,
    [city]             nvarchar(255),
    [street]           nvarchar(255),
    [state]            nvarchar(255),
    [zip]              nvarchar(255),
    [houseNumber]      nvarchar(10),
    [creditCardNumber] nvarchar(255)
)
GO

CREATE TABLE [States]
(
    [stateId] int PRIMARY KEY NOT NULL,
    [state]   nvarchar(255)   NOT NULL
)
GO

CREATE TABLE [Cities]
(
    [cityId]  int PRIMARY KEY NOT NULL,
    [stateId] int             NOT NULL,
    [city]    nvarchar(255)   NOT NULL
)
GO

CREATE TABLE [Streets]
(
    [streetId] int PRIMARY KEY NOT NULL,
    [cityId]   int             NOT NULL,
    [street]   nvarchar(255)   NOT NULL
)
GO

CREATE TABLE [AssignedEducationForms]
(
    [userId]          int  NOT NULL,
    [educationFormId] int  NOT NULL,
    [accessUntil]     date NOT NULL,
    PRIMARY KEY ([userId], [educationFormId])
)
GO

CREATE TABLE [EducationForms]
(
    [educationFormId] int PRIMARY KEY NOT NULL,
    [specificId]      int             NOT NULL,
    [type]            nvarchar(255)   NOT NULL
)
CREATE UNIQUE NONCLUSTERED INDEX SPECIFIC_EDUCATION_FORM
   ON [EducationForms] (specificId, type);
GO
CREATE TABLE [EducationFormsTranslators]
(
    [educationFormId] int NOT NULL,
    [translatorId]    int NOT NULL,
    PRIMARY KEY ([educationFormId], [translatorId])
)
GO
ALTER TABLE [EducationFormsTranslators]
    ADD FOREIGN KEY ([translatorId]) REFERENCES [Translators] ([translatorId])
GO

ALTER TABLE [EducationFormsTranslators]
    ADD FOREIGN KEY ([educationFormId]) REFERENCES [EducationForms] ([educationFormId])
GO

CREATE TABLE [Roles]
(
    [roleId] int PRIMARY KEY NOT NULL,
    [userId] int             NOT NULL
)
GO

CREATE TABLE [RoleDetails]
(
    [roleId]         int PRIMARY KEY NOT NULL,
    [roleName]       nvarchar(255)   NOT NULL,
    [hierarchyLevel] int             NOT NULL
)
GO

CREATE TABLE [Permissions]
(
    [permissionId] int PRIMARY KEY NOT NULL,
    [roleId]       int             NOT NULL,
    [permission]   nvarchar(255)   NOT NULL
)
GO

CREATE TABLE [Teachers]
(
    [teacherId]       int PRIMARY KEY NOT NULL,
    [academicTitleId] int             NOT NULL
)
GO

CREATE TABLE [AcademicsTitles]
(
    [academicTitleId] int PRIMARY KEY NOT NULL,
    [academicTitle]   nvarchar(255)   NOT NULL
)
GO

CREATE TABLE [Translators]
(
    [translatorId] int PRIMARY KEY NOT NULL
)
GO

CREATE TABLE [LanguagesDetails]
(
    [languageId] int PRIMARY KEY NOT NULL,
    [language]   nvarchar(255)   NOT NULL
)
GO

CREATE TABLE [Languages]
(
    [languageId]   int NOT NULL,
    [translatorId] int NOT NULL,
    PRIMARY KEY ([languageId], [translatorId])
)
GO

CREATE TABLE [WebinarDetails]
(
    [webinarDetailsId] int PRIMARY KEY NOT NULL,
    [webinarId]        int  UNIQUE        NOT NULL,
    [title]            nvarchar(255)   NOT NULL,
    [description]      nvarchar(255)   NOT NULL,
    [price]            money           NOT NULL
)
GO

CREATE TABLE [Webinars]
(
    [webinarId]       int PRIMARY KEY NOT NULL,
    [onlineMeetingId] int  UNIQUE            NOT NULL
)
GO

CREATE TABLE [Studies]
(
    [studiesId]  int PRIMARY KEY NOT NULL,
    [syllabusId] int             NOT NULL,
    [entryFee]   money           NOT NULL,
    [meetFee]    money,
    [slotsLimit] int             NOT NULL
)
GO

CREATE TABLE [Syllabuses]
(
    [syllabusId] int NOT NULL,
    [subjectId]  int NOT NULL,
    PRIMARY KEY ([syllabusId], [subjectId])
)
GO

CREATE TABLE [Exams]
(
    [examId]    int PRIMARY KEY NOT NULL,
    [studiesId] int             NOT NULL,
    [subjectId] int             NOT NULL
)
GO

CREATE TABLE [StudentsGrades]
(
    [examId]  int NOT NULL,
    [userId]  int NOT NULL,
    [gradeId] int NOT NULL,
    PRIMARY KEY ([examId], [userId])
)
GO

CREATE TABLE [Grades]
(
    [gradeId] int PRIMARY KEY NOT NULL,
    [grade]   float           NOT NULL
)
GO

CREATE TABLE [TeachersSubjects]
(
    [teacherId] int NOT NULL,
    [subjectId] int NOT NULL,
    PRIMARY KEY ([teacherId], [subjectId])
)
GO

CREATE TABLE [Subjects]
(
    [subjectId]   int PRIMARY KEY NOT NULL,
    [title]       nvarchar(255)   NOT NULL,
    [description] varchar(1000),
    [ECTS]        int             NOT NULL
        check (ECTS > 0)
)
GO

CREATE TABLE [Courses]
(
    [courseId]   int PRIMARY KEY NOT NULL,
    [slotsLimit] int
        check (slotsLimit > 0)
)
GO

CREATE TABLE [Modules]
(
    [moduleId] int PRIMARY KEY NOT NULL,
    [courseId] int             NOT NULL
)
GO

CREATE TABLE [StationaryModules]
(
    [id]       int PRIMARY KEY NOT NULL,
    [moduleId] int             NOT NULL
)
GO

CREATE TABLE [OnlineSyncModules]
(
    [id]       int PRIMARY KEY NOT NULL,
    [moduleId] int             NOT NULL
)
GO

CREATE TABLE [OnlineAsyncModules]
(
    [id]       int PRIMARY KEY NOT NULL,
    [moduleId] int             NOT NULL
)
GO

CREATE TABLE [HybridModules]
(
    [id]       int PRIMARY KEY NOT NULL,
    [moduleId] int             NOT NULL
)
GO

CREATE TABLE [WebinarMeetings]
(
    [onlineMeetingId] int PRIMARY KEY NOT NULL,
    [link]            nvarchar(255)   NOT NULL,
    [recordingLink]   nvarchar(255),
    [date]            datetime        NOT NULL
)
GO

CREATE TABLE [Meetings]
(
    [meetingId] int PRIMARY KEY NOT NULL,
    [date]      datetime        NOT NULL
)
GO

CREATE TABLE [OfflineMeetings]
(
    [meetingId] int PRIMARY KEY NOT NULL,
    [moduleId]  int             NOT NULL,
    [place]     nvarchar(255)   NOT NULL
)
GO

CREATE TABLE [OnlineMeetings]
(
    [meetingId] int PRIMARY KEY NOT NULL,
    [moduleId]  int             NOT NULL,
    [link]      nvarchar(255)   NOT NULL
)
GO

CREATE TABLE [Attendance]
(
    [userId]    int NOT NULL,
    [meetingId] int NOT NULL,
    PRIMARY KEY ([userId], [meetingId])
)
GO

CREATE TABLE [Recordings]
(
    [recordingId] int PRIMARY KEY NOT NULL,
    [link]        nvarchar(255)   NOT NULL,
    [moduleId]    int             NOT NULL
)
GO

CREATE TABLE [WatchedBy]
(
    [recordingId] int NOT NULL,
    [userId]      int NOT NULL,
    PRIMARY KEY ([recordingId], [userId])
)
GO

CREATE TABLE [StudiesSchedules]
(
    [scheduleId] int PRIMARY KEY NOT NULL,
    [studiesId]  int             NOT NULL,
    [year]       int             NOT NULL
        check (year > 0)
)
GO

CREATE TABLE [Practices]
(
    [studiesId] int NOT NULL,
    [userId]    int NOT NULL,
    PRIMARY KEY ([studiesId], [userId])
)
GO

CREATE TABLE [StudiesMeetings]
(
    [studiesMeetingId] int PRIMARY KEY NOT NULL,
    [date]             datetime        NOT NULL,
    [scheduleId]       int             NOT NULL
)
GO

CREATE TABLE [OfflineStudiesMeetings]
(
    [studiesMeetingId] int PRIMARY KEY NOT NULL,
    [place]            nvarchar(255)   NOT NULL
)
GO

CREATE TABLE [OnlineStudiesMeetings]
(
    [studiesMeetingId] int PRIMARY KEY NOT NULL,
    [link]             nvarchar(255)   NOT NULL
)
GO

CREATE TABLE [StudiesAttendance]
(
    [userId]           int NOT NULL,
    [studiesMeetingId] int NOT NULL,
    PRIMARY KEY ([userId], [studiesMeetingId])
)
GO

CREATE TABLE [EducationFormPrice]
(
    [priceId]         int PRIMARY KEY NOT NULL,
    [educationFormId] int             NOT NULL,
    [advanceDue]      int             NOT NULL,
    [advance]         money           NOT NULL,
    [wholePrice]      money           NOT NULL,
    [accessFor]       int,
    check (advance >= 0),
    check (advance <= wholePrice),
    check (accessFor > 0),
)
GO

CREATE TABLE [EducationFormPaymentsDue]
(
    [educationFormId] int PRIMARY KEY NOT NULL,
    [advanceDue]      date,
    [wholePriceDue]   date            NOT NULL
--         check (wholePriceDue >= advanceDue) cannot compare same columns
)
GO
ALTER TABLE [EducationFormPaymentsDue]
    ADD FOREIGN KEY ([educationFormId]) REFERENCES [EducationForms] ([educationFormId])
GO

CREATE TABLE [PaymentsHistory]
(
    [paymentId]      int PRIMARY KEY NOT NULL,
    [userId]         int             NOT NULL,
    [paymentDate]    datetime        NOT NULL,
    [payedFor]       int             NOT NULL,
    [amount]         money           NOT NULL,
    [paymentDetails] nvarchar(255)   NOT NULL
)
GO

ALTER TABLE [Teachers]
    ADD FOREIGN KEY ([teacherId]) REFERENCES [Users] ([userId])
GO

ALTER TABLE [Roles]
    ADD FOREIGN KEY ([userId]) REFERENCES [Users] ([userId])
GO

ALTER TABLE [Translators]
    ADD FOREIGN KEY ([translatorId]) REFERENCES [Users] ([userId])
GO

ALTER TABLE [AssignedEducationForms]
    ADD FOREIGN KEY ([userId]) REFERENCES [Users] ([userId])
GO

ALTER TABLE [AssignedEducationForms]
    ADD FOREIGN KEY ([educationFormId]) REFERENCES [EducationForms] ([educationFormId])
GO
--err - problem ze specific id
ALTER TABLE [Webinars]
    ADD FOREIGN KEY ([webinarId]) REFERENCES [EducationForms] ([specificId], [type])
GO

ALTER TABLE [Studies]
    ADD FOREIGN KEY ([studiesId]) REFERENCES [EducationForms] ([specificId])
GO

ALTER TABLE [Courses]
    ADD FOREIGN KEY ([courseId]) REFERENCES [EducationForms] ([specificId])
GO

ALTER TABLE [Languages]
    ADD FOREIGN KEY ([translatorId]) REFERENCES [Translators] ([translatorId])
GO

ALTER TABLE [Languages]
    ADD FOREIGN KEY ([languageId]) REFERENCES [LanguagesDetails] ([languageId])
GO

ALTER TABLE [WebinarMeetings]
    ADD FOREIGN KEY ([onlineMeetingId]) REFERENCES [Webinars] ([onlineMeetingId])
GO

ALTER TABLE [Attendance]
    ADD FOREIGN KEY ([userId]) REFERENCES [Users] ([userId])
GO

ALTER TABLE [WatchedBy]
    ADD FOREIGN KEY ([recordingId]) REFERENCES [Recordings] ([recordingId])
GO

ALTER TABLE [WatchedBy]
    ADD FOREIGN KEY ([userId]) REFERENCES [Users] ([userId])
GO

ALTER TABLE [Syllabuses]
    ADD FOREIGN KEY ([syllabusId]) REFERENCES [Studies] ([syllabusId])
GO

ALTER TABLE [Syllabuses]
    ADD FOREIGN KEY ([subjectId]) REFERENCES [Subjects] ([subjectId])
GO

ALTER TABLE [StudiesSchedules]
    ADD FOREIGN KEY ([studiesId]) REFERENCES [Studies] ([studiesId])
GO

ALTER TABLE [Permissions]
    ADD FOREIGN KEY ([roleId]) REFERENCES [RoleDetails] ([roleId])
GO

ALTER TABLE [PaymentsHistory]
    ADD FOREIGN KEY ([payedFor]) REFERENCES [EducationForms] ([educationFormId])
GO

ALTER TABLE [PaymentsHistory]
    ADD FOREIGN KEY ([userId]) REFERENCES [Users] ([userId])
GO

ALTER TABLE [Streets]
    ADD FOREIGN KEY ([cityId]) REFERENCES [Cities] ([cityId])
GO

ALTER TABLE [Cities]
    ADD FOREIGN KEY ([stateId]) REFERENCES [States] ([stateId])
GO

ALTER TABLE [Webinars]
    ADD FOREIGN KEY ([webinarId]) REFERENCES [WebinarDetails] ([webinarId])
GO

ALTER TABLE [Modules]
    ADD FOREIGN KEY ([courseId]) REFERENCES [Courses] ([courseId])
GO

ALTER TABLE [StationaryModules]
    ADD FOREIGN KEY ([moduleId]) REFERENCES [Modules] ([moduleId])
GO

ALTER TABLE [OnlineSyncModules]
    ADD FOREIGN KEY ([moduleId]) REFERENCES [Modules] ([moduleId])
GO

ALTER TABLE [OnlineAsyncModules]
    ADD FOREIGN KEY ([moduleId]) REFERENCES [Modules] ([moduleId])
GO

ALTER TABLE [HybridModules]
    ADD FOREIGN KEY ([moduleId]) REFERENCES [Modules] ([moduleId])
GO
--err
ALTER TABLE [OfflineMeetings]
    ADD FOREIGN KEY ([moduleId]) REFERENCES [StationaryModules] ([moduleId])
GO
--err

ALTER TABLE [OfflineMeetings]
    ADD FOREIGN KEY ([moduleId]) REFERENCES [HybridModules] ([moduleId])
GO
--err

ALTER TABLE [Recordings]
    ADD FOREIGN KEY ([moduleId]) REFERENCES [OnlineAsyncModules] ([moduleId])
GO
--err

ALTER TABLE [OnlineMeetings]
    ADD FOREIGN KEY ([moduleId]) REFERENCES [HybridModules] ([moduleId])
GO
--err

ALTER TABLE [OnlineMeetings]
    ADD FOREIGN KEY ([moduleId]) REFERENCES [OnlineSyncModules] ([moduleId])
GO

ALTER TABLE [OnlineMeetings]
    ADD FOREIGN KEY ([meetingId]) REFERENCES [Meetings] ([meetingId])
GO

ALTER TABLE [OfflineMeetings]
    ADD FOREIGN KEY ([meetingId]) REFERENCES [Meetings] ([meetingId])
GO

ALTER TABLE [Attendance]
    ADD FOREIGN KEY ([meetingId]) REFERENCES [Meetings] ([meetingId])
GO

ALTER TABLE [StudiesMeetings]
    ADD FOREIGN KEY ([scheduleId]) REFERENCES [StudiesSchedules] ([scheduleId])
GO

ALTER TABLE [StudiesMeetings]
    ADD FOREIGN KEY ([studiesMeetingId]) REFERENCES [OfflineStudiesMeetings] ([studiesMeetingId])
GO

ALTER TABLE [StudiesMeetings]
    ADD FOREIGN KEY ([studiesMeetingId]) REFERENCES [OnlineStudiesMeetings] ([studiesMeetingId])
GO

ALTER TABLE [StudiesAttendance]
    ADD FOREIGN KEY ([studiesMeetingId]) REFERENCES [OnlineStudiesMeetings] ([studiesMeetingId])
GO

ALTER TABLE [StudiesAttendance]
    ADD FOREIGN KEY ([studiesMeetingId]) REFERENCES [OfflineStudiesMeetings] ([studiesMeetingId])
GO

ALTER TABLE [StudiesAttendance]
    ADD FOREIGN KEY ([userId]) REFERENCES [Users] ([userId])
GO

ALTER TABLE [Practices]
    ADD FOREIGN KEY ([studiesId]) REFERENCES [Studies] ([studiesId])
GO

ALTER TABLE [Practices]
    ADD FOREIGN KEY ([userId]) REFERENCES [Users] ([userId])
GO

ALTER TABLE [Exams]
    ADD FOREIGN KEY ([studiesId]) REFERENCES [Studies] ([studiesId])
GO

ALTER TABLE [Exams]
    ADD FOREIGN KEY ([subjectId]) REFERENCES [Subjects] ([subjectId])
GO

ALTER TABLE [StudentsGrades]
    ADD FOREIGN KEY ([examId]) REFERENCES [Exams] ([examId])
GO

ALTER TABLE [StudentsGrades]
    ADD FOREIGN KEY ([userId]) REFERENCES [Users] ([userId])
GO

ALTER TABLE [StudentsGrades]
    ADD FOREIGN KEY ([gradeId]) REFERENCES [Grades] ([gradeId])
GO

ALTER TABLE [Teachers]
    ADD FOREIGN KEY ([academicTitleId]) REFERENCES [AcademicsTitles] ([academicTitleId])
GO

ALTER TABLE [TeachersSubjects]
    ADD FOREIGN KEY ([subjectId]) REFERENCES [Subjects] ([subjectId])
GO

ALTER TABLE [TeachersSubjects]
    ADD FOREIGN KEY ([teacherId]) REFERENCES [Teachers] ([teacherId])
GO



ALTER TABLE [RoleDetails]
    ADD FOREIGN KEY ([roleId]) REFERENCES [Roles] ([roleId])
GO

ALTER TABLE [EducationFormPrice]
    ADD FOREIGN KEY ([educationFormId]) REFERENCES [EducationForms] ([educationFormId])
GO

