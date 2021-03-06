/*

You are recommended to back up your database before running this script

Script created by SQL Compare version 14.2.9.15508 from Red Gate Software Ltd at 6/29/2020 6:32:44 PM

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
PRINT N'Creating [dbo].[Questions]'
GO
CREATE TABLE [dbo].[Questions]
(
[QuestionID] [smallint] NOT NULL IDENTITY(1, 1),
[QuestionEnglishDefault] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MultiChoice] [bit] NOT NULL,
[CorrectAnswer] [bit] NOT NULL,
[SurveyID] [smallint] NOT NULL,
[Sequence] [smallint] NULL,
[AnswerEnglishDefault] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Questions_Answer] DEFAULT (N''),
[Slider] [bit] NOT NULL CONSTRAINT [DF__Questions__Slide__345EC57D] DEFAULT ((0)),
[Summary] [bit] NOT NULL CONSTRAINT [DF__Questions__Summa__52E34C9D] DEFAULT ((0))
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating primary key [PK_Questions] on [dbo].[Questions]'
GO
ALTER TABLE [dbo].[Questions] ADD CONSTRAINT [PK_Questions] PRIMARY KEY CLUSTERED  ([QuestionID])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[QuestionVersion]'
GO
CREATE TABLE [dbo].[QuestionVersion]
(
[QuestionID] [smallint] NOT NULL,
[VersionNumber] [smallint] NOT NULL
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[UserSurveyAnswers]'
GO
CREATE TABLE [dbo].[UserSurveyAnswers]
(
[UserSurveyAnswerID] [int] NOT NULL IDENTITY(1, 1),
[UserSurveyID] [int] NOT NULL,
[ChoiceID] [int] NOT NULL,
[QuestionID] [smallint] NOT NULL
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating primary key [PK_UserSurveyAnswers] on [dbo].[UserSurveyAnswers]'
GO
ALTER TABLE [dbo].[UserSurveyAnswers] ADD CONSTRAINT [PK_UserSurveyAnswers] PRIMARY KEY CLUSTERED  ([UserSurveyAnswerID])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[UserSurveyFreeResponse]'
GO
CREATE TABLE [dbo].[UserSurveyFreeResponse]
(
[UserSurveyAnswerID] [int] NOT NULL,
[FreeResponse] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[Badge]'
GO
CREATE TABLE [dbo].[Badge]
(
[BadgeID] [tinyint] NOT NULL,
[BadgeEnglishDefault] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DescriptionEnglishDefault] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Method] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sequence] [tinyint] NULL,
[ImageName] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BadgeColor] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MaxShown] [tinyint] NULL,
[Enabled] [bit] NULL
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating primary key [PK_Badge] on [dbo].[Badge]'
GO
ALTER TABLE [dbo].[Badge] ADD CONSTRAINT [PK_Badge] PRIMARY KEY CLUSTERED  ([BadgeID])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[BadgeSurveyType]'
GO
CREATE TABLE [dbo].[BadgeSurveyType]
(
[BadgeID] [tinyint] NOT NULL,
[SurveyTypeID] [tinyint] NOT NULL
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[SurveyType]'
GO
CREATE TABLE [dbo].[SurveyType]
(
[TypeID] [tinyint] NOT NULL IDENTITY(1, 1),
[TypeEnglishDefault] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Timeframe] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating primary key [PK_SurveyType] on [dbo].[SurveyType]'
GO
ALTER TABLE [dbo].[SurveyType] ADD CONSTRAINT [PK_SurveyType] PRIMARY KEY CLUSTERED  ([TypeID])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[BadgeTranslations]'
GO
CREATE TABLE [dbo].[BadgeTranslations]
(
[BadgeID] [tinyint] NULL,
[LanguageID] [tinyint] NULL,
[Badge] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[Languages]'
GO
CREATE TABLE [dbo].[Languages]
(
[LanguageID] [tinyint] NOT NULL IDENTITY(1, 1),
[ISO639_Code] [nchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ISO639-2B_Code] [nchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating primary key [PK_Languages] on [dbo].[Languages]'
GO
ALTER TABLE [dbo].[Languages] ADD CONSTRAINT [PK_Languages] PRIMARY KEY CLUSTERED  ([LanguageID])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[BadgeWeek]'
GO
CREATE TABLE [dbo].[BadgeWeek]
(
[BadgeID] [tinyint] NOT NULL,
[WeekID] [smallint] NOT NULL
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[Week]'
GO
CREATE TABLE [dbo].[Week]
(
[WeekID] [smallint] NOT NULL IDENTITY(1, 1),
[StartDate] [smalldatetime] NULL,
[EndDate] [smalldatetime] NULL,
[WeekNumber] [smallint] NULL
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating primary key [PK_Week] on [dbo].[Week]'
GO
ALTER TABLE [dbo].[Week] ADD CONSTRAINT [PK_Week] PRIMARY KEY CLUSTERED  ([WeekID])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[Choices]'
GO
CREATE TABLE [dbo].[Choices]
(
[ChoiceID] [int] NOT NULL IDENTITY(1, 1),
[ChoiceEnglishDefault] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QuestionID] [smallint] NOT NULL,
[Sequence] [smallint] NULL,
[FreeResponse] [bit] NOT NULL CONSTRAINT [DF__Choices__FreeRes__336AA144] DEFAULT ((0)),
[Calendar] [bit] NOT NULL CONSTRAINT [DF__Choices__Calenda__3FD07829] DEFAULT ((0))
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating primary key [PK_Choices] on [dbo].[Choices]'
GO
ALTER TABLE [dbo].[Choices] ADD CONSTRAINT [PK_Choices] PRIMARY KEY CLUSTERED  ([ChoiceID])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[SymptomCategoryChoices]'
GO
CREATE TABLE [dbo].[SymptomCategoryChoices]
(
[SymptomCategoryID] [tinyint] NULL,
[ChoiceID] [int] NULL
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[ChoicesKey]'
GO
CREATE TABLE [dbo].[ChoicesKey]
(
[ChoiceID] [int] NOT NULL,
[Correct] [bit] NOT NULL CONSTRAINT [DF_ChoicesKey_Correct] DEFAULT ((1))
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[ChoicesTranslations]'
GO
CREATE TABLE [dbo].[ChoicesTranslations]
(
[ChoiceID] [int] NULL,
[LanguageID] [tinyint] NULL,
[Choice] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[Survey]'
GO
CREATE TABLE [dbo].[Survey]
(
[SurveyID] [smallint] NOT NULL IDENTITY(1, 1),
[SurveyEnglishDefault] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TypeID] [tinyint] NOT NULL,
[Image] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Calendar] [bit] NULL CONSTRAINT [DF_Survey_Calendar] DEFAULT ((0)),
[IsYesNo] [bit] NULL
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating primary key [PK_Survey] on [dbo].[Survey]'
GO
ALTER TABLE [dbo].[Survey] ADD CONSTRAINT [PK_Survey] PRIMARY KEY CLUSTERED  ([SurveyID])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[QuestionsTranslations]'
GO
CREATE TABLE [dbo].[QuestionsTranslations]
(
[QuestionID] [smallint] NULL,
[LanguageID] [tinyint] NULL,
[Question] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Answer] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[SurveyTranslations]'
GO
CREATE TABLE [dbo].[SurveyTranslations]
(
[SurveyID] [smallint] NULL,
[LanguageID] [tinyint] NULL,
[Survey] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[SurveyTypeTranslations]'
GO
CREATE TABLE [dbo].[SurveyTypeTranslations]
(
[SurveyTypeID] [tinyint] NULL,
[LanguageID] [tinyint] NULL,
[Type] [nvarchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[SurveyWeek]'
GO
CREATE TABLE [dbo].[SurveyWeek]
(
[SurveyID] [smallint] NOT NULL,
[WeekID] [smallint] NOT NULL
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[SymptomCategory]'
GO
CREATE TABLE [dbo].[SymptomCategory]
(
[SymptomCategoryID] [tinyint] NOT NULL IDENTITY(1, 1),
[Category] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating primary key [PK_SymptomCategory] on [dbo].[SymptomCategory]'
GO
ALTER TABLE [dbo].[SymptomCategory] ADD CONSTRAINT [PK_SymptomCategory] PRIMARY KEY CLUSTERED  ([SymptomCategoryID])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[SymptomCategoryTranslations]'
GO
CREATE TABLE [dbo].[SymptomCategoryTranslations]
(
[SymptomCategoryID] [tinyint] NULL,
[LanguageID] [tinyint] NULL,
[Category] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[UserBadge]'
GO
CREATE TABLE [dbo].[UserBadge]
(
[UserBadgeID] [int] NOT NULL IDENTITY(1, 1),
[UserID] [int] NOT NULL,
[BadgeID] [tinyint] NOT NULL,
[WeekID] [smallint] NOT NULL
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating primary key [PK_UserBadge] on [dbo].[UserBadge]'
GO
ALTER TABLE [dbo].[UserBadge] ADD CONSTRAINT [PK_UserBadge] PRIMARY KEY CLUSTERED  ([UserBadgeID])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[User]'
GO
CREATE TABLE [dbo].[User]
(
[UserID] [int] NOT NULL IDENTITY(1, 1),
[GUID] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ZipCode] [nchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Nickname] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastActiveLT] [smalldatetime] NOT NULL CONSTRAINT [DF_User_LastActiveUTC] DEFAULT (getutcdate()),
[CreatedLT] [smalldatetime] NOT NULL CONSTRAINT [DF_User_CreatedUTC] DEFAULT (getdate())
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating primary key [PK_User] on [dbo].[User]'
GO
ALTER TABLE [dbo].[User] ADD CONSTRAINT [PK_User] PRIMARY KEY CLUSTERED  ([UserID])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[UserChangeLog]'
GO
CREATE TABLE [dbo].[UserChangeLog]
(
[UserID] [int] NOT NULL,
[OldZipCode] [nchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NewZipCode] [nchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UserLocalTime] [smalldatetime] NOT NULL
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[UserSurvey]'
GO
CREATE TABLE [dbo].[UserSurvey]
(
[UserSurveyID] [int] NOT NULL IDENTITY(1, 1),
[UserID] [int] NOT NULL,
[SurveyID] [smallint] NOT NULL,
[WeekID] [smallint] NOT NULL,
[VersionNumber] [smallint] NULL
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating primary key [PK_UserSurvey] on [dbo].[UserSurvey]'
GO
ALTER TABLE [dbo].[UserSurvey] ADD CONSTRAINT [PK_UserSurvey] PRIMARY KEY CLUSTERED  ([UserSurveyID])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[UserSurveyDate]'
GO
CREATE TABLE [dbo].[UserSurveyDate]
(
[UserSurveyID] [int] NOT NULL,
[Date] [date] NOT NULL
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[UserSurveyOrder]'
GO
CREATE TABLE [dbo].[UserSurveyOrder]
(
[UserID] [int] NOT NULL,
[SurveyID] [smallint] NOT NULL,
[VersionNumber] [smallint] NOT NULL,
[Sequence] [int] NOT NULL,
[Completed] [bit] NOT NULL CONSTRAINT [DF__UserSurve__Compl__4C364F0E] DEFAULT ((0))
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[UserSurveyZipCode]'
GO
CREATE TABLE [dbo].[UserSurveyZipCode]
(
[UserSurveyID] [int] NOT NULL,
[ZipCode] [nchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Submitted] [bit] NOT NULL CONSTRAINT [DF__UserSurve__Submi__318258D2] DEFAULT ((0))
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[WCIDContentTranslations]'
GO
CREATE TABLE [dbo].[WCIDContentTranslations]
(
[ContentID] [int] NULL,
[LanguageID] [tinyint] NULL,
[Text] [nvarchar] (max) COLLATE Latin1_General_100_CI_AS_SC NULL,
[linkText] [nvarchar] (max) COLLATE Latin1_General_100_CI_AS_SC NULL,
[linkURL] [nvarchar] (max) COLLATE Latin1_General_100_CI_AS_SC NULL
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding constraints to [dbo].[WCIDContentTranslations]'
GO
ALTER TABLE [dbo].[WCIDContentTranslations] ADD CONSTRAINT [IX_WCIDContentTranslations] UNIQUE NONCLUSTERED  ([ContentID], [LanguageID])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[WCIDContent]'
GO
CREATE TABLE [dbo].[WCIDContent]
(
[ContentID] [int] NOT NULL IDENTITY(1, 1),
[Type] [nvarchar] (50) COLLATE Latin1_General_100_CI_AS_SC NULL,
[TextEnglishDefault] [nvarchar] (max) COLLATE Latin1_General_100_CI_AS_SC NULL,
[Sequence] [int] NULL
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating primary key [PK_WCIDContentNew] on [dbo].[WCIDContent]'
GO
ALTER TABLE [dbo].[WCIDContent] ADD CONSTRAINT [PK_WCIDContentNew] PRIMARY KEY CLUSTERED  ([ContentID])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[ZipCode]'
GO
CREATE TABLE [dbo].[ZipCode]
(
[ZipCode] [nchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Latitude] [numeric] (15, 4) NOT NULL,
[Longitude] [numeric] (15, 4) NOT NULL
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating primary key [PK_ZipCode_LatLon] on [dbo].[ZipCode]'
GO
ALTER TABLE [dbo].[ZipCode] ADD CONSTRAINT [PK_ZipCode_LatLon] PRIMARY KEY CLUSTERED  ([ZipCode])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[BadgeSurveyType]'
GO
ALTER TABLE [dbo].[BadgeSurveyType] ADD CONSTRAINT [FK_BadgeSurveyType_Badge] FOREIGN KEY ([BadgeID]) REFERENCES [dbo].[Badge] ([BadgeID])
GO
ALTER TABLE [dbo].[BadgeSurveyType] ADD CONSTRAINT [FK_BadgeSurveyType_SurveyType] FOREIGN KEY ([SurveyTypeID]) REFERENCES [dbo].[SurveyType] ([TypeID])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[BadgeTranslations]'
GO
ALTER TABLE [dbo].[BadgeTranslations] ADD CONSTRAINT [FK_BadgeTranslations_Badge] FOREIGN KEY ([BadgeID]) REFERENCES [dbo].[Badge] ([BadgeID])
GO
ALTER TABLE [dbo].[BadgeTranslations] ADD CONSTRAINT [FK_BadgeTranslations_Languages] FOREIGN KEY ([LanguageID]) REFERENCES [dbo].[Languages] ([LanguageID])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[BadgeWeek]'
GO
ALTER TABLE [dbo].[BadgeWeek] ADD CONSTRAINT [FK_BadgeWeek_Badge] FOREIGN KEY ([BadgeID]) REFERENCES [dbo].[Badge] ([BadgeID])
GO
ALTER TABLE [dbo].[BadgeWeek] ADD CONSTRAINT [FK_BadgeWeek_Week] FOREIGN KEY ([WeekID]) REFERENCES [dbo].[Week] ([WeekID])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[UserBadge]'
GO
ALTER TABLE [dbo].[UserBadge] ADD CONSTRAINT [FK_UserBadge_Badge] FOREIGN KEY ([BadgeID]) REFERENCES [dbo].[Badge] ([BadgeID])
GO
ALTER TABLE [dbo].[UserBadge] ADD CONSTRAINT [FK_UserBadge_User] FOREIGN KEY ([UserID]) REFERENCES [dbo].[User] ([UserID])
GO
ALTER TABLE [dbo].[UserBadge] ADD CONSTRAINT [FK_UserBadge_Week] FOREIGN KEY ([WeekID]) REFERENCES [dbo].[Week] ([WeekID])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[ChoicesKey]'
GO
ALTER TABLE [dbo].[ChoicesKey] ADD CONSTRAINT [FK_ChoicesKey_QuestionsChoices] FOREIGN KEY ([ChoiceID]) REFERENCES [dbo].[Choices] ([ChoiceID])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[ChoicesTranslations]'
GO
ALTER TABLE [dbo].[ChoicesTranslations] ADD CONSTRAINT [FK_ChoicesTranslations_Choices] FOREIGN KEY ([ChoiceID]) REFERENCES [dbo].[Choices] ([ChoiceID])
GO
ALTER TABLE [dbo].[ChoicesTranslations] ADD CONSTRAINT [FK_ChoicesTranslations_Languages] FOREIGN KEY ([LanguageID]) REFERENCES [dbo].[Languages] ([LanguageID])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[Choices]'
GO
ALTER TABLE [dbo].[Choices] ADD CONSTRAINT [FK_Choices_Choices] FOREIGN KEY ([ChoiceID]) REFERENCES [dbo].[Choices] ([ChoiceID])
GO
ALTER TABLE [dbo].[Choices] ADD CONSTRAINT [FK_Choices_Questions] FOREIGN KEY ([QuestionID]) REFERENCES [dbo].[Questions] ([QuestionID])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[SymptomCategoryChoices]'
GO
ALTER TABLE [dbo].[SymptomCategoryChoices] ADD CONSTRAINT [FK_Choices_SymptomCategory] FOREIGN KEY ([ChoiceID]) REFERENCES [dbo].[Choices] ([ChoiceID])
GO
ALTER TABLE [dbo].[SymptomCategoryChoices] ADD CONSTRAINT [FK_SymptomCategoryChoices_SymptomCategory] FOREIGN KEY ([SymptomCategoryID]) REFERENCES [dbo].[SymptomCategory] ([SymptomCategoryID])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[UserSurveyAnswers]'
GO
ALTER TABLE [dbo].[UserSurveyAnswers] ADD CONSTRAINT [FK_UserSurveyAnswers_Choices] FOREIGN KEY ([ChoiceID]) REFERENCES [dbo].[Choices] ([ChoiceID])
GO
ALTER TABLE [dbo].[UserSurveyAnswers] ADD CONSTRAINT [FK_UserSurveyAnswers_Questions] FOREIGN KEY ([QuestionID]) REFERENCES [dbo].[Questions] ([QuestionID])
GO
ALTER TABLE [dbo].[UserSurveyAnswers] ADD CONSTRAINT [FK_UserSurveyAnswers_UserSurvey] FOREIGN KEY ([UserSurveyID]) REFERENCES [dbo].[UserSurvey] ([UserSurveyID])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[QuestionsTranslations]'
GO
ALTER TABLE [dbo].[QuestionsTranslations] ADD CONSTRAINT [FK_QuestionsTranslations_Languages] FOREIGN KEY ([LanguageID]) REFERENCES [dbo].[Languages] ([LanguageID])
GO
ALTER TABLE [dbo].[QuestionsTranslations] ADD CONSTRAINT [FK_QuestionsTranslations_Questions] FOREIGN KEY ([QuestionID]) REFERENCES [dbo].[Questions] ([QuestionID])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[SurveyTranslations]'
GO
ALTER TABLE [dbo].[SurveyTranslations] ADD CONSTRAINT [FK_SurveyTranslations_Languages] FOREIGN KEY ([LanguageID]) REFERENCES [dbo].[Languages] ([LanguageID])
GO
ALTER TABLE [dbo].[SurveyTranslations] ADD CONSTRAINT [FK_SurveyTranslations_Survey] FOREIGN KEY ([SurveyID]) REFERENCES [dbo].[Survey] ([SurveyID])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[SurveyTypeTranslations]'
GO
ALTER TABLE [dbo].[SurveyTypeTranslations] ADD CONSTRAINT [FK_SurveyTypeTranslations_Languages] FOREIGN KEY ([LanguageID]) REFERENCES [dbo].[Languages] ([LanguageID])
GO
ALTER TABLE [dbo].[SurveyTypeTranslations] ADD CONSTRAINT [FK_SurveyTypeTranslations_SurveyType] FOREIGN KEY ([SurveyTypeID]) REFERENCES [dbo].[SurveyType] ([TypeID])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[SymptomCategoryTranslations]'
GO
ALTER TABLE [dbo].[SymptomCategoryTranslations] ADD CONSTRAINT [FK_SymptomCategoryTranslations_Languages] FOREIGN KEY ([LanguageID]) REFERENCES [dbo].[Languages] ([LanguageID])
GO
ALTER TABLE [dbo].[SymptomCategoryTranslations] ADD CONSTRAINT [FK_SymptomCategoryTranslations_Question] FOREIGN KEY ([SymptomCategoryID]) REFERENCES [dbo].[SymptomCategory] ([SymptomCategoryID])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[WCIDContentTranslations]'
GO
ALTER TABLE [dbo].[WCIDContentTranslations] ADD CONSTRAINT [FK_WCIDContentTranslations_Languages] FOREIGN KEY ([LanguageID]) REFERENCES [dbo].[Languages] ([LanguageID])
GO
ALTER TABLE [dbo].[WCIDContentTranslations] ADD CONSTRAINT [FK_WCIDContentTranslations_WCIDContent] FOREIGN KEY ([ContentID]) REFERENCES [dbo].[WCIDContent] ([ContentID])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[QuestionVersion]'
GO
ALTER TABLE [dbo].[QuestionVersion] ADD CONSTRAINT [FK__QuestionV__Quest__1A9EF37A] FOREIGN KEY ([QuestionID]) REFERENCES [dbo].[Questions] ([QuestionID])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[Questions]'
GO
ALTER TABLE [dbo].[Questions] ADD CONSTRAINT [FK_Questions_Survey] FOREIGN KEY ([SurveyID]) REFERENCES [dbo].[Survey] ([SurveyID])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[Survey]'
GO
ALTER TABLE [dbo].[Survey] ADD CONSTRAINT [FK_Survey_SurveyType] FOREIGN KEY ([TypeID]) REFERENCES [dbo].[SurveyType] ([TypeID])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[SurveyWeek]'
GO
ALTER TABLE [dbo].[SurveyWeek] ADD CONSTRAINT [FK_SurveyWeek_Survey] FOREIGN KEY ([SurveyID]) REFERENCES [dbo].[Survey] ([SurveyID])
GO
ALTER TABLE [dbo].[SurveyWeek] ADD CONSTRAINT [FK_SurveyWeek_Week] FOREIGN KEY ([WeekID]) REFERENCES [dbo].[Week] ([WeekID])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[UserSurvey]'
GO
ALTER TABLE [dbo].[UserSurvey] ADD CONSTRAINT [FK_UserSurvey_Survey] FOREIGN KEY ([SurveyID]) REFERENCES [dbo].[Survey] ([SurveyID])
GO
ALTER TABLE [dbo].[UserSurvey] ADD CONSTRAINT [FK_UserSurvey_User] FOREIGN KEY ([UserID]) REFERENCES [dbo].[User] ([UserID])
GO
ALTER TABLE [dbo].[UserSurvey] ADD CONSTRAINT [FK_UserSurvey_Week] FOREIGN KEY ([WeekID]) REFERENCES [dbo].[Week] ([WeekID])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[UserSurveyOrder]'
GO
ALTER TABLE [dbo].[UserSurveyOrder] ADD CONSTRAINT [FK_UserSurveyOrder_Survey] FOREIGN KEY ([SurveyID]) REFERENCES [dbo].[Survey] ([SurveyID])
GO
ALTER TABLE [dbo].[UserSurveyOrder] ADD CONSTRAINT [FK_UserSurveyOrder_User] FOREIGN KEY ([UserID]) REFERENCES [dbo].[User] ([UserID])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[UserChangeLog]'
GO
ALTER TABLE [dbo].[UserChangeLog] ADD CONSTRAINT [FK_UserChangeLog_User] FOREIGN KEY ([UserID]) REFERENCES [dbo].[User] ([UserID])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[UserSurveyFreeResponse]'
GO
ALTER TABLE [dbo].[UserSurveyFreeResponse] ADD CONSTRAINT [FK__UserSurve__UserS__3B0BC30C] FOREIGN KEY ([UserSurveyAnswerID]) REFERENCES [dbo].[UserSurveyAnswers] ([UserSurveyAnswerID])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[UserSurveyDate]'
GO
ALTER TABLE [dbo].[UserSurveyDate] ADD CONSTRAINT [FK_UserSurveyDate_UserSurvey] FOREIGN KEY ([UserSurveyID]) REFERENCES [dbo].[UserSurvey] ([UserSurveyID])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Adding foreign keys to [dbo].[UserSurveyZipCode]'
GO
ALTER TABLE [dbo].[UserSurveyZipCode] ADD CONSTRAINT [FK_UserSurveyZipCode_UserSurvey] FOREIGN KEY ([UserSurveyID]) REFERENCES [dbo].[UserSurvey] ([UserSurveyID])
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating extended properties'
GO
BEGIN TRY
	EXEC sp_addextendedproperty N'MS_Description', N'Links UserBadge table to the BadgeID record in the Badge table', 'SCHEMA', N'dbo', 'TABLE', N'UserBadge', 'CONSTRAINT', N'FK_UserBadge_Badge'
END TRY
BEGIN CATCH
	DECLARE @msg nvarchar(max);
	DECLARE @severity int;
	DECLARE @state int;
	SELECT @msg = ERROR_MESSAGE(), @severity = ERROR_SEVERITY(), @state = ERROR_STATE();
	RAISERROR(@msg, @severity, @state);

	SET NOEXEC ON
END CATCH
GO
BEGIN TRY
	EXEC sp_addextendedproperty N'MS_Description', N'This table will update any time a user changes their zip code, to ensure we capture if their observations were input for more than one location.', 'SCHEMA', N'dbo', 'TABLE', N'UserChangeLog', NULL, NULL
END TRY
BEGIN CATCH
	DECLARE @msg nvarchar(max);
	DECLARE @severity int;
	DECLARE @state int;
	SELECT @msg = ERROR_MESSAGE(), @severity = ERROR_SEVERITY(), @state = ERROR_STATE();
	RAISERROR(@msg, @severity, @state);

	SET NOEXEC ON
END CATCH
GO
BEGIN TRY
	EXEC sp_addextendedproperty N'MS_Description', N'Newly updated zip code', 'SCHEMA', N'dbo', 'TABLE', N'UserChangeLog', 'COLUMN', N'NewZipCode'
END TRY
BEGIN CATCH
	DECLARE @msg nvarchar(max);
	DECLARE @severity int;
	DECLARE @state int;
	SELECT @msg = ERROR_MESSAGE(), @severity = ERROR_SEVERITY(), @state = ERROR_STATE();
	RAISERROR(@msg, @severity, @state);

	SET NOEXEC ON
END CATCH
GO
BEGIN TRY
	EXEC sp_addextendedproperty N'MS_Description', N'Previously used zip code', 'SCHEMA', N'dbo', 'TABLE', N'UserChangeLog', 'COLUMN', N'OldZipCode'
END TRY
BEGIN CATCH
	DECLARE @msg nvarchar(max);
	DECLARE @severity int;
	DECLARE @state int;
	SELECT @msg = ERROR_MESSAGE(), @severity = ERROR_SEVERITY(), @state = ERROR_STATE();
	RAISERROR(@msg, @severity, @state);

	SET NOEXEC ON
END CATCH
GO
BEGIN TRY
	EXEC sp_addextendedproperty N'MS_Description', N'Identifies user', 'SCHEMA', N'dbo', 'TABLE', N'UserChangeLog', 'COLUMN', N'UserID'
END TRY
BEGIN CATCH
	DECLARE @msg nvarchar(max);
	DECLARE @severity int;
	DECLARE @state int;
	SELECT @msg = ERROR_MESSAGE(), @severity = ERROR_SEVERITY(), @state = ERROR_STATE();
	RAISERROR(@msg, @severity, @state);

	SET NOEXEC ON
END CATCH
GO
BEGIN TRY
	EXEC sp_addextendedproperty N'MS_Description', N'The local time the change was made in the user''s time zone', 'SCHEMA', N'dbo', 'TABLE', N'UserChangeLog', 'COLUMN', N'UserLocalTime'
END TRY
BEGIN CATCH
	DECLARE @msg nvarchar(max);
	DECLARE @severity int;
	DECLARE @state int;
	SELECT @msg = ERROR_MESSAGE(), @severity = ERROR_SEVERITY(), @state = ERROR_STATE();
	RAISERROR(@msg, @severity, @state);

	SET NOEXEC ON
END CATCH
GO
BEGIN TRY
	EXEC sp_addextendedproperty N'MS_Description', N'This table stores basic user information.', 'SCHEMA', N'dbo', 'TABLE', N'User', NULL, NULL
END TRY
BEGIN CATCH
	DECLARE @msg nvarchar(max);
	DECLARE @severity int;
	DECLARE @state int;
	SELECT @msg = ERROR_MESSAGE(), @severity = ERROR_SEVERITY(), @state = ERROR_STATE();
	RAISERROR(@msg, @severity, @state);

	SET NOEXEC ON
END CATCH
GO
BEGIN TRY
	EXEC sp_addextendedproperty N'MS_Description', N'Unique key specific to the user''s device', 'SCHEMA', N'dbo', 'TABLE', N'User', 'COLUMN', N'GUID'
END TRY
BEGIN CATCH
	DECLARE @msg nvarchar(max);
	DECLARE @severity int;
	DECLARE @state int;
	SELECT @msg = ERROR_MESSAGE(), @severity = ERROR_SEVERITY(), @state = ERROR_STATE();
	RAISERROR(@msg, @severity, @state);

	SET NOEXEC ON
END CATCH
GO
BEGIN TRY
	EXEC sp_addextendedproperty N'MS_Description', N'Any time the user opens the app, this updates; always stored in user''s local time', 'SCHEMA', N'dbo', 'TABLE', N'User', 'COLUMN', N'LastActiveLT'
END TRY
BEGIN CATCH
	DECLARE @msg nvarchar(max);
	DECLARE @severity int;
	DECLARE @state int;
	SELECT @msg = ERROR_MESSAGE(), @severity = ERROR_SEVERITY(), @state = ERROR_STATE();
	RAISERROR(@msg, @severity, @state);

	SET NOEXEC ON
END CATCH
GO
BEGIN TRY
	EXEC sp_addextendedproperty N'MS_Description', N'No longer populated, but was a placeholder for a nickname the user could choose to enter', 'SCHEMA', N'dbo', 'TABLE', N'User', 'COLUMN', N'Nickname'
END TRY
BEGIN CATCH
	DECLARE @msg nvarchar(max);
	DECLARE @severity int;
	DECLARE @state int;
	SELECT @msg = ERROR_MESSAGE(), @severity = ERROR_SEVERITY(), @state = ERROR_STATE();
	RAISERROR(@msg, @severity, @state);

	SET NOEXEC ON
END CATCH
GO
BEGIN TRY
	EXEC sp_addextendedproperty N'MS_Description', N'Arbitrary auto-incrementing ID for each user record', 'SCHEMA', N'dbo', 'TABLE', N'User', 'COLUMN', N'UserID'
END TRY
BEGIN CATCH
	DECLARE @msg nvarchar(max);
	DECLARE @severity int;
	DECLARE @state int;
	SELECT @msg = ERROR_MESSAGE(), @severity = ERROR_SEVERITY(), @state = ERROR_STATE();
	RAISERROR(@msg, @severity, @state);

	SET NOEXEC ON
END CATCH
GO
BEGIN TRY
	EXEC sp_addextendedproperty N'MS_Description', N'User input zip code', 'SCHEMA', N'dbo', 'TABLE', N'User', 'COLUMN', N'ZipCode'
END TRY
BEGIN CATCH
	DECLARE @msg nvarchar(max);
	DECLARE @severity int;
	DECLARE @state int;
	SELECT @msg = ERROR_MESSAGE(), @severity = ERROR_SEVERITY(), @state = ERROR_STATE();
	RAISERROR(@msg, @severity, @state);

	SET NOEXEC ON
END CATCH
GO
BEGIN TRY
	EXEC sp_addextendedproperty N'MS_Description', N'This table tracks the weeks in the study. A procedure in the database populates this table automatically to begin at a certain date, and auto-creates the records for all the following weeks. ', 'SCHEMA', N'dbo', 'TABLE', N'Week', NULL, NULL
END TRY
BEGIN CATCH
	DECLARE @msg nvarchar(max);
	DECLARE @severity int;
	DECLARE @state int;
	SELECT @msg = ERROR_MESSAGE(), @severity = ERROR_SEVERITY(), @state = ERROR_STATE();
	RAISERROR(@msg, @severity, @state);

	SET NOEXEC ON
END CATCH
GO
BEGIN TRY
	EXEC sp_addextendedproperty N'MS_Description', N'End date of week; always 1:59 pm in user''s local time zone', 'SCHEMA', N'dbo', 'TABLE', N'Week', 'COLUMN', N'EndDate'
END TRY
BEGIN CATCH
	DECLARE @msg nvarchar(max);
	DECLARE @severity int;
	DECLARE @state int;
	SELECT @msg = ERROR_MESSAGE(), @severity = ERROR_SEVERITY(), @state = ERROR_STATE();
	RAISERROR(@msg, @severity, @state);

	SET NOEXEC ON
END CATCH
GO
BEGIN TRY
	EXEC sp_addextendedproperty N'MS_Description', N'Start date of week; always 2 pm in user''s local time zone', 'SCHEMA', N'dbo', 'TABLE', N'Week', 'COLUMN', N'StartDate'
END TRY
BEGIN CATCH
	DECLARE @msg nvarchar(max);
	DECLARE @severity int;
	DECLARE @state int;
	SELECT @msg = ERROR_MESSAGE(), @severity = ERROR_SEVERITY(), @state = ERROR_STATE();
	RAISERROR(@msg, @severity, @state);

	SET NOEXEC ON
END CATCH
GO
BEGIN TRY
	EXEC sp_addextendedproperty N'MS_Description', N'Auto incrementing ID to for each week record', 'SCHEMA', N'dbo', 'TABLE', N'Week', 'COLUMN', N'WeekID'
END TRY
BEGIN CATCH
	DECLARE @msg nvarchar(max);
	DECLARE @severity int;
	DECLARE @state int;
	SELECT @msg = ERROR_MESSAGE(), @severity = ERROR_SEVERITY(), @state = ERROR_STATE();
	RAISERROR(@msg, @severity, @state);

	SET NOEXEC ON
END CATCH
GO
BEGIN TRY
	EXEC sp_addextendedproperty N'MS_Description', N'Weeks numbered in the intended order (week 1 is actually week 1 of the study, etc)', 'SCHEMA', N'dbo', 'TABLE', N'Week', 'COLUMN', N'WeekNumber'
END TRY
BEGIN CATCH
	DECLARE @msg nvarchar(max);
	DECLARE @severity int;
	DECLARE @state int;
	SELECT @msg = ERROR_MESSAGE(), @severity = ERROR_SEVERITY(), @state = ERROR_STATE();
	RAISERROR(@msg, @severity, @state);

	SET NOEXEC ON
END CATCH
GO
BEGIN TRY
	EXEC sp_addextendedproperty N'MS_Description', N'This table contains a list of valid zip codes currently used in AirNow; these are used to quality control the user''s zip code input.', 'SCHEMA', N'dbo', 'TABLE', N'ZipCode', NULL, NULL
END TRY
BEGIN CATCH
	DECLARE @msg nvarchar(max);
	DECLARE @severity int;
	DECLARE @state int;
	SELECT @msg = ERROR_MESSAGE(), @severity = ERROR_SEVERITY(), @state = ERROR_STATE();
	RAISERROR(@msg, @severity, @state);

	SET NOEXEC ON
END CATCH
GO
BEGIN TRY
	EXEC sp_addextendedproperty N'MS_Description', N'Corresponding latitude; metadata for smoke sense purposes', 'SCHEMA', N'dbo', 'TABLE', N'ZipCode', 'COLUMN', N'Latitude'
END TRY
BEGIN CATCH
	DECLARE @msg nvarchar(max);
	DECLARE @severity int;
	DECLARE @state int;
	SELECT @msg = ERROR_MESSAGE(), @severity = ERROR_SEVERITY(), @state = ERROR_STATE();
	RAISERROR(@msg, @severity, @state);

	SET NOEXEC ON
END CATCH
GO
BEGIN TRY
	EXEC sp_addextendedproperty N'MS_Description', N'Corresponding longitude; metadata for smoke sense purposes', 'SCHEMA', N'dbo', 'TABLE', N'ZipCode', 'COLUMN', N'Longitude'
END TRY
BEGIN CATCH
	DECLARE @msg nvarchar(max);
	DECLARE @severity int;
	DECLARE @state int;
	SELECT @msg = ERROR_MESSAGE(), @severity = ERROR_SEVERITY(), @state = ERROR_STATE();
	RAISERROR(@msg, @severity, @state);

	SET NOEXEC ON
END CATCH
GO
BEGIN TRY
	EXEC sp_addextendedproperty N'MS_Description', N'Recognized zip codes in AirNow', 'SCHEMA', N'dbo', 'TABLE', N'ZipCode', 'COLUMN', N'ZipCode'
END TRY
BEGIN CATCH
	DECLARE @msg nvarchar(max);
	DECLARE @severity int;
	DECLARE @state int;
	SELECT @msg = ERROR_MESSAGE(), @severity = ERROR_SEVERITY(), @state = ERROR_STATE();
	RAISERROR(@msg, @severity, @state);

	SET NOEXEC ON
END CATCH
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
