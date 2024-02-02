create view allDebtors as
with dane as (
       select userId, sum (entryFee + 7 * meetFee * S.semester) as do_zaplaty from Students S inner join Studies St on S.studiesId = St.studiesId
       group by userId
       union
       select userId, sum (wholePrice) from AssignedEducationForms A inner join EducationFormPrice E on E.educationFormId = A.educationFormId
       group by userId
       )
select dane.userId, U.name, U.surname, U.email, sum(do_zaplaty) - (select sum(amount) from PaymentsHistory where userId = dane.userId) as jeszcze_do_zaplaty from dane
inner join Users U on U.userId = dane.userId
group by U.name, dane.userId, U.surname, U.email
having sum(do_zaplaty) > (select sum(amount) from PaymentsHistory where userId = dane.userId)
GO

GRANT SELECT ON allDebtors TO student
GO

GRANT SELECT ON allDebtors TO studies_admin
GO

CREATE view allPractices as
    select S.title as kierunek, Users.name, surname, email, year(startDate) as semestr
    from Practices
             inner join dbo.Studies S on S.studiesId = Practices.studiesId
             inner join users on Users.userId = Practices.userId
    where datediff(day, startDate, endDate) = 14
GO

GRANT SELECT ON allPractices TO practice_supervisor
GO

create view allStudents as
select userId, name, email, city, street, state, zip, houseNumber from Users
inner join dbo.Cities C on C.cityId = Users.cityId
inner join dbo.States S on S.stateId = Users.stateId
inner join dbo.Streets S2 on S2.streetId = Users.streetId
where userId not in (select userId from allTeachers union select userId from allTranslators)
GO

GRANT SELECT ON allStudents TO practice_supervisor
GO

GRANT SELECT ON allStudents TO studies_admin
GO

GRANT SELECT ON allStudents TO teacher
GO

CREATE view allStudiesAttendance as
    select U.name, U.surname, U.email, S.title as kierunek, SM.date, SU.title, SS.semester
    from StudiesAttendance SA
             inner join Users U on U.userId = SA.userId
             inner join StudiesMeetings SM on SA.studiesMeetingId = SM.studiesMeetingId
             inner join Subjects SU on SM.subjectId = SU.subjectId
             inner join StudiesSchedules SS on SM.scheduleId = SS.scheduleId
             inner join Studies S on SS.studiesId = S.studiesId
GO

GRANT SELECT ON allStudiesAttendance TO student
GO

GRANT SELECT ON allStudiesAttendance TO studies_admin
GO

GRANT SELECT ON allStudiesAttendance TO teacher
GO

CREATE view allSyllabuses as
    select S.title as kierunek, S3.title as przedmiot, S2.semester
    from Studies S
             inner join Syllabuses S2 on S.syllabusId = S2.syllabusId
             inner join Subjects S3 on S2.subjectId = S3.subjectId
GO

GRANT SELECT ON allSyllabuses TO logged_user
GO

GRANT SELECT ON allSyllabuses TO non_logged_user
GO

GRANT SELECT ON allSyllabuses TO student
GO

GRANT SELECT ON allSyllabuses TO studies_admin
GO

GRANT SELECT ON allSyllabuses TO teacher
GO

create view allTeachers as
select userId, academicTitle, name, surname, email, city, street, state, zip, houseNumber from Users inner join Teachers on teacherId = userId
inner join dbo.Cities C on C.cityId = Users.cityId
inner join dbo.States S on S.stateId = Users.stateId
inner join dbo.Streets S2 on S2.streetId = Users.streetId
inner join AcademicsTitles A on Teachers.academicTitleId = A.academicTitleId
GO

GRANT SELECT ON allTeachers TO studies_admin
GO

GRANT SELECT ON allTeachers TO teacher
GO

create view allTranslators as
select userId, name, surname, string_agg(language, ', ') as języki, email, city, street, state, zip, houseNumber from Users inner join Translators on translatorId = userId
inner join dbo.Cities C on C.cityId = Users.cityId
inner join dbo.States S on S.stateId = Users.stateId
inner join dbo.Streets S2 on S2.streetId = Users.streetId
inner join dbo.Languages L on Translators.translatorId = L.translatorId
inner join LanguagesDetails on L.languageId = LanguagesDetails.languageId
group by userId, name, surname, email, city, street, state, zip, houseNumber
GO

GRANT SELECT ON allTranslators TO studies_admin
GO

create view bilocationReport as
with dane as (
SELECT u.userId, u.name, u.surname, me.date, COUNT(*) AS row_count
FROM Users AS u
INNER JOIN AssignedEducationForms AS aef ON u.userId = aef.userId
INNER JOIN EducationForms AS ef ON aef.educationFormId = ef.educationFormId
INNER JOIN Courses AS c ON ef.specificId = c.courseId
INNER JOIN Modules AS m ON c.courseId = m.courseId
INNER JOIN OnlineMeetings AS om ON m.moduleId = om.moduleId
INNER JOIN Meetings AS me ON om.meetingId = me.meetingId
where me.date > GETDATE()
GROUP BY u.userId, u.name, u.surname, me.date
having COUNT(*) > 1
UNION ALL
SELECT u.userId, u.name, u.surname, me.date, COUNT(*) AS row_count
FROM Users AS u
INNER JOIN AssignedEducationForms AS aef ON u.userId = aef.userId
INNER JOIN EducationForms AS ef ON aef.educationFormId = ef.educationFormId
INNER JOIN Courses AS c ON ef.specificId = c.courseId
INNER JOIN Modules AS m ON c.courseId = m.courseId
INNER JOIN OfflineMeetings AS om ON m.moduleId = om.moduleId
INNER JOIN Meetings AS me ON om.meetingId = me.meetingId
where me.date > GETDATE()
GROUP BY u.userId, u.name, u.surname, me.date
having COUNT(*) > 1
UNION ALL
SELECT u.userId, u.name, u.surname, sm.date, COUNT(*) AS row_count
FROM Users AS u
INNER JOIN Students AS s ON u.userId = s.userId
INNER JOIN Studies AS st ON s.studiesId = st.studiesId
INNER JOIN StudiesSchedules AS ss ON st.studiesId = ss.studiesId
INNER JOIN StudiesMeetings AS sm ON ss.scheduleId = sm.scheduleId
where sm.date > GETDATE()
GROUP BY u.userId, u.name, u.surname, sm.date
having COUNT(*) > 1
UNION ALL
SELECT u.userId, u.name, u.surname, wm.date, COUNT(*) AS row_count
FROM
  Users AS u
INNER JOIN AssignedEducationForms AS aef ON u.userId = aef.userId
INNER JOIN EducationForms AS ef ON aef.educationFormId = ef.educationFormId
INNER JOIN Webinars AS w ON ef.specificId = w.webinarId
INNER JOIN WebinarMeetings AS wm ON w.onlineMeetingId = wm.onlineMeetingId
where wm.date > GETDATE()
GROUP BY u.userId, u.name, u.surname, wm.date)
select distinct u.userId, u.name, u.surname from Users as u right join dane on u.userId = dane.userId
GO

GRANT SELECT ON bilocationReport TO student
GO

GRANT SELECT ON bilocationReport TO studies_admin
GO

GRANT SELECT ON bilocationReport TO teacher
GO

create view coursesMeetingsAttendance as
select courseId,
       moduleId,
       UFECMM.meetingId,
       enrolledUsers,
       count(userId)                                                  as present,
       round(cast(100.0 * count(userId) / enrolledUsers as float), 2) as presentPercent
from usersForEachPastCourseModuleMeeting UFECMM
         join Attendance A on UFECMM.meetingId = A.meetingId
group by courseId, moduleId, UFECMM.meetingId, enrolledUsers
GO

GRANT SELECT ON coursesMeetingsAttendance TO teacher
GO

create view coursesModulesAttendance as
select courseId,
       moduleId,
       sum(enrolledUsers)            as enrolledUsers,
       sum(present)                  as present,
       round(avg(presentPercent), 2) as presentPercent
from coursesMeetingsAttendance
group by courseId, moduleId
GO

GRANT SELECT ON coursesModulesAttendance TO teacher
GO

create view coursesStartEnd as
select C.courseId, min(date) as startDate, max(date) as finishDate
from Courses C
         join Modules M on C.courseId = M.courseId
         left join OfflineMeetings OM on M.moduleId = OM.moduleId
         left join OnlineMeetings ONM on M.moduleId = ONM.moduleId
         join Meetings M2 on OM.meetingId = M2.meetingId or ONM.meetingId = M2.meetingId
group by C.courseId
GO

GRANT SELECT ON coursesStartEnd TO student
GO

GRANT SELECT ON coursesStartEnd TO teacher
GO

create view currentStudies as
select studiesId, semester
from studiesStartEnd
where startDate < getdate()
  and finishDate > getdate()
GO

GRANT SELECT ON currentStudies TO studies_admin
GO

GRANT SELECT ON currentStudies TO teacher
GO

create view educationFormAttendance as
SELECT 'Studia' as forma_kształcenia, u.userId, u.name, u.surname, sm.date,
      IIF(sa.userId IS NOT NULL, 'Obecny', 'Nieobecny') AS Obecnosc
FROM
   Users AS u
INNER JOIN Students AS s ON u.userId = s.userId
INNER JOIN Studies AS st ON s.studiesId = st.studiesId
INNER JOIN StudiesSchedules AS ss ON st.studiesId = ss.studiesId
INNER JOIN StudiesMeetings AS sm ON ss.scheduleId = sm.scheduleId
LEFT JOIN StudiesAttendance AS sa ON u.userId = sa.userId AND sa.studiesMeetingId = sm.studiesMeetingId
union all
SELECT 'Kurs offline' as forma_kształcenia, u.userId, u.name, u.surname, me.date,
      IIF(a.userId IS NOT NULL, 'Obecny', 'Nieobecny') AS Obecnosc
FROM Users as u
inner join AssignedEducationForms as aef on u.userId = aef.userId
inner join EducationForms as ef on aef.educationFormId = ef.educationFormId
inner join Courses as c on ef.specificId = c.courseId
inner join Modules as m on c.courseId = m.courseId
inner join OfflineMeetings as om on m.moduleId = om.moduleId
inner join Meetings as me on om.meetingId = me.meetingId
left join Attendance as a on me.meetingId = A.meetingId
union all
SELECT 'Kurs online' as forma_kształcenia, u.userId, u.name, u.surname, me.date,
      IIF(a.userId IS NOT NULL, 'Obecny', 'Nieobecny') AS Obecnosc
FROM Users as u
inner join AssignedEducationForms as aef on u.userId = aef.userId
inner join EducationForms as ef on aef.educationFormId = ef.educationFormId
inner join Courses as c on ef.specificId = c.courseId
inner join Modules as m on c.courseId = m.courseId
inner join OnlineMeetings as om on m.moduleId = om.moduleId
inner join Meetings as me on om.meetingId = me.meetingId
left join Attendance as a on me.meetingId = A.meetingId
GO

GRANT SELECT ON educationFormAttendance TO student
GO

GRANT SELECT ON educationFormAttendance TO studies_admin
GO

GRANT SELECT ON educationFormAttendance TO teacher
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

CREATE view finishedFormsAttendance as
    (select 'studies'                                          as educationForm,
            title + ', semester: ' + cast(semester as varchar) as title,
            sumOfEnrolledPresent                               as present,
            sumOfEnrolledStudents                              as enrolled,
            avgAttendance,
            sumOfNotEnrolledPresent                            as notEnrolled
     from studiesAttendanceSummary
              join Studies on studiesAttendanceSummary.studiesId = Studies.studiesId)
    union
    select 'course', C.title + ': ' + M.title, present, enrolledUsers, presentPercent, 0
    from pastCoursesAttendance PCA
             join Courses C on PCA.courseId = C.courseId
             join Modules M on C.courseId = M.courseId and PCA.moduleId = M.moduleId
GO

GRANT SELECT ON finishedFormsAttendance TO studies_admin
GO

GRANT SELECT ON finishedFormsAttendance TO teacher
GO

create view pastCourses as
select courseId
from coursesStartEnd
where finishDate < getdate()
GO

GRANT SELECT ON pastCourses TO teacher
GO

create view pastCoursesAttendance as
select CMA.courseId, moduleId, enrolledUsers, present, presentPercent
from coursesModulesAttendance CMA
         join pastCourses PC on CMA.courseId = PC.courseId
GO

GRANT SELECT ON pastCoursesAttendance TO teacher
GO

create view pastStudies as
select studiesId, semester
from studiesStartEnd
where finishDate < getdate()
  and finishDate is not null
GO

GRANT SELECT ON pastStudies TO studies_admin
GO

GRANT SELECT ON pastStudies TO teacher
GO

create view pastWebinars as
select webinarId,W.onlineMeetingId from Webinars W
join WebinarMeetings WM on W.onlineMeetingId = WM.onlineMeetingId
where date < getdate()
GO

GRANT SELECT ON pastWebinars TO teacher
GO

create view studentsStudies as
select userId, S.studiesId, S.semester, scheduleId
from Students S
         join StudiesSchedules SS on S.studiesId = SS.studiesId and S.semester = SS.semester
GO

GRANT SELECT ON studentsStudies TO studies_admin
GO

create view studentStudiesMeetings as
with StudentsMeetings as
    (select userId,studiesId,semester,subjectId,date,studiesMeetingId from studentsStudies SS
    join StudiesMeetings SM on SS.scheduleId = SM.scheduleId)
select userId,studiesId,semester,subjectId,date,SM.studiesMeetingId,place,room from StudentsMeetings SM
join OfflineStudiesMeetings OSM on SM.studiesMeetingId = OSM.studiesMeetingId
union
select userId,studiesId,semester,subjectId,date,SM.studiesMeetingId,link,'online' as room from StudentsMeetings SM
join OnlineStudiesMeetings OSM on SM.studiesMeetingId = OSM.studiesMeetingId
GO

GRANT SELECT ON studentStudiesMeetings TO studies_admin
GO

create view studiesAttendanceSummary as
select studiesId,
       semester,
       sum(SMA.presentEnrolledStudents)                   as sumOfEnrolledPresent,
       sum(enrolledStudents)                              as sumOfEnrolledStudents,
       round(CAST(100.0 * (sum(presentEnrolledStudents)) / sum(enrolledStudents) as float),
             2)                                           as avgAttendance,
       sum(presentStudents - SMA.presentEnrolledStudents) as sumOfNotEnrolledPresent
from studiesMeetingsAttendance SMA
group by studiesId, semester
GO

GRANT SELECT ON studiesAttendanceSummary TO studies_admin
GO

create view studiesMeetingsAttendance as
select SS.studiesId,
       SS.semester,
       SM.studiesMeetingId,
       (select count(SSM1.userId)
        from studentStudiesMeetings SSM1
        where SSM1.studiesMeetingId = SM.studiesMeetingId) as enrolledStudents,
       presentEnrolledStudents,
       presentStudents
from StudiesMeetings SM
         join studiesMeetingsPresentStudents SMPS on SM.studiesMeetingId = SMPS.studiesMeetingId
         join studiesMeetingsPresentEnrolledStudents SMPES on SM.studiesMeetingId = SMPES.studiesMeetingId
         join StudiesSchedules SS on SM.scheduleId = SS.scheduleId
         join pastStudies SP on SS.studiesId = SP.studiesId and SS.semester = SP.semester
GO

GRANT SELECT ON studiesMeetingsAttendance TO studies_admin
GO

create view studiesMeetingsPresentEnrolledStudents as
select SSM.studiesMeetingId, count(SSM.userId) as presentEnrolledStudents
from studentStudiesMeetings SSM
         join StudiesAttendance SA on SSM.studiesMeetingId = SA.studiesMeetingId and SSM.userId = SA.userId
group by SSM.studiesMeetingId
GO

GRANT SELECT ON studiesMeetingsPresentEnrolledStudents TO studies_admin
GO

create view studiesMeetingsPresentStudents as
select studiesMeetingId,count(userId) as presentStudents from StudiesAttendance
group by studiesMeetingId
GO

GRANT SELECT ON studiesMeetingsPresentStudents TO studies_admin
GO

create view studiesStartEnd as
select studiesId, semester, min(date) as startDate, max(date) as finishDate
from StudiesSchedules SS
         left join StudiesMeetings SM on SS.scheduleId = SM.scheduleId
group by studiesId, semester
GO

GRANT SELECT ON studiesStartEnd TO logged_user
GO

GRANT SELECT ON studiesStartEnd TO non_logged_user
GO

GRANT SELECT ON studiesStartEnd TO student
GO

GRANT SELECT ON studiesStartEnd TO studies_admin
GO

GRANT SELECT ON studiesStartEnd TO teacher
GO

create view upcomingCourses as
select courseId
from coursesStartEnd
where startDate > getdate()
GO

GRANT SELECT ON upcomingCourses TO logged_user
GO

GRANT SELECT ON upcomingCourses TO non_logged_user
GO

GRANT SELECT ON upcomingCourses TO student
GO

GRANT SELECT ON upcomingCourses TO teacher
GO

create view upcomingStudies as
select studiesId, semester
from studiesStartEnd
where startDate > getdate()
   or startDate is null
GO

GRANT SELECT ON upcomingStudies TO logged_user
GO

GRANT SELECT ON upcomingStudies TO non_logged_user
GO

GRANT SELECT ON upcomingStudies TO student
GO

GRANT SELECT ON upcomingStudies TO studies_admin
GO

GRANT SELECT ON upcomingStudies TO teacher
GO

create view upcomingWebinars as
select webinarId,W.onlineMeetingId from Webinars W
join WebinarMeetings WM on W.onlineMeetingId = WM.onlineMeetingId
where date > getdate()
GO

GRANT SELECT ON upcomingWebinars TO logged_user
GO

GRANT SELECT ON upcomingWebinars TO non_logged_user
GO

GRANT SELECT ON upcomingWebinars TO student
GO

GRANT SELECT ON upcomingWebinars TO teacher
GO

create view usersCoursesMeetings as
select userId,
       courseId,
       UCM.moduleId,
       M.meetingId,
       date,
       place,
       room
from usersCoursesModules UCM
         join OfflineMeetings OM on UCM.moduleId = OM.moduleId
         join Meetings M on OM.meetingId = M.meetingId

union
select userId,
       courseId,
       UCM.moduleId,
       M.meetingId,
       date,
       link,
       'online' as room
from usersCoursesModules UCM
         join OnlineMeetings ONM on UCM.moduleId = ONM.moduleId
         join Meetings M on ONM.meetingId = M.meetingId
GO

GRANT SELECT ON usersCoursesMeetings TO student
GO

GRANT SELECT ON usersCoursesMeetings TO teacher
GO

create view usersCoursesModules as
select userId, C.courseId, moduleId
from usersEducationForms UEF
         join Courses C on C.courseId = UEF.specificId and UEF.type = 'course'
         join Modules M on M.courseId = C.courseId
GO

GRANT SELECT ON usersCoursesModules TO student
GO

GRANT SELECT ON usersCoursesModules TO teacher
GO

create view usersEducationForms as
    select userId, AEF.educationFormId, accessUntil, specificId,type from AssignedEducationForms AEF
    join EducationForms EF on EF.educationFormId = AEF.educationFormId
GO

GRANT SELECT ON usersEducationForms TO student
GO

GRANT SELECT ON usersEducationForms TO teacher
GO

create view usersEnrolledForUpcomingEvents as
(select count(userId) as zapisaneOsoby, 'webinar' as rodzajWydarzenia, 'zdalnie' as formatWydarzenia
 from WebinarMeetings WM
          join upcomingWebinars UW on UW.onlineMeetingId = WM.onlineMeetingId
          join usersEducationForms UEF on UEF.specificId = UW.webinarId and UEF.type = 'webinar'
 union
 select count(userId) as zapisaneOsoby, 'moduł' as rodzajWydarzenia, 'zdalnie' as formatWydarzenia
 from usersCoursesModules
          join upcomingCourses UC on UC.courseId = usersCoursesModules.courseId
          join OnlineSyncModules OSM on OSM.moduleId = usersCoursesModules.moduleId
 union
 select count(userId) as zapisaneOsoby, 'moduł' as rodzajWydarzenia, 'stacjonarnie' as formatWydarzenia
 from usersCoursesModules
          join upcomingCourses UC on UC.courseId = usersCoursesModules.courseId
          join StationaryModules SM on SM.moduleId = usersCoursesModules.moduleId
 union
 select count(userId) as zapisaneOsoby, 'moduł' as rodzajWydarzenia, 'hybrydowo' as formatWydarzenia
 from usersCoursesModules
          join upcomingCourses UC on UC.courseId = usersCoursesModules.courseId
          join HybridModules HM on HM.moduleId = usersCoursesModules.moduleId
 union
 select count(userId) as zapisaneOsoby, 'studia' as rodzajWydarzenia, 'stacjonarnie' as formatWydarzenia
 from studentsStudies SS
          join upcomingStudies US on US.studiesId = SS.studiesId and US.semester = SS.semester
          join StudiesMeetings SM on SM.scheduleId = SS.scheduleId
          join OfflineStudiesMeetings OSM on OSM.studiesMeetingId = SM.studiesMeetingId
union
select count(userId) as zapisaneOsoby, 'studia' as rodzajWydarzenia, 'zdalnie' as formatWydarzenia
from studentsStudies SS
         join upcomingStudies US on US.studiesId = SS.studiesId and US.semester = SS.semester
         join StudiesMeetings SM on SM.scheduleId = SS.scheduleId
         join OnlineStudiesMeetings OSM on OSM.studiesMeetingId = SM.studiesMeetingId )
GO

GRANT SELECT ON usersEnrolledForUpcomingEvents TO student
GO

GRANT SELECT ON usersEnrolledForUpcomingEvents TO teacher
GO

create view usersForEachPastCourseModuleMeeting as
select UCM.courseId, moduleId, meetingId, count(userId) as enrolledUsers
from usersCoursesMeetings UCM
         join pastCourses PC on UCM.courseId = PC.courseId
group by UCM.courseId, moduleId, meetingId
GO

GRANT SELECT ON usersForEachPastCourseModuleMeeting TO teacher
GO

