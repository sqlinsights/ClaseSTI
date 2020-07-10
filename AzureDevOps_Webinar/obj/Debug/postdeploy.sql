/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

DECLARE @SexType Nvarchar(Max)
SET @SexType = '[
	{
	"SexTypeID" : 1,
	"SexType":"Male"
	},
	{
	"SexTypeID" : 2,
	"SexType":"Female"
	},
	{
	"SexTypeID" : 3,
	"SexType":"Non-Binary"
	},
	{
	"SexTypeID" : 4,
	"SexType":"Unidentified"
	}
	]'

IF (ISJSON(@SexType) = 1)
BEGIN
		MERGE Reference.SexType as TGT
			USING (
			SELECT SexTypeID, SexType
				FROM OPENJSON(@SexType)
				WITH (
				SexTypeID INT '$.SexTypeID'
				,SexType Varchar(30) '$.SexType'
				)

			) as SRC
				ON TGT.SexTypeID = SRC.SexTypeID
			WHEN MATCHED THEN UPDATE SET SexType = SRC.SexType
			WHEN NOT MATCHED THEN 
			INSERT
			(SexTypeID, SexType)
			VALUES
			(SRC.SexTypeID, SRC.SexType
			)
			WHEN NOT MATCHED BY SOURCE THEN DELETE;
		END
ELSE
	RAISERROR('@SexType JSON has an incorrect format',11,1)
GO
