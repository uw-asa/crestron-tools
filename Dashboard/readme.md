# UW Crestron Dashboard

UW Crestron Dashboard provides device use metrics, using Crestron Programming, Crestron Fusion, Microsoft SQL, and Tableau.

## Crestron Controller Programming

Include and program for the Crestron Fusion Device Usage Module.

Crestron Answer ID 5757 - How To Program Fusion SSI Modules for Crestron Fusion
https://support.crestron.com/app/answers/detail/a_id/5757/

Crestron Answer ID 5758 - How To Program Fusion SSI Modules for Crestron Fusion (Guided Assistance)
https://support.crestron.com/app/answers/detail/a_id/5758/

## Crestron Fusion Server Setup

This project requires SQL read access to the Fusion database.

## Microsoft SQL Setup

### Create new database ClassroomTechData 
This database holds new views and tables.

### Create new view v_CRV_log_DeviceUsage
This view provides a filtered and condensed version of the Fusion Usage Log.
```
CREATE VIEW ClassroomTechData.dbo.v_CRV_log_DeviceUsage
AS
SELECT    CrestronFusion.dbo.CRV_UsageLog.LogID
		, CrestronFusion.dbo.CRV_UsageLog.LogTimeStamp
		, DATEADD(minute, - CrestronFusion.dbo.CRV_UsageLog.Data5, CAST(GETDATE() - GetUtcDate() + CrestronFusion.dbo.CRV_UsageLog.LogTimeStamp AS datetime)) AS Local_StartTime
		, CAST(GETDATE() - GetUtcDate() + CrestronFusion.dbo.CRV_UsageLog.LogTimeStamp AS datetime) AS Local_EndTime
		, CrestronFusion.dbo.CRV_Rooms.RoomName
		, CrestronFusion.dbo.CRV_UsageLog.Data2 AS DeviceType
		, CrestronFusion.dbo.CRV_UsageLog.Data3 AS DeviceName
		, CrestronFusion.dbo.CRV_UsageLog.Data5 AS DurationMinutes
FROM	CrestronFusion.dbo.CRV_UsageLog 
		INNER JOIN CrestronFusion.dbo.CRV_Rooms ON CrestronFusion.dbo.CRV_Rooms.RoomID = CrestronFusion.dbo.CRV_UsageLog.RoomID
WHERE	(CrestronFusion.dbo.CRV_UsageLog.DataType = 'USAGE') AND (CrestronFusion.dbo.CRV_UsageLog.Data1 = 'TIME')
```

### Create new table log_DeviceUsage
This table holds the filtered and condensed version of the Fusion Usage Log.  The separate table allows for faster queries, and for old data in the Fusion Usage Log to be purged.
```
CREATE TABLE [dbo].[log_DeviceUsage](
	[LogID] [varchar](50) NOT NULL,
	[LogTimeStamp] [datetime] NOT NULL,
	[Local_StartTime] [datetime] NOT NULL,
	[Local_EndTime] [datetime] NOT NULL,
	[RoomName] [nvarchar](128) NOT NULL,
	[DeviceType] [nvarchar](255) NOT NULL,
	[DeviceName] [nvarchar](255) NOT NULL,
	[DurationMinutes] [int] NOT NULL
)
```

### Create SQL Server Agent Job 
This job populates the log_DeviceUsage table with new data. It should be scheduled reoccurring.
```
INSERT INTO ClassroomTechData.dbo.log_DeviceUsage
	SELECT *
	FROM ClassroomTechData.dbo.v_CRV_log_DeviceUsage
	WHERE NOT EXISTS
		(
			SELECT 1
			FROM ClassroomTechData.dbo.log_DeviceUsage
			WHERE log_DeviceUsage.LogID = v_CRV_log_DeviceUsage.LogID
		)
		AND ClassroomTechData.dbo.v_CRV_log_DeviceUsage.LogTimeStamp > DATEADD(day, -5, GETUTCDATE())
```

## Tableau Workbook

### Create new Tableau Workbook
Connect to data source SQL ClassroomTechData, use table log_DeviceUsage


### Create new Tableau Worksheet

Add to columns: _Local Start Time_

Set _Local Start Time_ = 
```
Calculated Field: Duration Hours  = [Duration Minutes]/60Rows = SUM([Duration Hours]) / TOTAL(SUM([Duration Hours]))
```

Set chart type to Area Chart

Add filter of _Room Name_
Add filter of _DeviceType_

Create group from _Device Name_
Group similar devices together
Filter on new group
Manual sort on new group
Add new group to color marks, and labels

Change rows to compute using group

Set axis to percentage


![Tableau Dashboard graph, showing device usage over time](./readme_img_TableauReportExample.png?raw=true "Tableau Dashboard")
