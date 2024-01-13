-- this file contains following views:
-- usersEducationForms
-- coursesStartEnd
-- upcomingCourses
-- pastCourses
-- upcomingWebinars
-- pastWebinars
-- studiesStartEnd
-- pastStudies
-- currentStudies
-- upcomingStudies
-- studentsStudies
-- usersCoursesModules
-- usersEnrolledForUpcomingEvents
-- usersCoursesMeetings
-- usersForEachPastCourseModuleMeeting
-- coursesMeetingsAttendance
-- coursesModulesAttendance
-- pastCoursesAttendance
-- studentStudiesMeetings
-- studiesMeetingsPresentStudents
-- studiesMeetingsPresentEnrolledStudents
-- studiesMeetingsAttendance
-- FinishedStudiesAttendance
-- FinishedFormsAttendance


create view usersEducationForms as
select userId, AEF.educationFormId, accessUntil, specificId, type
from AssignedEducationForms AEF
         join EducationForms EF on EF.educationFormId = AEF.educationFormId

create view coursesStartEnd as
select C.courseId, min(date) as startDate, max(date) as finishDate
from Courses C
         join Modules M on C.courseId = M.courseId
         left join OfflineMeetings OM on M.moduleId = OM.moduleId
         left join OnlineMeetings ONM on M.moduleId = ONM.moduleId
         join Meetings M2 on OM.meetingId = M2.meetingId or ONM.meetingId = M2.meetingId
group by C.courseId

create view upcomingCourses as
select courseId
from coursesStartEnd
where startDate > getdate()

create view pastCourses as
select courseId
from coursesStartEnd
where finishDate < getdate()

create view upcomingWebinars as
select webinarId, W.onlineMeetingId
from Webinars W
         join WebinarMeetings WM on W.onlineMeetingId = WM.onlineMeetingId
where date > getdate()



create view pastWebinars as
select webinarId, W.onlineMeetingId
from Webinars W
         join WebinarMeetings WM on W.onlineMeetingId = WM.onlineMeetingId
where date < getdate()

create view studiesStartEnd as
select studiesId, semester, min(date) as startDate, max(date) as finishDate
from StudiesSchedules SS
         left join StudiesMeetings SM on SS.scheduleId = SM.scheduleId
group by studiesId, semester

create view pastStudies as
select studiesId, semester
from studiesStartEnd
where finishDate < getdate()
  and finishDate is not null

create view currentStudies as
select studiesId, semester
from studiesStartEnd
where startDate < getdate()
  and finishDate > getdate()

create view upcomingStudies as
select studiesId, semester
from studiesStartEnd
where startDate > getdate()
   or startDate is null

create view studentsStudies as
select userId, S.studiesId, S.semester, scheduleId
from Students S
         join StudiesSchedules SS on S.studiesId = SS.studiesId and S.semester = SS.semester

create view usersCoursesModules as
select userId, C.courseId, moduleId
from usersEducationForms UEF
         join Courses C on C.courseId = UEF.specificId and UEF.type = 'course'
         join Modules M on M.courseId = C.courseId

create view usersEnrolledForUpcomingEvents as
(
select count(userId) as zapisaneOsoby, 'webinar' as rodzajWydarzenia, 'zdalnie' as formatWydarzenia
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


create view usersForEachPastCourseModuleMeeting as
select UCM.courseId, moduleId, meetingId, count(userId) as enrolledUsers
from usersCoursesMeetings UCM
         join pastCourses PC on UCM.courseId = PC.courseId
group by UCM.courseId, moduleId, meetingId

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

create view coursesModulesAttendance as
select courseId,
       moduleId,
       sum(enrolledUsers)            as enrolledUsers,
       sum(present)                  as present,
       round(avg(presentPercent), 2) as presentPercent
from coursesMeetingsAttendance
group by courseId, moduleId

create view pastCoursesAttendance as
select CMA.courseId, moduleId, enrolledUsers, present, presentPercent
from coursesModulesAttendance CMA
         join pastCourses PC on CMA.courseId = PC.courseId

create view studentStudiesMeetings as
with StudentsMeetings as
         (select userId, studiesId, semester, subjectId, date, studiesMeetingId
          from studentsStudies SS
                   join StudiesMeetings SM on SS.scheduleId = SM.scheduleId)
select userId,
       studiesId,
       semester,
       subjectId,
       date,
       SM.studiesMeetingId,
       place,
       room
from StudentsMeetings SM
         join OfflineStudiesMeetings OSM on SM.studiesMeetingId = OSM.studiesMeetingId
union
select userId,
       studiesId,
       semester,
       subjectId,
       date,
       SM.studiesMeetingId,
       link,
       'online' as room
from StudentsMeetings SM
         join OnlineStudiesMeetings OSM on SM.studiesMeetingId = OSM.studiesMeetingId

create view studiesMeetingsPresentStudents as
select studiesMeetingId, count(userId) as presentStudents
from StudiesAttendance
group by studiesMeetingId

create view studiesMeetingsPresentEnrolledStudents as
select SSM.studiesMeetingId, count(SSM.userId) as presentEnrolledStudents
from studentStudiesMeetings SSM
         join StudiesAttendance SA on SSM.studiesMeetingId = SA.studiesMeetingId and SSM.userId = SA.userId
group by SSM.studiesMeetingId

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


create view finishedFormsAttendance as
(select 'studies'                                         as educationForm,
        name + ', semester: ' + cast(semester as varchar) as title,
        sumOfEnrolledPresent                              as present,
        sumOfEnrolledStudents                             as enrolled,
        avgAttendance,
        sumOfNotEnrolledPresent                           as notEnrolled
 from studiesAttendanceSummary
          join Studies on studiesAttendanceSummary.studiesId = Studies.studiesId)
union
select 'course', C.title + ': ' + M.title, present, enrolledUsers, presentPercent, 0
from pastCoursesAttendance PCA
         join Courses C on PCA.courseId = C.courseId
         join Modules M on C.courseId = M.courseId and PCA.moduleId = M.moduleId
