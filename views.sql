CREATE VIEW allDebtors AS
WITH dane AS (SELECT userId, SUM(entryFee + 7 * meetFee * S.semester) AS do_zaplaty
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
GO

GRANT
    SELECT
    ON allDebtors TO student
GO
GRANT
    SELECT
    ON allDebtors TO studies_admin
GO

CREATE VIEW allPractices AS
SELECT S.title         AS kierunek,
       Users.name,
       surname,
       email,
       YEAR(startDate) AS semestr
FROM Practices
         INNER JOIN dbo.Studies S ON S.studiesId = Practices.studiesId
         INNER JOIN users ON Users.userId = Practices.userId
WHERE DATEDIFF(DAY, startDate, endDate) = 14
GO
GRANT
    SELECT
    ON allPractices TO practice_supervisor
GO

CREATE VIEW allStudents AS
SELECT userId,
       name,
       email,
       city,
       street,
       state,
       zip,
       houseNumber
FROM Users
         INNER JOIN dbo.Cities C ON C.cityId = Users.cityId
         INNER JOIN dbo.States S ON S.stateId = Users.stateId
         INNER JOIN dbo.Streets S2 ON S2.streetId = Users.streetId
WHERE userId NOT IN (SELECT userId FROM allTeachers UNION SELECT userId FROM allTranslators)
GO

GRANT
    SELECT
    ON allStudents TO practice_supervisor
GO
GRANT
    SELECT
    ON allStudents TO studies_admin
GO
GRANT
    SELECT
    ON allStudents TO teacher
GO

CREATE VIEW allStudiesAttendance AS
SELECT U.name, U.surname, U.email, S.title AS kierunek, SM.date, SU.title, SS.semester
FROM StudiesAttendance SA
         INNER JOIN Users U ON U.userId = SA.userId
         INNER JOIN StudiesMeetings SM ON SA.studiesMeetingId = SM.studiesMeetingId
         INNER JOIN Subjects SU ON SM.subjectId = SU.subjectId
         INNER JOIN StudiesSchedules SS ON SM.scheduleId = SS.scheduleId
         INNER JOIN Studies S ON SS.studiesId = S.studiesId
GO

GRANT
    SELECT
    ON allStudiesAttendance TO student
GO
GRANT
    SELECT
    ON allStudiesAttendance TO studies_admin
GO
GRANT
    SELECT
    ON allStudiesAttendance TO teacher
GO

CREATE VIEW allSyllabuses AS
SELECT S.title AS kierunek, S3.title AS przedmiot, S2.semester
FROM Studies S
         INNER JOIN Syllabuses S2 ON S.syllabusId = S2.syllabusId
         INNER JOIN Subjects S3 ON S2.subjectId = S3.subjectId
GO

GRANT
    SELECT
    ON allSyllabuses TO logged_user
GO
GRANT
    SELECT
    ON allSyllabuses TO non_logged_user
GO
GRANT
    SELECT
    ON allSyllabuses TO student
GO
GRANT
    SELECT
    ON allSyllabuses TO studies_admin
GO
GRANT
    SELECT
    ON allSyllabuses TO teacher
GO

CREATE VIEW allTeachers AS
SELECT userId,
       academicTitle,
       name,
       surname,
       email,
       city,
       street,
       state,
       zip,
       houseNumber
FROM Users
         INNER JOIN Teachers ON teacherId = userId
         INNER JOIN dbo.Cities C ON C.cityId = Users.cityId
         INNER JOIN dbo.States S ON S.stateId = Users.stateId
         INNER JOIN dbo.Streets S2 ON S2.streetId = Users.streetId
         INNER JOIN AcademicsTitles A ON Teachers.academicTitleId = A.academicTitleId
GO

GRANT
    SELECT
    ON allTeachers TO studies_admin
GO
GRANT
    SELECT
    ON allTeachers TO teacher
GO

CREATE VIEW allTranslators AS
SELECT userId,
       name,
       surname,
       STRING_AGG(language, ', ') AS języki,
       email,
       city,
       street,
       state,
       zip,
       houseNumber
FROM Users
         INNER JOIN Translators ON translatorId = userId
         INNER JOIN dbo.Cities C ON C.cityId = Users.cityId
         INNER JOIN dbo.States S ON S.stateId = Users.stateId
         INNER JOIN dbo.Streets S2 ON S2.streetId = Users.streetId
         INNER JOIN dbo.Languages L ON Translators.translatorId = L.translatorId
         INNER JOIN LanguagesDetails ON L.languageId = LanguagesDetails.languageId
GROUP BY userId, name, surname, email, city, street, state, zip, houseNumber
GO

GRANT
    SELECT
    ON allTranslators TO studies_admin
GO

CREATE VIEW bilocationReport AS
WITH dane AS (SELECT u.userId, u.name, u.surname, me.date, COUNT(*) AS row_count
              FROM Users AS u
                       INNER JOIN AssignedEducationForms AS aef ON u.userId = aef.userId
                       INNER JOIN EducationForms AS ef ON aef.educationFormId = ef.educationFormId
                       INNER JOIN Courses AS c ON ef.specificId = c.courseId
                       INNER JOIN Modules AS m ON c.courseId = m.courseId
                       INNER JOIN OnlineMeetings AS om ON m.moduleId = om.moduleId
                       INNER JOIN Meetings AS me ON om.meetingId = me.meetingId
              WHERE me.date > GETDATE()
              GROUP BY u.userId, u.name, u.surname, me.date
              HAVING COUNT(*) > 1
              UNION ALL
              SELECT u.userId, u.name, u.surname, me.date, COUNT(*) AS row_count
              FROM Users AS u
                       INNER JOIN AssignedEducationForms AS aef ON u.userId = aef.userId
                       INNER JOIN EducationForms AS ef ON aef.educationFormId = ef.educationFormId
                       INNER JOIN Courses AS c ON ef.specificId = c.courseId
                       INNER JOIN Modules AS m ON c.courseId = m.courseId
                       INNER JOIN OfflineMeetings AS om ON m.moduleId = om.moduleId
                       INNER JOIN Meetings AS me ON om.meetingId = me.meetingId
              WHERE me.date > GETDATE()
              GROUP BY u.userId, u.name, u.surname, me.date
              HAVING COUNT(*) > 1
              UNION ALL
              SELECT u.userId, u.name, u.surname, sm.date, COUNT(*) AS row_count
              FROM Users AS u
                       INNER JOIN Students AS s ON u.userId = s.userId
                       INNER JOIN Studies AS st ON s.studiesId = st.studiesId
                       INNER JOIN StudiesSchedules AS ss ON st.studiesId = ss.studiesId
                       INNER JOIN StudiesMeetings AS sm ON ss.scheduleId = sm.scheduleId
              WHERE sm.date > GETDATE()
              GROUP BY u.userId, u.name, u.surname, sm.date
              HAVING COUNT(*) > 1
              UNION ALL
              SELECT u.userId, u.name, u.surname, wm.date, COUNT(*) AS row_count
              FROM Users AS u
                       INNER JOIN AssignedEducationForms AS aef ON u.userId = aef.userId
                       INNER JOIN EducationForms AS ef ON aef.educationFormId = ef.educationFormId
                       INNER JOIN Webinars AS w ON ef.specificId = w.webinarId
                       INNER JOIN WebinarMeetings AS wm ON w.onlineMeetingId = wm.onlineMeetingId
              WHERE wm.date > GETDATE()
              GROUP BY u.userId, u.name, u.surname, wm.date)
SELECT DISTINCT u.userId, u.name, u.surname
FROM Users AS u
         RIGHT JOIN dane ON u.userId = dane.userId
GO

GRANT
    SELECT
    ON bilocationReport TO student
GO
GRANT
    SELECT
    ON bilocationReport TO studies_admin
GO
GRANT
    SELECT
    ON bilocationReport TO teacher
GO

CREATE VIEW coursesMeetingsAttendance AS
SELECT courseId,
       moduleId,
       UFECMM.meetingId,
       enrolledUsers,
       COUNT(userId)                                                  AS present,
       ROUND(CAST(100.0 * COUNT(userId) / enrolledUsers AS float), 2) AS presentPercent
FROM usersForEachPastCourseModuleMeeting UFECMM
         JOIN Attendance A ON UFECMM.meetingId = A.meetingId
GROUP BY courseId, moduleId, UFECMM.meetingId, enrolledUsers
GO

GRANT
    SELECT
    ON coursesMeetingsAttendance TO teacher
GO

CREATE VIEW coursesModulesAttendance AS
SELECT courseId,
       moduleId,
       SUM(enrolledUsers)            AS enrolledUsers,
       SUM(present)                  AS present,
       ROUND(AVG(presentPercent), 2) AS presentPercent
FROM coursesMeetingsAttendance
GROUP BY courseId, moduleId
GO

GRANT
    SELECT
    ON coursesModulesAttendance TO teacher
GO

CREATE VIEW coursesStartEnd AS
SELECT C.courseId, MIN(date) AS startDate, MAX(date) AS finishDate
FROM Courses C
         JOIN Modules M ON C.courseId = M.courseId
         LEFT JOIN OfflineMeetings OM ON M.moduleId = OM.moduleId
         LEFT JOIN OnlineMeetings ONM ON M.moduleId = ONM.moduleId
         JOIN Meetings M2 ON OM.meetingId = M2.meetingId OR ONM.meetingId = M2.meetingId
GROUP BY C.courseId
GO

GRANT
    SELECT
    ON coursesStartEnd TO student
GO
GRANT
    SELECT
    ON coursesStartEnd TO teacher
GO

CREATE VIEW currentStudies AS
SELECT studiesId, semester
FROM studiesStartEnd
WHERE startDate < GETDATE()
  AND finishDate > GETDATE()
GO

GRANT
    SELECT
    ON currentStudies TO studies_admin
GO
GRANT
    SELECT
    ON currentStudies TO teacher
GO

CREATE VIEW educationFormAttendance AS
SELECT 'Studia'                                          AS forma_kształcenia,
       u.userId,
       u.name,
       u.surname,
       sm.date,
       IIF(sa.userId IS NOT NULL, 'Obecny', 'Nieobecny') AS Obecnosc
FROM Users AS u
         INNER JOIN Students AS s ON u.userId = s.userId
         INNER JOIN Studies AS st ON s.studiesId = st.studiesId
         INNER JOIN StudiesSchedules AS ss ON st.studiesId = ss.studiesId
         INNER JOIN StudiesMeetings AS sm ON ss.scheduleId = sm.scheduleId
         LEFT JOIN StudiesAttendance AS sa ON u.userId = sa.userId AND sa.studiesMeetingId = sm.studiesMeetingId
UNION ALL
SELECT 'Kurs offline'                                   AS forma_kształcenia,
       u.userId,
       u.name,
       u.surname,
       me.date,
       IIF(a.userId IS NOT NULL, 'Obecny', 'Nieobecny') AS Obecnosc
FROM Users AS u
         INNER JOIN AssignedEducationForms AS aef ON u.userId = aef.userId
         INNER JOIN EducationForms AS ef ON aef.educationFormId = ef.educationFormId
         INNER JOIN Courses AS c ON ef.specificId = c.courseId
         INNER JOIN Modules AS m ON c.courseId = m.courseId
         INNER JOIN OfflineMeetings AS om ON m.moduleId = om.moduleId
         INNER JOIN Meetings AS me ON om.meetingId = me.meetingId
         LEFT JOIN Attendance AS a ON me.meetingId = A.meetingId
UNION ALL
SELECT 'Kurs online'                                    AS forma_kształcenia,
       u.userId,
       u.name,
       u.surname,
       me.date,
       IIF(a.userId IS NOT NULL, 'Obecny', 'Nieobecny') AS Obecnosc
FROM Users AS u
         INNER JOIN AssignedEducationForms AS aef ON u.userId = aef.userId
         INNER JOIN EducationForms AS ef ON aef.educationFormId = ef.educationFormId
         INNER JOIN Courses AS c ON ef.specificId = c.courseId
         INNER JOIN Modules AS m ON c.courseId = m.courseId
         INNER JOIN OnlineMeetings AS om ON m.moduleId = om.moduleId
         INNER JOIN Meetings AS me ON om.meetingId = me.meetingId
         LEFT JOIN Attendance AS a ON me.meetingId = A.meetingId
GO

GRANT
    SELECT
    ON educationFormAttendance TO student
GO
GRANT
    SELECT
    ON educationFormAttendance TO studies_admin
GO
GRANT
    SELECT
    ON educationFormAttendance TO teacher
GO

CREATE VIEW educationFormsIncome AS
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
SELECT DISTINCT Studies.name,
                'studia',
                entryFee * (SELECT COUNT(*) FROM Students S2 WHERE S2.studiesId = S.studiesId) +
                7 * meetFee * (SELECT COUNT(*) FROM Students S2 WHERE S2.studiesId = S.studiesId)
FROM Students S
         INNER JOIN Studies ON S.studiesId = Studies.studiesId
GO

CREATE VIEW finishedFormsAttendance AS
(SELECT 'studies'                                          AS educationForm,
        title + ', semester: ' + CAST(semester AS varchar) AS title,
        sumOfEnrolledPresent                               AS present,
        sumOfEnrolledStudents                              AS enrolled,
        avgAttendance,
        sumOfNotEnrolledPresent                            AS notEnrolled
 FROM studiesAttendanceSummary
          JOIN Studies ON studiesAttendanceSummary.studiesId = Studies.studiesId)
UNION
SELECT 'course', C.title + ': ' + M.title, present, enrolledUsers, presentPercent, 0
FROM pastCoursesAttendance PCA
         JOIN Courses C ON PCA.courseId = C.courseId
         JOIN Modules M ON C.courseId = M.courseId AND PCA.moduleId = M.moduleId
GO

GRANT
    SELECT
    ON finishedFormsAttendance TO studies_admin
GO
GRANT
    SELECT
    ON finishedFormsAttendance TO teacher
GO

CREATE VIEW pastCourses AS
SELECT courseId
FROM coursesStartEnd
WHERE finishDate < GETDATE()
GO

GRANT
    SELECT
    ON pastCourses TO teacher
GO

CREATE VIEW pastCoursesAttendance AS
SELECT CMA.courseId, moduleId, enrolledUsers, present, presentPercent
FROM coursesModulesAttendance CMA
         JOIN pastCourses PC ON CMA.courseId = PC.courseId
GO

GRANT
    SELECT
    ON pastCoursesAttendance TO teacher
GO

CREATE VIEW pastStudies AS
SELECT studiesId, semester
FROM studiesStartEnd
WHERE finishDate < GETDATE()
  AND finishDate IS NOT NULL
GO

GRANT
    SELECT
    ON pastStudies TO studies_admin
GO
GRANT
    SELECT
    ON pastStudies TO teacher
GO

CREATE VIEW pastWebinars AS
SELECT webinarId, W.onlineMeetingId
FROM Webinars W
         JOIN WebinarMeetings WM ON W.onlineMeetingId = WM.onlineMeetingId
WHERE date < GETDATE()
GO
GRANT
    SELECT
    ON pastWebinars TO teacher
GO

CREATE VIEW studentsStudies AS
SELECT userId, S.studiesId, S.semester, scheduleId
FROM Students S
         JOIN StudiesSchedules SS ON S.studiesId = SS.studiesId AND S.semester = SS.semester
GO

GRANT
    SELECT
    ON studentsStudies TO studies_admin
GO

CREATE VIEW studentStudiesMeetings AS
WITH StudentsMeetings AS
         (SELECT userId,
                 studiesId,
                 semester,
                 subjectId,
                 date,
                 studiesMeetingId
          FROM studentsStudies SS
                   JOIN StudiesMeetings SM ON SS.scheduleId = SM.scheduleId)
SELECT userId,
       studiesId,
       semester,
       subjectId,
       date,
       SM.studiesMeetingId,
       place,
       room
FROM StudentsMeetings SM
         JOIN OfflineStudiesMeetings OSM
              ON SM.studiesMeetingId = OSM.studiesMeetingId
UNION
SELECT userId,
       studiesId,
       semester,
       subjectId,
       date,
       SM.studiesMeetingId,
       link,
       'online' AS room
FROM StudentsMeetings SM
         JOIN OnlineStudiesMeetings OSM
              ON SM.studiesMeetingId = OSM.studiesMeetingId
GO
GRANT
    SELECT
    ON studentStudiesMeetings TO studies_admin
GO

CREATE VIEW studiesAttendanceSummary AS
SELECT studiesId,
       semester,
       SUM(SMA.presentEnrolledStudents)                   AS sumOfEnrolledPresent,
       SUM(enrolledStudents)                              AS sumOfEnrolledStudents,
       ROUND(CAST(100.0 * (SUM(presentEnrolledStudents)) / SUM(enrolledStudents) AS float),
             2)                                           AS avgAttendance,
       SUM(presentStudents - SMA.presentEnrolledStudents) AS sumOfNotEnrolledPresent
FROM studiesMeetingsAttendance SMA
GROUP BY studiesId, semester
GO

GRANT
    SELECT
    ON studiesAttendanceSummary TO studies_admin
GO

CREATE VIEW studiesMeetingsAttendance AS
SELECT SS.studiesId,
       SS.semester,
       SM.studiesMeetingId,
       (SELECT COUNT(SSM1.userId)
        FROM studentStudiesMeetings SSM1
        WHERE SSM1.studiesMeetingId = SM.studiesMeetingId) AS enrolledStudents,
       presentEnrolledStudents,
       presentStudents
FROM StudiesMeetings SM
         JOIN studiesMeetingsPresentStudents SMPS ON SM.studiesMeetingId = SMPS.studiesMeetingId
         JOIN studiesMeetingsPresentEnrolledStudents SMPES ON SM.studiesMeetingId = SMPES.studiesMeetingId
         JOIN StudiesSchedules SS ON SM.scheduleId = SS.scheduleId
         JOIN pastStudies SP ON SS.studiesId = SP.studiesId AND SS.semester = SP.semester
GO

GRANT
    SELECT
    ON studiesMeetingsAttendance TO studies_admin
GO

CREATE VIEW studiesMeetingsPresentEnrolledStudents AS
SELECT SSM.studiesMeetingId, COUNT(SSM.userId) AS presentEnrolledStudents
FROM studentStudiesMeetings SSM
         JOIN StudiesAttendance SA ON SSM.studiesMeetingId = SA.studiesMeetingId AND SSM.userId = SA.userId
GROUP BY SSM.studiesMeetingId
GO

GRANT
    SELECT
    ON studiesMeetingsPresentEnrolledStudents TO studies_admin
GO

CREATE VIEW studiesMeetingsPresentStudents AS
SELECT studiesMeetingId, COUNT(userId) AS presentStudents
FROM StudiesAttendance
GROUP BY studiesMeetingId
GO

GRANT
    SELECT
    ON studiesMeetingsPresentStudents TO studies_admin
GO

CREATE VIEW studiesStartEnd AS
SELECT studiesId, semester, MIN(date) AS startDate, MAX(date) AS finishDate
FROM StudiesSchedules SS
         LEFT JOIN StudiesMeetings SM ON SS.scheduleId = SM.scheduleId
GROUP BY studiesId, semester
GO

GRANT
    SELECT
    ON studiesStartEnd TO logged_user
GO
GRANT
    SELECT
    ON studiesStartEnd TO non_logged_user
GO
GRANT
    SELECT
    ON studiesStartEnd TO student
GO
GRANT
    SELECT
    ON studiesStartEnd TO studies_admin
GO
GRANT
    SELECT
    ON studiesStartEnd TO teacher
GO

CREATE VIEW upcomingCourses AS
SELECT courseId
FROM coursesStartEnd
WHERE startDate > GETDATE()
GO

GRANT
    SELECT
    ON upcomingCourses TO logged_user
GO
GRANT
    SELECT
    ON upcomingCourses TO non_logged_user
GO
GRANT
    SELECT
    ON upcomingCourses TO student
GO
GRANT
    SELECT
    ON upcomingCourses TO teacher
GO

CREATE VIEW upcomingStudies AS
SELECT studiesId, semester
FROM studiesStartEnd
WHERE startDate > GETDATE()
   OR startDate IS NULL
GO

GRANT
    SELECT
    ON upcomingStudies TO logged_user
GO
GRANT
    SELECT
    ON upcomingStudies TO non_logged_user
GO
GRANT
    SELECT
    ON upcomingStudies TO student
GO
GRANT
    SELECT
    ON upcomingStudies TO studies_admin
GO
GRANT
    SELECT
    ON upcomingStudies TO teacher
GO

CREATE VIEW upcomingWebinars AS
SELECT webinarId, W.onlineMeetingId
FROM Webinars W
         JOIN WebinarMeetings WM ON W.onlineMeetingId = WM.onlineMeetingId
WHERE date > GETDATE()
GO
GRANT
    SELECT
    ON upcomingWebinars TO logged_user
GO
GRANT
    SELECT
    ON upcomingWebinars TO non_logged_user
GO
GRANT
    SELECT
    ON upcomingWebinars TO student
GO
GRANT
    SELECT
    ON upcomingWebinars TO teacher
GO

CREATE VIEW usersCoursesMeetings AS
SELECT userId,
       courseId,
       UCM.moduleId,
       M.meetingId,
       date,
       place,
       room
FROM usersCoursesModules UCM
         JOIN OfflineMeetings OM ON UCM.moduleId = OM.moduleId
         JOIN Meetings M ON OM.meetingId = M.meetingId
UNION
SELECT userId,
       courseId,
       UCM.moduleId,
       M.meetingId,
       date,
       link,
       'online' AS room
FROM usersCoursesModules UCM
         JOIN OnlineMeetings ONM
              ON UCM.moduleId = ONM.moduleId
         JOIN Meetings M ON ONM.meetingId = M.meetingId
GO
GRANT
    SELECT
    ON usersCoursesMeetings TO student
GO
GRANT
    SELECT
    ON usersCoursesMeetings TO teacher
GO

CREATE VIEW usersCoursesModules AS
SELECT userId, C.courseId, moduleId
FROM usersEducationForms UEF
         JOIN Courses C ON C.courseId = UEF.specificId AND UEF.type = 'course'
         JOIN Modules M ON M.courseId = C.courseId
GO

GRANT
    SELECT
    ON usersCoursesModules TO student
GO
GRANT
    SELECT
    ON usersCoursesModules TO teacher
GO

CREATE VIEW usersEducationForms AS
SELECT userId, AEF.educationFormId, accessUntil, specificId, type
FROM AssignedEducationForms AEF
         JOIN EducationForms EF ON EF.educationFormId = AEF.educationFormId
GO

GRANT
    SELECT
    ON usersEducationForms TO student
GO
GRANT
    SELECT
    ON usersEducationForms TO teacher
GO

CREATE VIEW usersEnrolledForUpcomingEvents AS
(
SELECT COUNT(userId) AS zapisaneOsoby, 'webinar' AS rodzajWydarzenia, 'zdalnie' AS formatWydarzenia
FROM WebinarMeetings WM
         JOIN upcomingWebinars UW ON UW.onlineMeetingId = WM.onlineMeetingId
         JOIN usersEducationForms UEF ON UEF.specificId = UW.webinarId AND UEF.type = 'webinar'
UNION
SELECT COUNT(userId) AS zapisaneOsoby, 'moduł' AS rodzajWydarzenia, 'zdalnie' AS formatWydarzenia
FROM usersCoursesModules
         JOIN upcomingCourses UC ON UC.courseId = usersCoursesModules.courseId
         JOIN OnlineSyncModules OSM ON OSM.moduleId = usersCoursesModules.moduleId
UNION
SELECT COUNT(userId) AS zapisaneOsoby, 'moduł' AS rodzajWydarzenia, 'stacjonarnie' AS formatWydarzenia
FROM usersCoursesModules
         JOIN upcomingCourses UC ON UC.courseId = usersCoursesModules.courseId
         JOIN StationaryModules SM ON SM.moduleId = usersCoursesModules.moduleId
UNION
SELECT COUNT(userId) AS zapisaneOsoby, 'moduł' AS rodzajWydarzenia, 'hybrydowo' AS formatWydarzenia
FROM usersCoursesModules
         JOIN upcomingCourses UC ON UC.courseId = usersCoursesModules.courseId
         JOIN HybridModules HM ON HM.moduleId = usersCoursesModules.moduleId
UNION
SELECT COUNT(userId) AS zapisaneOsoby, 'studia' AS rodzajWydarzenia, 'stacjonarnie' AS formatWydarzenia
FROM studentsStudies SS
         JOIN upcomingStudies US ON US.studiesId = SS.studiesId AND US.semester = SS.semester
         JOIN StudiesMeetings SM ON SM.scheduleId = SS.scheduleId
         JOIN OfflineStudiesMeetings OSM ON OSM.studiesMeetingId = SM.studiesMeetingId
UNION
SELECT COUNT(userId) AS zapisaneOsoby, 'studia' AS rodzajWydarzenia, 'zdalnie' AS formatWydarzenia
FROM studentsStudies SS
         JOIN upcomingStudies US ON US.studiesId = SS.studiesId AND US.semester = SS.semester
         JOIN StudiesMeetings SM ON SM.scheduleId = SS.scheduleId
         JOIN OnlineStudiesMeetings OSM ON OSM.studiesMeetingId = SM.studiesMeetingId )
GO

GRANT
    SELECT
    ON usersEnrolledForUpcomingEvents TO student
GO
GRANT
    SELECT
    ON usersEnrolledForUpcomingEvents TO teacher
GO

CREATE VIEW usersForEachPastCourseModuleMeeting AS
SELECT UCM.courseId, moduleId, meetingId, COUNT(userId) AS enrolledUsers
FROM usersCoursesMeetings UCM
         JOIN pastCourses PC ON UCM.courseId = PC.courseId
GROUP BY UCM.courseId, moduleId, meetingId
GO

GRANT
    SELECT
    ON usersForEachPastCourseModuleMeeting TO teacher
GO

