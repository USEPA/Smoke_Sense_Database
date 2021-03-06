/*

You are recommended to back up your database before running this script

Script created by SQL Compare version 14.2.9.15508 from Red Gate Software Ltd at 6/29/2020 6:46:16 PM

*/
SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
SET XACT_ABORT ON
GO
SET TRANSACTION ISOLATION LEVEL Serializable
GO
BEGIN TRANSACTION
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[Week_GetByDate]'
GO
-- =============================================
-- Author:		Angela Ekstrand
-- Create date: 2016-10-18
-- Description:	Gets the WeekID based on the User's local time
-- =============================================
CREATE PROCEDURE [dbo].[Week_GetByDate]
(
	@LT datetime
)
AS
BEGIN
	
	SET NOCOUNT ON;

    SELECT w.WeekID, w.StartDate, w.EndDate, w.WeekNumber, a.TotalWeeks
    FROM [Week] w
	CROSS JOIN (SELECT MAX(WeekNumber) TotalWeeks FROM Week) a
    WHERE @LT BETWEEN w.StartDate AND w.EndDate

END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[Week_Update]'
GO
-- =============================================
-- Author:		Angela Ekstrand
-- Create date: 2016-10-18
-- Description:	Updates start/end dates for a WeekID
-- =============================================
CREATE PROCEDURE [dbo].[Week_Update]
(
	@StartDate	smalldatetime,
	@EndDate	smalldatetime,
	@WeekID		smallint
)
AS
BEGIN
	
	SET NOCOUNT ON;

    UPDATE [Week]
	SET @StartDate = DATEADD(hh,-DATEPART(hh,@StartDate),DATEADD(mi,-DATEPART(mi,@StartDate),@StartDate)), 
		@EndDate = DATEADD(hh,23,DATEADD(mi,59,DATEADD(hh,-DATEPART(hh,@EndDate),DATEADD(mi,-DATEPART(mi,@EndDate),@EndDate))))
	WHERE [Week].WeekID = @WeekID

END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[WCIDContent_getAll]'
GO
-- =============================================
-- Author:		Tim Doughty
-- Create date: 2020-05-12
-- Description:	Retrieves the 'What Could I Do? content
-- =============================================
CREATE PROCEDURE [dbo].[WCIDContent_getAll]
	-- Add the parameters for the stored procedure here
	@LanguageCode nchar(2) = 'en'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT w.ContentID, w.[Type], w.[Sequence],
		   wcv.[Text], wcv.linkText, wcv.linkURL
	FROM dbo.WCIDContent w
	JOIN dbo.WCIDContentView wcv ON w.ContentID = wcv.ContentID
	WHERE wcv.ISO639_Code = @LanguageCode
	ORDER BY w.[Sequence]
END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[UserSurvey_Insert]'
GO
-- =============================================
-- Author:		Angela Ekstrand
-- Create date:	2016-10-18
-- Description:	Creates a UserSurveyID prior to survey "save"
-- =============================================
CREATE PROCEDURE [dbo].[UserSurvey_Insert]
(
	@SurveyID		smallint,
	@WeekID		int,
	@GUID		nvarchar(max),	
	@LT			smalldatetime
)
AS
BEGIN
	
	SET NOCOUNT ON;

	IF @SurveyID = 0 SET @WeekID = 0

	UPDATE dbo.[User]
	SET dbo.[User].LastActiveLT = @LT
	FROM dbo.[User] u
	WHERE u.GUID = @GUID

	DECLARE @UserSurveyID int

	--Find existing @UserSurveyID
	SELECT @UserSurveyID = us.UserSurveyID 
	FROM dbo.UserSurvey us
	JOIN dbo.[User]		u ON us.UserID = u.UserID
	WHERE u.GUID = @GUID
	  AND us.SurveyID = @SurveyID
	  AND us.WeekID = @WeekID
	
	--Insert Record for Survey if needed
	IF @UserSurveyID IS NULL
	BEGIN
		INSERT INTO dbo.UserSurvey
		(
		    --UserSurveyID - this column value is auto-generated
		    UserID,
		    SurveyID,
		    WeekID
		)
		SELECT u.UserID, @SurveyID, @WeekID
		FROM dbo.[User] u
		WHERE u.GUID = @GUID
	
		SET @UserSurveyID = @@IDENTITY
	END

	SELECT @UserSurveyID AS UserSurveyID

END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[UserBadge_Insert]'
GO
-- =============================================
-- Author:		Angela Ekstrand
-- Create date: 2016-10-18
-- Description:	Inserts a new user badge by week
-- =============================================
CREATE PROCEDURE [dbo].[UserBadge_Insert]
(
	@GUID		nvarchar(max),
	@BadgeID	tinyint,
	@WeekID		smallint,
	@LT			smalldatetime,
	@LanguageCode nchar(2) = 'en'
)
AS
BEGIN
	
	SET NOCOUNT ON;

	UPDATE dbo.[User]
	SET dbo.[User].LastActiveLT = @LT
	FROM dbo.[User] u
	WHERE u.GUID = @GUID

	DECLARE @BadgeReceived tinyint = 0
	IF @BadgeID NOT IN (3,4,9) BEGIN
		SELECT @BadgeReceived AS BadgeReceived, 'No badge received' AS Name
		RETURN;
	END

	DECLARE @UserBadgeID int = 0
	DECLARE @BadgeCount int

	IF @BadgeID = 4  --4 is observer badge
	BEGIN
		SELECT @BadgeCount = COUNT(ub.UserBadgeID) 
		FROM dbo.UserBadge ub 
		JOIN dbo.[User] u2 ON u2.UserID = ub.UserID
		WHERE ub.BadgeID = 4
			AND u2.GUID = @GUID
	END

	IF (@BadgeCount < 4 AND @BadgeID = 4) OR @BadgeID != 4
	BEGIN
		INSERT INTO dbo.UserBadge ( UserID, BadgeID, WeekID)
		SELECT u.UserID, @BadgeID, @WeekID
			FROM dbo.[User] u 		
			CROSS APPLY dbo.CheckBadgeWeek(@BadgeID, @WeekID) cbw
			WHERE u.GUID = @GUID
			AND NOT EXISTS ( SELECT * 
							   FROM dbo.UserBadge ub 
							   JOIN dbo.[User] u2 ON u2.UserID = ub.UserID
							   WHERE ub.BadgeID = @BadgeID
								 AND ub.WeekID = @WeekID
								 AND u2.GUID = @GUID )

		IF @@ROWCOUNT > 0 SET @UserBadgeID = @@IDENTITY

		SELECT @BadgeReceived = BadgeID 
			FROM dbo.UserBadge ub 
			WHERE ub.UserBadgeID = @UserBadgeID
	END

	IF @BadgeReceived = 4 --if they received another observer badge, update badge count
	BEGIN
		SELECT @BadgeCount = COUNT(ub.UserBadgeID) 
		FROM dbo.UserBadge ub 
		JOIN dbo.[User] u2 ON u2.UserID = ub.UserID
		WHERE ub.BadgeID = 4
			AND u2.GUID = @GUID	

		IF @BadgeCount = 4
		BEGIN
			INSERT INTO dbo.UserBadge ( UserID, BadgeID, WeekID)
			SELECT u.UserID, 8, @WeekID
			FROM dbo.[User] u
			WHERE u.GUID = @GUID
		END
	END
				
	SELECT @BadgeReceived AS BadgeReceived, 
			CASE WHEN @BadgeReceived = 0 THEN 'No badge received'
				 ELSE (SELECT btv.Badge 
						FROM dbo.BadgeTranslationsView btv
						WHERE btv.BadgeID = @BadgeReceived
						  AND btv.ISO639_Code = @LanguageCode)
			END AS Badge
	UNION
	SELECT 8 AS BadgeReceived, (SELECT btv.Badge 
								FROM dbo.BadgeTranslationsView btv
								WHERE btv.BadgeID = 8
								  AND btv.ISO639_Code = @LanguageCode) Badge
	WHERE @BadgeReceived = 4 AND @BadgeCount = 4

END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[Badge_GetAll]'
GO
-- =============================================
-- Author:		Angela Ekstrand
-- Create date: 2016-10-18
-- Description:	Retrieves a listing of badges
-- =============================================
CREATE PROCEDURE [dbo].[Badge_GetAll]
(
	@LanguageCode nchar(2) = 'en'
)
AS
BEGIN
	
	SET NOCOUNT ON;

    SELECT btv.BadgeID, btv.Badge, btv.Description, bst.SurveyTypeID, stt.Type AS SurveyType, bw.WeekID, btv.Sequence, btv.ImageName, btv.BadgeColor, btv.MaxShown, btv.Enabled
	FROM dbo.BadgeTranslationsView btv
	LEFT JOIN dbo.BadgeSurveyType bst ON bst.BadgeID = btv.BadgeID
	LEFT JOIN dbo.SurveyType st ON st.TypeID = bst.SurveyTypeID
	LEFT JOIN dbo.SurveyTypeTranslations stt ON bst.SurveyTypeID = stt.SurveyTypeID
											 AND btv.LanguageID = stt.LanguageID
	LEFT JOIN dbo.BadgeWeek bw ON bw.BadgeID = btv.BadgeID
	WHERE btv.ISO639_Code = @LanguageCode

END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[User_Insert]'
GO
-- =============================================
-- Author:		Angela Ekstrand
-- Create date: 2016-10-18
-- Description:	Inserts a new user
-- =============================================
CREATE PROCEDURE [dbo].[User_Insert]
(
	@GUID		nvarchar(max),
	@ZipCode		nchar(5) = NULL,
	@NickName		nvarchar(50) = NULL,
	@LT			smalldatetime
)
AS
BEGIN
	
	SET NOCOUNT ON;

	IF(@ZipCode IS NOT NULL)
	BEGIN
		IF (SELECT czc.ZipCode FROM dbo.CheckZipCode(@ZipCode) czc) IS NULL 
		    BEGIN
			    RAISERROR('ZipCode not recognized',11,1);
		    END		
	END    

	INSERT INTO dbo.[User] ( GUID, ZipCode, Nickname, LastActiveLT, CreatedLT )
	SELECT @GUID, @ZipCode, @NickName, @LT, @LT	

END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[UserBadge_GetByUserAndWeekID]'
GO
-- =============================================
-- Author:		Angela Ekstrand
-- Create date: 2016-10-18
-- Description:	Retrieves a listing of badges by user and week
-- =============================================
CREATE PROCEDURE [dbo].[UserBadge_GetByUserAndWeekID]
(
	@GUID nvarchar(max),
	@WeekID smallint,
	@LanguageCode nchar(2) = 'en'
)
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT btv.BadgeID, btv.Badge, w.WeekID, w.StartDate, w.EndDate, CASE WHEN ub.UserBadgeID IS NULL THEN 0 ELSE 1 END AS HasBadge
	FROM dbo.[Week] w
	JOIN dbo.[User] u ON u.GUID = @GUID
	JOIN dbo.BadgeTranslationsView btv ON btv.BadgeID = 1	
	CROSS APPLY dbo.CheckBadgeWeek(btv.BadgeID, w.WeekID) cbw
	LEFT JOIN dbo.UserBadge ub ON ub.WeekID = w.WeekID
								AND ub.UserID = u.UserID
								AND ub.BadgeID = btv.BadgeID
	WHERE w.WeekID = 0
	  AND btv.ISO639_Code = @LanguageCode

	UNION

	SELECT btv.BadgeID, btv.Badge, w.WeekID, w.StartDate, w.EndDate, CASE WHEN ub.UserBadgeID IS NULL THEN 0 ELSE 1 END AS HasBadge
	FROM dbo.[Week] w
	JOIN dbo.[User] u ON u.GUID = @GUID
	JOIN dbo.BadgeTranslationsView btv ON btv.BadgeID != 1
	CROSS APPLY dbo.CheckBadgeWeek(btv.BadgeID, w.WeekID) cbw
	LEFT JOIN dbo.UserBadge ub ON ub.WeekID = w.WeekID
								AND ub.UserID = u.UserID
								AND ub.BadgeID = btv.BadgeID
	WHERE w.WeekID = @WeekID
	  AND btv.ISO639_Code = @LanguageCode
		
END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[User_Update]'
GO
-- =============================================
-- Author:		Angela Ekstrand
-- Create date: 2016-10-18
-- Description:	Updates a user record
-- =============================================
CREATE PROCEDURE [dbo].[User_Update]
(
	@GUID		nvarchar(max),
	@ZipCode	nchar(5) = NULL,
	@NickName	nvarchar(50) = NULL,
	@LT			smalldatetime
)
AS
BEGIN
	
	SET NOCOUNT ON;

	IF (@ZipCode IS NOT NULL) AND (SELECT czc.ZipCode FROM dbo.CheckZipCode(@ZipCode) czc) IS NULL 
	BEGIN
		RAISERROR('ZipCode not recognized',11,1);
	END

	DECLARE @OldZipCode nchar(5)
	SELECT @OldZipCode = u.ZipCode FROM dbo.[User] u WHERE u.GUID = @GUID

    UPDATE dbo.[User] 
	SET	ZipCode		= ISNULL(@ZipCode, dbo.[User].ZipCode),
		Nickname		= ISNULL(@NickName, NickName), 
		LastActiveLT	= @LT
	WHERE dbo.[User].GUID = @GUID

	IF @OldZipCode != @ZipCode OR 
	   (@OldZipCode IS NULL AND @ZipCode IS NOT NULL) OR
	   (@OldZipCode IS NOT NULL AND @ZipCode IS NULL)
	BEGIN
		INSERT INTO dbo.UserChangeLog ( UserID, OldZipCode, NewZipCode, UserLocalTime )
		SELECT u.UserID, @OldZipCode, @ZipCode, @LT
		FROM dbo.[User] u
		WHERE u.GUID = @GUID
	END

END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[User_SetLastActive]'
GO
-- =============================================
-- Author:		Angela Ekstrand
-- Create date: 2016-10-18
-- Description:	Sets the time a user was last active
-- =============================================
CREATE PROCEDURE [dbo].[User_SetLastActive]
(
	@GUID		nvarchar(max),
	@LT			smalldatetime,
	@LanguageCode nchar(2) = 'en'
)
AS
BEGIN
	
	SET NOCOUNT ON;

    UPDATE dbo.[User] 
	SET	LastActiveLT = @LT
	WHERE GUID = @GUID

	DECLARE @BadgeReceived tinyint = 0
	DECLARE @UserBadgeID smallint = NULL

	INSERT INTO dbo.UserBadge ( UserID, BadgeID, WeekID)
	SELECT u.UserID, b.BadgeID, w.WeekID		
		FROM dbo.[Week] w	
		JOIN dbo.[User] u ON u.GUID = @GUID		
		JOIN dbo.Badge b ON b.BadgeID = 2	--hard coded for User badge
		CROSS APPLY dbo.CheckBadgeWeek(b.BadgeID, w.WeekID) cbw
		WHERE @LT BETWEEN w.StartDate AND w.EndDate
		AND NOT EXISTS ( SELECT * 
						   FROM dbo.UserBadge ub 						   
						   WHERE ub.BadgeID = b.BadgeID
						     AND ub.WeekID = w.WeekID
							 AND ub.UserID = u.UserID )

	IF @@ROWCOUNT > 0 SET @UserBadgeID = @@IDENTITY

	SELECT @BadgeReceived = BadgeID 
		FROM dbo.UserBadge ub 
		WHERE ub.UserBadgeID = @UserBadgeID
				
	SELECT @BadgeReceived AS BadgeReceived, 
			CASE WHEN @BadgeReceived = 0 THEN 'No badge received' --how to handle "No badge received" for languages??
				 ELSE (SELECT bt.Badge 
						FROM dbo.Badge b
						JOIN dbo.BadgeTranslations bt ON b.BadgeID = bt.BadgeID
						JOIN dbo.Languages l ON bt.LanguageID = l.LanguageID
						WHERE b.BadgeID = @BadgeReceived
						  AND l.ISO639_Code = @LanguageCode)
			END AS Badge

END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[User_GetByGUID]'
GO
-- =============================================
-- Author:		Angela Ekstrand
-- Create date: 2016-10-18
-- Description:	Retrieves a user record by their unique identifier
-- =============================================
CREATE PROCEDURE [dbo].[User_GetByGUID]
(
	@GUID		nvarchar(max)
)
AS
BEGIN
	
	SET NOCOUNT ON;

    SELECT u.UserID, u.GUID, u.ZipCode, u.Nickname, u.LastActiveLT
	FROM dbo.[User] u
	WHERE u.GUID = @GUID

END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[UserBadge_GetByGUID]'
GO
-- =============================================
-- Author:		Angela Ekstrand
-- Create date: 2016-10-18
-- Description:	Retrieves a listing of badges by user and week
-- =============================================
CREATE PROCEDURE [dbo].[UserBadge_GetByGUID]
(
	@GUID nvarchar(max),
	@LanguageCode nchar(2) = 'en'
)
AS
BEGIN
	
	SET NOCOUNT ON;

	/*SELECT b.BadgeID, b.Badge, w.WeekID, w.StartDate, w.EndDate, CASE WHEN ub.UserBadgeID IS NULL THEN 0 ELSE 1 END AS HasBadge
	FROM dbo.[Week] w
	CROSS JOIN dbo.Badge b 
	CROSS APPLY dbo.CheckBadgeWeek(b.BadgeID, w.WeekID) cbw
	JOIN dbo.[User] u ON u.GUID = @GUID
	LEFT JOIN dbo.UserBadge ub ON ub.WeekID = w.WeekID
								AND ub.UserID = u.UserID
								AND ub.BadgeID = b.BadgeID
	ORDER BY b.BadgeID, w.StartDate*/

	SELECT ub.BadgeID, btv.Badge, ub.WeekID, w.StartDate, w.EndDate, 1 AS HasBadge
	FROM dbo.[User] u
	JOIN dbo.UserBadge ub ON u.UserID = ub.UserID 
	JOIN dbo.BadgeTranslationsView btv ON ub.BadgeID = btv.BadgeID
	CROSS APPLY dbo.CheckBadgeWeek(ub.BadgeID, ub.WeekID) cbw
	JOIN dbo.Week w ON ub.WeekID = w.WeekID
	WHERE u.GUID = @GUID
	  AND btv.ISO639_Code = @LanguageCode
		
END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[UserSurveyZipCode_Submit]'
GO
-- =============================================
-- Author:		Angela Ekstrand
-- Create date: 2018-06-20
-- Description:	Inserts zip codes for survey answers
-- =============================================
CREATE PROCEDURE [dbo].[UserSurveyZipCode_Submit]
(
	@SurveyTypeID	tinyint,
	@WeekID			int,
	@GUID			nvarchar(max),
	@ZipCode		nchar(5) = NULL
)
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @UserSurveys TABLE (	UserSurveyID	int,
									SurveyID		smallint,
									WeekID			int,
									UserID			bigint	)

	--Find existing @UserSurveyIDs
	INSERT INTO @UserSurveys ( UserSurveyID, SurveyID, WeekID, UserID )
	SELECT us.UserSurveyID, us.SurveyID, us.WeekID, us.UserID
	FROM dbo.UserSurvey us
	JOIN dbo.Survey		s ON us.SurveyID = s.SurveyID	
	JOIN dbo.[User]		u ON us.UserID = u.UserID
	WHERE u.GUID = @GUID
	  AND s.TypeID = @SurveyTypeID
	  AND us.WeekID = @WeekID

	--Clear Old Dates
	DELETE FROM UserSurveyZipCode
	WHERE UserSurveyID IN (SELECT us.UserSurveyID FROM @UserSurveys us)
	
	DECLARE @Submitted bit = 0
	IF @ZipCode IS NOT NULL AND RTRIM(@ZipCode) != '' SET @Submitted = 1

	--Insert SELECT
	INSERT INTO dbo.UserSurveyZipCode
	(
	    UserSurveyID,
	    ZipCode,
		Submitted
	)	
	SELECT us.UserSurveyID, 
		   CASE WHEN @ZipCode IS NULL OR RTRIM(@ZipCode) = '' THEN u.ZipCode ELSE @ZipCode END AS ZipCode,
		   @Submitted
	FROM @UserSurveys us
	JOIN dbo.[User] u ON us.UserID = u.UserID
	
END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[UserSurvey_Delete]'
GO
-- =============================================
-- Author:		Angela Ekstrand
-- Create date:	2018-06-20
-- Description:	Deletes any data associated with a survey a user decides not to answer
-- =============================================
CREATE PROCEDURE [dbo].[UserSurvey_Delete]
(
	@SurveyID	smallint,
	@WeekID		int,
	@GUID		nvarchar(max),	
	@LT			smalldatetime
)
AS
BEGIN
	
	SET NOCOUNT ON;

	UPDATE dbo.[User]
	SET dbo.[User].LastActiveLT = @LT
	FROM dbo.[User] u
	WHERE u.GUID = @GUID

	DECLARE @UserSurveyID int

	--Find existing @UserSurveyID
	SELECT @UserSurveyID = us.UserSurveyID 
	FROM dbo.UserSurvey us
	JOIN dbo.[User]		u ON us.UserID = u.UserID
	WHERE u.GUID = @GUID
	  AND us.SurveyID = @SurveyID
	  AND us.WeekID = @WeekID
	
	IF @UserSurveyID IS NOT NULL
	BEGIN
		DELETE FROM dbo.UserSurveyZipCode
		WHERE dbo.UserSurveyZipCode.UserSurveyID = @UserSurveyID

		DELETE FROM dbo.UserSurveyDate
		WHERE dbo.UserSurveyDate.UserSurveyID = @UserSurveyID

		DELETE FROM dbo.UserSurveyAnswers
		WHERE dbo.UserSurveyAnswers.UserSurveyID = @UserSurveyID

		DELETE FROM dbo.UserSurvey
		WHERE dbo.UserSurvey.UserSurveyID = @UserSurveyID

	END

END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[Survey_InsertTranslation]'
GO
-- =============================================
-- Author:		Angela Ekstrand
-- Create date: 2016-10-18
-- Description:	Inserts surveys from files
-- DATABASE ONLY; THIS IS AN INGEST PROCEDURE
-- =============================================
CREATE PROCEDURE [dbo].[Survey_InsertTranslation]
(
--DECLARE
	@File	nvarchar(max),
	@Type	tinyint = 3
)
AS
BEGIN
	
	SET NOCOUNT ON;

	--BEGIN TRANSACTION

		DECLARE @LanguageCode nchar(2) = 'en'

		--DECLARE @File	nvarchar(max) = '\\sqldev1\c$\surveyquestions_toinsert_dbformat_pipe.txt',
				--@Type	tinyint = 1

		CREATE TABLE #SurveyToInsert (	SurveyEnglish		nvarchar(150),
										SurveyNewLanguage	nvarchar(150),
										LanguageCode		nchar(2),
										[Week]				int,
										QuestionSequence	smallint,
										QuestionVersion		tinyint,
										QuestionEnglish		nvarchar(max),
										QuestionNewLanguage nvarchar(max),
										MultiChoice			tinyint,
										Slider				tinyint,
										AnswerEnglish		nvarchar(max),
										AnswerNewLanguage	nvarchar(max),
										ChoiceSequence		smallint,
										ChoiceEnglish		nvarchar(max),
										ChoiceNewLanguage	nvarchar(max),
										FreeResponse		tinyint,
										Correct				tinyint,
										Calendar			tinyint )
	
		DECLARE @cmd1 nvarchar(500), @cmd2 nvarchar(500)

		-- Unix\Windows Line Endings
		SELECT @cmd1 = 'bulk insert #SurveyToInsert  from ' + '''' + replace(@File,'"','') + '''' + 'WITH (MAXERRORS = 2, TABLOCK, FIELDTERMINATOR=''|''' + ',ROWTERMINATOR = '''+CHAR(10)+''',CODEPAGE=''1252'')'
		-- Windows Extra New Lines at EOF
		SELECT @cmd2 = 'bulk insert #SurveyToInsert from ' + '''' + replace(@File,'"','') + '''' + ' WITH (MAXERRORS = 2, TABLOCK, FIELDTERMINATOR=''|'',CODEPAGE=''1252'')'

		BEGIN TRY --1
			EXEC (@cmd1);
		END TRY 
		BEGIN CATCH	--2									 
			EXEC (@cmd2);
		END CATCH

		UPDATE #SurveyToInsert
		SET SurveyEnglish = REPLACE(SurveyEnglish,'"',''), -- nvarchar
			SurveyNewLanguage = REPLACE(SurveyNewLanguage,'"',''), --nvarchar
			QuestionEnglish = REPLACE(QuestionEnglish,'"',''), -- nvarchar
			QuestionNewLanguage = REPLACE(QuestionNewLanguage,'"',''), -- nvarchar
			ChoiceEnglish = REPLACE(ChoiceEnglish,'"',''), -- nvarchar
			ChoiceNewLanguage = REPLACE(ChoiceNewLanguage,'"',''), -- nvarchar
			AnswerEnglish = REPLACE(AnswerEnglish,'"',''), -- nvarchar
			AnswerNewLanguage = REPLACE(AnswerNewLanguage,'"','') -- nvarchar

		--ôpreferredö with word/excel "" turns into this. This fixes it.
		--These statements could be nested but I don't feel like it.
		UPDATE #SurveyToInsert
		SET SurveyEnglish = REPLACE(SurveyEnglish,'ô','"'), -- nvarchar
			SurveyNewLanguage = REPLACE(SurveyNewLanguage,'ô','"'), --nvarchar
			QuestionEnglish = REPLACE(QuestionEnglish,'ô','"'), -- nvarchar
			QuestionNewLanguage = REPLACE(QuestionNewLanguage,'ô','"'), -- nvarchar
			ChoiceEnglish = REPLACE(ChoiceEnglish,'ô','"'), -- nvarchar
			ChoiceNewLanguage = REPLACE(ChoiceNewLanguage,'ô','"'), -- nvarchar
			AnswerEnglish = REPLACE(AnswerEnglish,'ô','"'), -- nvarchar
			AnswerNewLanguage = REPLACE(AnswerNewLanguage,'ô','"') -- nvarchar

		UPDATE #SurveyToInsert
		SET SurveyEnglish = REPLACE(SurveyEnglish,'ö','"'), -- nvarchar
			SurveyNewLanguage = REPLACE(SurveyNewLanguage,'ö','"'), --nvarchar
			QuestionEnglish = REPLACE(QuestionEnglish,'ö','"'), -- nvarchar
			QuestionNewLanguage = REPLACE(QuestionNewLanguage,'ö','"'), -- nvarchar
			ChoiceEnglish = REPLACE(ChoiceEnglish,'ö','"'), -- nvarchar
			ChoiceNewLanguage = REPLACE(ChoiceNewLanguage,'ö','"'), -- nvarchar
			AnswerEnglish = REPLACE(AnswerEnglish,'ö','"'), -- nvarchar
			AnswerNewLanguage = REPLACE(AnswerNewLanguage,'ö','"') -- nvarchar
	    
		UPDATE #SurveyToInsert
		SET #SurveyToInsert.AnswerEnglish = N''
		WHERE #SurveyToInsert.AnswerEnglish IS NULL

		UPDATE #SurveyToInsert
		SET #SurveyToInsert.AnswerNewLanguage = N''
		WHERE #SurveyToInsert.AnswerNewLanguage IS NULL

		SELECT * FROM #SurveyToInsert sti

		--DROP TABLE #SurveyToInsert
		--add bulk insert statement to read from file
		/*SELECT p.Survey, p.Question, p.MultiChoice, p.Choice, p.Correct
		INTO #SurveyToInsert
		FROM ALE_profilequestions2 p*/

		--SET @Type = 1

		DECLARE @SurveyInserted TABLE ( SurveyID smallint,
										Survey nvarchar(150),
										TypeID tinyint )
	
		--Insert Survey
		INSERT INTO dbo.SurveyTranslations
		(
			SurveyID,
			LanguageID,
			Survey
		)
		OUTPUT INSERTED.*
		SELECT DISTINCT stv.SurveyID, l.LanguageID, sti.SurveyNewLanguage
		FROM dbo.SurveyTranslationsView stv
		JOIN #SurveyToInsert sti ON stv.Survey = sti.SurveyEnglish
		JOIN dbo.Languages l ON sti.LanguageCode = l.ISO639_Code
		WHERE stv.ISO639_Code = @LanguageCode --original
	

		--Insert Questions
		INSERT INTO dbo.QuestionsTranslations
		(
			QuestionID,
			LanguageID,
			Question,
			Answer
		)
		OUTPUT INSERTED.*
		SELECT DISTINCT qtv.QuestionID, l.LanguageID, sti.QuestionNewLanguage, sti.AnswerNewLanguage
		FROM dbo.QuestionsTranslationsView qtv
		JOIN dbo.SurveyTranslationsView stv ON qtv.SurveyID = stv.SurveyID
											AND qtv.LanguageID = stv.LanguageID
		JOIN #SurveyToInsert sti ON qtv.Question = sti.QuestionEnglish
								 AND sti.SurveyEnglish = stv.Survey
		JOIN dbo.Languages l ON sti.LanguageCode = l.ISO639_Code
		WHERE qtv.ISO639_Code = @LanguageCode
		  AND stv.ISO639_Code = @LanguageCode

	
		--Insert Choices
		INSERT INTO dbo.ChoicesTranslations
		(
			ChoiceID,
			LanguageID,
			Choice
		)
		OUTPUT INSERTED.*
		SELECT DISTINCT ctv.ChoiceID, l.LanguageID, sti.ChoiceNewLanguage
		FROM dbo.ChoicesTranslationsView ctv
		JOIN dbo.QuestionsTranslationsView qtv ON ctv.QuestionID = qtv.QuestionID
											AND ctv.LanguageID = qtv.LanguageID
		JOIN dbo.SurveyTranslationsView stv ON qtv.SurveyID = stv.SurveyID
											AND ctv.LanguageID = stv.LanguageID
		JOIN #SurveyToInsert sti ON ((ctv.Choice = sti.ChoiceEnglish) OR (ctv.Choice IS NULL AND sti.ChoiceEnglish IS NULL))
								 AND qtv.Question = sti.QuestionEnglish
								 AND sti.SurveyEnglish = stv.Survey
		JOIN dbo.Languages l ON sti.LanguageCode = l.ISO639_Code
		WHERE ctv.ISO639_Code = @LanguageCode
		  AND qtv.ISO639_Code = @LanguageCode
		  AND stv.ISO639_Code = @LanguageCode
		
	--COMMIT TRANSACTION


END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[Survey_AssignSurveyOrderByUser]'
GO
-- =============================================
-- Author:		Angela Ekstrand
-- Create date: 2018-06-26
-- Description:	Assigns and stores a survey order for the user for a particular survey type
-- =============================================
CREATE PROCEDURE [dbo].[Survey_AssignSurveyOrderByUser]
(
--DECLARE
	@GUID	nvarchar(max),
	@LT		smalldatetime,
	@TypeID	tinyint = 7
)
AS
BEGIN
	
	SET NOCOUNT ON;

	UPDATE dbo.[User] 
	SET	LastActiveLT = @LT
	WHERE GUID = @GUID
		
	DECLARE @UserID int
	SELECT @UserID = u.UserID
	FROM dbo.[User] u
	WHERE u.[GUID] = @GUID

	IF NOT EXISTS (SELECT *
					FROM dbo.UserSurveyOrder uso
					JOIN dbo.Survey s ON uso.SurveyID = s.SurveyID
					WHERE uso.UserID = @UserID
					  AND s.TypeID = @TypeID)
	BEGIN
	
		SELECT IDENTITY(int,1,1) AS SurveyOrder, stv.Survey INTO #SurveyOrder
		FROM dbo.SurveyTranslationsView stv
		WHERE stv.TypeID = 7
		  AND stv.ISO639_Code = 'en' --doesn't matter what language we choose for ordering. this will all be based on IDs in the end.
		ORDER BY NEWID()

		--SELECT * FROM #SurveyOrder so

		SELECT a.SurveyOrder, a.Survey, a.GroupNumber, NULL AS VersionOrder, NULL AS VersionNumber
		INTO #Order 
		FROM
		(SELECT so.SurveyOrder, so.Survey, 1 AS GroupNumber
		FROM #SurveyOrder so
		UNION
		SELECT so.SurveyOrder, so.Survey, 2 AS GroupNumber
		FROM #SurveyOrder so
		UNION
		SELECT so.SurveyOrder, so.Survey, 3 AS GroupNumber
		FROM #SurveyOrder so
		) a
		ORDER BY a.GroupNumber, a.SurveyOrder

		DECLARE csSurvey CURSOR LOCAL FAST_FORWARD FOR
		SELECT *
		FROM #SurveyOrder so
		ORDER BY so.SurveyOrder

		DECLARE @SurveyOrder int, @SurveyName nvarchar(150)

		OPEN csSurvey

		FETCH NEXT FROM csSurvey INTO @SurveyOrder, @SurveyName

		WHILE @@FETCH_STATUS = 0
		BEGIN

			--SELECT @SurveyOrder SurveyOrder, @SurveyName SurveyName

			SELECT IDENTITY(int,1,1) AS VersionOrder, a.VersionNumber INTO #VersionOrder
			FROM
			(SELECT DISTINCT qv.VersionNumber
			FROM dbo.Survey s
			JOIN dbo.Questions q ON s.SurveyID = q.SurveyID
			JOIN dbo.QuestionVersion qv ON q.QuestionID = qv.QuestionID
			WHERE s.TypeID = 7) a
			ORDER BY NEWID()

			--SELECT * FROM #VersionOrder vo
	
			UPDATE #Order
			SET #Order.VersionOrder = a.VersionOrder,
				#Order.VersionNumber = a.VersionNumber
			FROM
			(SELECT vo.VersionOrder, vo.VersionNumber, @SurveyOrder SurveyOrder, @SurveyName SurveyName
				FROM #VersionOrder vo) a
			WHERE a.VersionOrder = #Order.GroupNumber
			  AND a.SurveyName = #Order.Survey

			/*SELECT * FROM #Order o WHERE o.Survey = @SurveyName*/
	
			/*SELECT * FROM #Order o*/

			DROP TABLE #VersionOrder

			FETCH NEXT FROM csSurvey INTO @SurveyOrder, @SurveyName

		END

		CLOSE csSurvey
		DEALLOCATE csSurvey

		/*SELECT * FROM #Order o ORDER BY GroupNumber, SurveyOrder*/

		SELECT IDENTITY(int,1,1) FinalOrder, o.SurveyOrder, o.Survey, o.VersionOrder, o.VersionNumber INTO #FinalOrder
		FROM #Order o
		ORDER BY GroupNumber, SurveyOrder

		/*SELECT *
		FROM #FinalOrder fo
		ORDER BY fo.FinalOrder*/

		INSERT INTO dbo.UserSurveyOrder
		(
			UserID,
			SurveyID,
			VersionNumber,
			[Sequence]
		)
		OUTPUT INSERTED.*
		SELECT @UserID, stv.SurveyID, fo.VersionNumber, fo.FinalOrder AS [Sequence] --these survey ids can be pulled in any language once order is set
		FROM #FinalOrder fo
		JOIN dbo.SurveyTranslationsView stv ON fo.Survey = stv.Survey
		ORDER BY fo.FinalOrder

		DROP TABLE #SurveyOrder
		DROP TABLE #Order
		DROP TABLE #FinalOrder

	END

	ELSE BEGIN

		RETURN;

	END
		
END



/*		SELECT IDENTITY(int,1,1) AS ID, s.Survey INTO #SurveyOrder
		FROM dbo.Survey s
		WHERE s.TypeID = @TypeID
		ORDER BY NEWID()

		SELECT IDENTITY(int,1,1) AS ID, a.VersionNumber INTO #VersionOrder
		FROM
		(SELECT DISTINCT qv.VersionNumber
		FROM dbo.Survey s
		JOIN dbo.Questions q ON s.SurveyID = q.SurveyID
		JOIN dbo.QuestionVersion qv ON q.QuestionID = qv.QuestionID
		WHERE s.TypeID = 7) a
		ORDER BY NEWID()

		--SELECT * FROM #SurveyOrder so
		--SELECT * FROM #VersionOrder vo

		SELECT so.ID SurveyOrder, so.Survey, vo.ID VersionOrder, vo.VersionNumber
		INTO #Order
		FROM #SurveyOrder so
		JOIN dbo.#VersionOrder vo ON vo.ID = 1
		UNION
		SELECT *
		FROM #SurveyOrder so
		JOIN dbo.#VersionOrder vo ON vo.ID = 2
		UNION
		SELECT *
		FROM #SurveyOrder so
		JOIN dbo.#VersionOrder vo ON vo.ID = 3
		ORDER BY vo.ID, so.ID

		SELECT IDENTITY(int,1,1) ID, o.SurveyOrder, o.Survey, o.VersionOrder, o.VersionNumber INTO #FinalOrder
		FROM #Order o
		ORDER BY VersionOrder, SurveyOrder

		--insert Sequence, SurveyID, Version, UserID into a table
		/*SELECT fo.ID Sequence, s.SurveyID, fo.VersionNumber, 
			   newid() [GUID], 531 UserID,
			   fo.Survey, fo.SurveyOrder, fo.VersionOrder
		FROM #FinalOrder fo
		JOIN dbo.Survey s ON fo.Survey = s.Survey
		ORDER BY ID*/

		INSERT INTO dbo.UserSurveyOrder
		(
			UserID,
			SurveyID,
			VersionNumber,
			[Sequence]
		)
		SELECT @UserID, s.SurveyID, fo.VersionNumber, fo.ID AS [Sequence]
		FROM #FinalOrder fo
		JOIN dbo.Survey s ON fo.Survey = s.Survey
		ORDER BY ID

		DROP TABLE #SurveyOrder
		DROP TABLE #VersionOrder
		DROP TABLE #Order
		DROP TABLE #FinalOrder*/
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[Survey_GetAll]'
GO
-- =============================================
-- Author:		Angela Ekstrand
-- Create date: 2016-10-18
-- Description:	Retrieves surveys
-- =============================================
CREATE PROCEDURE [dbo].[Survey_GetAll]
(
	@LanguageCode nchar(2) = 'en'
)
AS
BEGIN
	
	SET NOCOUNT ON;

    SELECT stv.SurveyID, stv.Survey, stv.TypeID, sttv.Type, stv.Image, stv.Calendar, sw.WeekID, w.StartDate, w.EndDate
	FROM dbo.SurveyTranslationsView stv
	JOIN dbo.SurveyTypeTranslationsView sttv ON sttv.SurveyTypeID = stv.TypeID
											 AND sttv.LanguageID = stv.LanguageID
	LEFT JOIN dbo.SurveyWeek sw ON sw.SurveyID = stv.SurveyID
	LEFT JOIN dbo.Week w ON w.WeekID = sw.WeekID
	WHERE stv.ISO639_Code = @LanguageCode

END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[Questions_GetBySurveyID]'
GO
-- =============================================
-- Author:		Angela Ekstrand
-- Create date: 2016-10-18
-- Description:	Retrieves survey questions
-- Changes:		Added VersionNumber functionality for Profile questions
-- =============================================
CREATE PROCEDURE [dbo].[Questions_GetBySurveyID]
(
	@SurveyID smallint,
	@VersionNumber smallint = NULL, --generated on app side by modular division of UserID by 2 (UserID % 2 in db)
	@LanguageCode nchar(2) = 'en'
)
AS
BEGIN
	
	SET NOCOUNT ON;

	IF (@SurveyID IN (0)) --profile survey only
	BEGIN
		SELECT qtv.QuestionID, qtv.Question, qtv.MultiChoice, qtv.Slider, qtv.CorrectAnswer, qtv.[Sequence], qtv.Answer, qtv.Summary
		FROM dbo.SurveyTranslationsView stv
		JOIN dbo.QuestionsTranslationsView qtv ON qtv.SurveyID = stv.SurveyID
											   AND qtv.LanguageID = stv.LanguageID
		WHERE qtv.QuestionID IN (SELECT qv.QuestionID FROM QuestionVersion qv WHERE qv.VersionNumber = @VersionNumber)
		  AND stv.SurveyID = @SurveyID
		  AND stv.ISO639_Code = @LanguageCode
		ORDER BY qtv.[Sequence];
	END
	IF (SELECT s.TypeID FROM dbo.Survey s WHERE s.SurveyID = @SurveyID) = 7 --SmokeSmarts only
	BEGIN
		SELECT qtv.QuestionID, qtv.Question, qtv.MultiChoice, qtv.Slider, qtv.CorrectAnswer, qtv.[Sequence], qtv.Answer, qtv.Summary
		FROM dbo.SurveyTranslationsView stv
		JOIN dbo.QuestionsTranslationsView qtv ON qtv.SurveyID = stv.SurveyID
											   AND qtv.LanguageID = stv.LanguageID
		LEFT JOIN dbo.QuestionVersion qv ON qtv.QuestionID = qv.QuestionID
		WHERE (qv.VersionNumber IS NULL OR qv.VersionNumber = @VersionNumber)
		  AND stv.SurveyID = @SurveyID
		  AND stv.ISO639_Code = @LanguageCode
		ORDER BY qtv.[Sequence];
	END
	ELSE BEGIN --all other surveys
		SELECT qtv.QuestionID, qtv.Question, qtv.MultiChoice, qtv.Slider, qtv.CorrectAnswer, qtv.[Sequence], qtv.Answer, qtv.Summary
		FROM dbo.SurveyTranslationsView stv
		JOIN dbo.QuestionsTranslationsView qtv ON qtv.SurveyID = stv.SurveyID
											   AND qtv.LanguageID = stv.LanguageID
		WHERE stv.SurveyID = @SurveyID
		  AND stv.ISO639_Code = @LanguageCode
		ORDER BY qtv.[Sequence];
	END

END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[Choices_GetByQuestionID]'
GO
-- =============================================
-- Author:		Angela Ekstrand
-- Create date: 2016-10-18
-- Description:	Retrieves survey questions choices
-- =============================================
CREATE PROCEDURE [dbo].[Choices_GetByQuestionID]
(
	@QuestionID int,
	@LanguageCode nchar(2) = 'en'
)
AS
BEGIN
	
	SET NOCOUNT ON;

    SELECT  qtv.QuestionID, --q.Question, q.MultiChoice, q.CorrectAnswer,
			ctv.ChoiceID, ctv.Choice, icc.IsCorrect,
			ctv.FreeResponse,
		    ctv.[Sequence]
	FROM dbo.QuestionsTranslationsView qtv
	JOIN dbo.ChoicesTranslationsView ctv ON ctv.QuestionID = qtv.QuestionID
										AND ctv.LanguageID = qtv.LanguageID
	CROSS APPLY dbo.IsChoiceCorrect(ctv.ChoiceID) icc
	WHERE qtv.QuestionID = @QuestionID
	  AND qtv.ISO639_Code = @LanguageCode
	ORDER BY ctv.[Sequence]

END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[Week_IsPastLastWeek]'
GO
-- =============================================
-- Author:		Angela Ekstrand
-- Create date: 2017-03-20
-- Description:	Determines if we are past the last week of the study
-- =============================================
CREATE PROCEDURE [dbo].[Week_IsPastLastWeek]
(
	@LT smalldatetime
)
AS
BEGIN
	
	SET NOCOUNT ON;

	--IF @LT > (SELECT w.EndDate FROM dbo.[Week] w WHERE w.WeekNumber = 4)
	--BEGIN
		--SELECT 1 AS IsPastLastWeek
	--END
	--ELSE BEGIN
		SELECT CASE WHEN @LT > MAX(w.EndDate) THEN 1 ELSE 0 END AS IsPastLastWeek
		FROM [Week] w
	--END
	

END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[Survey_Insert]'
GO
-- =============================================
-- Author:		Angela Ekstrand
-- Create date: 2016-10-18
-- Description:	Inserts surveys from files
-- DATABASE ONLY; THIS IS AN INGEST PROCEDURE
-- =============================================
CREATE PROCEDURE [dbo].[Survey_Insert]
(
--DECLARE
	@File	nvarchar(max),
	@Type	tinyint = 3
)
AS
BEGIN
	
	SET NOCOUNT ON;

	BEGIN TRANSACTION

	DECLARE @LanguageCode nchar(2) = 'en'

	--DECLARE @File	nvarchar(max) = '\\sqldev1\c$\surveyquestions_toinsert_dbformat_pipe.txt',
			--@Type	tinyint = 1

	CREATE TABLE #SurveyToInsert (	Survey				nvarchar(150),
									[Week]				int,
									QuestionSequence	smallint,
									QuestionVersion		tinyint,
									Question			nvarchar(max),
									MultiChoice			tinyint,
									Slider				tinyint,
									Answer				nvarchar(max),
									ChoiceSequence		smallint,
									Choice				nvarchar(max),
									FreeResponse		tinyint,
									Correct				tinyint,
									Calendar			tinyint )
	
	DECLARE @cmd1 nvarchar(500), @cmd2 nvarchar(500)

	-- Unix\Windows Line Endings
	SELECT @cmd1 = 'bulk insert #SurveyToInsert  from ' + '''' + replace(@File,'"','') + '''' + 'WITH (MAXERRORS = 2, TABLOCK, FIELDTERMINATOR=''|''' + ',ROWTERMINATOR = '''+CHAR(10)+''')'
	-- Windows Extra New Lines at EOF
	SELECT @cmd2 = 'bulk insert #SurveyToInsert from ' + '''' + replace(@File,'"','') + '''' + ' WITH (MAXERRORS = 2, TABLOCK, FIELDTERMINATOR=''|'')'

	BEGIN TRY --1
        EXEC (@cmd1);
    END TRY 
	BEGIN CATCH	--2									 
	    EXEC (@cmd2);
    END CATCH

	UPDATE #SurveyToInsert
	SET Survey = REPLACE(Survey,'"',''), -- nvarchar
	    Question = REPLACE(Question,'"',''), -- nvarchar
		Answer = REPLACE(Answer,'"',''), -- nvarchar
		Choice = REPLACE(Choice,'"','') -- nvarchar

	--ôpreferredö with word/excel "" turns into this. This fixes it.
	--These statements could be nested but I don't feel like it.
	UPDATE #SurveyToInsert
	SET Survey = REPLACE(Survey,'"',''), -- nvarchar
	    Question = REPLACE(Question,'ô','"'), -- nvarchar
		Answer = REPLACE(Answer,'"',''), -- nvarchar
		Choice = REPLACE(Choice,'"','') -- nvarchar

	UPDATE #SurveyToInsert
	SET Survey = REPLACE(Survey,'"',''), -- nvarchar
	    Question = REPLACE(Question,'ö','"'), -- nvarchar
		Answer = REPLACE(Answer,'"',''), -- nvarchar
		Choice = REPLACE(Choice,'"','') -- nvarchar
	
	UPDATE #SurveyToInsert
	SET #SurveyToInsert.Answer = N''
	WHERE #SurveyToInsert.Answer IS NULL
	    
	SELECT * FROM #SurveyToInsert sti

	--DROP TABLE #SurveyToInsert
	--add bulk insert statement to read from file
	/*SELECT p.Survey, p.Question, p.MultiChoice, p.Choice, p.Correct
	INTO #SurveyToInsert
	FROM ALE_profilequestions2 p*/

	--SET @Type = 1

	DECLARE @SurveyInserted TABLE ( SurveyID smallint,
									Survey nvarchar(150),
									TypeID tinyint )
	
	--Insert Survey
	SELECT stv.* 
	FROM dbo.SurveyTranslationsView stv
	JOIN #SurveyToInsert sti ON stv.Survey = sti.Survey
	WHERE stv.ISO639_Code = @LanguageCode

    INSERT INTO dbo.Survey
    (
        --SurveyID - this column value is auto-generated
        SurveyEnglishDefault,
        TypeID,
		Calendar
    )
	OUTPUT INSERTED.SurveyID, INSERTED.SurveyEnglishDefault, INSERTED.TypeID INTO @SurveyInserted
    SELECT sti.Survey, @Type AS Type, MAX(sti.Calendar) AS Calendar
	FROM #SurveyToInsert sti
	WHERE NOT EXISTS (SELECT * 
						FROM dbo.SurveyTranslationsView stv
						WHERE stv.Survey = sti.Survey 
						  AND stv.TypeID = @Type
						  AND stv.ISO639_Code = @LanguageCode)
	GROUP BY sti.Survey


	INSERT INTO dbo.SurveyTranslations
	(
	    SurveyID,
	    LanguageID,
	    Survey
	)
	SELECT si.SurveyID, l.LanguageID, si.Survey
	FROM @SurveyInserted si
	JOIN dbo.Languages l ON l.ISO639_Code = @LanguageCode

	SELECT stv.* 
	FROM dbo.SurveyTranslationsView stv
	JOIN #SurveyToInsert sti ON stv.Survey = sti.Survey
	WHERE stv.ISO639_Code = @LanguageCode



	--Insert week
	SELECT * 
	FROM dbo.SurveyWeek sw
	WHERE sw.SurveyID IN (SELECT si.SurveyID FROM @SurveyInserted si)

	INSERT INTO dbo.SurveyWeek
	(
	    SurveyID,
	    WeekID
	)
	SELECT DISTINCT stv.SurveyID, w.[WeekID]
	FROM #SurveyToInsert sti
	JOIN dbo.SurveyTranslationsView stv ON sti.Survey = stv.Survey
										AND stv.TypeID = 3
	JOIN dbo.Week w ON w.WeekNumber = sti.Week
	WHERE NOT EXISTS (SELECT * 
						FROM dbo.SurveyWeek sw
						JOIN dbo.SurveyTranslationsView stv2 ON stv2.SurveyID = sw.SurveyID
															 AND stv2.Survey = sti.Survey
						JOIN dbo.Week w2 ON w2.WeekID = sw.WeekID
						WHERE w2.WeekNumber = sti.[Week]
						  AND stv2.ISO639_Code = @LanguageCode)

	SELECT * 
	FROM dbo.SurveyWeek sw
	WHERE sw.SurveyID IN (SELECT si.SurveyID FROM @SurveyInserted si)


	
	DECLARE @QuestionsInserted TABLE (	QuestionID	smallint,
										Question	nvarchar(max),
										MultiChoice bit,
										CorrectAnswer bit,
										SurveyID	smallint,
										Sequence	smallint,
										Answer		nvarchar(max),
										Slider		bit,
										Summary		bit	)
	

	--Insert Questions
	SELECT qtv.* 
	FROM dbo.QuestionsTranslationsView qtv
	JOIN #SurveyToInsert sti ON qtv.Question = sti.Question
	WHERE qtv.ISO639_Code = @LanguageCode

	INSERT INTO dbo.Questions
	(
	    --QuestionID - this column value is auto-generated
	    QuestionEnglishDefault,
	    MultiChoice,
		Slider,
	    CorrectAnswer,
	    SurveyID,
		Sequence,
		AnswerEnglishDefault
	)
	OUTPUT INSERTED.QuestionID, INSERTED.QuestionEnglishDefault, INSERTED.MultiChoice, INSERTED.CorrectAnswer, INSERTED.SurveyID, INSERTED.Sequence, INSERTED.AnswerEnglishDefault, INSERTED.Slider, INSERTED.Summary 
			INTO @QuestionsInserted
	SELECT sti.Question, sti.MultiChoice, sti.Slider, 
		   CASE WHEN MAX(sti.Correct) IS NULL THEN 0 ELSE MAX(sti.Correct) END AS CorrectAnswer,
		   stv.SurveyID, sti.QuestionSequence, CASE WHEN sti.Answer IS NULL THEN '' ELSE sti.Answer END
	FROM #SurveyToInsert sti
	JOIN dbo.SurveyTranslationsView stv ON sti.Survey = stv.Survey
										AND stv.TypeID = @Type
	WHERE NOT EXISTS (SELECT * 
						FROM dbo.QuestionsTranslationsView qtv
						JOIN dbo.SurveyTranslationsView stv2 ON stv2.SurveyID = qtv.SurveyID
						WHERE qtv.Question = sti.Question				  
						  AND qtv.MultiChoice = sti.MultiChoice
						  AND qtv.CorrectAnswer = sti.Correct
						  AND qtv.Answer = sti.Answer
						  AND stv2.TypeID = @Type
						  AND qtv.ISO639_Code = @LanguageCode
						  AND stv2.Survey = sti.Survey)
	GROUP BY sti.Question, sti.MultiChoice, sti.Slider, stv.SurveyID, sti.QuestionSequence, CASE WHEN sti.Answer IS NULL THEN '' ELSE sti.Answer END

	INSERT INTO dbo.QuestionsTranslations
	(
	    QuestionID,
	    LanguageID,
	    Question,
	    Answer
	)
	SELECT qi.QuestionID, l.LanguageID, qi.Question, qi.Answer
	FROM @QuestionsInserted qi
	JOIN dbo.Languages l ON l.ISO639_Code = @LanguageCode

	SELECT qtv.* 
	FROM dbo.QuestionsTranslationsView qtv
	JOIN #SurveyToInsert sti ON qtv.Question = sti.Question
	WHERE qtv.ISO639_Code = @LanguageCode



	--Insert QuestionVersion
	SELECT * 
	FROM dbo.QuestionVersion qv
	WHERE qv.QuestionID IN (SELECT qi.QuestionID FROM @QuestionsInserted qi)

	INSERT INTO dbo.QuestionVersion
	(
	    QuestionID,
	    VersionNumber
	)
	SELECT DISTINCT qtv.QuestionID, sti.QuestionVersion
	FROM #SurveyToInsert sti
	JOIN dbo.SurveyTranslationsView stv ON sti.Survey = stv.Survey
										AND stv.TypeID = @Type
	JOIN dbo.QuestionsTranslationsView qtv ON sti.Question = qtv.Question
										   AND sti.MultiChoice = qtv.MultiChoice
										   AND qtv.SurveyID = stv.SurveyID
										   --AND sti.Correct = qtv.CorrectAnswer
	WHERE sti.QuestionVersion IS NOT NULL AND RTRIM(sti.QuestionVersion) != ''
	  AND NOT EXISTS (SELECT * 
						FROM dbo.QuestionVersion qv
						JOIN dbo.QuestionsTranslationsView qtv2 ON qtv2.QuestionID = qv.QuestionID											   
						JOIN dbo.SurveyTranslationsView stv2 ON stv2.SurveyID = qtv2.SurveyID
						WHERE qv.VersionNumber = sti.QuestionVersion
						  AND qtv.Question = sti.Question
						  AND qtv.MultiChoice = sti.MultiChoice
						  --AND qtv.CorrectAnswer = sti.Correct
						  AND stv2.Survey = sti.Survey
						  AND stv2.TypeID = @Type
						  AND qtv2.ISO639_Code = @LanguageCode)

	SELECT * 
	FROM dbo.QuestionVersion qv
	WHERE qv.QuestionID IN (SELECT qi.QuestionID FROM @QuestionsInserted qi)




	DECLARE @ChoicesInserted TABLE (	ChoiceID	int,
										Choice		nvarchar(max),
										QuestionID	smallint,
										Sequence	smallint,
										FreeResponse bit,
										Calendar	bit	)

	--Insert Choices
	SELECT ctv.* 
	FROM dbo.ChoicesTranslationsView ctv
	JOIN #SurveyToInsert sti ON ctv.Choice = sti.Choice
	WHERE ctv.ISO639_Code = @LanguageCode

	INSERT INTO dbo.Choices
	(
	    --ChoiceID,
	    ChoiceEnglishDefault,
		QuestionID,
		Sequence,
	    FreeResponse,
		Calendar
	)
	OUTPUT INSERTED.ChoiceID, INSERTED.ChoiceEnglishDefault, INSERTED.QuestionID, INSERTED.Sequence, INSERTED.FreeResponse, INSERTED.Calendar INTO @ChoicesInserted
	SELECT DISTINCT sti.Choice, qtv.QuestionID, sti.ChoiceSequence, sti.FreeResponse,
					--CASE WHEN sti.FreeResponse IS NULL THEN 0 ELSE sti.FreeResponse END, 
					sti.Calendar
	FROM #SurveyToInsert sti
	JOIN dbo.SurveyTranslationsView stv ON sti.Survey = stv.Survey
										AND stv.TypeID = @Type
	JOIN dbo.QuestionsTranslationsView qtv ON sti.Question = qtv.Question
										   AND sti.MultiChoice = qtv.MultiChoice
										   AND qtv.SurveyID = stv.SurveyID
										   --AND sti.Correct = qtv.CorrectAnswer
	WHERE NOT EXISTS (SELECT * 
						FROM dbo.ChoicesTranslationsView ctv
						JOIN dbo.QuestionsTranslationsView qtv2 ON qtv2.QuestionID = ctv.QuestionID											   
						JOIN dbo.SurveyTranslationsView stv2 ON stv2.SurveyID = qtv2.SurveyID
						WHERE ctv.Choice = sti.Choice						  
						  AND qtv.Question = sti.Question
						  AND qtv.MultiChoice = sti.MultiChoice
						  --AND qtv.CorrectAnswer = sti.Correct
						  AND stv2.Survey = sti.Survey
						  AND stv2.TypeID = @Type)
	 AND NOT (sti.Choice IS NULL AND sti.ChoiceSequence IS NULL AND sti.FreeResponse IS NULL AND sti.Calendar IS NULL)

	INSERT INTO dbo.ChoicesTranslations
	(
	    ChoiceID,
	    LanguageID,
	    Choice
	)
	SELECT ci.ChoiceID, l.LanguageID, ci.Choice
	FROM @ChoicesInserted ci
	JOIN dbo.Languages l ON l.ISO639_Code = @LanguageCode

	SELECT ctv.* 
	FROM dbo.ChoicesTranslationsView ctv
	JOIN #SurveyToInsert sti ON ctv.Choice = sti.Choice
	WHERE ctv.ISO639_Code = @LanguageCode



	--Insert Correct flags for Choices
	SELECT ck.*
	FROM dbo.ChoicesKey ck
	JOIN dbo.ChoicesTranslationsView ctv ON ck.ChoiceID = ctv.ChoiceID
	JOIN #SurveyToInsert sti ON ctv.Choice = sti.Choice
	WHERE ctv.ISO639_Code = @LanguageCode

	INSERT INTO dbo.ChoicesKey
	(
	    ChoiceID,
	    Correct
	)	
	SELECT ctv.ChoiceID, sti.Correct
	FROM #SurveyToInsert sti
	JOIN dbo.SurveyTranslationsView stv ON sti.Survey = stv.Survey
										AND stv.TypeID = @Type
	JOIN dbo.QuestionsTranslationsView qtv ON sti.Question = qtv.Question
										   AND sti.MultiChoice = qtv.MultiChoice
										   AND sti.Correct = qtv.CorrectAnswer
										   AND qtv.SurveyID = stv.SurveyID
	JOIN dbo.ChoicesTranslationsView ctv ON ctv.QuestionID = qtv.QuestionID
										 AND sti.Choice = ctv.Choice
	WHERE sti.Correct != 0
	  AND NOT EXISTS (SELECT * 
						FROM dbo.ChoicesKey ck 
						JOIN dbo.ChoicesTranslationsView ctv2 ON ctv2.ChoiceID = ck.ChoiceID
						JOIN dbo.QuestionsTranslationsView qtv2 ON qtv2.QuestionID = ctv2.QuestionID											   
						JOIN dbo.SurveyTranslationsView stv2 ON stv2.SurveyID = qtv2.SurveyID
						WHERE ck.Correct = sti.Correct
						  AND ctv.Choice = sti.Choice
						  AND qtv.Question = sti.Question
						  AND qtv.MultiChoice = sti.MultiChoice
						  --AND qtv.CorrectAnswer = sti.Correct
						  AND stv2.Survey = sti.Survey
						  AND stv2.TypeID = @Type)

	SELECT ck.*
	FROM dbo.ChoicesKey ck
	JOIN dbo.ChoicesTranslationsView ctv ON ck.ChoiceID = ctv.ChoiceID
	JOIN #SurveyToInsert sti ON ctv.Choice = sti.Choice
	WHERE ctv.ISO639_Code = @LanguageCode


	COMMIT TRANSACTION


END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[Questions_GetSummary]'
GO
-- =============================================
-- Author:		Angela Ekstrand
-- Create date: 2018-07-12
-- Description:	Retrieves surveys summaries
-- =============================================
CREATE PROCEDURE [dbo].[Questions_GetSummary]
(
	@QuestionID smallint = 783, --784
	@VersionNumber smallint = 1,	
	@GUID nvarchar(max) = '1e04ee69-532f-4143-b243-39d35106aa96',
	@LanguageCode nchar(2) = 'en'
)
AS
BEGIN
	
	SET NOCOUNT ON;

    SELECT qtv.QuestionID, qtv.Question, qtv.Slider, ctv.FreeResponse, ctv.ChoiceID, ctv.Choice, ctv.[Sequence],
			COUNT(usa.UserSurveyAnswerID) CountResponse INTO #IntermediateResults
	FROM dbo.QuestionsTranslationsView qtv
	JOIN dbo.ChoicesTranslationsView ctv ON ctv.QuestionID = qtv.QuestionID
										 AND ctv.LanguageID = qtv.LanguageID
	LEFT JOIN dbo.UserSurveyAnswers usa ON ctv.ChoiceID = usa.ChoiceID
										AND qtv.QuestionID = usa.QuestionID
	WHERE qtv.Summary = 1
	  AND qtv.Slider = 0
	  AND ctv.FreeResponse = 0
	  AND qtv.QuestionID = @QuestionID
	  AND qtv.ISO639_Code = @LanguageCode
	GROUP BY qtv.QuestionID, qtv.Question, qtv.Slider, ctv.FreeResponse, ctv.ChoiceID, ctv.Choice, ctv.[Sequence]

	DECLARE @TotalResults int
	SELECT @TotalResults = SUM(ir.CountResponse) FROM #IntermediateResults ir

	SELECT ir.QuestionID, ir.Question, ir.Slider, ir.FreeResponse, ir.ChoiceID, ir.Choice, ir.[Sequence], 
		   CASE WHEN @TotalResults = 0 THEN 0 ELSE CAST(ir.CountResponse*1.0/@TotalResults*100.0 AS int) END AS AveragePercent
	INTO #AllAnswers
	FROM #IntermediateResults ir
	UNION
	SELECT qtv.QuestionID, qtv.Question, qtv.Slider, ctv.FreeResponse, ctv.ChoiceID, ctv.Choice, ctv.[Sequence], 
			AVG(CAST(usfr.FreeResponse AS int)) AveragePercent	    
	FROM dbo.QuestionsTranslationsView qtv
	JOIN dbo.ChoicesTranslationsView ctv ON ctv.QuestionID = qtv.QuestionID
										 AND ctv.LanguageID = qtv.LanguageID
	LEFT JOIN dbo.UserSurveyAnswers usa ON ctv.ChoiceID = usa.ChoiceID
									AND qtv.QuestionID = usa.QuestionID
	LEFT JOIN dbo.UserSurveyFreeResponse usfr ON usa.UserSurveyAnswerID = usfr.UserSurveyAnswerID
	WHERE qtv.Summary = 1
	  AND qtv.Slider = 1
	  AND ctv.FreeResponse = 1
	  AND qtv.QuestionID = @QuestionID
	  AND qtv.ISO639_Code = @LanguageCode
	GROUP BY qtv.QuestionID, qtv.Question, qtv.Slider, ctv.FreeResponse, ctv.ChoiceID, ctv.Choice, ctv.[Sequence]

	DROP TABLE #IntermediateResults

	SELECT u.UserID, u.GUID, usa.QuestionID, usa.ChoiceID,
		   CASE WHEN qtv.Slider = 1 AND ctv.FreeResponse = 1 THEN usfr.FreeResponse ELSE NULL END AS FreeResponse
		   INTO #UserAnswer
	FROM [User] u
	JOIN dbo.UserSurvey us ON u.UserID = us.UserID
	JOIN dbo.UserSurveyAnswers usa ON usa.UserSurveyID = us.UserSurveyID
	JOIN dbo.QuestionsTranslationsView qtv ON qtv.QuestionID = usa.QuestionID
	JOIN dbo.ChoicesTranslationsView ctv ON qtv.QuestionID = ctv.QuestionID
										 AND usa.ChoiceID = ctv.ChoiceID
										 AND ctv.LanguageID = qtv.LanguageID
	LEFT JOIN dbo.UserSurveyFreeResponse usfr ON usa.UserSurveyAnswerID = usfr.UserSurveyAnswerID
	WHERE qtv.QuestionID = @QuestionID
	  AND us.VersionNumber = @VersionNumber
	  AND u.GUID = @GUID
	  AND qtv.ISO639_Code = @LanguageCode

 
	SELECT aa.QuestionID, aa.Question, aa.Slider, aa.FreeResponse, aa.ChoiceID, aa.Choice, aa.[Sequence], aa.AveragePercent,
		   CASE WHEN ua.ChoiceID IS NOT NULL AND ua.FreeResponse IS NULL THEN 1 
				WHEN ua.ChoiceID IS NOT NULL AND ua.FreeResponse IS NOT NULL THEN ua.FreeResponse
				ELSE NULL END AS UserResponse
	FROM #AllAnswers aa
	LEFT JOIN #UserAnswer ua ON aa.ChoiceID = ua.ChoiceID
	ORDER BY aa.[Sequence]

	DROP TABLE #UserAnswer
	DROP TABLE #AllAnswers


END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[UserSurvey_GetByUserAndSurvey]'
GO
-- =============================================
-- Author:		Angela Ekstrand
-- Create date:	2016-10-18
-- Description:	Creates a UserSurveyID prior to survey "save"
-- =============================================
CREATE PROCEDURE [dbo].[UserSurvey_GetByUserAndSurvey]
(
	@SurveyID		smallint,
	@WeekID		int,
	@GUID		nvarchar(max),	
	@LT			smalldatetime
)
AS
BEGIN
	
	SET NOCOUNT ON;
	DECLARE @UserID int

	UPDATE dbo.[User]
	SET dbo.[User].LastActiveLT = @LT
	FROM dbo.[User] u
	WHERE u.GUID = @GUID

	SELECT @UserID = u.UserID FROM dbo.[User] u WHERE  u.GUID = @GUID
	


	SELECT us.UserSurveyID, us.UserID, us.SurveyID, us.WeekID, us.VersionNumber 
	FROM UserSurvey us
	WHERE us.SurveyID = @SurveyID 
	  AND us.WeekID = @WeekID 
	  AND us.UserID = @UserID
	

END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[UserSurvey_GetSummaries]'
GO
CREATE PROCEDURE [dbo].[UserSurvey_GetSummaries]
(
	@VersionNumber smallint = 1,	
	@GUID nvarchar(max) = '1e04ee69-532f-4143-b243-39d35106aa96',
	@SurveyID smallint = 124,
	@LanguageCode nchar(2) = 'en'
)
AS
BEGIN
	SET NOCOUNT ON;

	CREATE TABLE #SurveySummaries (
		QuestionID int,
		Question nvarchar(MAX),
		Slider bit,
		FreeResponse bit,
		ChoiceID int,
		Choice nvarchar(MAX),
		[Sequence] int,
		AveragePercent int,
		UserResponse bit
	)

	DECLARE @question_id int

	DECLARE question_cursor CURSOR FOR
		SELECT q.QuestionID FROM Questions q
		JOIN UserSurvey s ON s.SurveyID = q.SurveyID
		WHERE q.SurveyID = @SurveyID --124
		AND s.VersionNumber = @VersionNumber --1
		AND q.Summary = 1

	OPEN question_cursor

	FETCH NEXT FROM question_cursor
	INTO @question_id

	WHILE @@FETCH_STATUS = 0
	BEGIN

		INSERT INTO #SurveySummaries 
		EXEC Questions_GetSummary @question_id, @VersionNumber, @GUID, @LanguageCode
	
		FETCH NEXT FROM question_cursor INTO @question_id
	END

	CLOSE question_cursor
	DEALLOCATE question_cursor

	SELECT * FROM #SurveySummaries
	DROP TABLE #SurveySummaries

END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[Week_SmartUpdate]'
GO
-- =============================================
-- Author:		Angela Ekstrand
-- Create date: 2016-10-18
-- Description:	Updates start/end dates for a number of weeks (@NumberWeeks) based on a week length (@WeekLengthDays) and a @StartDate
-- =============================================
CREATE PROCEDURE [dbo].[Week_SmartUpdate]
(
	@StartDate		smalldatetime = '2017-03-27',
	@NumberWeeks	smallint = 24,
	@WeekLengthDays	smallint = 7
)
AS
BEGIN
	
	SET NOCOUNT ON;
	
	DECLARE @StartWeek smallint = 1
	DECLARE @CurrentWeek smallint
	DECLARE @EndDate smalldatetime
	DECLARE @AddMinutes smallint
	
	SET @AddMinutes = @WeekLengthDays*24*60
	SET @StartDate = DATEADD(hh,14,dbo.Trunc(@StartDate))
	SET @EndDate = DATEADD(minute,@AddMinutes-1,@StartDate)
		
	SET @CurrentWeek = @StartWeek
	
	WHILE @CurrentWeek <= @NumberWeeks
	BEGIN

		--SELECT @CurrentWeek AS WeekNumber, @StartDate AS StartDate, @EndDate AS EndDate
		
		IF (SELECT COUNT(*) FROM dbo.[Week] w WHERE w.WeekNumber = @CurrentWeek) = 1
		BEGIN
			UPDATE dbo.[Week]
			SET dbo.[Week].StartDate = @StartDate,
			    dbo.[Week].EndDate = @EndDate
			WHERE dbo.[Week].WeekNumber = @CurrentWeek
		END
		ELSE
		BEGIN
			INSERT INTO dbo.[Week]
			(
			    --WeekID - this column value is auto-generated
			    StartDate,
			    EndDate,
			    WeekNumber
			)
			SELECT @StartDate, @EndDate, @CurrentWeek
		END

		SET @CurrentWeek = @CurrentWeek + 1
		SET @StartDate = DATEADD(minute,@AddMinutes,@StartDate)
		SET @EndDate = DATEADD(minute,@AddMinutes, @EndDate)

	END
	
	DECLARE @DeleteWeeks smallint
	SET @CurrentWeek=@CurrentWeek-1
	SELECT @DeleteWeeks = COUNT(*) FROM dbo.[Week] w WHERE w.WeekNumber > @CurrentWeek	

	IF NOT EXISTS (SELECT * FROM dbo.SurveyWeek sw 
							JOIN dbo.[Week] w ON w.WeekID = sw.WeekID 
							WHERE w.WeekNumber > @NumberWeeks)
		BEGIN
			DELETE FROM dbo.[Week] WHERE WeekNumber > @NumberWeeks
			SELECT CAST(@DeleteWeeks AS nvarchar(max)) + ' weeks with WeekNumber > ' + CAST(@NumberWeeks AS nvarchar(max)) + ' deleted.' AS [Message]
		END
	ELSE
		BEGIN		
			SELECT CAST(@DeleteWeeks AS nvarchar(max)) + ' weeks with WeekNumber > ' + CAST(@NumberWeeks AS nvarchar(max)) + ' not deleted because they are associated with Surveys. Please extend your study or manually clear these records from the SurveyWeek and Week tables.' AS [Message]
		END

	SELECT * FROM dbo.[Week] w

END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[UserSurveyAnswers_GetByUserAndQuestionID]'
GO
-- =============================================
-- Author:		Angela Ekstrand
-- Create date: 2016-10-18
-- Description:	Retrieves survey questions choices
-- =============================================
CREATE PROCEDURE [dbo].[UserSurveyAnswers_GetByUserAndQuestionID]
(
	@SurveyID	smallint,
	@WeekID		int,
	@GUID		nvarchar(max),
	@QuestionID int
	
)
AS
BEGIN
	
	SET NOCOUNT ON;

	IF @SurveyID = 0 SET @WeekID = 0

    SELECT  usa.QuestionID, usa.ChoiceID
	FROM dbo.[User] u 
	JOIN dbo.UserSurvey us ON u.UserID = us.UserID								
	JOIN dbo.UserSurveyAnswers usa ON usa.UserSurveyID = us.UserSurveyID									
	WHERE u.GUID = @GUID
	  AND us.SurveyID = @SurveyID
	  AND us.WeekID = @WeekID
	  AND usa.QuestionID = @QuestionID	  

END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[Week_SmartAdd]'
GO
-- =============================================
-- Author:		Angela Ekstrand
-- Create date:	2018-04-05
-- Description:	Updates adds weeks in a dynamic fashion; must be run by a SQL job or called by a scheduled external job (e.g., Jenkins) to function automatically in a production setting
-- =============================================
CREATE PROCEDURE [dbo].[Week_SmartAdd]	
AS
BEGIN

    SET NOCOUNT ON;
	
    
    DECLARE @NumberWeeks	   smallint = 1,
		  @WeekLengthDays smallint = 7,
		  @CurrentDate	   smalldatetime = GETUTCDATE(),--'2018-06-27',--GETUTCDATE(),
		  @CurrentWeek	   smallint

    SELECT @CurrentWeek = w.WeekNumber
    FROM dbo.[Week] w
    WHERE @CurrentDate BETWEEN w.StartDate AND w.EndDate

    --SELECT COUNT(*) FROM dbo.[Week] w WHERE w.WeekNumber > @CurrentWeek

    IF (SELECT COUNT(*) FROM dbo.[Week] w WHERE w.WeekNumber > @CurrentWeek) < 2
    BEGIN
	   
	   DECLARE @MaxWeek smallint, @MaxWeekStart smalldatetime, @MaxWeekEnd smalldatetime

	   SELECT @MaxWeek = MAX(w.WeekNumber), @MaxWeekStart = MAX(w.StartDate), @MaxWeekEnd = MAX(w.EndDate)
	   FROM dbo.[Week] w
	   SELECT @MaxWeek MaxWeek, @MaxWeekStart MaxWeekStart, @MaxWeekEnd MaxWeekEnd
	   
	   DECLARE @NewWeek smallint, @StartDate smalldatetime, @EndDate smalldatetime, @AddMinutes smallint
	
	   SET @NewWeek = @MaxWeek + 1 
	   SET @AddMinutes = @WeekLengthDays*24*60
	   SET @StartDate = DATEADD(minute,@AddMinutes,@MaxWeekStart)
	   SET @EndDate = DATEADD(minute,@AddMinutes, @MaxWeekEnd)

	   SELECT @NewWeek NewWeek, @StartDate StartDate, @EndDate EndDate

	   INSERT INTO dbo.[Week]
	   (
	       --WeekID - this column value is auto-generated
	       StartDate,
	       EndDate,
	       WeekNumber
	   )
	   VALUES
	   (
	       -- WeekID - smallint
	       @StartDate, -- StartDate - smalldatetime
	       @EndDate, -- EndDate - smalldatetime
	       @NewWeek -- WeekNumber - smallint
	   )

    END

    SELECT *
    FROM dbo.[Week] w
    WHERE w.WeekNumber = @NewWeek
    

END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[UserSurveyAnswers_Submit]'
GO
-- =============================================
-- Author:		Angela Ekstrand
-- Create date: 2016-10-18
-- Description:	Retrieves surveys
-- =============================================
CREATE PROCEDURE [dbo].[UserSurveyAnswers_Submit]
(
	@SurveyID	smallint,
	@WeekID		int,
	@GUID		nvarchar(max),
	@QuestionID smallint,
	@ChoiceIDs	nvarchar(max),
	@LT			smalldatetime,
	@FreeResponse	nvarchar(max) = NULL,
	@VersionNumber  smallint = NULL, --required for every smoke smarts call
	@LanguageCode	nchar(2) = 'en'
)
AS
BEGIN
	
	SET NOCOUNT ON;
	--SELECT @SurveyID SurveyID, @WeekID WeekID, @GUID [GUID], @QuestionID QuestionID, @ChoiceIDs ChoiceIDs, @LT LT, @FreeResponse FreeResponse, @VersionNumber VersionNumber

	IF @SurveyID = 0 SET @WeekID = 0
	IF RTRIM(@VersionNumber) = '' SET @VersionNumber = NULL
	IF RTRIM(@FreeResponse) = '' SET @FreeResponse = NULL

	--SELECT @SurveyID SurveyID, @WeekID WeekID, @GUID [GUID], @QuestionID QuestionID, @ChoiceIDs ChoiceIDs, @LT LT, @FreeResponse FreeResponse, @VersionNumber VersionNumber

	UPDATE dbo.[User]
	SET dbo.[User].LastActiveLT = @LT
	FROM dbo.[User] u
	WHERE u.GUID = @GUID

	DECLARE @UserSurveyID int

	DECLARE @SurveyType tinyint
	SELECT @SurveyType = TypeID FROM dbo.Survey s WHERE s.SurveyID = @SurveyID
	
	IF @SurveyType = 7 --for SmokeSmarts only
	BEGIN 
		
		DECLARE @Completed bit
		SELECT @Completed = Completed 
		FROM dbo.UserSurveyOrder uso 
		JOIN dbo.[User] u ON uso.UserID = u.UserID
		WHERE u.GUID = @GUID
		  AND uso.SurveyID = @SurveyID
		  AND uso.VersionNumber = @VersionNumber

		IF @Completed = 0 --for incomplete surverys only NOT in the current week
		BEGIN

			--Find existing @UserSurveyID if it was began in an old week
			SELECT us.UserSurveyID INTO #OldUserSurveyIDs
			FROM dbo.UserSurvey us
			JOIN dbo.[User]		u ON us.UserID = u.UserID
			WHERE u.GUID = @GUID
			  AND us.SurveyID = @SurveyID
			  AND us.WeekID != @WeekID --not in the current week
			  AND us.VersionNumber = @VersionNumber

			DELETE FROM dbo.UserSurveyFreeResponse
			WHERE dbo.UserSurveyFreeResponse.UserSurveyAnswerID IN (SELECT usa.UserSurveyAnswerID
																	FROM dbo.UserSurveyAnswers usa
																	WHERE usa.UserSurveyID 
																	   IN (SELECT UserSurveyID
																			FROM #OldUserSurveyIDs))

			DELETE FROM dbo.UserSurveyAnswers
			WHERE dbo.UserSurveyAnswers.UserSurveyID IN (SELECT UserSurveyID FROM #OldUserSurveyIDs)

			DELETE FROM dbo.UserSurveyZipcode
			WHERE dbo.UserSurveyZipcode.UserSurveyID IN (SELECT UserSurveyID FROM #OldUserSurveyIDs)

			DELETE FROM dbo.UserSurvey
			WHERE dbo.UserSurvey.UserSurveyID IN (SELECT UserSurveyID FROM #OldUserSurveyIDs)

		END

	END

	
	--Find existing @UserSurveyID
	SELECT @UserSurveyID = us.UserSurveyID 
	FROM dbo.UserSurvey us
	JOIN dbo.[User]		u ON us.UserID = u.UserID
	WHERE u.GUID = @GUID
	  AND us.SurveyID = @SurveyID
	  AND us.WeekID = @WeekID
	  AND ((us.VersionNumber IS NULL AND @VersionNumber IS NULL) OR (us.VersionNumber = @VersionNumber))
	--SELECT @UserSurveyID UserSurveyID
	
	--Insert Record for Survey if neeeded
	IF @UserSurveyID IS NULL
	BEGIN
		INSERT INTO dbo.UserSurvey
		(
		    --UserSurveyID - this column value is auto-generated
		    UserID,
		    SurveyID,
		    WeekID,
			VersionNumber
		)
		SELECT u.UserID, @SurveyID, @WeekID, @VersionNumber
		FROM dbo.[User] u
		WHERE u.GUID = @GUID
	
		SET @UserSurveyID = @@IDENTITY
	END
	--SELECT @UserSurveyID UserSurveyID

	--Clear Old Free Response Answers
	-- SELECT * FROM UserSurveyFreeResponse
	DELETE FROM UserSurveyFreeResponse
	WHERE UserSurveyAnswerID IN 
	(SELECT UserSurveyAnswerID FROM UserSurveyAnswers WHERE QuestionID = @QuestionID 
	  AND UserSurveyID = @UserSurveyID)
	-- SELECT * FROM UserSurveyFreeResponse

	--Clear Old Answers
	DELETE FROM UserSurveyAnswers
	WHERE QuestionID = @QuestionID 
	  AND UserSurveyID = @UserSurveyID
	
	--Insert Answers
	IF @ChoiceIDs IS NOT NULL
	BEGIN 
		INSERT INTO dbo.UserSurveyAnswers
		(
			UserSurveyID,
			ChoiceID,
			QuestionID
		)
		SELECT @UserSurveyID, ti.ID, @QuestionID
		FROM dbo.TblID(@ChoiceIDs) ti
	END
	IF @ChoiceIDs IS NULL AND @FreeResponse IS NOT NULL 
	BEGIN
		SELECT @ChoiceIDs = CAST(ChoiceID as VARCHAR(MAX)) FROM Choices WHERE QuestionID = @QuestionID
		INSERT INTO dbo.UserSurveyAnswers
		(
			UserSurveyID,
			ChoiceID,
			QuestionID
		)
		SELECT @UserSurveyID, ti.ID, @QuestionID
		FROM dbo.TblID(@ChoiceIDs) ti

		-- SELECT * FROM UserSurveyAnswers WHERE UserSurveyID = @UserSurveyID AND QuestionID = @QuestionID
	END 
    --SELECT * FROM dbo.UserSurveyAnswers usa
	
	IF @FreeResponse IS NOT NULL 
	BEGIN
		INSERT INTO dbo.UserSurveyFreeResponse
		(
		    UserSurveyAnswerID,
		    FreeResponse
		)
		SELECT usa.UserSurveyAnswerID, @FreeResponse
		FROM dbo.UserSurveyAnswers usa
		WHERE usa.UserSurveyID = @UserSurveyID
		  AND usa.QuestionID = @QuestionID
	END
    --SELECT * FROM dbo.UserSurveyFreeResponse usfr

	DECLARE @BadgeReceived tinyint = 0

	IF @SurveyType IN (1,3,7) BEGIN

		/*Create a command to execute that creates a temp table in order to 
		get the accurate number of questions available to the user to decide whether
		they receive a badge for the profile or not.*/
		/*=============================================================================*/
		CREATE TABLE #Questions	(	GUID nvarchar(MAX),
									SurveyID int,
									VersionNumber smallint,								
									QuestionsTotal int,
									QuestionsAnswered int)

		IF @SurveyType = 1 BEGIN
			INSERT INTO #Questions SELECT a.GUID, a.SurveyID, a.VersionNumber, COUNT(a.QuestionID) AS QuestionsTotal, COUNT(a.AnsweredQuestionID) QuestionsAnswered			
				FROM
				(SELECT DISTINCT u.GUID, us.SurveyID, q.QuestionID, qv.VersionNumber, usa.QuestionID AnsweredQuestionID	
					FROM dbo.[User] u
					JOIN dbo.UserSurvey us ON us.UserID = u.UserID
					JOIN dbo.QuestionsTranslationsView q ON us.SurveyID = q.SurveyID
					JOIN dbo.QuestionVersion qv ON qv.QuestionID = q.QuestionID AND qv.VersionNumber = us.UserID % 2
					LEFT JOIN dbo.UserSurveyAnswers usa ON usa.QuestionID = q.QuestionID
												 AND us.UserSurveyID = usa.UserSurveyID
					WHERE u.GUID =  @GUID
					  AND EXISTS(SELECT * FROM dbo.Choices c WHERE c.QuestionID = q.QuestionID) 
					  AND us.SurveyID = @SurveyID
					  AND q.ISO639_Code = @LanguageCode
				) a
			GROUP BY a.GUID, a.SurveyID, a.VersionNumber

		END ELSE BEGIN

			INSERT INTO #Questions SELECT a.GUID, a.SurveyID, MAX(a.VersionNumber), COUNT(a.QuestionID) AS QuestionsTotal, COUNT(a.AnsweredQuestionID) QuestionsAnswered					
			FROM
			(SELECT DISTINCT u.GUID, us.SurveyID, q.QuestionID, us.VersionNumber, usa.QuestionID AnsweredQuestionID	
				FROM dbo.[User] u
				JOIN dbo.UserSurvey us ON us.UserID = u.UserID
				JOIN dbo.QuestionsTranslationsView q ON us.SurveyID = q.SurveyID
				LEFT JOIN dbo.QuestionVersion qv ON q.QuestionID = qv.QuestionID
				LEFT JOIN dbo.UserSurveyAnswers usa ON usa.QuestionID = q.QuestionID
											 AND us.UserSurveyID = usa.UserSurveyID
				WHERE u.GUID = @GUID 
				  AND EXISTS(SELECT * FROM dbo.Choices c WHERE c.QuestionID = q.QuestionID) 
				  AND us.SurveyID = @SurveyID
				  AND q.ISO639_Code = @LanguageCode
				  AND ((us.VersionNumber = @VersionNumber) OR (us.VersionNumber IS NULL AND @VersionNumber IS NULL))
			) a
			GROUP BY a.GUID, a.SurveyID
		END

		DECLARE @Questions XML = (SELECT * FROM #Questions FOR XML AUTO)

		DECLARE @UserBadgeID int = 0
		/*=============================================================================*/

		/*Original functionality*/
		/*=============================================================================*/
		--SELECT a.GUID, a.SurveyID, COUNT(a.QuestionID) AS QuestionsTotal, COUNT(a.AnsweredQuestionID) QuestionsAnswered					
		--INTO #Questions
		--FROM
		--(SELECT DISTINCT u.GUID, us.SurveyID, q.QuestionID, usa.QuestionID AnsweredQuestionID	
		--FROM dbo.[User] u
		--JOIN dbo.UserSurvey us ON us.UserID = u.UserID
		--JOIN dbo.Questions q ON q.SurveyID = us.SurveyID
		--LEFT JOIN dbo.UserSurveyAnswers usa ON usa.QuestionID = q.QuestionID
		--							 AND us.UserSurveyID = usa.UserSurveyID
		--WHERE u.GUID = @GUID
		--  AND us.SurveyID = @SurveyID ) a
		--GROUP BY a.GUID, a.SurveyID
		/*=============================================================================*/

		INSERT INTO dbo.UserBadge ( UserID, BadgeID, WeekID)
		SELECT u.UserID, bst.BadgeID, @WeekID
		FROM dbo.[User] u 
		JOIN dbo.BadgeSurveyType bst ON SurveyTypeID = @SurveyType
		CROSS APPLY dbo.CheckBadgeWeek(bst.BadgeID, @WeekID) cbw
		WHERE u.GUID = @GUID
		  AND (SELECT CASE WHEN @SurveyType IN (1,3,7) AND q.QuestionsTotal = q.QuestionsAnswered THEN 1 ELSE 0 END FROM #Questions q) = 1
		  AND NOT EXISTS ( SELECT *
						   FROM dbo.UserBadge ub
						   JOIN dbo.[User] u2 ON u2.UserID = ub.UserID
						   WHERE ub.BadgeID = bst.BadgeID
						     AND ub.WeekID = @WeekID
							 AND u2.GUID = @GUID )
		
		IF @@ROWCOUNT > 0 SET @UserBadgeID = @@IDENTITY

		SELECT @BadgeReceived = BadgeID
		FROM dbo.UserBadge ub
		WHERE ub.UserBadgeID = @UserBadgeID
		
		UPDATE dbo.UserSurveyOrder
		SET dbo.UserSurveyOrder.Completed = a.Completed
		FROM (SELECT q.SurveyID, q.VersionNumber, u.UserID, CASE WHEN @SurveyType = 7 AND q.QuestionsTotal = q.QuestionsAnswered THEN 1 ELSE 0 END AS Completed
				FROM #Questions q
				JOIN dbo.UserSurveyOrder uso ON q.SurveyID = uso.SurveyID
											 AND uso.VersionNumber = q.VersionNumber
				JOIN dbo.[User] u ON uso.UserID = u.UserID
				WHERE u.GUID = @GUID ) a
		WHERE a.SurveyID = dbo.UserSurveyOrder.SurveyID
		  AND a.VersionNumber = dbo.UserSurveyOrder.VersionNumber
		  AND a.UserID = dbo.UserSurveyOrder.UserID
		  AND @SurveyType = 7
				
	END
	
	SELECT @BadgeReceived AS BadgeReceived, 
			CASE WHEN @BadgeReceived = 0 THEN 'No badge received'
				 ELSE (SELECT btv.Badge 
						FROM dbo.BadgeTranslationsView btv 
						WHERE btv.BadgeID = @BadgeReceived
						  AND btv.ISO639_Code = @LanguageCode )
			END AS Badge
END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[UserSurveyDate_Submit]'
GO
-- =============================================
-- Author:		Angela Ekstrand
-- Create date: 2016-10-18
-- Description:	Retrieves surveys
-- =============================================
CREATE PROCEDURE [dbo].[UserSurveyDate_Submit]
(
	@SurveyID	smallint,
	@WeekID		int,
	@GUID		nvarchar(max),
	@Dates		nvarchar(max)	--format yyyy-mm-dd; sql "date" format
)
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @UserSurveyID int

	--Find existing @UserSurveyID
	SELECT @UserSurveyID = us.UserSurveyID 
	FROM dbo.UserSurvey us
	JOIN dbo.[User]		u ON us.UserID = u.UserID
	WHERE u.GUID = @GUID
	  AND us.SurveyID = @SurveyID
	  AND us.WeekID = @WeekID

	--Insert Record for Survey if neeeded
	IF @UserSurveyID IS NULL
	BEGIN
		INSERT INTO dbo.UserSurvey
		(
		    --UserSurveyID - this column value is auto-generated
		    UserID,
		    SurveyID,
		    WeekID
		)
		SELECT u.UserID, @SurveyID, @WeekID
		FROM dbo.[User] u
		WHERE u.GUID = @GUID
	
		SET @UserSurveyID = @@IDENTITY
	END

	--Clear Old Dates
	DELETE FROM UserSurveyDate
	WHERE UserSurveyID = @UserSurveyID

	--Insert Dates
	INSERT INTO dbo.UserSurveyDate
	(
	    UserSurveyID,
	    [Date]
	)	
	SELECT @UserSurveyID, CAST(tc.Code AS date)
	FROM dbo.TblCode(@Dates) tc

	
END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[Survey_GetByTypeID]'
GO
-- =============================================
-- Author:		Angela Ekstrand
-- Create date: 2016-10-18
-- Description:	Retrieves surveys
-- =============================================
CREATE PROCEDURE [dbo].[Survey_GetByTypeID]
(
	@TypeID tinyint,
	@GUID   nvarchar(max) = NULL,
	@LT		smalldatetime = NULL,
	@LanguageCode nchar(2) = 'en'
)
AS
BEGIN
	
	SET NOCOUNT ON;

	IF @TypeID != 7 BEGIN
		SELECT stv.SurveyID, stv.Survey, stv.TypeID, sttv.Type, stv.Image, stv.Calendar, 
				sw.WeekID, w.StartDate, w.EndDate, NULL AS VersionNumber, NULL AS [Sequence], NULL AS Completed
		FROM dbo.SurveyTranslationsView stv
		JOIN dbo.SurveyTypeTranslationsView sttv ON sttv.SurveyTypeID = stv.TypeID
												 AND sttv.LanguageID = stv.LanguageID
		LEFT JOIN dbo.SurveyWeek sw ON sw.SurveyID = stv.SurveyID
		LEFT JOIN dbo.Week w ON w.WeekID = sw.WeekID
		WHERE stv.TypeID = @TypeID
		  AND stv.ISO639_Code = @LanguageCode
	END

	IF @TypeID = 7
	BEGIN
		
		DECLARE @AnsweredCount tinyint
	
		SELECT us.UserID, us.SurveyID, us.VersionNumber, us.WeekID INTO #Answered
		FROM dbo.UserSurvey us
		JOIN dbo.[User] u ON us.UserID = u.UserID
		JOIN dbo.Survey s ON us.SurveyID = s.SurveyID
		JOIN dbo.Week w2 ON us.WeekID = w2.WeekID
		WHERE s.TypeID = 7
		  AND u.GUID = @GUID
		  AND @LT BETWEEN w2.StartDate AND w2.EndDate

		SELECT @AnsweredCount = (SELECT COUNT(*) FROM #Answered a)
		DECLARE @SelectCount int = 3-@AnsweredCount
		
		CREATE TABLE #SmokeSmartsSurveys	(	SurveyID		smallint,
												Survey			nvarchar(150),
												TypeID			tinyint,
												[Type]			nvarchar(150),
												[Image]			nvarchar(max),
												Calendar		bit,
												WeekID			smallint,
												StartDate		smalldatetime,
												EndDate			smalldatetime,
												VersionNumber	smallint,
												Sequence		int,
												Completed		bit
											)
		INSERT INTO #SmokeSmartsSurveys	( SurveyID, Survey, TypeID, Type, Image, Calendar, WeekID, StartDate, EndDate, VersionNumber, [Sequence], Completed )
		SELECT stv.SurveyID, stv.Survey, stv.TypeID, sttv.Type, stv.Image, stv.Calendar, 
				sw.WeekID, w.StartDate, w.EndDate, uso.VersionNumber, uso.[Sequence], uso.Completed 
		FROM dbo.SurveyTranslationsView stv
		JOIN dbo.SurveyTypeTranslationsView sttv ON sttv.SurveyTypeID = stv.TypeID
												 AND sttv.LanguageID = stv.LanguageID
		JOIN dbo.UserSurveyOrder uso ON stv.SurveyID = uso.SurveyID
		JOIN dbo.[User] u ON uso.UserID = u.UserID
		LEFT JOIN dbo.SurveyWeek sw ON sw.SurveyID = stv.SurveyID
		LEFT JOIN dbo.Week w ON w.WeekID = sw.WeekID
		WHERE stv.TypeID = @TypeID
		  AND u.GUID = @GUID
		  AND stv.ISO639_Code = @LanguageCode
		  AND EXISTS (SELECT *
						FROM #Answered a
						WHERE a.UserID = uso.UserID
						  AND a.SurveyID = uso.SurveyID
						  AND a.VersionNumber = uso.VersionNumber)
		ORDER BY uso.[Sequence]
		
		INSERT INTO #SmokeSmartsSurveys	( SurveyID, Survey, TypeID, Type, Image, Calendar, WeekID, StartDate, EndDate, VersionNumber, [Sequence], Completed )
		SELECT TOP (@SelectCount) stv.SurveyID, stv.Survey, stv.TypeID, sttv.Type, stv.Image, stv.Calendar, 
					sw.WeekID, w.StartDate, w.EndDate, uso.VersionNumber, uso.[Sequence], uso.Completed
		FROM dbo.SurveyTranslationsView stv
		JOIN dbo.SurveyTypeTranslationsView sttv ON sttv.SurveyTypeID = stv.TypeID
												 AND sttv.LanguageID = stv.LanguageID
		JOIN dbo.UserSurveyOrder uso ON stv.SurveyID = uso.SurveyID
		JOIN dbo.[User] u ON uso.UserID = u.UserID
		LEFT JOIN dbo.SurveyWeek sw ON sw.SurveyID = stv.SurveyID
		LEFT JOIN dbo.Week w ON w.WeekID = sw.WeekID
		WHERE stv.TypeID = @TypeID
		  AND u.GUID = @GUID
		  AND stv.ISO639_Code = @LanguageCode
		  AND uso.Completed = 0
		  AND NOT EXISTS (SELECT *
							FROM #Answered a
							WHERE a.UserID = u.UserID
							  AND a.SurveyID = stv.SurveyID)
		ORDER BY uso.[Sequence]

		SELECT sss.SurveyID, sss.Survey, sss.TypeID, sss.Type, sss.Image, sss.Calendar, sss.WeekID, sss.StartDate, sss.EndDate, sss.VersionNumber, sss.[Sequence], sss.Completed
		FROM #SmokeSmartsSurveys sss
		ORDER BY sss.[Sequence]

	END



END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[UserSurveyDate_GetByUserAndSurveyID]'
GO
-- =============================================
-- Author:		Angela Ekstrand
-- Create date: 2016-10-18
-- Description:	Retrieves surveys
-- =============================================
CREATE PROCEDURE [dbo].[UserSurveyDate_GetByUserAndSurveyID]
(
	@SurveyID	smallint,
	@WeekID		int,
	@GUID		nvarchar(max)
)
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT usd.[Date]
	FROM dbo.UserSurvey us
	JOIN dbo.[User]		u ON us.UserID = u.UserID
	JOIN dbo.UserSurveyDate usd ON usd.UserSurveyID = us.UserSurveyID	
	WHERE u.GUID = @GUID
	  AND us.SurveyID = @SurveyID
	  AND us.WeekID = @WeekID

END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[User_GetProfileStatsByGUID]'
GO
-- =============================================
-- Author:		Angela Ekstrand
-- Create date: 2016-10-18
-- Description:	Retrieves a user's stats for profile questions answers, obs submitted, and obs last submitted
-- =============================================
CREATE PROCEDURE [dbo].[User_GetProfileStatsByGUID]
(
	@GUID		nvarchar(max),
	@LT			smalldatetime --user's time by their phone's clock
)
AS
BEGIN
	
	SET NOCOUNT ON;

    SELECT a.GUID, a.SurveyID, COUNT(a.QuestionID) AS ProfileTotal, COUNT(a.AnsweredQuestionID) ProfileAnswered,
					CAST((COUNT(a.AnsweredQuestionID)*1.0)/(COUNT(a.QuestionID)*1.0)*100.0 AS numeric(5,2)) AS PctComplete
	INTO #Profile
	FROM
	(SELECT DISTINCT u.GUID, us.SurveyID, q.QuestionID, usa.QuestionID AnsweredQuestionID	
	FROM dbo.[User] u
	JOIN dbo.UserSurvey us ON us.UserID = u.UserID
	JOIN dbo.Questions q ON q.SurveyID = us.SurveyID
	LEFT JOIN dbo.UserSurveyAnswers usa ON usa.QuestionID = q.QuestionID
								 AND us.UserSurveyID = usa.UserSurveyID
	WHERE u.GUID = @GUID
	  AND us.SurveyID = 0 ) a
	GROUP BY a.GUID, a.SurveyID

	--SELECT * FROM #Profile p

	
	SELECT c.GUID, COUNT(c.WeekID) ObsWeeksTotal, SUM(c.Submitted) ObsWeeksSubmitted
	INTO #Observations
	FROM 
	(SELECT DISTINCT b.GUID, b.WeekID, CASE WHEN b.CountSubmitted > 0 AND b.CountSubmitted IS NOT NULL THEN 1 ELSE 0 END AS Submitted 
	FROM
	(SELECT a.GUID, a.WeekID, COUNT(us.UserSurveyID) CountSubmitted
	FROM
	(SELECT u.GUID, u.UserID, w.WeekID
	FROM dbo.[User] u
	CROSS APPLY dbo.Week w
	WHERE u.GUID = @GUID
	  AND w.StartDate IS NOT NULL AND w.StartDate <= @LT ) a
	JOIN dbo.SurveyType st ON st.TypeID = 2 --weekly observation surveys
	JOIN dbo.Survey s ON s.TypeID = st.TypeID
	LEFT JOIN dbo.UserSurvey us ON a.UserID = us.UserID
								AND us.SurveyID = s.SurveyID
								AND us.WeekID = a.WeekID
	GROUP BY a.GUID, a.WeekID ) b ) c
	GROUP BY c.GUID

	--SELECT * FROM #Observations o


	SELECT a.GUID, MAX(a.WeekID) MaxWeekIDPossible, MAX(us.WeekID) MaxWeekIDSubmitted
	INTO #MostRecentObs
	FROM
	(SELECT u.GUID, u.UserID, w.WeekID
	FROM dbo.[User] u
	CROSS APPLY dbo.Week w
	WHERE u.GUID = @GUID
	  AND w.StartDate IS NOT NULL AND w.StartDate <= @LT ) a
	JOIN dbo.SurveyType st ON st.TypeID = 2 --weekly observation surveys
	JOIN dbo.Survey s ON s.TypeID = st.TypeID
	LEFT JOIN dbo.UserSurvey us ON a.UserID = us.UserID
								AND us.SurveyID = s.SurveyID
								AND us.WeekID = a.WeekID
	GROUP BY a.GUID

	--SELECT * FROM #MostRecentObs mro

	--Get EndDate to use if User has never submitted forecasts
	DECLARE @UserSpecificStartDate smalldatetime, @UserSpecificEndDate smalldatetime
	SELECT @UserSpecificStartDate = w.StartDate, @UserSpecificEndDate = w.EndDate
	FROM dbo.[User] u
	JOIN dbo.Week w ON u.CreatedLT BETWEEN w.StartDate AND w.EndDate
	WHERE u.GUID = @GUID

	--SELECT @UserSpecificStartDate,@UserSpecificEndDate

	SELECT u.GUID, us.UserSurveyID, us.SurveyID, us.WeekID, w.StartDate, w.EndDate INTO #NonResponseSurveySubmitted
	FROM dbo.UserSurvey us
	JOIN dbo.[User] u ON us.UserID = u.UserID
	JOIN dbo.Week w ON us.WeekID = w.WeekID
	WHERE u.GUID = @GUID
	  AND us.SurveyID = 7
     ORDER BY w.WeekID DESC

	--SELECT * FROM #NonResponseSurveySubmitted nrss

	SELECT p.GUID,	p.ProfileTotal, p.ProfileAnswered, 
					o.ObsWeeksTotal, o.ObsWeeksSubmitted, 
					mro.MaxWeekIDPossible, w.StartDate MaxStartDatePossible, w.EndDate MaxEndDatePossible, 
					mro.MaxWeekIDSubmitted, 
					ISNULL(w2.StartDate,@UserSpecificStartDate) MaxStartDateSubmitted, 
					ISNULL(w2.EndDate,@UserSpecificEndDate) MaxEndDateSubmitted, 
					CAST(CASE WHEN DATEDIFF(dd,ISNULL(w2.EndDate,@UserSpecificEndDate),w.EndDate) >= 15
							 AND nrss.EndDate IS NULL THEN 1 ELSE 0 END AS bit) AS MoreThanTwoWeeks
	FROM #Profile p
	JOIN #Observations o ON p.GUID = o.GUID
	JOIN #MostRecentObs mro ON p.GUID = mro.GUID
	JOIN dbo.Week w ON mro.MaxWeekIDPossible = w.WeekID
	LEFT JOIN dbo.Week w2 ON mro.MaxWeekIDSubmitted = w2.WeekID
	LEFT JOIN #NonResponseSurveySubmitted nrss ON nrss.GUID = p.GUID
									   AND nrss.EndDate > ISNULL(w2.EndDate,@UserSpecificEndDate)
	
END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[User_GetSurveyStatusByGUIDAndWeekID]'
GO
-- =============================================
-- Author:		Angela Ekstrand
-- Create date: 2016-10-18
-- Description:	Retrieves a user's stats for profile questions answers, obs submitted, and obs last submitted
-- =============================================
CREATE PROCEDURE [dbo].[User_GetSurveyStatusByGUIDAndWeekID]
(
	@GUID		nvarchar(max),
	@WeekID		smallint,
	@LanguageCode nchar(2) = 'en'
)
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT s.SurveyID, st.Survey, CASE WHEN us.UserSurveyID IS NOT NULL THEN 1 ELSE 0 END AS Submitted
	FROM dbo.Survey s
	JOIN dbo.SurveyTranslations st ON s.SurveyID = st.SurveyID
	JOIN dbo.Languages l ON st.LanguageID = l.LanguageID
	JOIN dbo.[User] u ON u.GUID = @GUID
	LEFT JOIN dbo.UserSurvey us ON s.SurveyID = us.SurveyID
								AND us.UserID = u.UserID
								AND us.WeekID = @WeekID								
	WHERE s.TypeID IN (2, 5) --weekly observation surveys
	  AND l.ISO639_Code = @LanguageCode
	
END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[SystemStats_GetByDate]'
GO
-- =============================================
-- Author:		Angela Ekstrand
-- Create date: 2016-10-18
-- Description:	Inserts a new user
-- =============================================
CREATE PROCEDURE [dbo].[SystemStats_GetByDate]
(
--DECLARE
	@LT smalldatetime = '2018-08-26'
)
AS
BEGIN
	
	SET NOCOUNT ON;

    DECLARE @AllUserCount int = 0,
			@ActiveUserCount int  = 0,
			@ReportingUserCount int = 0,
			@SmokeObsvCount int = 0

	--Find count of all users
	SELECT @AllUserCount = COUNT(*) FROM dbo.[User] u
	--SELECT @AllUserCount AS AllUserCount

	--Find count of active users based on last week's start date
	SELECT @ActiveUserCount = COUNT(*) FROM dbo.[User] u 
	WHERE u.LastActiveLT >= (SELECT w.StartDate
								FROM [Week] w 
								--WHERE DATEADD(dd,-7,@LT) BETWEEN w.StartDate AND w.EndDate)
								WHERE w.WeekID = CASE WHEN DATEADD(dd,-7,@LT) < (SELECT w.StartDate FROM dbo.Week w WHERE w.WeekNumber = 1) 
													  THEN (SELECT w.WeekID FROM dbo.Week w WHERE w.WeekNumber = 1)
													  ELSE (SELECT w.WeekID FROM dbo.Week w WHERE DATEADD(dd,-7,@LT) BETWEEN w.StartDate AND w.EndDate)
													  END)
								--DATEADD(dd,-7,GETUTCDATE())
	--SELECT @ActiveUserCount AS ActiveUserCount

	--Find count of reporting users
	SELECT @ReportingUserCount = COUNT(*) 
	FROM (SELECT DISTINCT us.UserID
			FROM [Week] w 
			JOIN dbo.UserSurvey us ON us.WeekID = w.WeekID
			WHERE @LT BETWEEN w.StartDate AND w.EndDate
			 OR DATEADD(dd,-7,@LT) BETWEEN w.StartDate AND w.EndDate
		 ) a
	--SELECT @ReportingUserCount AS ReportingUserCount

	SELECT @SmokeObsvCount = COUNT(*) 
	FROM (SELECT DISTINCT us.UserID
			FROM [Week] w
			JOIN dbo.UserSurvey us ON w.WeekID = us.WeekID
			WHERE (@LT BETWEEN w.StartDate AND w.EndDate
			   OR DATEADD(dd,-7,@LT) BETWEEN w.StartDate AND w.EndDate)
			  AND us.SurveyID = 1
		 ) a
	--SELECT @SmokeObsvCount AS SmokeObsvCount

	--Find count of all surveys submitted last week
	/*Part II. Calculate the following 10 (2 sets of 5) summary values:
    Percent of active users reporting symptoms: 
		For each of the 5 symptom categories last week, 
		number of users reported symptoms in a given category / number of active users 
    Percent of users reporting symptoms while experiencing smoke : 
		For each of the 5 symptom categories last week, 
		number of users reported symptoms in a given category AND experienced smoke / number of users experienced smoke*/

	SELECT sc.SymptomCategoryID, sc.Category, scc.ChoiceID, w.WeekID, w.StartDate, w.EndDate INTO #SymptomsWeeksChoices
	FROM dbo.SymptomCategory sc
	JOIN dbo.SymptomCategoryChoices scc ON sc.SymptomCategoryID = scc.SymptomCategoryID
	CROSS JOIN dbo.[Week] w
	WHERE (@LT BETWEEN w.StartDate AND w.EndDate
			   OR DATEADD(dd,-7,@LT) BETWEEN w.StartDate AND w.EndDate)

	SELECT b.SymptomCategoryID, b.Category, COUNT(b.UserID) UserCount INTO #SymptomsUsersAll
	FROM
	(SELECT DISTINCT swc.SymptomCategoryID, swc.Category, a.UserID
	FROM
	#SymptomsWeeksChoices swc
	LEFT JOIN 
		(SELECT us.UserID, us.SurveyID, us.WeekID, usa.ChoiceID
			FROM dbo.UserSurvey us
			JOIN dbo.UserSurveyAnswers usa ON us.UserSurveyID = usa.UserSurveyID
			WHERE us.SurveyID = 2
			  AND us.WeekID IN (SELECT DISTINCT WeekID FROM #SymptomsWeeksChoices)) a ON a.WeekID = swc.WeekID
																					  AND a.ChoiceID = swc.ChoiceID
	) b
	GROUP BY b.SymptomCategoryID, b.Category
	--SELECT * FROM #SymptomsUsersAll sua

	SELECT b.SymptomCategoryID, b.Category, COUNT(b.UserID) AS UserCount INTO #SymptomsUsersSmoke
	FROM
	(SELECT DISTINCT swc.SymptomCategoryID, swc.Category, a.UserID
	FROM #SymptomsWeeksChoices swc
	LEFT JOIN 
		(SELECT us.UserID, us.SurveyID, us.WeekID, usa.ChoiceID
			FROM dbo.UserSurvey us
			JOIN dbo.UserSurveyAnswers usa ON us.UserSurveyID = usa.UserSurveyID
			JOIN dbo.UserSurvey us2 ON us.UserID = us2.UserID
									AND us.WeekID = us2.WeekID
									AND us2.SurveyID = 1
			WHERE us.SurveyID = 2
			  AND us.WeekID IN (SELECT DISTINCT WeekID FROM #SymptomsWeeksChoices) ) a  ON swc.WeekID = a.WeekID
																						AND swc.ChoiceID = a.ChoiceID
	) b
	GROUP BY b.SymptomCategoryID, b.Category
	--SELECT * FROM #SymptomsUsersSmoke

	SELECT b.SymptomCategoryID, b.Category, COUNT(b.UserID) AS UserCount INTO #SymptomsUsersReporting
	FROM
	(SELECT DISTINCT swc.SymptomCategoryID, swc.Category, a.UserID
	FROM #SymptomsWeeksChoices swc
	LEFT JOIN 
		(SELECT us.UserID, us.SurveyID, us.WeekID, usa.ChoiceID
			FROM dbo.UserSurvey us
			JOIN dbo.UserSurveyAnswers usa ON us.UserSurveyID = usa.UserSurveyID
			JOIN dbo.UserSurvey us2 ON us.UserID = us2.UserID
									AND us.WeekID = us2.WeekID
									AND us2.SurveyID = us2.SurveyID
			WHERE us.SurveyID = 2
			  AND us.WeekID IN (SELECT DISTINCT WeekID FROM #SymptomsWeeksChoices)
			  AND us2.WeekID IN (SELECT DISTINCT WeekID FROM #SymptomsWeeksChoices) ) a  ON swc.WeekID = a.WeekID
																						AND swc.ChoiceID = a.ChoiceID
	) b
	GROUP BY b.SymptomCategoryID, b.Category
	--SELECT * FROM #SymptomsUsersReporting

	/*SELECT @AllUserCount AS AllUserCount,
		   @ActiveUserCount AS ActiveUserCount,
		   @ReportingUserCount AS ReportingUserCount,
		   @SmokeObsvCount AS SmokeObsvUserCount*/	

	SELECT MAX(Cardiovascular) AS CardiovasularPrct_ActiveUsers, 
		   MAX([Eyes and ears]) AS EyesAndEarsPrct_ActiveUsers, 
		   MAX([Upper respiratory]) AS UpperRespiratoryPrct_ActiveUsers, 
		   MAX(Respiratory) AS RespiratoryPrct_ActiveUsers, 
		   MAX(Other) AS OtherPrct_ActiveUsers
		   INTO #SymptomPercentsActiveUsers
	FROM
	(SELECT sua.SymptomCategoryID, sua.Category, 
		   sua.UserCount AS SymptomCountActiveUsers,
		   (CASE WHEN @ActiveUserCount=0 THEN 0 ELSE sua.UserCount*1.0/@ActiveUserCount*1.0 END)*100 AS SymptomPercentActiveUsers
	FROM #SymptomsUsersAll sua ) AS [DataTable]
	PIVOT
	(SUM(SymptomPercentActiveUsers) FOR Category IN ([Cardiovascular],
												   [Eyes and ears],
												   [Upper respiratory],
												   [Respiratory],
												   [Other] )
	) AS PivotTable
	--SELECT * FROM #SymptomPercentsActiveUsers spau

	SELECT MAX(Cardiovascular) AS CardiovasularPrct_UsersWSmokeObsv, 
		   MAX([Eyes and ears]) AS EyesAndEarsPrct_UsersWSmokeObsv, 
		   MAX([Upper respiratory]) AS UpperRespiratoryPrct_UsersWSmokeObsv, 
		   MAX(Respiratory) AS RespiratoryPrct_UsersWSmokeObsv, 
		   MAX(Other) AS OtherPrct_UsersWSmokeObsv
		   INTO #SymptomPercentsSmoke
	FROM
	(SELECT sus.SymptomCategoryID, sus.Category, 
		   sus.UserCount AS SymptomCountUsersWSmokeObsv,
		   (CASE WHEN @SmokeObsvCount = 0 THEN 0 ELSE sus.UserCount*1.0/@SmokeObsvCount*1.0 END)*100 AS SymptomPercentUsersWSmokeObsv
	FROM #SymptomsUsersSmoke sus ) AS [DataTable]
	PIVOT
	(SUM(SymptomPercentUsersWSmokeObsv) FOR Category IN ([Cardiovascular],
														 [Eyes and ears],
														 [Upper respiratory],
														 [Respiratory],
														 [Other] )
	) AS PivotTable
	--SELECT * FROM #SymptomPercentsSmoke sps

	SELECT MAX(Cardiovascular) AS CardiovasularPrct_UsersReporting, 
		   MAX([Eyes and ears]) AS EyesAndEarsPrct_UsersReporting, 
		   MAX([Upper respiratory]) AS UpperRespiratoryPrct_UsersReporting, 
		   MAX(Respiratory) AS RespiratoryPrct_UsersReporting, 
		   MAX(Other) AS OtherPrct_UsersReporting
		   INTO #SymptomsPercentsUsersReporting
	FROM
	(SELECT sus.SymptomCategoryID, sus.Category, 
		   sus.UserCount AS SymptomCountUsersReporting,
		   (CASE WHEN @ReportingUserCount = 0 THEN 0 ELSE sus.UserCount*1.0/@ReportingUserCount*1.0 END)*100 AS SymptomPercentUsersReporting
	FROM #SymptomsUsersReporting sus ) AS [DataTable]
	PIVOT
	(SUM(SymptomPercentUsersReporting) FOR Category IN ([Cardiovascular],
														 [Eyes and ears],
														 [Upper respiratory],
														 [Respiratory],
														 [Other] )
	) AS PivotTable
	--SELECT * FROM #SymptomsPercentsUsersReporting spr

	SELECT @AllUserCount AS AllUserCount,
		   @ActiveUserCount AS ActiveUserCount,
		   @ReportingUserCount AS ReportingUserCount,
		   @SmokeObsvCount AS SmokeObsvUserCount,

		   spau.CardiovasularPrct_ActiveUsers,
		   spau.EyesAndEarsPrct_ActiveUsers,
		   spau.UpperRespiratoryPrct_ActiveUsers,
		   spau.RespiratoryPrct_ActiveUsers,
		   spau.OtherPrct_ActiveUsers,

		   sps.CardiovasularPrct_UsersWSmokeObsv,
		   sps.EyesAndEarsPrct_UsersWSmokeObsv,
		   sps.UpperRespiratoryPrct_UsersWSmokeObsv,
		   sps.RespiratoryPrct_UsersWSmokeObsv,
		   sps.OtherPrct_UsersWSmokeObsv,

		   spr.CardiovasularPrct_UsersReporting,
		   spr.EyesAndEarsPrct_UsersReporting, 
		   spr.UpperRespiratoryPrct_UsersReporting, 
		   spr.RespiratoryPrct_UsersReporting, 
		   spr.OtherPrct_UsersReporting
	FROM #SymptomPercentsActiveUsers spau
	CROSS JOIN #SymptomPercentsSmoke sps
	CROSS JOIN #SymptomsPercentsUsersReporting spr


	DROP TABLE #SymptomsWeeksChoices
	DROP TABLE #SymptomsUsersAll
	DROP TABLE #SymptomsUsersSmoke
	DROP TABLE #SymptomPercentsActiveUsers
	DROP TABLE #SymptomPercentsSmoke
	DROP TABLE #SymptomsPercentsUsersReporting

END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[Week_Insert]'
GO
-- =============================================
-- Author:		Angela Ekstrand
-- Create date: 2016-10-18
-- Description:	Inserts a new Week for the study
-- =============================================
CREATE PROCEDURE [dbo].[Week_Insert]
(
	@StartDate	smalldatetime,
	@EndDate	smalldatetime
)
AS
BEGIN
	
	SET NOCOUNT ON;

    INSERT INTO dbo.[Week] ( /*WeekID*/ StartDate, EndDate )
    SELECT DATEADD(hh,-DATEPART(hh,@StartDate),DATEADD(mi,-DATEPART(mi,@StartDate),@StartDate)) AS StartDate, 
			DATEADD(hh,23,DATEADD(mi,59,DATEADD(hh,-DATEPART(hh,@EndDate),DATEADD(mi,-DATEPART(mi,@EndDate),@EndDate)))) AS EndDate

	SELECT @@IDENTITY AS WeekID

END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[User_Delete]'
GO
-- =============================================
-- Author:		Angela Ekstrand
-- Create date: 2016-10-18
-- Description:	Deletes a user (inactive)
-- =============================================
CREATE PROCEDURE [dbo].[User_Delete]
AS
BEGIN
	
	SET NOCOUNT ON;

    --This procedure doesn't do anything; we don't delete users.

END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[Week_Delete]'
GO
-- =============================================
-- Author:		Angela Ekstrand
-- Create date: 2016-10-18
-- Description:	Deletes a week, but we don't want to do this, really, ever.
-- =============================================
CREATE PROCEDURE [dbo].[Week_Delete]
(
	@WeekID		smallint
)
AS
BEGIN
	
	SET NOCOUNT ON;

    --this does nothing; we don't delete weeks unless done manually and intentionally

END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
COMMIT TRANSACTION
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
-- This statement writes to the SQL Server Log so SQL Monitor can show this deployment.
IF HAS_PERMS_BY_NAME(N'sys.xp_logevent', N'OBJECT', N'EXECUTE') = 1
BEGIN
    DECLARE @databaseName AS nvarchar(2048), @eventMessage AS nvarchar(2048)
    SET @databaseName = REPLACE(REPLACE(DB_NAME(), N'\', N'\\'), N'"', N'\"')
    SET @eventMessage = N'Redgate SQL Compare: { "deployment": { "description": "Redgate SQL Compare deployed to ' + @databaseName + N'", "database": "' + @databaseName + N'" }}'
    EXECUTE sys.xp_logevent 55000, @eventMessage
END
GO
DECLARE @Success AS BIT
SET @Success = 1
SET NOEXEC OFF
IF (@Success = 1) PRINT 'The database update succeeded'
ELSE BEGIN
	IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	PRINT 'The database update failed'
END
GO
