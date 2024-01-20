-- DELETE
-- FROM EducationForms
-- WHERE specificId = 1004
--   AND type = 'course'
-- EXEC CreateCourse 'test', 10, 100, '2025-01-01', 10, 10, 10
-- SELECT title, courseId, slotsLimit, wholePrice, advance, accessFor
-- FROM Courses
--          JOIN EducationForms ON Courses.courseId = EducationForms.specificId AND type = 'course'
--          JOIN EducationFormPrice ON EducationForms.educationFormId = EducationFormPrice.educationFormId
-- WHERE title = 'test'
-- EXEC CreateModule 'test2', 1101, 'stationary'
-- SELECT *
-- FROM Modules
-- WHERE title = 'test2'
-- SELECT *
-- FROM StationaryModules
-- WHERE moduleId = 301
-- EXEC SaveOfflineMeeting 301, '2025-01-01 15:00:00', 100, 'test', 'test'
-- EXEC SaveOfflineMeeting 301, '2025-01-01 15:30:00', 100, 'test', 'test'

-- DELETE
-- FROM OfflineMeetings
-- WHERE moduleId = 301
-- DELETE
-- FROM Meetings
-- WHERE meetingId = 712
-- DELETE
-- FROM StationaryModules
-- WHERE moduleId = 301
-- DELETE
-- FROM Modules
-- WHERE moduleId = 301
-- DELETE
-- FROM Courses
-- WHERE courseId = 1101
--
-- -- select * from Courses where title ='test'
-- DELETE
-- FROM EducationForms
-- WHERE specificId = 1101
--   AND type = 'Course'
-- DELETE
-- FROM Courses
-- WHERE title = 'test'
-- DELETE
-- FROM Modules
-- WHERE title = 'test2'
-- SELECT *
-- FROM Modules
-- WHERE title = 'test2'
-- DELETE
-- FROM StationaryModules
-- WHERE moduleId = 301
-- -- EXEC CreateModule 'test2', 1101, 'stationary'
-- -- EXEC CreateEducationForm 1101, 'Course'


-- SELECT *
-- FROM dbo.emptyRooms('2023-07-25', '19:00', '20:00')
-- WHERE room='3'
-- SELECT * from OfflineStudiesMeetings
-- join dbo.StudiesMeetings SM ON OfflineStudiesMeetings.studiesMeetingId = SM.studiesMeetingId
-- WHERE cast(date as date)  ='2023-07-25'


-- dodawanie do koszyka
SELECT *
FROM Courses
SELECT *
FROM Webinars
EXEC AddToCart 1, 1002, 'course'
EXEC AddToCart 1, 1004, 'course'
EXEC AddToCart 1, 1001, 'course'
EXEC RemoveFromCart 1, 1
SELECT *
FROM dbo.getCartForUser(1)
EXEC ClearCart 1

-- finalizowanie koszyka
SELECT *
FROM AssignedEducationForms
WHERE userId = 1
SELECT *
FROM Courses
SELECT *
FROM Webinars
EXEC AddToCart 1, 1002, 'course'
EXEC AddToCart 1, 1004, 'course'
-- EXEC AddToCart 1, 1001, 'course' #should fail
EXEC AddToCart 1, 1001, 'webinar'
SELECT *
FROM dbo.getCartForUser(1)
EXEC FinalizeCart 1
