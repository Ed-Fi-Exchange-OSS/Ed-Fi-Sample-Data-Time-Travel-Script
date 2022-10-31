-- =======================================================================================================
-- Author:      Emilio Baez, Sr. Solution Architect @ Developers.Net
-- Create date: 09/07/2020
-- Description:	This T-SQL script was created to help update an Ed-FI ODS DB to the most recent school year.
--              Except for 'CreateDate' and 'LastModifiedDate', this logic will update all columns that have the keywords
--              'Date' or 'Year' as part of the name. 
-- Modifications:
-- * 2022-10-31 - SFUQUA - remove transactions. Recommended to be in SIMPLE recovery model
-- ========================================================================================================
USE [DBName]
GO


--by default the query will always attempt to update date to the current year. 
DECLARE @targetSchoolYear SMALLINT = CASE WHEN MONTH(GETDATE()) >= 7 THEN YEAR(GETDATE()) + 1 ELSE YEAR(GETDATE())  END;
DECLARE @existingSchoolYear SMALLINT = (SELECT TOP(1) SchoolYear FROM edfi.Calendar ORDER BY SchoolYear DESC);
DECLARE @yearDifference SMALLINT = @targetSchoolYear - @existingSchoolYear;

IF (@yearDifference > 0)
 BEGIN 
 
	--using a temp tables to loop through all tables
	--trying to stay away from cursors 
	DECLARE @tableNames TABLE (Id SMALLINT NOT NULL IDENTITY(1,1), 
							   TableName NVARCHAR(500) NOT NULL, 
							   ColumnName NVARCHAR(500) NOT NULL );
	DECLARE @rowId SMALLINT = 1;
	DECLARE @totalTables SMALLINT = 1;
	DECLARE @tableName NVARCHAR(500);
	DECLARE @columnName NVARCHAR(500);
	DECLARE @sqlCommand NVARCHAR(MAX);
	DECLARE @sqlCommandParamDefinition NVARCHAR(500);

	--searching for all tables with the SchoolYear column 
	INSERT INTO @tableNames (TableName, ColumnName)
	SELECT DISTINCT  CONCAT(c.TABLE_SCHEMA,'.',c.TABLE_NAME) AS TableName, c.COLUMN_NAME AS ColumnName
	FROM INFORMATION_SCHEMA.COLUMNS c
	WHERE (
		   (CHARINDEX('Date',c.COLUMN_NAME,1) > 0 AND c.DATA_TYPE IN ('date','datetime','datetime2'))
			 OR
		   (CHARINDEX('Year',c.COLUMN_NAME,1) > 0 AND CHARINDEX('int',c.DATA_TYPE,1) > 0)      
		  )
	AND c.COLUMN_NAME NOT IN ('CreateDate','LastModifiedDate')
	AND c.TABLE_SCHEMA NOT IN ('SchoolYearType')
	AND NOT EXISTS (SELECT 1 
					FROM INFORMATION_SCHEMA.VIEWS v
					WHERE c.TABLE_CATALOG = v.TABLE_CATALOG
					  AND c.TABLE_SCHEMA = v.TABLE_SCHEMA
					  AND c.TABLE_NAME = v.TABLE_NAME)
	ORDER BY TableName, ColumnName

	--storing the total number of tables/columns found 
	SET @totalTables = @@ROWCOUNT;
	
	-- disabling all constraints
	EXEC sp_msforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT all";

	--looping through each table 
	WHILE (@rowId <= @totalTables)
		BEGIN
		--retrieving the table name from the temp table variable
		SELECT @tableName = TableName,
				@columnName = ColumnName
		FROM @tableNames WHERE Id = @rowId;

		PRINT(CONCAT('Processing: Table:',@tableName,'. Column:', @columnName));

		--SET @sqlCommand = 'ALTER INDEX ALL ON ' + @tableName + ' DISABLE;';
		--EXECUTE sp_executesql @sqlCommand;
   
		SET @sqlCommand = 'IF EXISTS( SELECT 1
										FROM INFORMATION_SCHEMA.COLUMNS 
										WHERE CONCAT(TABLE_SCHEMA,''.'',TABLE_NAME) = @tableName
										AND column_name = @columnName)
								AND EXISTS (SELECT 1
											FROM ' + @tableName + ')
								BEGIN
									UPDATE ' + @tableName + '        
									SET [' + @columnName + '] = ' + CASE WHEN CHARINDEX('Year',@columnName,1) > 0 THEN 
										                                /*
																			Adding the year difference to the existing year column
																		*/																				
																		'COALESCE([' + @columnName + '],' + CAST(@existingSchoolYear AS NVARCHAR) + ') + ' + CAST(@yearDifference AS NVARCHAR(max))  										                                        
																		ELSE
																		/*
																			Transporting the existing date column to the target year.
																			Because the existing year is not a leap year and does not start on a Thursday, finding the target week won't be an issue
																			If the existing year is leap year that starts on a wednesday or a regular year that starts on a thursday, the year has 53 weeks. 
																			If existing date is: '08/31/2010' which falls on Week Day # 3 (Tuesday) and Week Of Year # 36, we will transform this date into '09/01/2020' which also falls on a Tuesday and Week Of Year # 36.
																		*/																				
																		' DATEADD(WEEKDAY,DATEPART(weekday,[' + @columnName + '])-1,DATEADD(wk, DATEDIFF(wk, 6, ''1/1/'' + CAST(YEAR([' + @columnName + ']) + ' + CAST(@yearDifference AS NVARCHAR(max)) + ' AS NVARCHAR(max))) + (DATEPART(week,[' + @columnName + '])-1), 6))' 
																END + '

    
								END;
							';  
     
		SET @sqlCommandParamDefinition = N'@tableName nvarchar(500), @columnName nvarchar(500)';
		EXECUTE sp_executesql @sqlCommand, @sqlCommandParamDefinition, 
								@tableName = @tableName,
								@columnName = @columnName;

		--SET @sqlCommand = 'ALTER INDEX ALL ON [@tableName] REBUILD;';
		--EXECUTE sp_executesql @sqlCommand, N'@tableName nvarchar(500)', @tableName = @tableName;

		--moving to next records
		SET @rowId = @rowId + 1;
	END;

	-- enabling all constraints 
	EXEC sp_msforeachtable "ALTER TABLE ? WITH CHECK CHECK CONSTRAINT all"
 END
