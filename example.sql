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


--
SELECT courseId, dbo.getFreeCourseSlots(courseId)
FROM Courses
WHERE courseId = 1050

SELECT *
FROM EducationForms
WHERE specificId = 1050

DELETE
FROM AssignedEducationForms
WHERE (userId = 7 OR userId = 8)
  AND educationFormId = 50

SELECT *
FROM AssignedEducationForms
WHERE educationFormId = 50

EXEC AddToCart 7, 1050, 'course'
EXEC AddToCart 8, 1050, 'course'


SELECT *
FROM dbo.getCartForUser(7)
EXEC AreFreeSlotsInAllFormsInCart 7

DECLARE @myPaymentLink varchar(255)
EXEC dbo.generatePaymentLink 7, @paymentLink = @myPaymentLink OUTPUT
SELECT @myPaymentLink
INSERT INTO PaymentsHistory (paymentId, userId, paymentDate, payedFor, amount, paymentDetails)
VALUES (dbo.nextPaymentId(), 8, GETDATE(), 1, 833, 'course1050')

SELECT *
FROM PaymentsHistory
WHERE userId = 8


--
SELECT *
FROM dbo.getCartForUser(1)
SELECT *
FROM Courses
SELECT *
FROM Studies
--sprawdzmy educationFormId
SELECT *
FROM EducationForms
WHERE specificId = 273
  AND type = 'webinar'
SELECT *
FROM EducationForms
WHERE specificId = 1002
  AND type = 'course'

-- EXEC ClearCart 1
EXEC AddToCart 1, 1002, 'course'
EXEC AddToCart 1, 1, 'studies'
EXEC AddToCart 1, 273, 'webinar'

DECLARE @myPaymentLink varchar(255)
EXEC generatePaymentLink 1, @myPaymentLink OUTPUT
SELECT @myPaymentLink

SELECT *
FROM AssignedEducationForms
WHERE userId = 1


INSERT INTO PaymentsHistory (paymentId, userId, paymentDate, payedFor, amount, paymentDetails)
VALUES (dbo.nextPaymentId(), 1, GETDATE(), 60, 888, 'koszyk1')

SELECT *
FROM Webinars

EXEC CreateWebinar 'test', 'abc', '2025-01-01 15:00:00', 100, 'test', 10
