-- frekwencja zakończonych kursów i studiów
create view WebinarsPast as
select webinarId from Webinars W
join WebinarMeetings WM on W.onlineMeetingId = WM.onlineMeetingId
where date < getdate()

create view CoursesPast as
    select courseId from CoursesStartFinishDates
    where finishDate < getdate()

create view StudiesScheduleStartFinishDates as
select studiesId,year,min(date) as startDate,max(date) as finishDate from StudiesSchedules SS
join StudiesMeetings SM on SS.scheduleId = SM.scheduleId
group by studiesId,year

create view StudiesPast as
    select studiesId,year from StudiesScheduleStartFinishDates
    where finishDate < getdate()


create view CoursesMeetings as (
select C.courseId, ME.meetingId from Courses C
join Modules M on C.courseId = M.courseId
left join OfflineMeetings OM on OM.moduleId = M.moduleId
left join OnlineMeetings ONM on ONM.moduleId = M.moduleId
join Meetings ME on OM.meetingId = ME.meetingId or ONM.meetingId = ME.meetingId
)


create view FinishedCoursesAttendance as
select CM.courseId,title, round(CAST(100.0*count(userId)/count(CM.meetingId)as float),2) as średniaFrekwencja from CoursesMeetings CM
join Courses C on CM.courseId = C.courseId
join CoursesPast CP on CM.courseId = CP.courseId
left join Attendance A on CM.meetingId = A.meetingId
group by CM.courseId, title;


create view StudiesSummary as (select SP.studiesId as studiesId, SP.year as year, SM.studiesMeetingId as meetingId, StudiesAttendance.studiesMeetingId as present, (select count(*) from Attendance where Attendance.meetingId = SM.studiesMeetingId) as liczbaObecnychNiezapisanych from Students
    join StudiesPast SP on Students.studiesId = SP.studiesId and Students.year = SP.year
    join StudiesSchedules SS on Students.studiesId = SS.studiesId and Students.year = SS.year
    join StudiesMeetings SM on SS.scheduleId = SM.scheduleId
    left join StudiesAttendance on SM.studiesMeetingId = StudiesAttendance.studiesMeetingId and Students.userId = StudiesAttendance.userId)

create view FinishedStudiesAttendance as (
select studiesId,year, round(CAST(100.0*(count(present))/count(meetingId) as float),2) as średniaFrekwencja, sum(liczbaObecnychNiezapisanych) as liczbaObecnychNiezapisanych from StudiesSummary group by studiesId,year)


create view FinishedFormsAttendance as (
select 'studia' as formaNauczania, name + ', rok: ' + cast(year as varchar) as nazwa, średniaFrekwencja from FinishedStudiesAttendance
join Studies on FinishedStudiesAttendance.studiesId = Studies.studiesId
                                           )
union
select 'kurs',title,średniaFrekwencja from FinishedCoursesAttendance
