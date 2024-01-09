-- Ogólny raport dotyczący liczby zapisanych osób na przyszłe wydarzenia (z informacją, czy wydarzenie jest stacjonarnie, czy zdalnie).

create view CoursesStartFinishDates as
select C.courseId,min(date) as startDate,max(date) as finishDate from Courses C
join Modules M on C.courseId = M.courseId
left join OfflineMeetings OM on M.moduleId = OM.moduleId
left join OnlineMeetings ONM on M.moduleId = ONM.moduleId
join Meetings M2 on OM.meetingId = M2.meetingId or ONM.meetingId = M2.meetingId
group by C.courseId

create view UpcomingCourses as
select courseId from CoursesStartFinishDates
where startDate > getdate()


create view UserModuleUpcomingCourses as (select userId, moduleId
                                  from AssignedEducationForms AEF
                                           join EducationForms EF on EF.educationFormId = AEF.educationFormId
                                           join UpcomingCourses UC on UC.courseId = EF.specificId
                                           join Modules M on M.courseId = UC.courseId)

create view UsersEnrolledForUpcomingEvents as
(
select count(userId) as zapisaneOsoby, 'webinar' as rodzajWydarzenia, 'zdalnie' as formatWydarzenia
from WebinarMeetings
         join Webinars on Webinars.onlineMeetingId = WebinarMeetings.onlineMeetingId
         join EducationForms on EducationForms.specificId = Webinars.webinarId
         join AssignedEducationForms on AssignedEducationForms.educationFormId = EducationForms.educationFormId
where date > getdate()
union
select count(userId) as zapisaneOsoby, 'kurs' as rodzajWydarzenia, 'zdalnie' as formatWydarzenia
from UserModuleUpcomingCourses
         join OnlineSyncModules OSM on OSM.moduleId = UserModuleUpcomingCourses.moduleId
union
select count(userId) as zapisaneOsoby, 'kurs' as rodzajWydarzenia, 'stacjonarnie' as formatWydarzenia
from UserModuleUpcomingCourses
         join StationaryModules SM on SM.moduleId = UserModuleUpcomingCourses.moduleId
union
select count(userId) as zapisaneOsoby, 'kurs' as rodzajWydarzenia, 'hybrydowo' as formatWydarzenia
from UserModuleUpcomingCourses
         join HybridModules HM on HM.moduleId = UserModuleUpcomingCourses.moduleId
union
select count(userId) as zapisaneOsoby, 'studia' as rodzajWydarzenia, 'hybrydowo' as formatWydarzenia
from Students
         join (select studiesId, year
               from StudiesSchedules
                        join StudiesMeetings on StudiesSchedules.scheduleId = StudiesMeetings.scheduleId
               group by studiesId, year
               having min(date) > getdate()) as UpcomingStudies
              on Students.studiesId = UpcomingStudies.studiesId and Students.year = UpcomingStudies.year
    )

select * from UsersEnrolledForUpcomingEvents

