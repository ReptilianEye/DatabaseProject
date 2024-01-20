CREATE TYPE usersList AS table
(
    userId int
)
CREATE TYPE userCart AS TABLE
(
    educationFormId int,
    specificId int,
    title varchar(100),
    type varchar(100),
    advance money,
    advanceDue int,
    wholePrice money
)