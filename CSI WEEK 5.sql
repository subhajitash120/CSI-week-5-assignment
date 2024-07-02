create database CSI_5
use CSI_5

-- Create the SubjectAllotments table
CREATE TABLE SubjectAllotments (
    StudentID VARCHAR(50),
    SubjectID VARCHAR(50),
    Is_Valid BIT
);
GO

-- Create the SubjectRequest table
CREATE TABLE SubjectRequest (
    StudentID VARCHAR(50),
    SubjectID VARCHAR(50)
);
GO

-- Insert initial data into SubjectAllotments table
INSERT INTO SubjectAllotments (StudentID, SubjectID, Is_Valid)
VALUES
('159103036', 'PO1491', 1),
('159103036', 'PO1492', 0),
('159103036', 'PO1493', 0),
('159103036', 'PO1494', 0),
('159103036', 'PO1495', 0);
GO

-- Insert data into SubjectRequest table
INSERT INTO SubjectRequest (StudentID, SubjectID)
VALUES
('159103036', 'PO1496'), -- Existing student requesting a new subject
('159103037', 'PO1497'); -- New student requesting a subject
GO

-- Create the stored procedure to update SubjectAllotments
CREATE PROCEDURE UpdateSubjectAllotments
AS
BEGIN
    -- Declare a cursor to iterate over each record in the SubjectRequest table
    DECLARE cur CURSOR FOR
    SELECT StudentID, SubjectID
    FROM SubjectRequest;

    DECLARE @StudentID VARCHAR(50);
    DECLARE @SubjectID VARCHAR(50);

    OPEN cur;

    FETCH NEXT FROM cur INTO @StudentID, @SubjectID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Check if the student exists in the SubjectAllotments table
        IF EXISTS (SELECT 1 FROM SubjectAllotments WHERE StudentID = @StudentID)
        BEGIN
            -- Check if the current subject is different from the requested subject
            IF EXISTS (SELECT 1 FROM SubjectAllotments WHERE StudentID = @StudentID AND SubjectID = @SubjectID AND Is_Valid = 1)
            BEGIN
                -- Do nothing, as the requested subject is already the current subject
				set @StudentID=@StudentID
            END
            ELSE
            BEGIN
                -- Mark the current valid subject as invalid
                UPDATE SubjectAllotments
                SET Is_Valid = 0
                WHERE StudentID = @StudentID AND Is_Valid = 1;

                -- Insert the new subject as valid
                INSERT INTO SubjectAllotments (StudentID, SubjectID, Is_Valid)
                VALUES (@StudentID, @SubjectID, 1);
            END
        END
        ELSE
        BEGIN
            -- Insert the requested subject as a valid record for a new student
            INSERT INTO SubjectAllotments (StudentID, SubjectID, Is_Valid)
            VALUES (@StudentID, @SubjectID, 1);
        END

        FETCH NEXT FROM cur INTO @StudentID, @SubjectID;
    END

    CLOSE cur;
    DEALLOCATE cur;
END;
GO

-- Test the stored procedure
EXEC UpdateSubjectAllotments;
GO

-- Query the SubjectAllotments table to check the updated records
SELECT * FROM SubjectAllotments;
GO

-- Query the SubjectRequest table to check the remaining requests
SELECT * FROM SubjectRequest;
GO
