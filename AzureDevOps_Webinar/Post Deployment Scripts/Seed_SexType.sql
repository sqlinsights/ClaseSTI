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