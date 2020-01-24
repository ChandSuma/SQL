drop table COPS_Cluster.dbo.CycleExecution_FoodLed
CREATE TABLE COPS_Cluster.[dbo].[CycleExecution_FoodLed](
       [Year] [int] NULL,
       [date] [date] NULL,
       [Month] [varchar](30) NULL,
       [FiscalMonth] [varchar](30) NULL,
       [Quarter] [varchar](30) NULL,
       [Continent] [varchar](25) NULL,
       [BusinessUnit] [varchar](20) NULL,
       [Cluster] [varchar](100) NULL,
       [Country] [varchar](150) NULL,
       [SubCountry] [varchar](100) NULL,
       [Segment] [nvarchar](255) NULL,
       [Outlettype] [nvarchar] (255) NULL,
       [OutletGrade] [nvarchar](255) NULL,
       [City] [nvarchar](150) NULL,
       [PostCode] [nvarchar](150) NULL,
       [SalesRepName] [nvarchar](255) NULL,
       [SalesrepStatus] [nvarchar] (255) NULL,
       [Territory] [nvarchar](255) NULL,
       [Manager] [nvarchar](255) NULL,
       [Region] [nvarchar](255) NULL,
       [Channel] [varchar](50) NULL,
       [OutletId] [varchar](50) NULL,
       [OutletName] [nvarchar](250) NULL,
       CycleExecution [float] NULL,
       [Status] [nvarchar] (50) NULL,
	     CycleExecutionTarget [float] NULL,
       [JoinKey] [nvarchar](340) NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO



INSERT INTO [COPS_Cluster].[dbo].[CycleExecution_FoodLed]
( [Year]
      ,[date]
      ,[Month]
      ,[FiscalMonth]
      ,[Quarter]
      ,[Continent]
      ,[BusinessUnit]
      ,[Cluster]
      ,[Country]
      ,[SubCountry]
      ,[Segment]
      ,[Outlettype]
      ,[OutletGrade]
      ,[City]
      ,[PostCode]
      ,[SalesRepName]
      ,[SalesrepStatus]
      ,[Territory]
      ,[Manager]
      ,[Region]
      ,[Channel]
		  ,[OutletId]
		  ,[OutletName]
      ,CycleExecution
      ,[Status]
	    ,CycleExecutionTarget
      ,[JoinKey]
)
SELECT dd.FiscalYearId AS Year,
dd.[date],
dd.CalendarMonthName AS Month,
dd.FiscalPeriodName AS FiscalMonth,
dd.FiscalQuarterName AS Quarter,
dm.Continent,
dm.Region AS BusinessUnit,
dm.SuperCluster AS Cluster,
CASE WHEN dp.Country='Ireland' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Iberia' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Germany' THEN 'GAS'
WHEN dp.Country='Denmark' THEN 'Nordics' ELSE dp.Country  END AS Country,
ISNULL(m.subcountry,dp.country) AS Subcountry,
Isnull(dp.PrimaryCDOS,'Unknown')  as Segment,
ISNULL(dp.outlettype,'Unknown') as Outlettype,
CASE WHEN dp.SourceSystem='Comarch'then dp.[OutletGrade] else ISNULL(dpo.[Outlet Priority],'Unknown') end as outletgrade,
dp.City as City,
dp.PostCode,
isnull(df.Name,'Unknown') as SalesRepName,
df.active as SalesrepStatus,
isnull(dt.territory,'Unknown') AS Territory,
ISNULL(M.[Manager],'Unknown') as Manager,
ISNULL(M.Region,'Unknown') AS Region,
dp.Channel,
dp.OutletId,
dp.OutletName,
fo.[IsResponseOfInterest] as CycleExecution,
dp.Status as Status,
NULL as CycleExecutionTarget,
CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.Status) as JoinKey

FROM CustomerExecutionWarehouse.[Fct].[Survey] fo
left JOIN CustomerExecutionWarehouse.[Dim].[Market] dm ON dm.MarketKey=fo.MarketKey
left JOIN CustomerExecutionWarehouse.[Dim].[PointOfPurchase] dp ON dp.PointOfPurchaseKey=fo.[PointOfPurchaseKey]
left join CustomerExecutionWarehouse.[Dim].[FieldSalesRep] df on df.[FieldSalesRepKey]=fo.[FieldSalesRepKey]
full outer join CustomerExecutionWarehouse.dim.territory dt on dt.territorykey = fo.territorykey
left join CustomerExecutionWarehouse.[Dim].[Date] dd on dd.[DateKey]=fo.[DateKey]
left join CustomerExecutionWarehouse.[Dim].[CallType] dc on dc.[CallTypeKey]=fo.[CallTypeKey]
left join CustomerExecutionWarehouse.[Dim].[BusinessRole] db on db.[BusinessRoleKey]=fo.[BusinessRoleKey]
left join CustomerExecutionWarehouse.[Dim].[Question] dq
on fo.[QuestionKey]=dq.[QuestionKey]
full outer join
( select distinct [OutletGrade], [Country],[Outlet Priority] from
COPS.[dbo].[OutletGrade_Rawdata] )
dpo on dpo.[OutletGrade]=dp.OutletGrade 
and dpo.Country=dp.Country
left join  COPS.dbo.Salesrep_Rawdata m
on ((m.territory = dt.territory) or (m.Name = df.Name)) and (m.Country = dt.Country)
and fo.datekey <= m.enddate
full outer join COPS.dbo.CallTypes_Rawdata mc
on dc.[CallTypeCode]=mc.code
and dc.Country=mc.Country
full outer join cops.dbo.businessroles_Rawdata mb
on db.[BusinessRoleCode]=mb.code
and db.Country=mb.Country


WHERE  dp.country not in ('Unknown','Kenya','N/A')
and dp.County is not null
and mb.includedincalculationcore = 3
and dd.fiscalPeriodName is not null
and dp.channel not like 'Unknown'
and dd.[datekey] > '20190701'
and lower(dq.MasterQuestionName) like '%cycle%execution%'

group by
dd.FiscalYearId,
dd.[date],
dd.CalendarMonthName,
dd.FiscalPeriodName,
dd.FiscalQuarterName,
dm.Continent,
dm.Region,
dm.SuperCluster,
CASE WHEN dp.Country='Ireland' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Iberia' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Germany' THEN 'GAS'
WHEN dp.Country='Denmark' THEN 'Nordics' ELSE dp.Country  END,
Isnull(dp.PrimaryCDOS,'Unknown'),
Isnull(dp.outlettype,'Unknown'),
CASE WHEN dp.SourceSystem='Comarch'then dp.[OutletGrade] else ISNULL(dpo.[Outlet Priority],'Unknown')end ,
dp.City,
dp.PostCode,
isnull(df.Name,'Unknown'),
df.active,
isnull(dt.territory,'Unknown'),
ISNULL(M.[Manager],'Unknown'),
ISNULL(M.Region,'Unknown'),
dp.Channel,
dp.OutletId,
dp.Outletname,
dp.Status,
CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.Status),
ISNULL(m.subcountry,dp.country),
fo.[IsResponseOfInterest]

drop table [dbo].[LineManagerTimeinTrade_FoodLed]
CREATE TABLE [dbo].[LineManagerTimeinTrade_FoodLed](
       [Year] [int] NULL,
       [date] [date] NULL,
       [Month] [varchar](30) NULL,
       [FiscalMonth] [varchar](30) NULL,
       [Quarter] [varchar](30) NULL,
       [Continent] [varchar](25) NULL,
       [BusinessUnit] [varchar](20) NULL,
       [Cluster] [varchar](100) NULL,
       [Country] [varchar](150) NULL,
       [SubCountry] [varchar](150) NULL,
       [Segment] [nvarchar](255) NULL,
       [OutletType] [nvarchar] (255) NULL,
       [OutletGrade] [nvarchar](255) NULL,
       [City] [nvarchar](50) NULL,
       [PostCode] [nvarchar](50) NULL,
	     [Salesrepname] [nvarchar](255) NULL,
       [Salesrepstatus] [nvarchar] (255) NULL,
       Territory [nvarchar](255) NULL,
       [Manager] [nvarchar](255) NULL,
       Region [nvarchar](255) NULL,
       [Channel] [varchar](50) NULL,
       [OutletId] [varchar](50) NULL,
       [OutletName] [nvarchar](255) NULL,
       [Status] [nvarchar] (50) NULL,
       [JoinKey] [nvarchar](340) NOT NULL,
       [TotalCallsManager] [FLOAT] NULL,
       [WorkingDaysManager] [FLOAT] NULL,
       [LineManagerTimeinTrade] [float] NULL,
       [LineManagerTimeinTradeTarget] [Float] NULL


) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO



Insert into [COPS_Cluster].[dbo].[LineManagerTimeinTrade_FoodLed]
       ([Year]
      ,[date]
      ,[Month]
      ,[FiscalMonth]
      ,[Quarter]
      ,[Continent]
      ,[BusinessUnit]
      ,[Cluster]
      ,[Country]
      ,[SubCountry]
      ,[Segment]
      ,[outlettype]
      ,[OutletGrade]
      ,[City]
      ,[PostCode]
	    ,[Salesrepname]
      ,[Salesrepstatus]
	    ,[Territory]
      ,Manager
      ,Region
      ,[Channel]
      ,[OutletId]
      ,[OutletName]
      ,[Status]
      ,[JoinKey]
      ,[TotalCallsManager]
      ,[WorkingDaysManager]
      ,[LineManagerTimeinTrade]
      ,[LineManagerTimeinTradeTarget]

)

Select
Year,
date,
Month,
FiscalMonth,
Quarter,
Continent,
BusinessUnit,
Cluster,
Country,
SubCountry,
Segment,
Outlettype,
OutletGrade,
City,
PostCode,
SalesRepName,
Salesrepstatus,
Territory,
Manager,
Region,
Channel,
[OutletId],
[OutletName],
[Status],
JoinKey,
TotalCallsManager,
WorkingDaysManager,
Null As [LineManagerTimeinTrade],
NULL as Linmanagertimeintradetraget

FROM
(SELECT dd.FiscalYearId AS Year,
dd.[date],
dd.CalendarMonthName AS Month,
dd.FiscalPeriodName AS FiscalMonth,
dd.FiscalQuarterName AS Quarter,
dm.Continent,
dm.Region AS BusinessUnit,
dm.SuperCluster AS Cluster,
CASE WHEN dp.Country='Ireland' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Iberia' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Germany' THEN 'GAS'
WHEN dp.Country='Denmark' THEN 'Nordics' ELSE dp.Country END as Country,
ISNULL(m.subcountry,dp.country) AS Subcountry,
ISNULL(dp.[PrimaryCDOS],'Unknown') as Segment,
ISNULL(dp.outlettype,'Unknown') as Outlettype,
CASE WHEN dp.SourceSystem='Comarch'then dp.[OutletGrade] else ISNULL(dpo.[Outlet Priority],'Unknown') end as outletgrade,
dp.city,
dp.postcode,
isnull(df.Name,'Unknown') as SalesRepName,
df.active as SalesrepStatus,
isnull(dt.territory,'Unknown') AS Territory,
ISNULL(M.[Manager],'Unknown') as Manager,
ISNULL(M.Region,'Unknown') AS Region,
dp.Channel,
dp.OutletId,
dp.Outletname,
dp.Status,
CASE WHEN (FO.IsResponseOfInterest) >= 1 THEN 1 ELSE 0 END AS TotalCallsmanager,
count(distinct(fo.DateKey)) as WorkingDaysManager,
CONCAT(dd.[date],fo.PointOfPurchaseKey,fo.Fieldsalesrepkey,ISNULL(m.subcountry,dp.country),dp.status) as JoinKey

FROM CustomerExecutionWarehouse.[Fct].Survey fo
left JOIN CustomerExecutionWarehouse.[Dim].[Market] dm ON dm.MarketKey=fo.MarketKey
left JOIN CustomerExecutionWarehouse.[Dim].[PointOfPurchase] dp ON dp.PointOfPurchaseKey=fo.[PointOfPurchaseKey]
left join CustomerExecutionWarehouse.[Dim].[BusinessRole] db on db.[BusinessRoleKey]=fo.[BusinessRoleKey]
left join CustomerExecutionWarehouse.[Dim].[FieldSalesRep] df on df.FieldSalesRepKey=fo.Fieldsalesrepkey
full outer join CustomerExecutionWarehouse.dim.territory dt on dt.territorykey = fo.territorykey
left join CustomerExecutionWarehouse.[Dim].[Date] dd on dd.[DateKey]=fo.[DateKey]

full outer join
( select distinct [OutletGrade], [Country],[Outlet Priority] from
COPS.[dbo].[OutletGrade_Rawdata] )dpo
on dpo.[OutletGrade]=dp.OutletGrade
and dpo.Country=dp.Country
left join CustomerExecutionWarehouse.[Dim].[CallType] dc on dc.[CallTypeKey]=fo.[CallTypeKey]
left join CustomerExecutionWarehouse.[Dim].[Question] dq on fo.[QuestionKey]=dq.[QuestionKey]
left join  COPS.dbo.Salesrep_Rawdata m
on ((m.territory = dt.territory) or (m.Name = df.Name)) and (m.Country = dt.Country)
and fo.datekey <= m.enddate
full outer join COPS.dbo.CallTypes_Rawdata mc
on dc.[CallTypeCode]=mc.code
and dc.Country=mc.Country
full outer join cops.dbo.businessroles_Rawdata mb
on db.[BusinessRoleCode]=mb.code
and db.Country=mb.Country

WHERE  dp.country not in ('Unknown','Kenya','N/A')
and dp.Country is not null
and mb.includedincalculationcore = 3
and dd.fiscalPeriodName is not null
and dp.channel not like 'Unknown'
and dd.[datekey] > '20190701'
and lower(dq.MasterQuestionName) like '%Line%Manager%Time%in%Trade%'


group by
dd.FiscalYearId,
dd.[date],
dd.CalendarMonthName,
dd.FiscalPeriodName,
dd.FiscalQuarterName,
dm.Continent,
dm.Region,
dm.SuperCluster,
CASE WHEN dp.Country='Ireland' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Iberia' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Germany' THEN 'GAS'
WHEN dp.Country='Denmark' THEN 'Nordics' ELSE dp.Country END,
ISNULL(m.subcountry,dp.country),
ISNULL(dp.[PrimaryCDOS],'Unknown'),
ISNULL(dp.outlettype,'Unknown'),
CASE WHEN dp.SourceSystem='Comarch'then dp.[OutletGrade] else ISNULL(dpo.[Outlet Priority],'Unknown') end,
dp.OutletId,
dp.Outletname,
dp.Status,
dp.city,
dp.postcode,
isnull(df.Name,'Unknown'),
df.active,
isnull(dt.territory,'Unknown'),
ISNULL(M.[Manager],'Unknown'),
ISNULL(M.Region,'Unknown'),
dp.Channel,
fo.FieldSalesRepKey,
CONCAT(dd.[date],fo.PointOfPurchaseKey,fo.Fieldsalesrepkey,ISNULL(m.subcountry,dp.country),dp.status),
fo.isresponseofinterest
)
main
group by  Year,
date,
Month,
FiscalMonth,
Quarter,
Continent,
BusinessUnit,
Cluster,
Country,
SubCountry,
Segment,
Outlettype,
OutletGrade,
City,
PostCode,
SalesRepName,
Salesrepstatus,
Territory,
Manager,
Region,
Channel,
OutletId,
OutletName,
Status,
JoinKey,
TotalCallsmanager,
workingdaysmanager


drop table COPS_Cluster.dbo.[PouringGin_FoodLed]
CREATE TABLE COPS_Cluster.[dbo].[PouringGin_FoodLed](
       [Year] [int] NULL,
       [date] [date] NULL,
       [Month] [varchar](30) NULL,
       [FiscalMonth] [varchar](30) NULL,
       [Quarter] [varchar](30) NULL,
       [Continent] [varchar](25) NULL,
       [BusinessUnit] [varchar](20) NULL,
       [Cluster] [varchar](100) NULL,
       [Country] [varchar](50) NULL,
       [SubCountry] [varchar](100) NULL,
       [Segment] [nvarchar](255) NULL,
       [Outlettype] [nvarchar] (255) NULL,
       [OutletGrade] [nvarchar](255) NULL,
       [City] [nvarchar](50) NULL,
       [PostCode] [nvarchar](50) NULL,
       [SalesRepName] [nvarchar](255) NULL,
       [SalesrepStatus] [nvarchar] (255) NULL,
       [Territory] [nvarchar](255) NULL,
       [Manager] [nvarchar](255) NULL,
       [Region] [nvarchar](255) NULL,
       [Channel] [varchar](50) NULL,
       [OutletId] [varchar](50) NULL,
       [OutletName] [nvarchar](50) NULL,
       [PouringGin] float null,
       [Status] [nvarchar] (50) NULL,
	     [PouringGinTarget] [float] Null,
       [JoinKey] [nvarchar](340) NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO



INSERT INTO [COPS_Cluster].[dbo].[PouringGin_FoodLed]
( [Year]
      ,[date]
      ,[Month]
      ,[FiscalMonth]
      ,[Quarter]
      ,[Continent]
      ,[BusinessUnit]
      ,[Cluster]
      ,[Country]
      ,[SubCountry]
      ,[Segment]
      ,[Outlettype]
      ,[OutletGrade]
      ,[City]
      ,[PostCode]
      ,[SalesRepName]
      ,[SalesrepStatus]
      ,[Territory]
      ,[Manager]
      ,[Region]
      ,[Channel]
		  ,[OutletId]
		  ,[OutletName]
      ,[PouringGin]
      ,[Status]
	    ,[PouringGinTarget]
      ,[JoinKey]
)
SELECT dd.FiscalYearId AS Year,
dd.[date],
dd.CalendarMonthName AS Month,
dd.FiscalPeriodName AS FiscalMonth,
dd.FiscalQuarterName AS Quarter,
dm.Continent,
dm.Region AS BusinessUnit,
dm.SuperCluster AS Cluster,
CASE WHEN dp.Country='Ireland' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Iberia' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Germany' THEN 'GAS'
WHEN dp.Country='Denmark' THEN 'Nordics' ELSE dp.Country  END AS Country,
ISNULL(m.subcountry,dp.country) AS Subcountry,
Isnull(dp.PrimaryCDOS,'Unknown')  as Segment,
ISNULL(dp.Outlettype,'Unknown') as Outlettype,
CASE WHEN dp.SourceSystem='Comarch'then dp.[OutletGrade] else ISNULL(dpo.[Outlet Priority],'Unknown') end as outletgrade,
dp.City as City,
dp.PostCode,
isnull(df.Name,'Unknown') as SalesRepName,
df.active as SalesrepStatus,
isnull(dt.territory,'Unknown') AS Territory,
ISNULL(M.[Manager],'Unknown') as Manager,
ISNULL(M.Region,'Unknown') AS Region,
dp.Channel,
dp.OutletId,
dp.OutletName,
fo.[IsResponseOfInterest] as PouringGin,
dp.Status as Status,
NULL as PouringGinTarget,
CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.Status) as JoinKey

FROM CustomerExecutionWarehouse.[Fct].[Survey] fo
left JOIN CustomerExecutionWarehouse.[Dim].[Market] dm ON dm.MarketKey=fo.MarketKey
left JOIN CustomerExecutionWarehouse.[Dim].[PointOfPurchase] dp ON dp.PointOfPurchaseKey=fo.[PointOfPurchaseKey]
left join CustomerExecutionWarehouse.[Dim].[BusinessRole] db on db.[BusinessRoleKey]=fo.[BusinessRoleKey]
left join CustomerExecutionWarehouse.[Dim].[FieldSalesRep] df on df.[FieldSalesRepKey]=fo.[FieldSalesRepKey]
full outer join CustomerExecutionWarehouse.dim.territory dt on dt.territorykey = fo.territorykey
left join CustomerExecutionWarehouse.[Dim].[Date] dd on dd.[DateKey]=fo.[DateKey]
left join CustomerExecutionWarehouse.[Dim].[CallType] dc on dc.[CallTypeKey]=fo.[CallTypeKey]
left join CustomerExecutionWarehouse.[Dim].[Question] dq
on fo.[QuestionKey]=dq.[QuestionKey]
left join CustomerExecutionWarehouse.[Dim].[Response] dr on fo.ResponseKey=dr.ResponseKey
full outer join
( select distinct [OutletGrade], [Country],[Outlet Priority] from
COPS.[dbo].[OutletGrade_Rawdata] )
dpo on dpo.[OutletGrade]=dp.OutletGrade
and dpo.Country=dp.Country
left join  COPS.dbo.Salesrep_Rawdata m
on ((m.territory = dt.territory) or (m.Name = df.Name)) and (m.Country = dt.Country)
and fo.datekey <= m.enddate
full outer join COPS.dbo.CallTypes_Rawdata mc
on dc.[CallTypeCode]=mc.code
and dc.Country=mc.Country
and fo.datekey<=m.enddate
full outer join cops.dbo.businessroles_Rawdata mb
on db.[BusinessRoleCode]=mb.code
and db.Country=mb.Country


WHERE  dp.country not in ('Unknown','Kenya','N/A')
and dp.County is not null
and mb.includedincalculationcore = 3
and dd.fiscalPeriodName is not null
and dp.channel not like 'Unknown'
and dd.[datekey] > '20190701'
and (lower(dq.[MasterQuestionName]) like '%pouring%status%gin%')

group by
dd.FiscalYearId,
dd.[date],
dd.CalendarMonthName,
dd.FiscalPeriodName,
dd.FiscalQuarterName,
dm.Continent,
dm.Region,
dm.SuperCluster,
CASE WHEN dp.Country='Ireland' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Iberia' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Germany' THEN 'GAS'
WHEN dp.Country='Denmark' THEN 'Nordics' ELSE dp.Country  END,
Isnull(dp.PrimaryCDOS,'Unknown'),
ISNULL(dp.Outlettype,'Unknown'),
CASE WHEN dp.SourceSystem='Comarch'then dp.[OutletGrade] else ISNULL(dpo.[Outlet Priority],'Unknown')end ,
dp.City,
dp.PostCode,
isnull(df.Name,'Unknown'),
df.active,
isnull(dt.territory,'Unknown'),
ISNULL(M.[Manager],'Unknown'),
ISNULL(M.Region,'Unknown'),
dp.Channel,
dp.OutletId,
dp.Outletname,
dp.Status,
CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.Status),
ISNULL(m.subcountry,dp.country),
fo.[IsResponseOfInterest]

drop table COPS_Cluster.dbo.[PouringVodka_FoodLed]
CREATE TABLE COPS_Cluster.[dbo].[PouringVodka_FoodLed](
       [Year] [int] NULL,
       [date] [date] NULL,
       [Month] [varchar](30) NULL,
       [FiscalMonth] [varchar](30) NULL,
       [Quarter] [varchar](30) NULL,
       [Continent] [varchar](25) NULL,
       [BusinessUnit] [varchar](20) NULL,
       [Cluster] [varchar](100) NULL,
       [Country] [varchar](50) NULL,
       [SubCountry] [varchar](100) NULL,
       [Segment] [nvarchar](255) NULL,
       [Outlettype] [nvarchar] (255) NULL,
       [OutletGrade] [nvarchar](255) NULL,
       [City] [nvarchar](50) NULL,
       [PostCode] [nvarchar](50) NULL,
       [SalesRepName] [nvarchar](255) NULL,
       [SalesrepStatus] [nvarchar] (255) NULL,
       [Territory] [nvarchar](255) NULL,
       [Manager] [nvarchar](255) NULL,
       [Region] [nvarchar](255) NULL,
       [Channel] [varchar](50) NULL,
       [OutletId] [varchar](50) NULL,
       [OutletName] [nvarchar](50) NULL,
       [PouringVodka] float null,
       [Status] [nvarchar] (50) NULL,
	     [PouringVodkaTarget] [float] Null,
       [JoinKey] [nvarchar](340) NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO



INSERT INTO [COPS_Cluster].[dbo].[PouringVodka_FoodLed]
      ([Year]
      ,[date]
      ,[Month]
      ,[FiscalMonth]
      ,[Quarter]
      ,[Continent]
      ,[BusinessUnit]
      ,[Cluster]
      ,[Country]
      ,[SubCountry]
      ,[Segment]
      ,[Outlettype]
      ,[OutletGrade]
      ,[City]
      ,[PostCode]
      ,[SalesRepName]
      ,[SalesrepStatus]
      ,[Territory]
      ,[Manager]
      ,[Region]
      ,[Channel]
		  ,[OutletId]
		  ,[OutletName]
      ,[PouringVodka]
      ,[Status]
	    ,[PouringVodkaTarget]
      ,[JoinKey]
)
SELECT dd.FiscalYearId AS Year,
dd.[date],
dd.CalendarMonthName AS Month,
dd.FiscalPeriodName AS FiscalMonth,
dd.FiscalQuarterName AS Quarter,
dm.Continent,
dm.Region AS BusinessUnit,
dm.SuperCluster AS Cluster,
CASE WHEN dp.Country='Ireland' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Iberia' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Germany' THEN 'GAS'
WHEN dp.Country='Denmark' THEN 'Nordics' ELSE dp.Country  END AS Country,
ISNULL(m.subcountry,dp.country) AS Subcountry,
Isnull(dp.PrimaryCDOS,'Unknown')  as Segment,
ISNULL(dp.Outlettype,'Unknown') as Outlettype,
CASE WHEN dp.SourceSystem='Comarch'then dp.[OutletGrade] else ISNULL(dpo.[Outlet Priority],'Unknown') end as outletgrade,
dp.City as City,
dp.PostCode,
isnull(df.Name,'Unknown') as SalesRepName,
df.active as SalesrepStatus,
isnull(dt.territory,'Unknown') AS Territory,
ISNULL(M.[Manager],'Unknown') as Manager,
ISNULL(M.Region,'Unknown') AS Region,
dp.Channel,
dp.OutletId,
dp.OutletName,
fo.[IsResponseOfInterest] as PouringVodka,
dp.Status as Status,
NULL as PouringVodkaTarget,
CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.Status) as JoinKey

FROM CustomerExecutionWarehouse.[Fct].[Survey] fo
left JOIN CustomerExecutionWarehouse.[Dim].[Market] dm ON dm.MarketKey=fo.MarketKey
left JOIN CustomerExecutionWarehouse.[Dim].[PointOfPurchase] dp ON dp.PointOfPurchaseKey=fo.[PointOfPurchaseKey]
left join CustomerExecutionWarehouse.[Dim].[BusinessRole] db on db.[BusinessRoleKey]=fo.[BusinessRoleKey]
left join CustomerExecutionWarehouse.[Dim].[FieldSalesRep] df on df.[FieldSalesRepKey]=fo.[FieldSalesRepKey]
full outer join CustomerExecutionWarehouse.dim.territory dt on dt.territorykey = fo.territorykey
left join CustomerExecutionWarehouse.[Dim].[Date] dd on dd.[DateKey]=fo.[DateKey]
left join CustomerExecutionWarehouse.[Dim].[CallType] dc on dc.[CallTypeKey]=fo.[CallTypeKey]
left join CustomerExecutionWarehouse.[Dim].[Question] dq
on fo.[QuestionKey]=dq.[QuestionKey]
left join CustomerExecutionWarehouse.[Dim].[Response] dr on fo.ResponseKey=dr.ResponseKey
full outer join
( select distinct [OutletGrade], [Country],[Outlet Priority] from
COPS.[dbo].[OutletGrade_Rawdata] )
dpo on dpo.[OutletGrade]=dp.OutletGrade
and dpo.Country=dp.Country
left join  COPS.dbo.Salesrep_Rawdata m
on ((m.territory = dt.territory) or (m.Name = df.Name)) and (m.Country = dt.Country)
and fo.datekey <= m.enddate
full outer join COPS.dbo.CallTypes_Rawdata mc
on dc.[CallTypeCode]=mc.code
and dc.Country=mc.Country
and fo.datekey<=m.enddate
full outer join cops.dbo.businessroles_Rawdata mb
on db.[BusinessRoleCode]=mb.code
and db.Country=mb.Country


WHERE  dp.country not in ('Unknown','Kenya','N/A')
and dp.County is not null
and mb.includedincalculationcore = 3
and dd.fiscalPeriodName is not null
and dp.channel not like 'Unknown'
and dd.[datekey] > '20190701'
and (lower(dq.[MasterQuestionName]) like '%pouring%status%vodka%')

group by
dd.FiscalYearId,
dd.[date],
dd.CalendarMonthName,
dd.FiscalPeriodName,
dd.FiscalQuarterName,
dm.Continent,
dm.Region,
dm.SuperCluster,
CASE WHEN dp.Country='Ireland' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Iberia' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Germany' THEN 'GAS'
WHEN dp.Country='Denmark' THEN 'Nordics' ELSE dp.Country  END,
Isnull(dp.PrimaryCDOS,'Unknown'),
ISNULL(dp.Outlettype,'Unknown'),
CASE WHEN dp.SourceSystem='Comarch'then dp.[OutletGrade] else ISNULL(dpo.[Outlet Priority],'Unknown')end ,
dp.City,
dp.PostCode,
isnull(df.Name,'Unknown'),
df.active,
isnull(dt.territory,'Unknown'),
ISNULL(M.[Manager],'Unknown'),
ISNULL(M.Region,'Unknown'),
dp.Channel,
dp.OutletId,
dp.Outletname,
dp.Status,
CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.Status),
ISNULL(m.subcountry,dp.country),
fo.[IsResponseOfInterest]

drop table COPS_Cluster.dbo.[Pouringrum_FoodLed]
CREATE TABLE COPS_Cluster.[dbo].[Pouringrum_FoodLed](
       [Year] [int] NULL,
       [date] [date] NULL,
       [Month] [varchar](30) NULL,
       [FiscalMonth] [varchar](30) NULL,
       [Quarter] [varchar](30) NULL,
       [Continent] [varchar](25) NULL,
       [BusinessUnit] [varchar](20) NULL,
       [Cluster] [varchar](100) NULL,
       [Country] [varchar](50) NULL,
       [SubCountry] [varchar](100) NULL,
       [Segment] [nvarchar](255) NULL,
       [Outlettype] [nvarchar] (255) NULL,
       [OutletGrade] [nvarchar](255) NULL,
       [City] [nvarchar](50) NULL,
       [PostCode] [nvarchar](50) NULL,
       [SalesRepName] [nvarchar](255) NULL,
       [SalesrepStatus] [nvarchar] (255) NULL,
       [Territory] [nvarchar](255) NULL,
       [Manager] [nvarchar](255) NULL,
       [Region] [nvarchar](255) NULL,
       [Channel] [varchar](50) NULL,
       [OutletId] [varchar](50) NULL,
       [OutletName] [nvarchar](50) NULL,
       [PouringRum] float null,
       [Status] [nvarchar] (50) NULL,
	     [PouringRumTarget] [float] Null,
       [JoinKey] [nvarchar](340) NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO



INSERT INTO [COPS_Cluster].[dbo].[Pouringrum_FoodLed]
( [Year]
      ,[date]
      ,[Month]
      ,[FiscalMonth]
      ,[Quarter]
      ,[Continent]
      ,[BusinessUnit]
      ,[Cluster]
      ,[Country]
      ,[SubCountry]
      ,[Segment]
      ,[Outlettype]
      ,[OutletGrade]
      ,[City]
      ,[PostCode]
      ,[SalesRepName]
      ,[SalesrepStatus]
      ,[Territory]
      ,[Manager]
      ,[Region]
      ,[Channel]
		  ,[OutletId]
		  ,[OutletName]
      ,[PouringRum]
      ,[Status]
	    ,[PouringRumTarget]
      ,[JoinKey]
)
SELECT dd.FiscalYearId AS Year,
dd.[date],
dd.CalendarMonthName AS Month,
dd.FiscalPeriodName AS FiscalMonth,
dd.FiscalQuarterName AS Quarter,
dm.Continent,
dm.Region AS BusinessUnit,
dm.SuperCluster AS Cluster,
CASE WHEN dp.Country='Ireland' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Iberia' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Germany' THEN 'GAS'
WHEN dp.Country='Denmark' THEN 'Nordics' ELSE dp.Country  END AS Country,
ISNULL(m.subcountry,dp.country) AS Subcountry,
Isnull(dp.PrimaryCDOS,'Unknown')  as Segment,
ISNULL(dp.Outlettype,'Unknown') as Outlettype,
CASE WHEN dp.SourceSystem='Comarch'then dp.[OutletGrade] else ISNULL(dpo.[Outlet Priority],'Unknown') end as outletgrade,
dp.City as City,
dp.PostCode,
isnull(df.Name,'Unknown') as SalesRepName,
df.active as SalesrepStatus,
isnull(dt.territory,'Unknown') AS Territory,
ISNULL(M.[Manager],'Unknown') as Manager,
ISNULL(M.Region,'Unknown') AS Region,
dp.Channel,
dp.OutletId,
dp.OutletName,
fo.[IsResponseOfInterest] as PouringRum,
dp.Status as Status,
NULL as PouringRumTarget,
CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.Status) as JoinKey

FROM CustomerExecutionWarehouse.[Fct].[Survey] fo
left JOIN CustomerExecutionWarehouse.[Dim].[Market] dm ON dm.MarketKey=fo.MarketKey
left JOIN CustomerExecutionWarehouse.[Dim].[PointOfPurchase] dp ON dp.PointOfPurchaseKey=fo.[PointOfPurchaseKey]
left join CustomerExecutionWarehouse.[Dim].[BusinessRole] db on db.[BusinessRoleKey]=fo.[BusinessRoleKey]
left join CustomerExecutionWarehouse.[Dim].[FieldSalesRep] df on df.[FieldSalesRepKey]=fo.[FieldSalesRepKey]
full outer join CustomerExecutionWarehouse.dim.territory dt on dt.territorykey = fo.territorykey
left join CustomerExecutionWarehouse.[Dim].[Date] dd on dd.[DateKey]=fo.[DateKey]
left join CustomerExecutionWarehouse.[Dim].[CallType] dc on dc.[CallTypeKey]=fo.[CallTypeKey]
left join CustomerExecutionWarehouse.[Dim].[Question] dq
on fo.[QuestionKey]=dq.[QuestionKey]
left join CustomerExecutionWarehouse.[Dim].[Response] dr on fo.ResponseKey=dr.ResponseKey
full outer join
( select distinct [OutletGrade], [Country],[Outlet Priority] from
COPS.[dbo].[OutletGrade_Rawdata] )
dpo on dpo.[OutletGrade]=dp.OutletGrade
and dpo.Country=dp.Country
left join  COPS.dbo.Salesrep_Rawdata m
on ((m.territory = dt.territory) or (m.Name = df.Name)) and (m.Country = dt.Country)
and fo.datekey <= m.enddate
full outer join COPS.dbo.CallTypes_Rawdata mc
on dc.[CallTypeCode]=mc.code
and dc.Country=mc.Country
and fo.datekey<=m.enddate
full outer join cops.dbo.businessroles_Rawdata mb
on db.[BusinessRoleCode]=mb.code
and db.Country=mb.Country


WHERE  dp.country not in ('Unknown','Kenya','N/A')
and dp.County is not null
and mb.includedincalculationcore = 3
and dd.fiscalPeriodName is not null
and dp.channel not like 'Unknown'
and dd.[datekey] > '20190701'
and (lower(dq.[MasterQuestionName]) like '%pouring%status%rum%')


group by
dd.FiscalYearId,
dd.[date],
dd.CalendarMonthName,
dd.FiscalPeriodName,
dd.FiscalQuarterName,
dm.Continent,
dm.Region,
dm.SuperCluster,
CASE WHEN dp.Country='Ireland' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Iberia' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Germany' THEN 'GAS'
WHEN dp.Country='Denmark' THEN 'Nordics' ELSE dp.Country  END,
Isnull(dp.PrimaryCDOS,'Unknown'),
ISNULL(dp.Outlettype,'Unknown'),
CASE WHEN dp.SourceSystem='Comarch'then dp.[OutletGrade] else ISNULL(dpo.[Outlet Priority],'Unknown')end ,
dp.City,
dp.PostCode,
isnull(df.Name,'Unknown'),
df.active,
isnull(dt.territory,'Unknown'),
ISNULL(M.[Manager],'Unknown'),
ISNULL(M.Region,'Unknown'),
dp.Channel,
dp.OutletId,
dp.Outletname,
dp.Status,
CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.Status),
ISNULL(m.subcountry,dp.country),
fo.[IsResponseOfInterest]

drop table COPS_Cluster.dbo.[Pouringwhiskey_FoodLed]
CREATE TABLE COPS_Cluster.[dbo].[Pouringwhiskey_FoodLed](
       [Year] [int] NULL,
       [date] [date] NULL,
       [Month] [varchar](30) NULL,
       [FiscalMonth] [varchar](30) NULL,
       [Quarter] [varchar](30) NULL,
       [Continent] [varchar](25) NULL,
       [BusinessUnit] [varchar](20) NULL,
       [Cluster] [varchar](100) NULL,
       [Country] [varchar](50) NULL,
       [SubCountry] [varchar](100) NULL,
       [Segment] [nvarchar](255) NULL,
       [Outlettype] [nvarchar] (255) NULL,
       [OutletGrade] [nvarchar](255) NULL,
       [City] [nvarchar](50) NULL,
       [PostCode] [nvarchar](50) NULL,
       [SalesRepName] [nvarchar](255) NULL,
       [SalesrepStatus] [nvarchar] (255) NULL,
       [Territory] [nvarchar](255) NULL,
       [Manager] [nvarchar](255) NULL,
       [Region] [nvarchar](255) NULL,
       [Channel] [varchar](50) NULL,
       [OutletId] [varchar](50) NULL,
       [OutletName] [nvarchar](50) NULL,
       [PouringWhiskey] float null,
       [Status] [nvarchar] (50) NULL,
	     [PouringWhiskeyTarget] [float] Null,
       [JoinKey] [nvarchar](340) NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO



INSERT INTO [COPS_Cluster].[dbo].[Pouringwhiskey_FoodLed]
( [Year]
      ,[date]
      ,[Month]
      ,[FiscalMonth]
      ,[Quarter]
      ,[Continent]
      ,[BusinessUnit]
      ,[Cluster]
      ,[Country]
      ,[SubCountry]
      ,[Segment]
      ,[Outlettype]
      ,[OutletGrade]
      ,[City]
      ,[PostCode]
      ,[SalesRepName]
      ,[SalesrepStatus]
      ,[Territory]
      ,[Manager]
      ,[Region]
      ,[Channel]
		  ,[OutletId]
		  ,[OutletName]
      ,[PouringWhiskey]
      ,[Status]
	    ,[PouringWhiskeyTarget]
      ,[JoinKey]
)
SELECT dd.FiscalYearId AS Year,
dd.[date],
dd.CalendarMonthName AS Month,
dd.FiscalPeriodName AS FiscalMonth,
dd.FiscalQuarterName AS Quarter,
dm.Continent,
dm.Region AS BusinessUnit,
dm.SuperCluster AS Cluster,
CASE WHEN dp.Country='Ireland' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Iberia' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Germany' THEN 'GAS'
WHEN dp.Country='Denmark' THEN 'Nordics' ELSE dp.Country  END AS Country,
ISNULL(m.subcountry,dp.country) AS Subcountry,
Isnull(dp.PrimaryCDOS,'Unknown')  as Segment,
ISNULL(dp.Outlettype,'Unknown') as Outlettype,
CASE WHEN dp.SourceSystem='Comarch'then dp.[OutletGrade] else ISNULL(dpo.[Outlet Priority],'Unknown') end as outletgrade,
dp.City as City,
dp.PostCode,
isnull(df.Name,'Unknown') as SalesRepName,
df.active as SalesrepStatus,
isnull(dt.territory,'Unknown') AS Territory,
ISNULL(M.[Manager],'Unknown') as Manager,
ISNULL(M.Region,'Unknown') AS Region,
dp.Channel,
dp.OutletId,
dp.OutletName,
fo.[IsResponseOfInterest] as PouringWhiskey,
dp.Status as Status,
NULL as PouringWhiskeyTarget,
CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.Status) as JoinKey

FROM CustomerExecutionWarehouse.[Fct].[Survey] fo
left JOIN CustomerExecutionWarehouse.[Dim].[Market] dm ON dm.MarketKey=fo.MarketKey
left JOIN CustomerExecutionWarehouse.[Dim].[PointOfPurchase] dp ON dp.PointOfPurchaseKey=fo.[PointOfPurchaseKey]
left join CustomerExecutionWarehouse.[Dim].[BusinessRole] db on db.[BusinessRoleKey]=fo.[BusinessRoleKey]
left join CustomerExecutionWarehouse.[Dim].[FieldSalesRep] df on df.[FieldSalesRepKey]=fo.[FieldSalesRepKey]
full outer join CustomerExecutionWarehouse.dim.territory dt on dt.territorykey = fo.territorykey
left join CustomerExecutionWarehouse.[Dim].[Date] dd on dd.[DateKey]=fo.[DateKey]
left join CustomerExecutionWarehouse.[Dim].[CallType] dc on dc.[CallTypeKey]=fo.[CallTypeKey]
left join CustomerExecutionWarehouse.[Dim].[Question] dq
on fo.[QuestionKey]=dq.[QuestionKey]
left join CustomerExecutionWarehouse.[Dim].[Response] dr on fo.ResponseKey=dr.ResponseKey
full outer join
( select distinct [OutletGrade], [Country],[Outlet Priority] from
COPS.[dbo].[OutletGrade_Rawdata] )
dpo on dpo.[OutletGrade]=dp.OutletGrade
and dpo.Country=dp.Country
left join  COPS.dbo.Salesrep_Rawdata m
on ((m.territory = dt.territory) or (m.Name = df.Name)) and (m.Country = dt.Country)
and fo.datekey <= m.enddate
full outer join COPS.dbo.CallTypes_Rawdata mc
on dc.[CallTypeCode]=mc.code
and dc.Country=mc.Country
and fo.datekey<=m.enddate
full outer join cops.dbo.businessroles_Rawdata mb
on db.[BusinessRoleCode]=mb.code
and db.Country=mb.Country


WHERE  dp.country not in ('Unknown','Kenya','N/A')
and dp.County is not null
and mb.includedincalculationcore = 3
and dd.fiscalPeriodName is not null
and dp.channel not like 'Unknown'
and dd.[datekey] > '20190701'
and (lower(dq.[MasterQuestionName]) like '%pouring%status%whisk%')


group by
dd.FiscalYearId,
dd.[date],
dd.CalendarMonthName,
dd.FiscalPeriodName,
dd.FiscalQuarterName,
dm.Continent,
dm.Region,
dm.SuperCluster,
CASE WHEN dp.Country='Ireland' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Iberia' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Germany' THEN 'GAS'
WHEN dp.Country='Denmark' THEN 'Nordics' ELSE dp.Country  END,
Isnull(dp.PrimaryCDOS,'Unknown'),
ISNULL(dp.Outlettype,'Unknown'),
CASE WHEN dp.SourceSystem='Comarch'then dp.[OutletGrade] else ISNULL(dpo.[Outlet Priority],'Unknown')end ,
dp.City,
dp.PostCode,
isnull(df.Name,'Unknown'),
df.active,
isnull(dt.territory,'Unknown'),
ISNULL(M.[Manager],'Unknown'),
ISNULL(M.Region,'Unknown'),
dp.Channel,
dp.OutletId,
dp.Outletname,
dp.Status,
CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.Status),
ISNULL(m.subcountry,dp.country),
fo.[IsResponseOfInterest]


drop table COPS_Cluster.dbo.[SocialMedia_FoodLed]
CREATE TABLE COPS_Cluster.[dbo].[SocialMedia_FoodLed](
       [Year] [int] NULL,
       [date] [date] NULL,
       [Month] [varchar](30) NULL,
       [FiscalMonth] [varchar](30) NULL,
       [Quarter] [varchar](30) NULL,
       [Continent] [varchar](25) NULL,
       [BusinessUnit] [varchar](20) NULL,
       [Cluster] [varchar](100) NULL,
       [Country] [varchar](50) NULL,
       [SubCountry] [varchar](100) NULL,
       [Segment] [nvarchar](255) NULL,
       [Outlettype] [nvarchar] (255) NULL,
       [OutletGrade] [nvarchar](255) NULL,
       [City] [nvarchar](150) NULL,
       [PostCode] [nvarchar](150) NULL,
       [SalesRepName] [nvarchar](255) NULL,
       [SalesrepStatus] [nvarchar] (255) NULL,
       [Territory] [nvarchar](255) NULL,
       [Manager] [nvarchar](255) NULL,
       [Region] [nvarchar](255) NULL,
       [Channel] [varchar](50) NULL,
       [OutletId] [varchar](50) NULL,
       [OutletName] [nvarchar](250) NULL,
       [SocialMedia] float null,
       [Status] [nvarchar] (50) NULL,
       [JoinKey] [nvarchar](340) NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO



INSERT INTO [COPS_Cluster].[dbo].[SocialMedia_FoodLed]
( [Year]
      ,[date]
      ,[Month]
      ,[FiscalMonth]
      ,[Quarter]
      ,[Continent]
      ,[BusinessUnit]
      ,[Cluster]
      ,[Country]
      ,[SubCountry]
      ,[Segment]
      ,[Outlettype]
      ,[OutletGrade]
      ,[City]
      ,[PostCode]
      ,[SalesRepName]
      ,[SalesrepStatus]
      ,[Territory]
      ,[Manager]
      ,[Region]
      ,[Channel]
		  ,[OutletId]
		  ,[OutletName]
      ,[SocialMedia]
      ,[Status]
      ,[JoinKey]
)
SELECT dd.FiscalYearId AS Year,
dd.[date],
dd.CalendarMonthName AS Month,
dd.FiscalPeriodName AS FiscalMonth,
dd.FiscalQuarterName AS Quarter,
dm.Continent,
dm.Region AS BusinessUnit,
dm.SuperCluster AS Cluster,
CASE WHEN dp.Country='Ireland' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Iberia' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Germany' THEN 'GAS'
WHEN dp.Country='Denmark' THEN 'Nordics' ELSE dp.Country  END AS Country,
ISNULL(m.subcountry,dp.country) AS Subcountry,
Isnull(dp.PrimaryCDOS,'Unknown')  as Segment,
ISNULL(dp.outlettype,'Unknown') as Outlettype,
CASE WHEN dp.SourceSystem='Comarch'then dp.[OutletGrade] else ISNULL(dpo.[Outlet Priority],'Unknown') end as outletgrade,
dp.City as City,
dp.PostCode,
isnull(df.Name,'Unknown') as SalesRepName,
df.active as SalesrepStatus,
isnull(dt.territory,'Unknown') AS Territory,
ISNULL(M.[Manager],'Unknown') as Manager,
ISNULL(M.Region,'Unknown') AS Region,
dp.Channel,
dp.OutletId,
dp.OutletName,
fo.[IsResponseOfInterest] as SocialMedia,
dp.Status as Status,
CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.Status) as JoinKey

FROM CustomerExecutionWarehouse.[Fct].[Survey] fo
left JOIN CustomerExecutionWarehouse.[Dim].[Market] dm ON dm.MarketKey=fo.MarketKey
left JOIN CustomerExecutionWarehouse.[Dim].[PointOfPurchase] dp ON dp.PointOfPurchaseKey=fo.[PointOfPurchaseKey]
left join CustomerExecutionWarehouse.[Dim].[BusinessRole] db on db.[BusinessRoleKey]=fo.[BusinessRoleKey]
left join CustomerExecutionWarehouse.[Dim].[FieldSalesRep] df on df.[FieldSalesRepKey]=fo.[FieldSalesRepKey]
full outer join CustomerExecutionWarehouse.dim.territory dt on dt.territorykey = fo.territorykey
left join CustomerExecutionWarehouse.[Dim].[Date] dd on dd.[DateKey]=fo.[DateKey]
left join CustomerExecutionWarehouse.[Dim].[CallType] dc on dc.[CallTypeKey]=fo.[CallTypeKey]
left join CustomerExecutionWarehouse.[Dim].[Question] dq
on fo.[QuestionKey]=dq.[QuestionKey]
full outer join
( select distinct [OutletGrade], [Country],[Outlet Priority] from
COPS.[dbo].[OutletGrade_Rawdata] )
dpo on dpo.[OutletGrade]=dp.OutletGrade
and dpo.Country=dp.Country
left join [COPS].[dbo].[Salesrep_Rawdata] m
on (m.id = df.employeeid or m.name = df.name)
and m.country=df.sourcecountry
full outer join COPS.dbo.CallTypes_Rawdata mc
on dc.[CallTypeCode]=mc.code
and dc.Country=mc.Country
and fo.datekey<=m.enddate
full outer join cops.dbo.businessroles_Rawdata mb
on db.[BusinessRoleCode]=mb.code
and db.Country=mb.Country


WHERE  dp.country not in ('Unknown','Kenya','N/A')
and dp.County is not null
and mb.includedincalculationcore = 3
and dd.fiscalPeriodName is not null
and dp.channel not like 'Unknown'
and dd.[datekey] > '20190701'
and lower(dq.MasterQuestionName) like '%social%media%question%'


group by
dd.FiscalYearId,
dd.[date],
dd.CalendarMonthName,
dd.FiscalPeriodName,
dd.FiscalQuarterName,
dm.Continent,
dm.Region,
dm.SuperCluster,
CASE WHEN dp.Country='Ireland' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Iberia' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Germany' THEN 'GAS'
WHEN dp.Country='Denmark' THEN 'Nordics' ELSE dp.Country  END,
Isnull(dp.PrimaryCDOS,'Unknown'),
ISNULL(dp.outlettype,'Unknown'),
CASE WHEN dp.SourceSystem='Comarch'then dp.[OutletGrade] else ISNULL(dpo.[Outlet Priority],'Unknown')end ,
dp.City,
dp.PostCode,
isnull(df.Name,'Unknown'),
df.active,
isnull(dt.territory,'Unknown'),
ISNULL(M.[Manager],'Unknown'),
ISNULL(M.Region,'Unknown'),
dp.Channel,
dp.OutletId,
dp.Outletname,
dp.Status,
CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.Status),
ISNULL(m.subcountry,dp.country),
fo.[IsResponseOfInterest]


use COPS_Cluster
drop table TotalCalls_FoodLed
CREATE TABLE [dbo].[TotalCalls_FoodLed]
(	[Year] [int] NULL,
	[date] [date] NULL,
	[Month] [varchar](30) NULL,
	[FiscalMonth] [varchar](30) NULL,
	[Quarter] [varchar](30) NULL,
	[Continent] [varchar](25) NULL,
	[BusinessUnit] [varchar](20) NULL,
	[Cluster] [varchar](100) NULL,
	[Country] [varchar](50) NULL,
	[SubCountry] [varchar](100) NULL,
	[Segment] [nvarchar](255) NULL,
	[Outlettype] [nvarchar] (255) NULL,
	[OutletGrade] [nvarchar](255) NULL,
	[City] [nvarchar](50) NULL,
	[PostCode] [nvarchar](50) NULL,
	[SalesRepName] [nvarchar](255) NULL,
	[SalesrepStatus] [nvarchar] (255) NULL,
	[Territory] [nvarchar](255) NULL,
	[Manager] [nvarchar](255) NULL,
	[Region] [nvarchar](255) NULL,
	[Channel] [varchar](50) NULL,
	[OutletId] [varchar](50) NULL,
	[OutletName] [nvarchar](50) NULL,
	[Coverage] [float] NULL,
	[Status] [nvarchar] (50) NULL,
	[CoverageTarget] [float] NULL,
	[JoinKey] [nvarchar](340) NOT NULL,
      [LastUpdated] [date]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO



INSERT INTO [COPS_Cluster].[dbo].[TotalCalls_FoodLed]
		( [Year]
      ,[date]
      ,[Month]
	  	,[FiscalMonth]
      ,[Quarter]
      ,[Continent]
      ,[BusinessUnit]
      ,[Cluster]
      ,[Country]
      ,[SubCountry]
      ,[Segment]
			,[Outlettype]
      ,[OutletGrade]
      ,[City]
      ,[PostCode]
      ,[SalesRepName]
			,[SalesrepStatus]
      ,[Territory]
      ,[Manager]
      ,[Region]
      ,[Channel]
	  	,[OutletId]
	  	,[OutletName]
      ,[Coverage]
			,[Status]
			,[CoverageTarget]
      ,[JoinKey]
      ,[LastUpdated]
		)
SELECT dd.FiscalYearId AS Year,
dd.[date],
dd.CalendarMonthName AS Month,
dd.FiscalPeriodName AS FiscalMonth,
dd.FiscalQuarterName AS Quarter,
dm.Continent,
dm.Region AS BusinessUnit,
dm.SuperCluster AS Cluster,
CASE WHEN dp.Country='Ireland' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Iberia' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Germany' THEN 'GAS'
WHEN dp.Country='Denmark' THEN 'Nordics' ELSE dp.Country  END AS Country,
ISNULL(m.subcountry,dp.country) AS Subcountry,
Isnull(dp.PrimaryCDOS,'Unknown')  as Segment,
isnull(dp.Outlettype,'Unknown') as Outlettype,
CASE WHEN dp.SourceSystem='Comarch'then dp.[OutletGrade] else ISNULL(dpo.[Outlet Priority],'Unknown') end as outletgrade,
dp.City as City,
dp.PostCode,
isnull(df.Name,'Unknown') as SalesRepName,
df.active as SalesrepStatus,
isnull(dt.territory,'Unknown') AS Territory,
ISNULL(M.[Manager],'Unknown') as Manager,
ISNULL(M.Region,'Unknown') AS Region,
dp.Channel,
dp.OutletId,
dp.OutletName,
FO.Visited AS TotalCalls,
dp.Status as Status,
Null as TotalCallsTraget,
CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.Status) as JoinKey,
getdate() as [LastUpdated]

FROM CustomerExecutionWarehouse.[Fct].[OutletCall] fo
left JOIN CustomerExecutionWarehouse.[Dim].[Market] dm ON dm.MarketKey=fo.MarketKey
left JOIN CustomerExecutionWarehouse.[Dim].[PointOfPurchase] dp ON dp.PointOfPurchaseKey=fo.[PointOfPurchaseKey]
left join CustomerExecutionWarehouse.[Dim].[BusinessRole] db on db.[BusinessRoleKey]=fo.[BusinessRoleKey]
left join CustomerExecutionWarehouse.[Dim].[FieldSalesRep] df on df.[FieldSalesRepKey]=fo.[FieldSalesRepKey]
full outer join CustomerExecutionWarehouse.dim.territory dt on dt.territorykey = fo.territorykey
left join  COPS.dbo.Salesrep_Rawdata m
on ((m.territory = dt.territory) or (m.Name = df.Name)) and (m.Country = dt.Country)
and fo.datekey <= m.enddate
left join CustomerExecutionWarehouse.[Dim].[Date] dd on dd.[DateKey]=fo.[DateKey]
left join CustomerExecutionWarehouse.[Dim].[CallType] dc on dc.[CallTypeKey]=fo.[CallTypeKey]
full outer join
( select distinct [OutletGrade], [Country],[Outlet Priority] from
COPS.[dbo].[OutletGrade_Rawdata] )
dpo on dpo.[OutletGrade]=dp.OutletGrade
and dpo.Country=dp.Country
full outer join COPS.dbo.CallTypes_Rawdata mc
on dc.[CallTypeCode]=mc.code
and dc.Country=mc.Country
and fo.datekey<=m.enddate
full outer join cops.dbo.businessroles_Rawdata mb
on db.[BusinessRoleCode]=mb.code
and db.Country=mb.Country


WHERE  dp.country not in ('Unknown','Kenya','N/A')
and dp.County is not null
and mb.includedincalculationcore = 3
and dd.fiscalPeriodName is not null
and dp.channel not like 'Unknown'
and dd.[datekey] > '20190701'

group by
dd.FiscalYearId,
dd.[date],
dd.CalendarMonthName,
dd.FiscalPeriodName,
dd.FiscalQuarterName,
dm.Continent,
dm.Region,
dm.SuperCluster,
CASE WHEN dp.Country='Ireland' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Iberia' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Germany' THEN 'GAS'
WHEN dp.Country='Denmark' THEN 'Nordics' ELSE dp.Country  END,
Isnull(dp.PrimaryCDOS,'Unknown'),
ISNULL(dp.Outlettype,'Unknown'),
CASE WHEN dp.SourceSystem='Comarch'then dp.[OutletGrade] else ISNULL(dpo.[Outlet Priority],'Unknown')end ,
dp.City,
dp.PostCode,
isnull(df.Name,'Unknown'),
df.active,
isnull(dt.territory,'Unknown'),
ISNULL(M.[Manager],'Unknown'),
ISNULL(M.Region,'Unknown'),
dp.Channel,
dp.OutletId,
dp.Outletname,
dp.Status,
fo.visited,
CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.status),
ISNULL(m.subcountry,dp.country)


drop table COPS_Cluster.[dbo].[Innovation_Distribution]
CREATE TABLE COPS_Cluster.[dbo].[Innovation_Distribution](
       [Year] [int] NULL,
       [date] [date] NULL,
       [Month] [varchar](30) NULL,
       [FiscalMonth] [varchar](30) NULL,
       [Quarter] [varchar](30) NULL,
       [Continent] [varchar](25) NULL,
       [BusinessUnit] [varchar](20) NULL,
       [Cluster] [varchar](100) NULL,
       [Country] [varchar](50) NULL,
       [SubCountry] [varchar](100) NULL,
       [Segment] [nvarchar](255) NULL,
       [OutletGrade] [nvarchar](255) NULL,
       [City] [nvarchar](255) NULL,
       [PostCode] [nvarchar](50) NULL,
       [SalesRepName] [nvarchar](255) NULL,
       [Salesrepstatus] [nvarchar] (255) NULL,
       Territory [nvarchar](255) NULL,
       [Manager] [nvarchar](255) NULL,
       Region [nvarchar](255) NULL,
       [Channel] [varchar](50) NULL,
       [OutletId] [varchar](255) NULL,
       [OutletName] [nvarchar](255) NULL,
       [Status] [nvarchar] (50) NULL,
       [OutletType] [varchar](50) NULL,
       [Brand] [nvarchar](255) NULL,
       [InnovationDistribution] [float] NULL ,
       [InnovationDistributionTarget] [float] NULL,
       [JoinKey] [nvarchar](1500) NOT NULL

) ON [PRIMARY]

GO

INSERT INTO COPS_Cluster.[dbo].[Innovation_Distribution]
      (
       [Year],
       [date] ,
       [Month] ,
       [FiscalMonth] ,
       [Quarter] ,
       [Continent] ,
       [BusinessUnit] ,
       [Cluster] ,
       [Country] ,
       [SubCountry] ,
       [Segment] ,
       [OutletGrade] ,
       [City] ,
       [PostCode] ,
       [SalesRepName] ,
       [Salesrepstatus],
       Territory ,
       [Manager] ,
       Region ,
       [Channel] ,
       [OutletId] ,
       [OutletName] ,
       [Status] ,
       [OutletType],
       [Brand],
       [InnovationDistribution],
       [InnovationDistributionTarget],
       [JoinKey]
     )
(
SELECT dd.FiscalYearId AS Year,
dd.[date],
dd.CalendarMonthName AS Month,
dd.FiscalPeriodName AS FiscalMonth,
dd.FiscalQuarterName AS Quarter,
crd.Continent,
crd.BusinessUnit AS BusinessUnit,
crd.Cluster AS Cluster,
dp.Country,
dp.Subcountry,
dp.Segment,
dp.outletgrade,
dp.City,
dp.PostCode,
isnull(df.Name,'Unknown') as SalesRepName,
df.active as SalesrepStatus,
isnull(dt.territory,'Unknown') AS Territory,
ISNULL(M.[Manager],'Unknown') as Manager,
ISNULL(M.Region,'Unknown') AS Region,
isnull(tm.Channel,dp.channel) as Channel,
dp.OutletID,
dp.OutletName,
dp.[Status] as [Status],
dp.outlettype as [OutletType],
tbm.BrandMapping as Brand,
Case when od.[# Products Distributed]> 0 then 1 else 0 end as [InnovationDistribution],
NULL as InnovationDistributionTarget,
CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.status) as JoinKey


FROM COPS_TRAX.[dbo].[DOOS] od
left join COPS_TRAX.[dbo].POP dp on dp.pointofpurchaseid = od.[store number] and dp.[SourceCountry]=od.[SourceCountry]
left join customerexecutionwarehouse.[Dim].[Date] dd on dd.[date] = od.[date]
left join CustomerExecutionWarehouse.[Fct].[OutletCall] fo on fo.[DateKey]=dd.DateKey and fo.[PointOfPurchaseKey]=dp.PointOfPurchaseKey
left join CustomerExecutionWarehouse.[Dim].[FieldSalesRep] df on df.[FieldSalesRepKey]=fo.[FieldSalesRepKey]
full outer join CustomerExecutionWarehouse.dim.territory dt on dt.territorykey = fo.territorykey
left JOIN CustomerExecutionWarehouse.[Dim].[Market] dm ON dm.MarketKey=fo.MarketKey
left join CustomerExecutionWarehouse.[Dim].[CallType] dc on dc.[CallTypeKey]=fo.[CallTypeKey]
left join CustomerExecutionWarehouse.[Dim].[BusinessRole] db on db.[BusinessRoleKey]=fo.[BusinessRoleKey]
left join  COPS.dbo.Salesrep_Rawdata m
on ((m.territory = dt.territory) or (m.Name = df.Name)) and (m.Country = dt.Country)
and fo.datekey <= m.enddate
Full outer join COPS.[dbo].[Cluster_Rawdata] crd on dp.country=crd.country
inner join [COPS_TRAX].[dbo].[Distribution_Mapping] tbm on od.SourceCountry=tbm.Sourcecountry
and od.Product=tbm.product
full outer join COPS_TRAX.dbo.TRAXStoreMapping tm on tm.[Store Number]=od.[Store Number] and tm.Sourcecountry=od.SourceCountry
full outer join COPS.dbo.CallTypes_Rawdata mc
on dc.[CallTypeCode]=mc.code
and dc.Country=mc.Country
and fo.datekey<=m.enddate
full outer join cops.dbo.businessroles_Rawdata mb
on db.[BusinessRoleCode]=mb.code
and db.Country=mb.Country

Where dp.country not in ('Kenya')
and dd.datekey > '20190701'
and mb.includedincalculationcore = 3
and tbm.[Core/Innovation] ='Innovation' 

group by

dd.FiscalYearId ,
dd.[date],
dd.CalendarMonthName ,
dd.FiscalPeriodName ,
dd.FiscalQuarterName ,
crd.Continent,
crd.BusinessUnit ,
crd.Cluster ,
dp.Country,
dp.Subcountry,
dp.Segment,
dp.outletgrade,
dp.City,
dp.PostCode,
isnull(df.Name,'Unknown'),
df.active,
isnull(dt.territory,'Unknown'),
ISNULL(M.[Manager],'Unknown'),
ISNULL(M.Region,'Unknown'),
isnull(tm.Channel,dp.channel),
dp.OutletID,
dp.OutletName,
dp.[Status],
dp.[OutletType],
tbm.BrandMapping,
Case when od.[# Products Distributed] > 0 then 1 else 0 end,
CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.status)
)

drop table COPS_Cluster.[dbo].[Numeric_Distribution]
CREATE TABLE COPS_Cluster.[dbo].[Numeric_Distribution](
       [Year] [int] NULL,
       [date] [date] NULL,
       [Month] [varchar](30) NULL,
       [FiscalMonth] [varchar](30) NULL,
       [Quarter] [varchar](30) NULL,
       [Continent] [varchar](25) NULL,
       [BusinessUnit] [varchar](20) NULL,
       [Cluster] [varchar](100) NULL,
       [Country] [varchar](50) NULL,
       [SubCountry] [varchar](100) NULL,
       [Segment] [nvarchar](255) NULL,
       [OutletGrade] [nvarchar](255) NULL,
       [City] [nvarchar](255) NULL,
       [PostCode] [nvarchar](50) NULL,
       [SalesRepName] [nvarchar](255) NULL,
       [Salesrepstatus] [nvarchar] (255) NULL,
       Territory [nvarchar](255) NULL,
       [Manager] [nvarchar](255) NULL,
       Region [nvarchar](255) NULL,
       [Channel] [varchar](50) NULL,
       [OutletId] [varchar](255) NULL,
       [OutletName] [nvarchar](255) NULL,
       [Status] [nvarchar] (50) NULL,
       [OutletType] [varchar](50) NULL,
       [Brand] [nvarchar](255) NULL,
       [NumericDistribution] [float] NULL ,
       [NumericDistributionTarget] [float] NULL,
       [JoinKey] [nvarchar](1500) NOT NULL

) ON [PRIMARY]

GO

INSERT INTO COPS_Cluster.[dbo].[Numeric_Distribution]
      (
       [Year],
       [date] ,
       [Month] ,
       [FiscalMonth] ,
       [Quarter] ,
       [Continent] ,
       [BusinessUnit] ,
       [Cluster] ,
       [Country] ,
       [SubCountry] ,
       [Segment] ,
       [OutletGrade] ,
       [City] ,
       [PostCode] ,
       [SalesRepName] ,
       [Salesrepstatus],
       Territory ,
       [Manager] ,
       Region ,
       [Channel] ,
       [OutletId] ,
       [OutletName] ,
       [Status] ,
       [OutletType],
       [Brand],
       [NumericDistribution],
       [NumericDistributionTarget],
       [JoinKey]
     )
(
SELECT dd.FiscalYearId AS Year,
dd.[date],
dd.CalendarMonthName AS Month,
dd.FiscalPeriodName AS FiscalMonth,
dd.FiscalQuarterName AS Quarter,
crd.Continent,
crd.BusinessUnit AS BusinessUnit,
crd.Cluster AS Cluster,
dp.Country,
dp.Subcountry,
dp.Segment,
dp.outletgrade,
dp.City,
dp.PostCode,
isnull(df.Name,'Unknown') as SalesRepName,
df.active as SalesrepStatus,
isnull(dt.territory,'Unknown') AS Territory,
ISNULL(M.[Manager],'Unknown') as Manager,
ISNULL(M.Region,'Unknown') AS Region,
isnull(tm.Channel,dp.channel) as Channel,
dp.OutletID,
dp.OutletName,
dp.[Status] as [Status],
dp.outlettype as [OutletType],
tbm.BrandMapping as Brand,
Case when od.[# Products Distributed] > 0 then 1 else 0 end as [NumericDistribution],
NULL as NumericDistributionTarget,
CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.status) as JoinKey


FROM COPS_TRAX.[dbo].[DOOS] od
left join COPS_TRAX.[dbo].POP dp on dp.pointofpurchaseid = od.[store number] and dp.[SourceCountry]=od.[SourceCountry]
left join customerexecutionwarehouse.[Dim].[Date] dd on dd.[date] = od.[date]
left join CustomerExecutionWarehouse.[Fct].[OutletCall] fo on fo.[DateKey]=dd.DateKey and fo.[PointOfPurchaseKey]=dp.PointOfPurchaseKey
left join CustomerExecutionWarehouse.[Dim].[FieldSalesRep] df on df.[FieldSalesRepKey]=fo.[FieldSalesRepKey]
full outer join CustomerExecutionWarehouse.dim.territory dt on dt.territorykey = fo.territorykey
left JOIN CustomerExecutionWarehouse.[Dim].[Market] dm ON dm.MarketKey=fo.MarketKey
left join CustomerExecutionWarehouse.[Dim].[CallType] dc on dc.[CallTypeKey]=fo.[CallTypeKey]
left join CustomerExecutionWarehouse.[Dim].[BusinessRole] db on db.[BusinessRoleKey]=fo.[BusinessRoleKey]
left join  COPS.dbo.Salesrep_Rawdata m
on ((m.territory = dt.territory) or (m.Name = df.Name)) and (m.Country = dt.Country)
and fo.datekey <= m.enddate

Full outer join COPS.[dbo].[Cluster_Rawdata] crd on dp.country=crd.country
inner join [COPS_TRAX].[dbo].[Distribution_Mapping] tbm on od.SourceCountry=tbm.Sourcecountry
and od.Product=tbm.product
full outer join COPS_TRAX.dbo.TRAXStoreMapping tm on tm.[Store Number]=od.[Store Number] and tm.Sourcecountry=od.SourceCountry

Where dp.country not in ('Kenya')
and dd.datekey > '20190701'
and mb.includedincalculationcore = 3
and tbm.[Core/Innovation] ='Core'

group by

dd.FiscalYearId ,
dd.[date],
dd.CalendarMonthName ,
dd.FiscalPeriodName ,
dd.FiscalQuarterName ,
crd.Continent,
crd.BusinessUnit ,
crd.Cluster ,
dp.Country,
dp.Subcountry,
dp.Segment,
dp.outletgrade,
dp.City,
dp.PostCode,
isnull(df.Name,'Unknown'),
df.active,
isnull(dt.territory,'Unknown'),
ISNULL(M.[Manager],'Unknown'),
ISNULL(M.Region,'Unknown'),
isnull(tm.Channel,dp.channel),
dp.OutletID,
dp.OutletName,
dp.[Status],
dp.[OutletType],
tbm.BrandMapping,
Case when od.[# Products Distributed] > 0 then 1 else 0 end,
CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.status)
)


drop table AssortmentStandard_FoodLed
CREATE TABLE [dbo].[AssortmentStandard_FoodLed](
       [Year] [int] NULL,
       [date] [date] NULL,
       [Month] [varchar](30) NULL,
       [FiscalMonth] [varchar](30) NULL,
       [Quarter] [varchar](30) NULL,
       [Continent] [varchar](25) NULL,
       [BusinessUnit] [varchar](20) NULL,
       [Cluster] [varchar](100) NULL,
       [Country] [varchar](50) NULL,
       [SubCountry] [varchar](100) NULL,
       [Segment] [nvarchar](255) NULL,
       [Outlettype] [nvarchar] (255) NULL,
       [OutletGrade] [nvarchar](255) NULL,
       [City] [nvarchar](50) NULL,
       [PostCode] [nvarchar](50) NULL,
       [SalesRepName] [nvarchar](255) NULL,
       [SalesrepStatus] [nvarchar] (255) NULL,
       [Territory] [nvarchar](255) NULL,
       [Manager] [nvarchar](255) NULL,
       [Region] [nvarchar](255) NULL,
       [Channel] [varchar](50) NULL,
       [OutletId] [nvarchar](340) NULL,
       [OutletName] [nvarchar](340) NULL,
       [Status] [nvarchar] (50) NULL,
       AssortmentStandard [float] NULL,
	   AssortmentStandardTarget [float] NULL,
       [JoinKey] [nvarchar](max) NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

INSERT INTO [COPS_Cluster].[dbo].[AssortmentStandard_FoodLed]
     ( [Year]
      ,[date]
      ,[Month]
      ,[FiscalMonth]
      ,[Quarter]
      ,[Continent]
      ,[BusinessUnit]
      ,[Cluster]
      ,[Country]
      ,[SubCountry]
      ,[Segment]
      ,[outlettype]
      ,[OutletGrade]
      ,[City]
      ,[PostCode]
      ,[SalesRepName]
      ,[SalesrepStatus]
      ,[Territory]
      ,[Manager]
      ,[Region]
      ,[Channel]
		  ,[OutletId]
		  ,[OutletName]
      ,[Status]
      ,AssortmentStandard
	    ,AssortmentStandardTarget
      ,[JoinKey]
)
(
SELECT dd.FiscalYearId AS Year,
dd.[date],
dd.CalendarMonthName AS Month,
dd.FiscalPeriodName AS FiscalMonth,
dd.FiscalQuarterName AS Quarter,
crd.Continent,
crd.Businessunit AS BusinessUnit,
crd.Cluster AS Cluster,
dp.Country,
dp.Subcountry,
dp.Segment,
dp.outlettype as [OutletType],
dp.outletgrade,
dp.City,
dp.PostCode,
isnull(df.Name,'Unknown') as SalesRepName,
df.active as SalesrepStatus,
isnull(dt.territory,'Unknown') AS Territory,
ISNULL(M.[Manager],'Unknown') as Manager,
ISNULL(M.Region,'Unknown') AS Region,
tm.Channel,
dp.OutletID,
dp.OutletName,
dp.[Status] as [Status],
mpa.[# Scored Stores] as AssortmentStandard,
NULL as AssortmentStandardTarget,
CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.status) as JoinKey

FROM
COPS_TRAX.dbo.MPA mpa
left join COPS_TRAX.[dbo].POP dp on dp.pointofpurchaseid = mpa.[store number] and dp.[SourceCountry]=mpa.[SourceCountry]
left join customerexecutionwarehouse.[Dim].[Date] dd on dd.[date] = mpa.[date]
left join CustomerExecutionWarehouse.[Fct].[OutletCall] fo on fo.[DateKey]=dd.DateKey and fo.[PointOfPurchaseKey]=dp.PointOfPurchaseKey
left join CustomerExecutionWarehouse.[Dim].[FieldSalesRep] df on df.[FieldSalesRepKey]=fo.[FieldSalesRepKey]
full outer join CustomerExecutionWarehouse.dim.territory dt on dt.territorykey = fo.territorykey
left JOIN CustomerExecutionWarehouse.[Dim].[Market] dm ON dm.MarketKey=fo.MarketKey
left join CustomerExecutionWarehouse.[Dim].[CallType] dc on dc.[CallTypeKey]=fo.[CallTypeKey]
left join CustomerExecutionWarehouse.[Dim].[BusinessRole] db on db.[BusinessRoleKey]=fo.[BusinessRoleKey]
left join  COPS.dbo.Salesrep_Rawdata m
on ((m.territory = dt.territory) or (m.Name = df.Name)) and (m.Country = dt.Country)
and fo.datekey <= m.enddate

left join COPS.[dbo].[Cluster_Rawdata] crd on dp.country=crd.country
full outer join COPS_TRAX.dbo.TRAXStoreMapping tm on tm.[Store Number]=mpa.[Store Number] and tm.Sourcecountry=mpa.SourceCountry
full outer join COPS.dbo.CallTypes_Rawdata mc
on dc.[CallTypeCode]=mc.code
and dc.Country=mc.Country
and fo.datekey<=m.enddate
full outer join cops.dbo.businessroles_Rawdata mb
on db.[BusinessRoleCode]=mb.code
and db.Country=mb.Country

Where dp.country not in ('Kenya')
and dd.datekey > '20190701'
and mb.includedincalculationcore = 3
and mpa.[Assortment] in ('MPA','LMPA', 'GMPA')

group by
dd.FiscalYearId ,
dd.[date],
dd.CalendarMonthName ,
dd.FiscalPeriodName ,
dd.FiscalQuarterName ,
crd.Continent,
crd.Businessunit ,
crd.Cluster ,
dp.Country,
dp.Subcountry,
dp.Segment,
dp.outletgrade,
dp.City,
dp.PostCode,
isnull(df.Name,'Unknown'),
df.active,
isnull(dt.territory,'Unknown'),
ISNULL(M.[Manager],'Unknown'),
ISNULL(M.Region,'Unknown'),
tm.Channel,
dp.OutletID,
dp.OutletName,
dp.[Status],
dp.[OutletType],
mpa.[# Scored Stores],
CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.status)
)

drop table COPS_Cluster.[dbo].[OutOfStock]
CREATE TABLE COPS_Cluster.[dbo].[OutOfStock](
       [Year] [int] NULL,
       [date] [date] NULL,
       [Month] [varchar](30) NULL,
       [FiscalMonth] [varchar](30) NULL,
       [Quarter] [varchar](30) NULL,
       [Continent] [varchar](25) NULL,
       [BusinessUnit] [varchar](20) NULL,
       [Cluster] [varchar](100) NULL,
       [Country] [varchar](50) NULL,
       [SubCountry] [varchar](100) NULL,
       [Segment] [nvarchar](255) NULL,
       [OutletGrade] [nvarchar](255) NULL,
       [City] [nvarchar](255) NULL,
       [PostCode] [nvarchar](50) NULL,
       [SalesRepName] [nvarchar](255) NULL,
       [Salesrepstatus] [nvarchar] (255) NULL,
       Territory [nvarchar](255) NULL,
       [Manager] [nvarchar](255) NULL,
       Region [nvarchar](255) NULL,
       [Channel] [varchar](50) NULL,
       [OutletId] [varchar](255) NULL,
       [OutletName] [nvarchar](255) NULL,
       [Status] [nvarchar] (50) NULL,
       [OutletType] [varchar](50) NULL,
       [Brand] [nvarchar](255) NULL,
       [OutOfStock] [float] NULL ,
       [JoinKey] [nvarchar](1500) NOT NULL

) ON [PRIMARY]

GO

INSERT INTO COPS_Cluster.[dbo].[OutOfStock]
( [Year],
       [date] ,
       [Month] ,
       [FiscalMonth] ,
       [Quarter] ,
       [Continent] ,
       [BusinessUnit] ,
       [Cluster] ,
       [Country] ,
       [SubCountry] ,
       [Segment] ,
       [OutletGrade] ,
       [City] ,
       [PostCode] ,
       [SalesRepName] ,
       [Salesrepstatus],
       Territory ,
       [Manager] ,
       Region ,
       [Channel] ,
       [OutletId] ,
       [OutletName] ,
       [Status] ,
       [OutletType],
       [Brand],
       [OutOfStock],
       [JoinKey])

(
SELECT dd.FiscalYearId AS Year,
dd.[date],
dd.CalendarMonthName AS Month,
dd.FiscalPeriodName AS FiscalMonth,
dd.FiscalQuarterName AS Quarter,
crd.Continent,
crd.BusinessUnit AS BusinessUnit,
crd.Cluster AS Cluster,
dp.Country,
dp.Subcountry,
dp.Segment,
dp.outletgrade,
dp.City,
dp.PostCode,
isnull(df.Name,'Unknown') as SalesRepName,
df.active as SalesrepStatus,
isnull(dt.territory,'Unknown') AS Territory,
ISNULL(M.[Manager],'Unknown') as Manager,
ISNULL(M.Region,'Unknown') AS Region,
isnull(tm.Channel,dp.channel) as Channel,
dp.OutletID,
dp.OutletName,
dp.[Status] as [Status],
dp.outlettype as [OutletType],
tbm.BrandMapping as Brand,
Case when od.[# Products Distributed] = 0 then 1 else 0 end as [OutofStock],
CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.status) as JoinKey


FROM COPS_TRAX.[dbo].[DOOS] od
left join COPS_TRAX.[dbo].POP dp on dp.pointofpurchaseid = od.[store number] and dp.[SourceCountry]=od.[SourceCountry]
left join customerexecutionwarehouse.[Dim].[Date] dd on dd.[date] = od.[date]
left join CustomerExecutionWarehouse.[Fct].[OutletCall] fo on fo.[DateKey]=dd.DateKey and fo.[PointOfPurchaseKey]=dp.PointOfPurchaseKey
left join CustomerExecutionWarehouse.[Dim].[FieldSalesRep] df on df.[FieldSalesRepKey]=fo.[FieldSalesRepKey]
full outer join CustomerExecutionWarehouse.dim.territory dt on dt.territorykey = fo.territorykey
left JOIN CustomerExecutionWarehouse.[Dim].[Market] dm ON dm.MarketKey=fo.MarketKey
left join CustomerExecutionWarehouse.[Dim].[CallType] dc on dc.[CallTypeKey]=fo.[CallTypeKey]
left join CustomerExecutionWarehouse.[Dim].[BusinessRole] db on db.[BusinessRoleKey]=fo.[BusinessRoleKey]
left join  COPS.dbo.Salesrep_Rawdata m
on ((m.territory = dt.territory) or (m.Name = df.Name)) and (m.Country = dt.Country)
and fo.datekey <= m.enddate

Full outer join COPS.[dbo].[Cluster_Rawdata] crd on dp.country=crd.country
inner join [COPS_TRAX].[dbo].[Distribution_Mapping] tbm on od.SourceCountry=tbm.Sourcecountry
and od.Product=tbm.product
full outer join COPS_TRAX.dbo.TRAXStoreMapping tm on tm.[Store Number]=od.[Store Number] and tm.Sourcecountry=od.SourceCountry
full outer join COPS.dbo.CallTypes_Rawdata mc
on dc.[CallTypeCode]=mc.code
and dc.Country=mc.Country
and fo.datekey<=m.enddate
full outer join cops.dbo.businessroles_Rawdata mb
on db.[BusinessRoleCode]=mb.code
and db.Country=mb.Country


Where dp.country not in ('Kenya')
and dd.datekey > '20190701'
and mb.includedincalculationcore = 3
and tbm.[Core/Innovation] ='Core'
group by

dd.FiscalYearId ,
dd.[date],
dd.CalendarMonthName ,
dd.FiscalPeriodName ,
dd.FiscalQuarterName ,
crd.Continent,
crd.BusinessUnit ,
crd.Cluster ,
dp.Country,
dp.Subcountry,
dp.Segment,
dp.outletgrade,
dp.City,
dp.PostCode,
isnull(df.Name,'Unknown'),
df.active,
isnull(dt.territory,'Unknown'),
ISNULL(M.[Manager],'Unknown'),
ISNULL(M.Region,'Unknown'),
isnull(tm.Channel,dp.channel),
dp.OutletID,
dp.OutletName,
dp.[Status],
dp.[OutletType],
tbm.BrandMapping,
Case when od.[# Products Distributed] = 0 then 1 else 0 end,
CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.status)
)

drop table TraxAudits_FoodLed
CREATE TABLE [dbo].[TraxAudits_FoodLed](
       [Year] [int] NULL,
       [date] [date] NULL,
       [Month] [varchar](30) NULL,
       [FiscalMonth] [varchar](30) NULL,
       [Quarter] [varchar](30) NULL,
       [Continent] [varchar](25) NULL,
       [BusinessUnit] [varchar](20) NULL,
       [Cluster] [varchar](100) NULL,
       [Country] [varchar](50) NULL,
       [SubCountry] [varchar](100) NULL,
       [Segment] [nvarchar](255) NULL,
       [Outlettype] [nvarchar] (255) NULL,
       [OutletGrade] [nvarchar](255) NULL,
       [City] [nvarchar](50) NULL,
       [PostCode] [nvarchar](50) NULL,
       [SalesRepName] [nvarchar](255) NULL,
       [SalesrepStatus] [nvarchar] (255) NULL,
       [Territory] [nvarchar](255) NULL,
       [Manager] [nvarchar](255) NULL,
       [Region] [nvarchar](255) NULL,
       [Channel] [varchar](50) NULL,
       [OutletId] [nvarchar](340) NULL,
       [OutletName] [nvarchar](340) NULL,
       [Status] [nvarchar] (50) NULL,
       TraxAudits [float] NULL,
	   TraxAuditsTarget [float] NULL,
       [JoinKey] [nvarchar](max) NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

INSERT INTO [COPS_Cluster].[dbo].[TraxAudits_FoodLed]
     ( [Year]
      ,[date]
      ,[Month]
      ,[FiscalMonth]
      ,[Quarter]
      ,[Continent]
      ,[BusinessUnit]
      ,[Cluster]
      ,[Country]
      ,[SubCountry]
      ,[Segment]
      ,[outlettype]
      ,[OutletGrade]
      ,[City]
      ,[PostCode]
      ,[SalesRepName]
      ,[SalesrepStatus]
      ,[Territory]
      ,[Manager]
      ,[Region]
      ,[Channel]
		  ,[OutletId]
		  ,[OutletName]
      ,[Status]
      ,TraxAudits
	    ,TraxAuditsTarget
      ,[JoinKey]
)
SELECT dd.FiscalYearId AS Year,
dd.[date],
dd.CalendarMonthName AS Month,
dd.FiscalPeriodName AS FiscalMonth,
dd.FiscalQuarterName AS Quarter,
crd.Continent,
crd.Businessunit AS BusinessUnit,
crd.Cluster AS Cluster,
dp.Country,
dp.Subcountry,
dp.Segment,
dp.outlettype as [OutletType],
dp.outletgrade,
dp.City,
dp.PostCode,
isnull(df.Name,'Unknown') as SalesRepName,
df.active as SalesrepStatus,
isnull(dt.territory,'Unknown') AS Territory,
ISNULL(M.[Manager],'Unknown') as Manager,
ISNULL(M.Region,'Unknown') AS Region,
tm.Channel,
dp.OutletID,
dp.OutletName,
dp.[Status] as [Status],
mpa.[# Scenes] as TraxAudits,
NULL as TraxAuditsTarget,
CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.status) as JoinKey

FROM
COPS_TRAX.dbo.TRAXStoreMapping mpa
left join COPS_TRAX.[dbo].POP dp on dp.pointofpurchaseid = mpa.[store number] and dp.[SourceCountry]=mpa.[SourceCountry]
left join customerexecutionwarehouse.[Dim].[Date] dd on dd.[date] = mpa.[date]
left join CustomerExecutionWarehouse.[Fct].[OutletCall] fo on fo.[DateKey]=dd.DateKey and fo.[PointOfPurchaseKey]=dp.PointOfPurchaseKey
left join COPS.[dbo].[Cluster_Rawdata] crd on dp.country=crd.country
left join CustomerExecutionWarehouse.[Dim].[FieldSalesRep] df on df.[FieldSalesRepKey]=fo.[FieldSalesRepKey]
full outer join CustomerExecutionWarehouse.dim.territory dt on dt.territorykey = fo.territorykey
left JOIN CustomerExecutionWarehouse.[Dim].[Market] dm ON dm.MarketKey=fo.MarketKey
left join CustomerExecutionWarehouse.[Dim].[CallType] dc on dc.[CallTypeKey]=fo.[CallTypeKey]
left join CustomerExecutionWarehouse.[Dim].[BusinessRole] db on db.[BusinessRoleKey]=fo.[BusinessRoleKey]
left join  COPS.dbo.Salesrep_Rawdata m
on ((m.territory = dt.territory) or (m.Name = df.Name)) and (m.Country = dt.Country)
and fo.datekey <= m.enddate

full outer join COPS_TRAX.dbo.TRAXStoreMapping tm on tm.[Store Number]=mpa.[Store Number] and tm.Sourcecountry=mpa.SourceCountry
full outer join COPS.dbo.CallTypes_Rawdata mc
on dc.[CallTypeCode]=mc.code
and dc.Country=mc.Country
and fo.datekey<=m.enddate
full outer join cops.dbo.businessroles_Rawdata mb
on db.[BusinessRoleCode]=mb.code
and db.Country=mb.Country

Where dp.country not in ('Kenya')
and mb.includedincalculationcore = 3
and dd.datekey > '20190701'

group by
dd.FiscalYearId ,
dd.[date],
dd.CalendarMonthName ,
dd.FiscalPeriodName ,
dd.FiscalQuarterName ,
crd.Continent,
crd.Businessunit ,
crd.Cluster ,
dp.Country,
dp.Subcountry,
dp.Segment,
dp.outletgrade,
dp.City,
dp.PostCode,
isnull(df.Name,'Unknown'),
df.active,
isnull(dt.territory,'Unknown'),
ISNULL(M.[Manager],'Unknown'),
ISNULL(M.Region,'Unknown'),
tm.Channel,
dp.OutletID,
dp.OutletName,
dp.[Status],
dp.[OutletType],
mpa.[# Scenes],
CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.status)


---TotalShelfSOS
drop table COPS_Cluster.[dbo].TotalStore_SOS_FoodLed
CREATE TABLE COPS_Cluster.[dbo].TotalStore_SOS_FoodLed
(
[Year] [int] NULL,
[date] [date] NULL,
[Month] [varchar](30) NULL,
[FiscalMonth] [varchar](30) NULL,
[Quarter] [varchar](30) NULL,
[Continent] [varchar](25) NULL,
[BusinessUnit] [varchar](20) NULL,
[Cluster] [varchar](100) NULL,
[Country] [varchar](50) NULL,
[SubCountry] [varchar](100) NULL,
[Segment] [nvarchar](255) NULL,
[OutletGrade] [nvarchar](255) NULL,
[City] [nvarchar](50) NULL,
[PostCode] [nvarchar](50) NULL,
[SalesRepName] [nvarchar](255) NULL,
[Salesrepstatus] [nvarchar] (255) NULL,
[Territory] [nvarchar](255) NULL,
[Manager] [nvarchar](255) NULL,
[Region] [nvarchar](255) NULL,
[Channel] [varchar](50) NULL,
[OutletID] [varchar](255) NULL,
[OutletName] [nvarchar](255) NULL,
[Status] [nvarchar] (50) NULL,
[OutletType] [varchar](50) NULL,
[Manufacturer] [nvarchar](255) NULL ,
[Product] [nvarchar](255) NULL,
TotalDiageoFacings [float] NULL,
TotalStoreFacings [float] NULL,
[JoinKey] [nvarchar](1500) NOT NULL


)

INSERT INTO COPS_Cluster.[dbo].TotalStore_SOS_FoodLed
(
[Year],
[date],
[Month],
[FiscalMonth],
[Quarter],
[Continent],
[BusinessUnit],
[Cluster],
[Country],
[SubCountry],
[Segment],
[OutletGrade],
[City],
[PostCode],
[SalesRepName],
[Salesrepstatus],
[Territory],
[Manager],
[Region],
[Channel],
[OutletID],
[OutletName],
[Status] ,
[OutletType],
[Manufacturer] ,
[Product],
TotalDiageoFacings ,
TotalStoreFacings,
[JoinKey]
)
(

SELECT dd.FiscalYearId AS Year,
dd.[date],
dd.CalendarMonthName AS Month,
dd.FiscalPeriodName AS FiscalMonth,
dd.FiscalQuarterName AS Quarter,
crd.Continent,
crd.Businessunit AS BusinessUnit,
crd.Cluster AS Cluster,
crd.Country,
dp.Subcountry,
dp.Segment,
dp.outletgrade,
dp.City,
dp.PostCode,
isnull(df.Name,'Unknown') as SalesRepName,
df.active as SalesrepStatus,
isnull(dt.territory,'Unknown') AS Territory,
ISNULL(M.[Manager],'Unknown') as Manager,
ISNULL(M.Region,'Unknown') AS Region,
f.Channel,
dp.OutletID,
dp.OutletName,
dp.[Status] as [Status],
dp.[OutletType] as [OutletType],
f.[Manufacturer] as [Manufacturer],
f.[Product] as Product,
CASE WHEN f.[Manufacturer]='Diageo' then f.facings end as TotalDiageoFacings,
f.[facings] as TotalStoreFacings,
CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.Status) as JoinKey

FROM COPS_TRAX.[dbo].[Facings_Combinedtest] f
left join COPS_TRAX.[dbo].POP dp on dp.pointofpurchaseid = f.[store number] and dp.[SourceCountry]=f.[SourceCountry]
left join customerexecutionwarehouse.[Dim].[Date] dd on dd.[date] = f.[date]
left join CustomerExecutionWarehouse.[Fct].[OutletCall] fo on fo.[DateKey]=dd.DateKey and fo.[PointOfPurchaseKey]=dp.PointOfPurchaseKey
left join COPS.[dbo].[Cluster_Rawdata] crd on dp.country=crd.country
left JOIN CustomerExecutionWarehouse.[Dim].[Market] dm ON dm.MarketKey=fo.MarketKey
left join CustomerExecutionWarehouse.[Dim].[CallType] dc on dc.[CallTypeKey]=fo.[CallTypeKey]
left join CustomerExecutionWarehouse.[Dim].[BusinessRole] db on db.[BusinessRoleKey]=fo.[BusinessRoleKey]
left join CustomerExecutionWarehouse.[Dim].[FieldSalesRep] df on df.[FieldSalesRepKey]=fo.[FieldSalesRepKey]
full outer join CustomerExecutionWarehouse.dim.territory dt on dt.territorykey = fo.territorykey
left join  COPS.dbo.Salesrep_Rawdata m
on ((m.territory = dt.territory) or (m.Name = df.Name)) and (m.Country = dt.Country)
and fo.datekey <= m.enddate
full outer join COPS.dbo.CallTypes_Rawdata mc
on dc.[CallTypeCode]=mc.code
and dc.Country=mc.Country
and fo.datekey<=m.enddate
full outer join cops.dbo.businessroles_Rawdata mb
on db.[BusinessRoleCode]=mb.code
and db.Country=mb.Country


WHERE  dp.country not in ('Kenya')
and mb.includedincalculationcore = 3
and dd.datekey > '20190701'
group by
dd.FiscalYearId ,
dd.[date],
dd.CalendarMonthName ,
dd.FiscalPeriodName ,
dd.FiscalQuarterName ,
crd.Continent,
crd.Businessunit ,
crd.Cluster ,
crd.Country,
dp.Subcountry,
dp.Segment,
dp.outletgrade,
dp.City,
dp.PostCode,
isnull(df.Name,'Unknown'),
df.active,
isnull(dt.territory,'Unknown'),
ISNULL(M.[Manager],'Unknown'),
ISNULL(M.Region,'Unknown'),
f.Channel,
dp.OutletID,
dp.OutletName,
dp.[Status],
dp.[OutletType],
f.[Manufacturer] ,
f.[Product],
CASE WHEN f.[Manufacturer]='Diageo' then f.facings end ,
f.[facings] ,
CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.status)
)

use COPS_Cluster
drop table COPS_Cluster.[dbo].SecondaryStore_SOS_FoodLed
CREATE TABLE COPS_Cluster.[dbo].SecondaryStore_SOS_FoodLed
(
[Year] [int] NULL,
[date] [date] NULL,
[Month] [varchar](30) NULL,
[FiscalMonth] [varchar](30) NULL,
[Quarter] [varchar](30) NULL,
[Continent] [varchar](25) NULL,
[BusinessUnit] [varchar](20) NULL,
[Cluster] [varchar](100) NULL,
[Country] [varchar](50) NULL,
[SubCountry] [varchar](100) NULL,
[Segment] [nvarchar](255) NULL,
[OutletGrade] [nvarchar](255) NULL,
[City] [nvarchar](50) NULL,
[PostCode] [nvarchar](50) NULL,
[SalesRepName] [nvarchar](255) NULL,
[Salesrepstatus] [nvarchar] (255) NULL,
[Territory] [nvarchar](255) NULL,
[Manager] [nvarchar](255) NULL,
[Region] [nvarchar](255) NULL,
[Channel] [varchar](50) NULL,
[OutletID] [varchar](255) NULL,
[OutletName] [nvarchar](255) NULL,
[Status] [nvarchar] (50) NULL,
[OutletType] [varchar](50) NULL,
[Product] [nvarchar] (255) NULL,
[SecondaryDiageoFacings] [float] null,
[TotalSecondaryFacings] [float] null,
[Manufacturer] [nvarchar] (50) null,
[JoinKey] [nvarchar](1500) NOT NULL
)

INSERT INTO [COPS_Cluster].[dbo].SecondaryStore_SOS_FoodLed
(
[Year],
[date],
[Month],
[FiscalMonth],
[Quarter],
[Continent],
[BusinessUnit],
[Cluster],
[Country],
[SubCountry],
[Segment],
[OutletGrade],
[City],
[PostCode],
[SalesRepName],
[Salesrepstatus],
[Territory],
[Manager],
[Region],
[Channel],
[OutletID],
[OutletName],
[Status] ,
[OutletType],
[Product],
[SecondaryDiageoFacings],
[TotalSecondaryFacings],
[Manufacturer],
[JoinKey]
)

(
SELECT dd.FiscalYearId AS Year,
dd.[date],
dd.CalendarMonthName AS Month,
dd.FiscalPeriodName AS FiscalMonth,
dd.FiscalQuarterName AS Quarter,
crd.Continent,
crd.Businessunit AS BusinessUnit,
crd.Cluster AS Cluster,
crd.Country,
dp.Subcountry,
dp.Segment,
dp.outletgrade,
dp.City,
dp.PostCode,
isnull(df.Name,'Unknown') as SalesRepName,
df.active as SalesrepStatus,
isnull(dt.territory,'Unknown') AS Territory,
ISNULL(M.[Manager],'Unknown') as Manager,
ISNULL(M.Region,'Unknown') AS Region,
f.Channel,
dp.OutletID,
dp.OutletName,
dp.Status,
dp.outlettype,
f.[Product] as Brand,
CASE WHEN f.[Manufacturer]='Diageo' then f.facings end as [SecondaryDiageoFacings],
f.[Facings]  as [TotalSecondaryFacings],
f.[Manufacturer],
CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.Status) as JoinKey

FROM COPS_TRAX.[dbo].[Facings_Combinedtest] f
left join COPS_TRAX.[dbo].POP dp on dp.pointofpurchaseid = f.[store number] and dp.[SourceCountry]=f.[SourceCountry]
left join customerexecutionwarehouse.[Dim].[Date] dd on dd.[date] = f.[date]
left join CustomerExecutionWarehouse.[Fct].[OutletCall] fo on fo.[DateKey]=dd.DateKey and fo.[PointOfPurchaseKey]=dp.PointOfPurchaseKey
left join COPS.[dbo].[Cluster_Rawdata] crd on dp.country=crd.country
left JOIN CustomerExecutionWarehouse.[Dim].[Market] dm ON dm.MarketKey=fo.MarketKey
left join CustomerExecutionWarehouse.[Dim].[CallType] dc on dc.[CallTypeKey]=fo.[CallTypeKey]
left join CustomerExecutionWarehouse.[Dim].[BusinessRole] db on db.[BusinessRoleKey]=fo.[BusinessRoleKey]
left join CustomerExecutionWarehouse.[Dim].[FieldSalesRep] df on df.[FieldSalesRepKey]=fo.[FieldSalesRepKey]
full outer join CustomerExecutionWarehouse.dim.territory dt on dt.territorykey = fo.territorykey
left join  COPS.dbo.Salesrep_Rawdata m
on ((m.territory = dt.territory) or (m.Name = df.Name)) and (m.Country = dt.Country)
and fo.datekey <= m.enddate
full outer join COPS.dbo.CallTypes_Rawdata mc
on dc.[CallTypeCode]=mc.code
and dc.Country=mc.Country
and fo.datekey<=m.enddate
full outer join cops.dbo.businessroles_Rawdata mb
on db.[BusinessRoleCode]=mb.code
and db.Country=mb.Country


WHERE  dp.country not in ('Kenya')
and dd.datekey > '20190701'
and mb.includedincalculationcore = 3
and f.[Scn#location_type] in ('Secondary', 'Secondary Shelf')

group by
dd.FiscalYearId ,
dd.[date],
dd.CalendarMonthName ,
dd.FiscalPeriodName ,
dd.FiscalQuarterName ,
crd.Continent,
crd.Businessunit ,
crd.Cluster ,
crd.Country,
dp.Subcountry,
dp.Segment,
dp.outletgrade,
dp.City,
dp.PostCode,
isnull(df.Name,'Unknown'),
df.active,
isnull(dt.territory,'Unknown'),
ISNULL(M.[Manager],'Unknown'),
ISNULL(M.Region,'Unknown'),
f.Channel,
dp.OutletID,
dp.OutletName,
dp.Status,
dp.outlettype,
f.[Product],
CASE WHEN f.[Manufacturer]='Diageo' then f.facings end,
f.[facings],
f.[Manufacturer],
CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.Status))


---MainStoreSOS
use COPS_Cluster
drop table COPS_Cluster.[dbo].MainStore_SOS_FoodLed
CREATE TABLE COPS_Cluster.[dbo].MainStore_SOS_FoodLed
(
[Year] [int] NULL,
[date] [date] NULL,
[Month] [varchar](30) NULL,
[FiscalMonth] [varchar](30) NULL,
[Quarter] [varchar](30) NULL,
[Continent] [varchar](25) NULL,
[BusinessUnit] [varchar](20) NULL,
[Cluster] [varchar](100) NULL,
[Country] [varchar](50) NULL,
[SubCountry] [varchar](100) NULL,
[Segment] [nvarchar](255) NULL,
[OutletGrade] [nvarchar](255) NULL,
[City] [nvarchar](50) NULL,
[PostCode] [nvarchar](50) NULL,
[SalesRepName] [nvarchar](255) NULL,
[Salesrepstatus] [nvarchar] (255) NULL,
[Territory] [nvarchar](255) NULL,
[Manager] [nvarchar](255) NULL,
[Region] [nvarchar](255) NULL,
[Channel] [varchar](50) NULL,
[OutletID] [varchar](255) NULL,
[OutletName] [nvarchar](255) NULL,
[Status] [nvarchar] (50) NULL,
[OutletType] [varchar](50) NULL,
[Brand] [nvarchar] (255) NULL,
MainShelfDiageoFacings [float] null,
MainShelfFacings [float] null,
[Manufacturer] [nvarchar] (50) null,
[JoinKey] [nvarchar](1500) NOT NULL
)

INSERT INTO [COPS_Cluster].[dbo].MainStore_SOS_FoodLed
(
[Year],
[date],
[Month],
[FiscalMonth],
[Quarter],
[Continent],
[BusinessUnit],
[Cluster],
[Country],
[SubCountry],
[Segment],
[OutletGrade],
[City],
[PostCode],
[SalesRepName],
[Salesrepstatus],
[Territory],
[Manager],
[Region],
[Channel],
[OutletID],
[OutletName],
[Status] ,
[OutletType],
[Brand],
MainShelfDiageoFacings,
MainShelfFacings,
[Manufacturer],
[JoinKey]
)

(
SELECT dd.FiscalYearId AS Year,
dd.[date],
dd.CalendarMonthName AS Month,
dd.FiscalPeriodName AS FiscalMonth,
dd.FiscalQuarterName AS Quarter,
crd.Continent,
crd.Businessunit AS BusinessUnit,
crd.Cluster AS Cluster,
crd.Country,
dp.Subcountry,
dp.Segment,
dp.outletgrade,
dp.City,
dp.PostCode,
isnull(df.Name,'Unknown') as SalesRepName,
df.active as SalesrepStatus,
isnull(dt.territory,'Unknown') AS Territory,
ISNULL(M.[Manager],'Unknown') as Manager,
ISNULL(M.Region,'Unknown') AS Region,
f.Channel,
dp.OutletID,
dp.OutletName,
dp.Status,
dp.outlettype,
f.[Product] as Brand,
CASE WHEN f.[Manufacturer]='Diageo' then f.facings end as MainShelfDiageoFacings,
f.[facings] as MainShelfFacings,
f.[Manufacturer],
CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.Status) as JoinKey

FROM COPS_TRAX.[dbo].[Facings_Combinedtest] f
left join COPS_TRAX.[dbo].POP dp on dp.pointofpurchaseid = f.[store number] and dp.[SourceCountry]=f.[SourceCountry]
left join customerexecutionwarehouse.[Dim].[Date] dd on dd.[date] = f.[date]
left join CustomerExecutionWarehouse.[Fct].[OutletCall] fo on fo.[DateKey]=dd.DateKey and fo.[PointOfPurchaseKey]=dp.PointOfPurchaseKey
left join COPS.[dbo].[Cluster_Rawdata] crd on dp.country=crd.country
left JOIN CustomerExecutionWarehouse.[Dim].[Market] dm ON dm.MarketKey=fo.MarketKey
left join CustomerExecutionWarehouse.[Dim].[CallType] dc on dc.[CallTypeKey]=fo.[CallTypeKey]
left join CustomerExecutionWarehouse.[Dim].[BusinessRole] db on db.[BusinessRoleKey]=fo.[BusinessRoleKey]
left join CustomerExecutionWarehouse.[Dim].[FieldSalesRep] df on df.[FieldSalesRepKey]=fo.[FieldSalesRepKey]
full outer join CustomerExecutionWarehouse.dim.territory dt on dt.territorykey = fo.territorykey
left join  COPS.dbo.Salesrep_Rawdata m
on ((m.territory = dt.territory) or (m.Name = df.Name)) and (m.Country = dt.Country)
and fo.datekey <= m.enddate
full outer join COPS.dbo.CallTypes_Rawdata mc
on dc.[CallTypeCode]=mc.code
and dc.Country=mc.Country
and fo.datekey<=m.enddate
full outer join cops.dbo.businessroles_Rawdata mb
on db.[BusinessRoleCode]=mb.code
and db.Country=mb.Country


WHERE  dp.country not in ('Kenya')
and dd.datekey > '20190701'
and mb.includedincalculationcore = 3
and f.[Scn#location_type] in ('Primary', 'Primary Shelf')

group by
dd.FiscalYearId ,
dd.[date],
dd.CalendarMonthName ,
dd.FiscalPeriodName ,
dd.FiscalQuarterName ,
crd.Continent,
crd.Businessunit ,
crd.Cluster ,
crd.Country,
dp.Subcountry,
dp.Segment,
dp.outletgrade,
dp.City,
dp.PostCode,
isnull(df.Name,'Unknown'),
df.active,
isnull(dt.territory,'Unknown'),
ISNULL(M.[Manager],'Unknown'),
ISNULL(M.Region,'Unknown'),
f.Channel,
dp.OutletID,
dp.OutletName,
dp.Status,
dp.outlettype,
f.[Product],
CASE WHEN f.[Manufacturer]='Diageo' then f.facings end,
f.[facings] ,
f.[Manufacturer],
CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.Status))





---Backbar SOS
drop table COPS_Cluster.[dbo].SOS_Backbar_FoodLed
CREATE TABLE COPS_Cluster.[dbo].[SOS_Backbar_FoodLed]
(
[Year] [int] NULL,
[date] [date] NULL,
[Month] [varchar](30) NULL,
[FiscalMonth] [varchar](30) NULL,
[Quarter] [varchar](30) NULL,
[Continent] [varchar](25) NULL,
[BusinessUnit] [varchar](20) NULL,
[Cluster] [varchar](100) NULL,
[Country] [varchar](50) NULL,
[SubCountry] [varchar](100) NULL,
[Segment] [nvarchar](255) NULL,
[OutletGrade] [nvarchar](255) NULL,
[City] [nvarchar](50) NULL,
[PostCode] [nvarchar](50) NULL,
[SalesRepName] [nvarchar](255) NULL,
[Salesrepstatus] [nvarchar] (255) NULL,
[Territory] [nvarchar](255) NULL,
[Manager] [nvarchar](255) NULL,
[Region] [nvarchar](255) NULL,
[Channel] [varchar](50) NULL,
[OutletID] [varchar](255) NULL,
[OutletName] [nvarchar](255) NULL,
[Status] [nvarchar] (50) NULL,
[OutletType] [varchar](50) NULL,
[Manufacturer] [nvarchar](255) NULL ,
[Product] [nvarchar](255) NULL,
[BackbarFacings] [float] NULL,
[BackbarTotalfacings][float] NULL,
[JoinKey] [nvarchar](1500) NOT NULL,
[Backbar] [nvarchar] (50) NULL


)

INSERT INTO COPS_Cluster.[dbo].[SOS_Backbar_FoodLed]
(
[Year],
[date],
[Month],
[FiscalMonth],
[Quarter],
[Continent],
[BusinessUnit],
[Cluster],
[Country],
[SubCountry],
[Segment],
[OutletGrade],
[City],
[PostCode],
[SalesRepName],
[Salesrepstatus],
[Territory],
[Manager],
[Region],
[Channel],
[OutletID],
[OutletName],
[Status] ,
[OutletType],
[Manufacturer] ,
[Product],
[BackbarFacings] ,
[BackbarTotalfacings],

[JoinKey],
[BackBar]
)
(

SELECT dd.FiscalYearId AS Year,
dd.[date],
dd.CalendarMonthName AS Month,
dd.FiscalPeriodName AS FiscalMonth,
dd.FiscalQuarterName AS Quarter,
crd.Continent,
crd.Businessunit AS BusinessUnit,
crd.Cluster AS Cluster,
crd.Country,
dp.Subcountry,
dp.Segment,
dp.outletgrade,
dp.City,
dp.PostCode,
isnull(df.Name,'Unknown') as SalesRepName,
df.active as SalesrepStatus,
isnull(dt.territory,'Unknown') AS Territory,
ISNULL(M.[Manager],'Unknown') as Manager,
ISNULL(M.Region,'Unknown') AS Region,
f.Channel,
dp.OutletID,
dp.OutletName,
dp.[Status] as [Status],
dp.[OutletType] as [OutletType],
f.[Manufacturer] as [Manufacturer],
f.[Product] as Product,
CASE WHEN f.[Manufacturer]='Diageo' then f.facings end as [BackbarFacings],
f.facings as [BackbarTotalfacings],

CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.Status) as JoinKey
, f.[MainShelf/BackBar] as Backbar
FROM COPS_TRAX.[dbo].[Facings_Combinedtest] f
left join COPS_TRAX.[dbo].POP dp on dp.pointofpurchaseid = f.[store number] and dp.[SourceCountry]=f.[SourceCountry]
left join customerexecutionwarehouse.[Dim].[Date] dd on dd.[date] = f.[date]
left join CustomerExecutionWarehouse.[Fct].[OutletCall] fo on fo.[DateKey]=dd.DateKey and fo.[PointOfPurchaseKey]=dp.PointOfPurchaseKey
left JOIN CustomerExecutionWarehouse.[Dim].[Market] dm ON dm.MarketKey=fo.MarketKey
left join CustomerExecutionWarehouse.[Dim].[CallType] dc on dc.[CallTypeKey]=fo.[CallTypeKey]
left join CustomerExecutionWarehouse.[Dim].[BusinessRole] db on db.[BusinessRoleKey]=fo.[BusinessRoleKey]
left join CustomerExecutionWarehouse.[Dim].[FieldSalesRep] df on df.[FieldSalesRepKey]=fo.[FieldSalesRepKey]
full outer join CustomerExecutionWarehouse.dim.territory dt on dt.territorykey = fo.territorykey
left join  COPS.dbo.Salesrep_Rawdata m
on ((m.territory = dt.territory) or (m.Name = df.Name)) and (m.Country = dt.Country)
and fo.datekey <= m.enddate

left join COPS.[dbo].[Cluster_Rawdata] crd on dp.country=crd.country
full outer join COPS.dbo.CallTypes_Rawdata mc
on dc.[CallTypeCode]=mc.code
and dc.Country=mc.Country
and fo.datekey<=m.enddate
full outer join cops.dbo.businessroles_Rawdata mb
on db.[BusinessRoleCode]=mb.code
and db.Country=mb.Country

WHERE  dp.country not in ('Kenya')
and dd.datekey > '20190701'
and mb.includedincalculationcore = 3
and f.[MainShelf/BackBar] ='Backbar'

group by
dd.FiscalYearId ,
dd.[date],
dd.CalendarMonthName ,
dd.FiscalPeriodName ,
dd.FiscalQuarterName ,
crd.Continent,
crd.Businessunit ,
crd.Cluster ,
crd.Country,
dp.Subcountry,
dp.Segment,
dp.outletgrade,
dp.City,
dp.PostCode,
isnull(df.Name,'Unknown'),
df.active,
isnull(dt.territory,'Unknown'),
ISNULL(M.[Manager],'Unknown'),
ISNULL(M.Region,'Unknown'),
f.Channel,
dp.OutletID,
dp.OutletName,
dp.[Status],
dp.[OutletType],
f.[Manufacturer] ,
f.[Product],
CASE WHEN f.[Manufacturer]='Diageo' then f.facings end ,
f.[facings] ,
f.[MainShelf/BackBar],
CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.Status)
)

---MainShelf SOS
drop table COPS_Cluster.[dbo].SOS_MainShelf_FoodLed
CREATE TABLE COPS_Cluster.[dbo].[SOS_MainShelf_FoodLed]
(
[Year] [int] NULL,
[date] [date] NULL,
[Month] [varchar](30) NULL,
[FiscalMonth] [varchar](30) NULL,
[Quarter] [varchar](30) NULL,
[Continent] [varchar](25) NULL,
[BusinessUnit] [varchar](20) NULL,
[Cluster] [varchar](100) NULL,
[Country] [varchar](50) NULL,
[SubCountry] [varchar](100) NULL,
[Segment] [nvarchar](255) NULL,
[OutletGrade] [nvarchar](255) NULL,
[City] [nvarchar](50) NULL,
[PostCode] [nvarchar](50) NULL,
[SalesRepName] [nvarchar](255) NULL,
[Salesrepstatus] [nvarchar] (255) NULL,
[Territory] [nvarchar](255) NULL,
[Manager] [nvarchar](255) NULL,
[Region] [nvarchar](255) NULL,
[Channel] [varchar](50) NULL,
[OutletID] [varchar](255) NULL,
[OutletName] [nvarchar](255) NULL,
[Status] [nvarchar] (50) NULL,
[OutletType] [varchar](50) NULL,
[Manufacturer] [nvarchar](255) NULL ,
[Product] [nvarchar](255) NULL,
[MainShelfSOSFacings] [float] NULL,
[MainShelfTotalfacings][float] NULL,

[JoinKey] [nvarchar](1500) NOT NULL,
[MainShelf] [nvarchar] (50) NULL


)

INSERT INTO COPS_Cluster.[dbo].[SOS_MainShelf_FoodLed]
(
[Year],
[date],
[Month],
[FiscalMonth],
[Quarter],
[Continent],
[BusinessUnit],
[Cluster],
[Country],
[SubCountry],
[Segment],
[OutletGrade],
[City],
[PostCode],
[SalesRepName],
[Salesrepstatus],
[Territory],
[Manager],
[Region],
[Channel],
[OutletID],
[OutletName],
[Status] ,
[OutletType],
[Manufacturer] ,
[Product],
[MainShelfSOSFacings] ,
[MainShelfTotalfacings],

[JoinKey],
[MainShelf]
)
(

SELECT dd.FiscalYearId AS Year,
dd.[date],
dd.CalendarMonthName AS Month,
dd.FiscalPeriodName AS FiscalMonth,
dd.FiscalQuarterName AS Quarter,
crd.Continent,
crd.Businessunit AS BusinessUnit,
crd.Cluster AS Cluster,
crd.Country,
dp.Subcountry,
dp.Segment,
dp.outletgrade,
dp.City,
dp.PostCode,
isnull(df.Name,'Unknown') as SalesRepName,
df.active as SalesrepStatus,
isnull(dt.territory,'Unknown') AS Territory,
ISNULL(M.[Manager],'Unknown') as Manager,
ISNULL(M.Region,'Unknown') AS Region,
f.Channel,
dp.OutletID,
dp.OutletName,
dp.[Status] as [Status],
dp.[OutletType] as [OutletType],
f.[Manufacturer] as [Manufacturer],
f.[Product] as Product,
CASE WHEN f.[Manufacturer]='Diageo' then f.facings end as [MainShelfSOSFacings],
f.facings as [MainShelfTotalfacings],

CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.Status) as JoinKey
,f.[MainShelf/BackBar] as mainshelf
FROM COPS_TRAX.[dbo].[Facings_Combinedtest] f
left join COPS_TRAX.[dbo].POP dp on dp.pointofpurchaseid = f.[store number] and dp.[SourceCountry]=f.[SourceCountry]
left join customerexecutionwarehouse.[Dim].[Date] dd on dd.[date] = f.[date]
left join CustomerExecutionWarehouse.[Fct].[OutletCall] fo on fo.[DateKey]=dd.DateKey and fo.[PointOfPurchaseKey]=dp.PointOfPurchaseKey
left JOIN CustomerExecutionWarehouse.[Dim].[Market] dm ON dm.MarketKey=fo.MarketKey
left join CustomerExecutionWarehouse.[Dim].[CallType] dc on dc.[CallTypeKey]=fo.[CallTypeKey]
left join CustomerExecutionWarehouse.[Dim].[BusinessRole] db on db.[BusinessRoleKey]=fo.[BusinessRoleKey]
left join CustomerExecutionWarehouse.[Dim].[FieldSalesRep] df on df.[FieldSalesRepKey]=fo.[FieldSalesRepKey]
full outer join CustomerExecutionWarehouse.dim.territory dt on dt.territorykey = fo.territorykey
left join  COPS.dbo.Salesrep_Rawdata m
on ((m.territory = dt.territory) or (m.Name = df.Name)) and (m.Country = dt.Country)
and fo.datekey <= m.enddate

left join COPS.[dbo].[Cluster_Rawdata] crd on dp.country=crd.country
full outer join COPS.dbo.CallTypes_Rawdata mc
on dc.[CallTypeCode]=mc.code
and dc.Country=mc.Country
and fo.datekey<=m.enddate
full outer join cops.dbo.businessroles_Rawdata mb
on db.[BusinessRoleCode]=mb.code
and db.Country=mb.Country

WHERE  dp.country not in ('Kenya')
and dd.datekey > '20190701'
and mb.includedincalculationcore = 3
and f.[MainShelf/BackBar] ='Main Shelf'

group by
dd.FiscalYearId ,
dd.[date],
dd.CalendarMonthName ,
dd.FiscalPeriodName ,
dd.FiscalQuarterName ,
crd.Continent,
crd.Businessunit ,
crd.Cluster ,
crd.Country,
dp.Subcountry,
dp.Segment,
dp.outletgrade,
dp.City,
dp.PostCode,
isnull(df.Name,'Unknown'),
df.active,
isnull(dt.territory,'Unknown'),
ISNULL(M.[Manager],'Unknown'),
ISNULL(M.Region,'Unknown'),
f.Channel,
dp.OutletID,
dp.OutletName,
dp.[Status],
dp.[OutletType],
f.[Manufacturer] ,
f.[Product],
CASE WHEN f.[Manufacturer]='Diageo' then f.facings end ,
f.[facings] ,
f.[MainShelf/BackBar],
CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.Status)
)

drop table COPS_Cluster.dbo.OnFoodMenu_FoodLed
CREATE TABLE COPS_Cluster.[dbo].[OnFoodMenu_FoodLed](
       [Year] [int] NULL,
       [date] [date] NULL,
       [Month] [varchar](30) NULL,
       [FiscalMonth] [varchar](30) NULL,
       [Quarter] [varchar](30) NULL,
       [Continent] [varchar](25) NULL,
       [BusinessUnit] [varchar](20) NULL,
       [Cluster] [varchar](100) NULL,
       [Country] [varchar](150) NULL,
       [SubCountry] [varchar](100) NULL,
       [Segment] [nvarchar](255) NULL,
       [Outlettype] [nvarchar] (255) NULL,
       [OutletGrade] [nvarchar](255) NULL,
       [City] [nvarchar](150) NULL,
       [PostCode] [nvarchar](150) NULL,
       [SalesRepName] [nvarchar](255) NULL,
       [SalesrepStatus] [nvarchar] (255) NULL,
       [Territory] [nvarchar](255) NULL,
       [Manager] [nvarchar](255) NULL,
       [Region] [nvarchar](255) NULL,
       [Channel] [varchar](50) NULL,
       [OutletId] [varchar](50) NULL,
       [OutletName] [nvarchar](250) NULL,
       OnFoodMenu [float] NULL,
       [Status] [nvarchar] (50) NULL,
	     OnFoodMenuTarget [float] NULL,
       [JoinKey] [nvarchar](340) NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO



INSERT INTO [COPS_Cluster].[dbo].[OnFoodMenu_FoodLed]
( [Year]
      ,[date]
      ,[Month]
      ,[FiscalMonth]
      ,[Quarter]
      ,[Continent]
      ,[BusinessUnit]
      ,[Cluster]
      ,[Country]
      ,[SubCountry]
      ,[Segment]
      ,[Outlettype]
      ,[OutletGrade]
      ,[City]
      ,[PostCode]
      ,[SalesRepName]
      ,[SalesrepStatus]
      ,[Territory]
      ,[Manager]
      ,[Region]
      ,[Channel]
		  ,[OutletId]
		  ,[OutletName]
      ,OnFoodMenu
      ,[Status]
	    ,OnFoodMenuTarget
      ,[JoinKey]
)
SELECT dd.FiscalYearId AS Year,
dd.[date],
dd.CalendarMonthName AS Month,
dd.FiscalPeriodName AS FiscalMonth,
dd.FiscalQuarterName AS Quarter,
dm.Continent,
dm.Region AS BusinessUnit,
dm.SuperCluster AS Cluster,
CASE WHEN dp.Country='Ireland' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Iberia' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Germany' THEN 'GAS'
WHEN dp.Country='Denmark' THEN 'Nordics' ELSE dp.Country  END AS Country,
ISNULL(m.subcountry,dp.country) AS Subcountry,
Isnull(dp.PrimaryCDOS,'Unknown')  as Segment,
ISNULL(dp.outlettype,'Unknown') as Outlettype,
CASE WHEN dp.SourceSystem='Comarch'then dp.[OutletGrade] else ISNULL(dpo.[Outlet Priority],'Unknown') end as outletgrade,
dp.City as City,
dp.PostCode,
isnull(df.Name,'Unknown') as SalesRepName,
df.active as SalesrepStatus,
isnull(dt.territory,'Unknown') AS Territory,
ISNULL(M.[Manager],'Unknown') as Manager,
ISNULL(M.Region,'Unknown') AS Region,
dp.Channel,
dp.OutletId,
dp.OutletName,
fo.[IsResponseOfInterest] as OnFoodMenu,
dp.Status as Status,
NULL as OnFoodMenuTarget,
CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.Status) as JoinKey

FROM CustomerExecutionWarehouse.[Fct].[Survey] fo
left JOIN CustomerExecutionWarehouse.[Dim].[Market] dm ON dm.MarketKey=fo.MarketKey
left JOIN CustomerExecutionWarehouse.[Dim].[PointOfPurchase] dp ON dp.PointOfPurchaseKey=fo.[PointOfPurchaseKey]
left join CustomerExecutionWarehouse.[Dim].[BusinessRole] db on db.[BusinessRoleKey]=fo.[BusinessRoleKey]
left join CustomerExecutionWarehouse.[Dim].[FieldSalesRep] df on df.[FieldSalesRepKey]=fo.[FieldSalesRepKey]
full outer join CustomerExecutionWarehouse.dim.territory dt on dt.territorykey = fo.territorykey
left join CustomerExecutionWarehouse.[Dim].[Date] dd on dd.[DateKey]=fo.[DateKey]
left join CustomerExecutionWarehouse.[Dim].[CallType] dc on dc.[CallTypeKey]=fo.[CallTypeKey]
left join CustomerExecutionWarehouse.[Dim].[Question] dq
on fo.[QuestionKey]=dq.[QuestionKey]
full outer join
( select distinct [OutletGrade], [Country],[Outlet Priority] from
COPS.[dbo].[OutletGrade_Rawdata] )
dpo on dpo.[OutletGrade]=dp.OutletGrade
and dpo.Country=dp.Country
left join  COPS.dbo.Salesrep_Rawdata m
on ((m.territory = dt.territory) or (m.Name = df.Name)) and (m.Country = dt.Country)
and fo.datekey <= m.enddate
full outer join COPS.dbo.CallTypes_Rawdata mc
on dc.[CallTypeCode]=mc.code
and dc.Country=mc.Country
and fo.datekey<=m.enddate
full outer join cops.dbo.businessroles_Rawdata mb
on db.[BusinessRoleCode]=mb.code
and db.Country=mb.Country


WHERE  dp.country not in ('Unknown','Kenya','N/A')
and dp.County is not null
and mb.includedincalculationcore = 3
and dd.fiscalPeriodName is not null
and dp.channel not like 'Unknown'
and dd.[datekey] > '20190701'
and lower(dq.QuestionName) like '%on%food%' 

group by
dd.FiscalYearId,
dd.[date],
dd.CalendarMonthName,
dd.FiscalPeriodName,
dd.FiscalQuarterName,
dm.Continent,
dm.Region,
dm.SuperCluster,
CASE WHEN dp.Country='Ireland' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Iberia' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Germany' THEN 'GAS'
WHEN dp.Country='Denmark' THEN 'Nordics' ELSE dp.Country  END,
Isnull(dp.PrimaryCDOS,'Unknown'),
Isnull(dp.outlettype,'Unknown'),
CASE WHEN dp.SourceSystem='Comarch'then dp.[OutletGrade] else ISNULL(dpo.[Outlet Priority],'Unknown')end ,
dp.City,
dp.PostCode,
isnull(df.Name,'Unknown'),
df.active,
isnull(dt.territory,'Unknown'),
ISNULL(M.[Manager],'Unknown'),
ISNULL(M.Region,'Unknown'),
dp.Channel,
dp.OutletId,
dp.Outletname,
dp.Status,
CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.Status),
ISNULL(m.subcountry,dp.country),
fo.[IsResponseOfInterest]

drop table COPS_Cluster.dbo.OnDrinksMenu_FoodLed
CREATE TABLE COPS_Cluster.[dbo].[OnDrinksMenu_FoodLed](
       [Year] [int] NULL,
       [date] [date] NULL,
       [Month] [varchar](30) NULL,
       [FiscalMonth] [varchar](30) NULL,
       [Quarter] [varchar](30) NULL,
       [Continent] [varchar](25) NULL,
       [BusinessUnit] [varchar](20) NULL,
       [Cluster] [varchar](100) NULL,
       [Country] [varchar](150) NULL,
       [SubCountry] [varchar](100) NULL,
       [Segment] [nvarchar](255) NULL,
       [Outlettype] [nvarchar] (255) NULL,
       [OutletGrade] [nvarchar](255) NULL,
       [City] [nvarchar](150) NULL,
       [PostCode] [nvarchar](150) NULL,
       [SalesRepName] [nvarchar](255) NULL,
       [SalesrepStatus] [nvarchar] (255) NULL,
       [Territory] [nvarchar](255) NULL,
       [Manager] [nvarchar](255) NULL,
       [Region] [nvarchar](255) NULL,
       [Channel] [varchar](50) NULL,
       [OutletId] [varchar](50) NULL,
       [OutletName] [nvarchar](250) NULL,
       OnDrinksMenu [float] NULL,
       [Status] [nvarchar] (50) NULL,
	     OnDrinksMenuTarget [float] NULL,
       [JoinKey] [nvarchar](340) NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO



INSERT INTO [COPS_Cluster].[dbo].[OnDrinksMenu_FoodLed]
( [Year]
      ,[date]
      ,[Month]
      ,[FiscalMonth]
      ,[Quarter]
      ,[Continent]
      ,[BusinessUnit]
      ,[Cluster]
      ,[Country]
      ,[SubCountry]
      ,[Segment]
      ,[Outlettype]
      ,[OutletGrade]
      ,[City]
      ,[PostCode]
      ,[SalesRepName]
      ,[SalesrepStatus]
      ,[Territory]
      ,[Manager]
      ,[Region]
      ,[Channel]
		  ,[OutletId]
		  ,[OutletName]
      ,OnDrinksMenu
      ,[Status]
	    ,OnDrinksMenuTarget
      ,[JoinKey]
)
SELECT dd.FiscalYearId AS Year,
dd.[date],
dd.CalendarMonthName AS Month,
dd.FiscalPeriodName AS FiscalMonth,
dd.FiscalQuarterName AS Quarter,
dm.Continent,
dm.Region AS BusinessUnit,
dm.SuperCluster AS Cluster,
CASE WHEN dp.Country='Ireland' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Iberia' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Germany' THEN 'GAS'
WHEN dp.Country='Denmark' THEN 'Nordics' ELSE dp.Country  END AS Country,
ISNULL(m.subcountry,dp.country) AS Subcountry,
Isnull(dp.PrimaryCDOS,'Unknown')  as Segment,
ISNULL(dp.outlettype,'Unknown') as Outlettype,
CASE WHEN dp.SourceSystem='Comarch'then dp.[OutletGrade] else ISNULL(dpo.[Outlet Priority],'Unknown') end as outletgrade,
dp.City as City,
dp.PostCode,
isnull(df.Name,'Unknown') as SalesRepName,
df.active as SalesrepStatus,
isnull(dt.territory,'Unknown') AS Territory,
ISNULL(M.[Manager],'Unknown') as Manager,
ISNULL(M.Region,'Unknown') AS Region,
dp.Channel,
dp.OutletId,
dp.OutletName,
fo.[IsResponseOfInterest] as OnDrinksMenu,
dp.Status as Status,
NULL as OnDrinksMenuTarget,
CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.Status) as JoinKey

FROM CustomerExecutionWarehouse.[Fct].[Survey] fo
left JOIN CustomerExecutionWarehouse.[Dim].[Market] dm ON dm.MarketKey=fo.MarketKey
left JOIN CustomerExecutionWarehouse.[Dim].[PointOfPurchase] dp ON dp.PointOfPurchaseKey=fo.[PointOfPurchaseKey]
left join CustomerExecutionWarehouse.[Dim].[BusinessRole] db on db.[BusinessRoleKey]=fo.[BusinessRoleKey]
left join CustomerExecutionWarehouse.[Dim].[FieldSalesRep] df on df.[FieldSalesRepKey]=fo.[FieldSalesRepKey]
full outer join CustomerExecutionWarehouse.dim.territory dt on dt.territorykey = fo.territorykey
left join CustomerExecutionWarehouse.[Dim].[Date] dd on dd.[DateKey]=fo.[DateKey]
left join CustomerExecutionWarehouse.[Dim].[CallType] dc on dc.[CallTypeKey]=fo.[CallTypeKey]
left join CustomerExecutionWarehouse.[Dim].[Question] dq
on fo.[QuestionKey]=dq.[QuestionKey]
full outer join
( select distinct [OutletGrade], [Country],[Outlet Priority] from
COPS.[dbo].[OutletGrade_Rawdata] )
dpo on dpo.[OutletGrade]=dp.OutletGrade
and dpo.Country=dp.Country
left join  COPS.dbo.Salesrep_Rawdata m
on ((m.territory = dt.territory) or (m.Name = df.Name)) and (m.Country = dt.Country)
and fo.datekey <= m.enddate
full outer join COPS.dbo.CallTypes_Rawdata mc
on dc.[CallTypeCode]=mc.code
and dc.Country=mc.Country
and fo.datekey<=m.enddate
full outer join cops.dbo.businessroles_Rawdata mb
on db.[BusinessRoleCode]=mb.code
and db.Country=mb.Country


WHERE  dp.country not in ('Unknown','Kenya','N/A')
and dp.County is not null
and mb.includedincalculationcore = 3
and dd.fiscalPeriodName is not null
and dp.channel not like 'Unknown'
and dd.[datekey] > '20190701'
and lower(dq.QuestionName) like '%on%drinks%'

group by
dd.FiscalYearId,
dd.[date],
dd.CalendarMonthName,
dd.FiscalPeriodName,
dd.FiscalQuarterName,
dm.Continent,
dm.Region,
dm.SuperCluster,
CASE WHEN dp.Country='Ireland' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Iberia' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Germany' THEN 'GAS'
WHEN dp.Country='Denmark' THEN 'Nordics' ELSE dp.Country  END,
Isnull(dp.PrimaryCDOS,'Unknown'),
Isnull(dp.outlettype,'Unknown'),
CASE WHEN dp.SourceSystem='Comarch'then dp.[OutletGrade] else ISNULL(dpo.[Outlet Priority],'Unknown')end ,
dp.City,
dp.PostCode,
isnull(df.Name,'Unknown'),
df.active,
isnull(dt.territory,'Unknown'),
ISNULL(M.[Manager],'Unknown'),
ISNULL(M.Region,'Unknown'),
dp.Channel,
dp.OutletId,
dp.Outletname,
dp.Status,
CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.Status),
ISNULL(m.subcountry,dp.country),
fo.[IsResponseOfInterest]


drop table COPS_Cluster.dbo.DessertMenu_FoodLed
CREATE TABLE COPS_Cluster.[dbo].[DessertMenu_FoodLed](
       [Year] [int] NULL,
       [date] [date] NULL,
       [Month] [varchar](30) NULL,
       [FiscalMonth] [varchar](30) NULL,
       [Quarter] [varchar](30) NULL,
       [Continent] [varchar](25) NULL,
       [BusinessUnit] [varchar](20) NULL,
       [Cluster] [varchar](100) NULL,
       [Country] [varchar](150) NULL,
       [SubCountry] [varchar](100) NULL,
       [Segment] [nvarchar](255) NULL,
       [Outlettype] [nvarchar] (255) NULL,
       [OutletGrade] [nvarchar](255) NULL,
       [City] [nvarchar](150) NULL,
       [PostCode] [nvarchar](150) NULL,
       [SalesRepName] [nvarchar](255) NULL,
       [SalesrepStatus] [nvarchar] (255) NULL,
       [Territory] [nvarchar](255) NULL,
       [Manager] [nvarchar](255) NULL,
       [Region] [nvarchar](255) NULL,
       [Channel] [varchar](50) NULL,
       [OutletId] [varchar](50) NULL,
       [OutletName] [nvarchar](250) NULL,
       DessertMenu [float] NULL,
       [Status] [nvarchar] (50) NULL,
	     DessertMenuTarget [float] NULL,
       [JoinKey] [nvarchar](340) NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO



INSERT INTO [COPS_Cluster].[dbo].[DessertMenu_FoodLed]
( [Year]
      ,[date]
      ,[Month]
      ,[FiscalMonth]
      ,[Quarter]
      ,[Continent]
      ,[BusinessUnit]
      ,[Cluster]
      ,[Country]
      ,[SubCountry]
      ,[Segment]
      ,[Outlettype]
      ,[OutletGrade]
      ,[City]
      ,[PostCode]
      ,[SalesRepName]
      ,[SalesrepStatus]
      ,[Territory]
      ,[Manager]
      ,[Region]
      ,[Channel]
		  ,[OutletId]
		  ,[OutletName]
      ,DessertMenu
      ,[Status]
	    ,DessertMenuTarget
      ,[JoinKey]
)
SELECT dd.FiscalYearId AS Year,
dd.[date],
dd.CalendarMonthName AS Month,
dd.FiscalPeriodName AS FiscalMonth,
dd.FiscalQuarterName AS Quarter,
dm.Continent,
dm.Region AS BusinessUnit,
dm.SuperCluster AS Cluster,
CASE WHEN dp.Country='Ireland' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Iberia' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Germany' THEN 'GAS'
WHEN dp.Country='Denmark' THEN 'Nordics' ELSE dp.Country  END AS Country,
ISNULL(m.subcountry,dp.country) AS Subcountry,
Isnull(dp.PrimaryCDOS,'Unknown')  as Segment,
ISNULL(dp.outlettype,'Unknown') as Outlettype,
CASE WHEN dp.SourceSystem='Comarch'then dp.[OutletGrade] else ISNULL(dpo.[Outlet Priority],'Unknown') end as outletgrade,
dp.City as City,
dp.PostCode,
isnull(df.Name,'Unknown') as SalesRepName,
df.active as SalesrepStatus,
isnull(dt.territory,'Unknown') AS Territory,
ISNULL(M.[Manager],'Unknown') as Manager,
ISNULL(M.Region,'Unknown') AS Region,
dp.Channel,
dp.OutletId,
dp.OutletName,
fo.[IsResponseOfInterest] as DessertMenu,
dp.Status as Status,
NULL as DessertMenuTarget,
CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.Status) as JoinKey

FROM CustomerExecutionWarehouse.[Fct].[Survey] fo
left JOIN CustomerExecutionWarehouse.[Dim].[Market] dm ON dm.MarketKey=fo.MarketKey
left JOIN CustomerExecutionWarehouse.[Dim].[PointOfPurchase] dp ON dp.PointOfPurchaseKey=fo.[PointOfPurchaseKey]
left join CustomerExecutionWarehouse.[Dim].[BusinessRole] db on db.[BusinessRoleKey]=fo.[BusinessRoleKey]
left join CustomerExecutionWarehouse.[Dim].[FieldSalesRep] df on df.[FieldSalesRepKey]=fo.[FieldSalesRepKey]
full outer join CustomerExecutionWarehouse.dim.territory dt on dt.territorykey = fo.territorykey
left join CustomerExecutionWarehouse.[Dim].[Date] dd on dd.[DateKey]=fo.[DateKey]
left join CustomerExecutionWarehouse.[Dim].[CallType] dc on dc.[CallTypeKey]=fo.[CallTypeKey]
left join CustomerExecutionWarehouse.[Dim].[Question] dq
on fo.[QuestionKey]=dq.[QuestionKey]
full outer join
( select distinct [OutletGrade], [Country],[Outlet Priority] from
COPS.[dbo].[OutletGrade_Rawdata] )
dpo on dpo.[OutletGrade]=dp.OutletGrade
and dpo.Country=dp.Country
left join  COPS.dbo.Salesrep_Rawdata m
on ((m.territory = dt.territory) or (m.Name = df.Name)) and (m.Country = dt.Country)
and fo.datekey <= m.enddate
full outer join COPS.dbo.CallTypes_Rawdata mc
on dc.[CallTypeCode]=mc.code
and dc.Country=mc.Country
and fo.datekey<=m.enddate
full outer join cops.dbo.businessroles_Rawdata mb
on db.[BusinessRoleCode]=mb.code
and db.Country=mb.Country


WHERE  dp.country not in ('Unknown','Kenya','N/A')
and dp.County is not null
and mb.includedincalculationcore = 3
and dd.fiscalPeriodName is not null
and dp.channel not like 'Unknown'
and dd.[datekey] > '20190701'
and lower(dq.QuestionName) like '%dessert%'

group by
dd.FiscalYearId,
dd.[date],
dd.CalendarMonthName,
dd.FiscalPeriodName,
dd.FiscalQuarterName,
dm.Continent,
dm.Region,
dm.SuperCluster,
CASE WHEN dp.Country='Ireland' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Iberia' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Germany' THEN 'GAS'
WHEN dp.Country='Denmark' THEN 'Nordics' ELSE dp.Country  END,
Isnull(dp.PrimaryCDOS,'Unknown'),
Isnull(dp.outlettype,'Unknown'),
CASE WHEN dp.SourceSystem='Comarch'then dp.[OutletGrade] else ISNULL(dpo.[Outlet Priority],'Unknown')end ,
dp.City,
dp.PostCode,
isnull(df.Name,'Unknown'),
df.active,
isnull(dt.territory,'Unknown'),
ISNULL(M.[Manager],'Unknown'),
ISNULL(M.Region,'Unknown'),
dp.Channel,
dp.OutletId,
dp.Outletname,
dp.Status,
CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.Status),
ISNULL(m.subcountry,dp.country),
fo.[IsResponseOfInterest]

drop table COPS_Cluster.dbo.DigestifMenu_FoodLed
CREATE TABLE COPS_Cluster.[dbo].[DigestifMenu_FoodLed](
       [Year] [int] NULL,
       [date] [date] NULL,
       [Month] [varchar](30) NULL,
       [FiscalMonth] [varchar](30) NULL,
       [Quarter] [varchar](30) NULL,
       [Continent] [varchar](25) NULL,
       [BusinessUnit] [varchar](20) NULL,
       [Cluster] [varchar](100) NULL,
       [Country] [varchar](150) NULL,
       [SubCountry] [varchar](100) NULL,
       [Segment] [nvarchar](255) NULL,
       [Outlettype] [nvarchar] (255) NULL,
       [OutletGrade] [nvarchar](255) NULL,
       [City] [nvarchar](150) NULL,
       [PostCode] [nvarchar](150) NULL,
       [SalesRepName] [nvarchar](255) NULL,
       [SalesrepStatus] [nvarchar] (255) NULL,
       [Territory] [nvarchar](255) NULL,
       [Manager] [nvarchar](255) NULL,
       [Region] [nvarchar](255) NULL,
       [Channel] [varchar](50) NULL,
       [OutletId] [varchar](50) NULL,
       [OutletName] [nvarchar](250) NULL,
       DigestifMenu [float] NULL,
       [Status] [nvarchar] (50) NULL,
	     DigestifMenuTarget [float] NULL,
       [JoinKey] [nvarchar](340) NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO



INSERT INTO [COPS_Cluster].[dbo].[DigestifMenu_FoodLed]
( [Year]
      ,[date]
      ,[Month]
      ,[FiscalMonth]
      ,[Quarter]
      ,[Continent]
      ,[BusinessUnit]
      ,[Cluster]
      ,[Country]
      ,[SubCountry]
      ,[Segment]
      ,[Outlettype]
      ,[OutletGrade]
      ,[City]
      ,[PostCode]
      ,[SalesRepName]
      ,[SalesrepStatus]
      ,[Territory]
      ,[Manager]
      ,[Region]
      ,[Channel]
		  ,[OutletId]
		  ,[OutletName]
      ,DigestifMenu
      ,[Status]
	    ,DigestifMenuTarget
      ,[JoinKey]
)
SELECT dd.FiscalYearId AS Year,
dd.[date],
dd.CalendarMonthName AS Month,
dd.FiscalPeriodName AS FiscalMonth,
dd.FiscalQuarterName AS Quarter,
dm.Continent,
dm.Region AS BusinessUnit,
dm.SuperCluster AS Cluster,
CASE WHEN dp.Country='Ireland' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Iberia' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Germany' THEN 'GAS'
WHEN dp.Country='Denmark' THEN 'Nordics' ELSE dp.Country  END AS Country,
ISNULL(m.subcountry,dp.country) AS Subcountry,
Isnull(dp.PrimaryCDOS,'Unknown')  as Segment,
ISNULL(dp.outlettype,'Unknown') as Outlettype,
CASE WHEN dp.SourceSystem='Comarch'then dp.[OutletGrade] else ISNULL(dpo.[Outlet Priority],'Unknown') end as outletgrade,
dp.City as City,
dp.PostCode,
isnull(df.Name,'Unknown') as SalesRepName,
df.active as SalesrepStatus,
isnull(dt.territory,'Unknown') AS Territory,
ISNULL(M.[Manager],'Unknown') as Manager,
ISNULL(M.Region,'Unknown') AS Region,
dp.Channel,
dp.OutletId,
dp.OutletName,
fo.[IsResponseOfInterest] as DigestifMenu,
dp.Status as Status,
NULL as DigestifMenuTarget,
CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.Status) as JoinKey

FROM CustomerExecutionWarehouse.[Fct].[Survey] fo
left JOIN CustomerExecutionWarehouse.[Dim].[Market] dm ON dm.MarketKey=fo.MarketKey
left JOIN CustomerExecutionWarehouse.[Dim].[PointOfPurchase] dp ON dp.PointOfPurchaseKey=fo.[PointOfPurchaseKey]
left join CustomerExecutionWarehouse.[Dim].[BusinessRole] db on db.[BusinessRoleKey]=fo.[BusinessRoleKey]
left join CustomerExecutionWarehouse.[Dim].[FieldSalesRep] df on df.[FieldSalesRepKey]=fo.[FieldSalesRepKey]
full outer join CustomerExecutionWarehouse.dim.territory dt on dt.territorykey = fo.territorykey
left join CustomerExecutionWarehouse.[Dim].[Date] dd on dd.[DateKey]=fo.[DateKey]
left join CustomerExecutionWarehouse.[Dim].[CallType] dc on dc.[CallTypeKey]=fo.[CallTypeKey]
left join CustomerExecutionWarehouse.[Dim].[Question] dq
on fo.[QuestionKey]=dq.[QuestionKey]
full outer join
( select distinct [OutletGrade], [Country],[Outlet Priority] from
COPS.[dbo].[OutletGrade_Rawdata] )
dpo on dpo.[OutletGrade]=dp.OutletGrade
and dpo.Country=dp.Country
left join  COPS.dbo.Salesrep_Rawdata m
on ((m.territory = dt.territory) or (m.Name = df.Name)) and (m.Country = dt.Country)
and fo.datekey <= m.enddate
full outer join COPS.dbo.CallTypes_Rawdata mc
on dc.[CallTypeCode]=mc.code
and dc.Country=mc.Country
and fo.datekey<=m.enddate
full outer join cops.dbo.businessroles_Rawdata mb
on db.[BusinessRoleCode]=mb.code
and db.Country=mb.Country

WHERE  dp.country not in ('Unknown','Kenya','N/A')
and dp.County is not null
and mb.includedincalculationcore = 3
and dd.fiscalPeriodName is not null
and dp.channel not like 'Unknown'
and dd.[datekey] > '20190701'
and lower(dq.QuestionName) like '%digestif%'

group by
dd.FiscalYearId,
dd.[date],
dd.CalendarMonthName,
dd.FiscalPeriodName,
dd.FiscalQuarterName,
dm.Continent,
dm.Region,
dm.SuperCluster,
CASE WHEN dp.Country='Ireland' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Iberia' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Germany' THEN 'GAS'
WHEN dp.Country='Denmark' THEN 'Nordics' ELSE dp.Country  END,
Isnull(dp.PrimaryCDOS,'Unknown'),
Isnull(dp.outlettype,'Unknown'),
CASE WHEN dp.SourceSystem='Comarch'then dp.[OutletGrade] else ISNULL(dpo.[Outlet Priority],'Unknown')end ,
dp.City,
dp.PostCode,
isnull(df.Name,'Unknown'),
df.active,
isnull(dt.territory,'Unknown'),
ISNULL(M.[Manager],'Unknown'),
ISNULL(M.Region,'Unknown'),
dp.Channel,
dp.OutletId,
dp.Outletname,
dp.Status,
CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.Status),
ISNULL(m.subcountry,dp.country),
fo.[IsResponseOfInterest]

drop table COPS_Cluster.dbo.AperitifMenu_FoodLed
CREATE TABLE COPS_Cluster.[dbo].[AperitifMenu_FoodLed](
       [Year] [int] NULL,
       [date] [date] NULL,
       [Month] [varchar](30) NULL,
       [FiscalMonth] [varchar](30) NULL,
       [Quarter] [varchar](30) NULL,
       [Continent] [varchar](25) NULL,
       [BusinessUnit] [varchar](20) NULL,
       [Cluster] [varchar](100) NULL,
       [Country] [varchar](150) NULL,
       [SubCountry] [varchar](100) NULL,
       [Segment] [nvarchar](255) NULL,
       [Outlettype] [nvarchar] (255) NULL,
       [OutletGrade] [nvarchar](255) NULL,
       [City] [nvarchar](150) NULL,
       [PostCode] [nvarchar](150) NULL,
       [SalesRepName] [nvarchar](255) NULL,
       [SalesrepStatus] [nvarchar] (255) NULL,
       [Territory] [nvarchar](255) NULL,
       [Manager] [nvarchar](255) NULL,
       [Region] [nvarchar](255) NULL,
       [Channel] [varchar](50) NULL,
       [OutletId] [varchar](50) NULL,
       [OutletName] [nvarchar](250) NULL,
       AperitifMenu [float] NULL,
       [Status] [nvarchar] (50) NULL,
	     AperitifMenuTarget [float] NULL,
       [JoinKey] [nvarchar](340) NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO



INSERT INTO [COPS_Cluster].[dbo].[AperitifMenu_FoodLed]
( [Year]
      ,[date]
      ,[Month]
      ,[FiscalMonth]
      ,[Quarter]
      ,[Continent]
      ,[BusinessUnit]
      ,[Cluster]
      ,[Country]
      ,[SubCountry]
      ,[Segment]
      ,[Outlettype]
      ,[OutletGrade]
      ,[City]
      ,[PostCode]
      ,[SalesRepName]
      ,[SalesrepStatus]
      ,[Territory]
      ,[Manager]
      ,[Region]
      ,[Channel]
		  ,[OutletId]
		  ,[OutletName]
      ,AperitifMenu
      ,[Status]
	    ,AperitifMenuTarget
      ,[JoinKey]
)
SELECT dd.FiscalYearId AS Year,
dd.[date],
dd.CalendarMonthName AS Month,
dd.FiscalPeriodName AS FiscalMonth,
dd.FiscalQuarterName AS Quarter,
dm.Continent,
dm.Region AS BusinessUnit,
dm.SuperCluster AS Cluster,
CASE WHEN dp.Country='Ireland' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Iberia' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Germany' THEN 'GAS'
WHEN dp.Country='Denmark' THEN 'Nordics' ELSE dp.Country  END AS Country,
ISNULL(m.subcountry,dp.country) AS Subcountry,
Isnull(dp.PrimaryCDOS,'Unknown')  as Segment,
ISNULL(dp.outlettype,'Unknown') as Outlettype,
CASE WHEN dp.SourceSystem='Comarch'then dp.[OutletGrade] else ISNULL(dpo.[Outlet Priority],'Unknown') end as outletgrade,
dp.City as City,
dp.PostCode,
isnull(df.Name,'Unknown') as SalesRepName,
df.active as SalesrepStatus,
isnull(dt.territory,'Unknown') AS Territory,
ISNULL(M.[Manager],'Unknown') as Manager,
ISNULL(M.Region,'Unknown') AS Region,
dp.Channel,
dp.OutletId,
dp.OutletName,
fo.[IsResponseOfInterest] as AperitifMenu,
dp.Status as Status,
NULL as AperitifMenuTarget,
CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.Status) as JoinKey

FROM CustomerExecutionWarehouse.[Fct].[Survey] fo
left JOIN CustomerExecutionWarehouse.[Dim].[Market] dm ON dm.MarketKey=fo.MarketKey
left JOIN CustomerExecutionWarehouse.[Dim].[PointOfPurchase] dp ON dp.PointOfPurchaseKey=fo.[PointOfPurchaseKey]
left join CustomerExecutionWarehouse.[Dim].[BusinessRole] db on db.[BusinessRoleKey]=fo.[BusinessRoleKey]
left join CustomerExecutionWarehouse.[Dim].[FieldSalesRep] df on df.[FieldSalesRepKey]=fo.[FieldSalesRepKey]
full outer join CustomerExecutionWarehouse.dim.territory dt on dt.territorykey = fo.territorykey
left join CustomerExecutionWarehouse.[Dim].[Date] dd on dd.[DateKey]=fo.[DateKey]
left join CustomerExecutionWarehouse.[Dim].[CallType] dc on dc.[CallTypeKey]=fo.[CallTypeKey]
left join CustomerExecutionWarehouse.[Dim].[Question] dq
on fo.[QuestionKey]=dq.[QuestionKey]
full outer join
( select distinct [OutletGrade], [Country],[Outlet Priority] from
COPS.[dbo].[OutletGrade_Rawdata] )
dpo on dpo.[OutletGrade]=dp.OutletGrade
and dpo.Country=dp.Country
left join  COPS.dbo.Salesrep_Rawdata m
on ((m.territory = dt.territory) or (m.Name = df.Name)) and (m.Country = dt.Country)
and fo.datekey <= m.enddate
full outer join COPS.dbo.CallTypes_Rawdata mc
on dc.[CallTypeCode]=mc.code
and dc.Country=mc.Country
and fo.datekey<=m.enddate
full outer join cops.dbo.businessroles_Rawdata mb
on db.[BusinessRoleCode]=mb.code
and db.Country=mb.Country

WHERE  dp.country not in ('Unknown','Kenya','N/A')
and dp.County is not null
and mb.includedincalculationcore = 3
and dd.fiscalPeriodName is not null
and dp.channel not like 'Unknown'
and dd.[datekey] > '20190701'
and lower(dq.QuestionName) like '%aperitif%'

group by
dd.FiscalYearId,
dd.[date],
dd.CalendarMonthName,
dd.FiscalPeriodName,
dd.FiscalQuarterName,
dm.Continent,
dm.Region,
dm.SuperCluster,
CASE WHEN dp.Country='Ireland' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Iberia' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Germany' THEN 'GAS'
WHEN dp.Country='Denmark' THEN 'Nordics' ELSE dp.Country  END,
Isnull(dp.PrimaryCDOS,'Unknown'),
Isnull(dp.outlettype,'Unknown'),
CASE WHEN dp.SourceSystem='Comarch'then dp.[OutletGrade] else ISNULL(dpo.[Outlet Priority],'Unknown')end ,
dp.City,
dp.PostCode,
isnull(df.Name,'Unknown'),
df.active,
isnull(dt.territory,'Unknown'),
ISNULL(M.[Manager],'Unknown'),
ISNULL(M.Region,'Unknown'),
dp.Channel,
dp.OutletId,
dp.Outletname,
dp.Status,
CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.Status),
ISNULL(m.subcountry,dp.country),
fo.[IsResponseOfInterest]

drop table COPS_Cluster.dbo.MenuImplemented_FoodLed
CREATE TABLE COPS_Cluster.[dbo].[MenuImplemented_FoodLed](
       [Year] [int] NULL,
       [date] [date] NULL,
       [Month] [varchar](30) NULL,
       [FiscalMonth] [varchar](30) NULL,
       [Quarter] [varchar](30) NULL,
       [Continent] [varchar](25) NULL,
       [BusinessUnit] [varchar](20) NULL,
       [Cluster] [varchar](100) NULL,
       [Country] [varchar](150) NULL,
       [SubCountry] [varchar](100) NULL,
       [Segment] [nvarchar](255) NULL,
       [Outlettype] [nvarchar] (255) NULL,
       [OutletGrade] [nvarchar](255) NULL,
       [City] [nvarchar](150) NULL,
       [PostCode] [nvarchar](150) NULL,
       [SalesRepName] [nvarchar](255) NULL,
       [SalesrepStatus] [nvarchar] (255) NULL,
       [Territory] [nvarchar](255) NULL,
       [Manager] [nvarchar](255) NULL,
       [Region] [nvarchar](255) NULL,
       [Channel] [varchar](50) NULL,
       [OutletId] [varchar](50) NULL,
       [OutletName] [nvarchar](250) NULL,
       MenuImplemented [float] NULL,
       [Status] [nvarchar] (50) NULL,
	     MenuImplementedTarget [float] NULL,
       [JoinKey] [nvarchar](340) NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO



INSERT INTO [COPS_Cluster].[dbo].[MenuImplemented_FoodLed]
( [Year]
      ,[date]
      ,[Month]
      ,[FiscalMonth]
      ,[Quarter]
      ,[Continent]
      ,[BusinessUnit]
      ,[Cluster]
      ,[Country]
      ,[SubCountry]
      ,[Segment]
      ,[Outlettype]
      ,[OutletGrade]
      ,[City]
      ,[PostCode]
      ,[SalesRepName]
      ,[SalesrepStatus]
      ,[Territory]
      ,[Manager]
      ,[Region]
      ,[Channel]
		  ,[OutletId]
		  ,[OutletName]
      ,MenuImplemented
      ,[Status]
	    ,MenuImplementedTarget
      ,[JoinKey]
)
SELECT dd.FiscalYearId AS Year,
dd.[date],
dd.CalendarMonthName AS Month,
dd.FiscalPeriodName AS FiscalMonth,
dd.FiscalQuarterName AS Quarter,
dm.Continent,
dm.Region AS BusinessUnit,
dm.SuperCluster AS Cluster,
CASE WHEN dp.Country='Ireland' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Iberia' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Germany' THEN 'GAS'
WHEN dp.Country='Denmark' THEN 'Nordics' ELSE dp.Country  END AS Country,
ISNULL(m.subcountry,dp.country) AS Subcountry,
Isnull(dp.PrimaryCDOS,'Unknown')  as Segment,
ISNULL(dp.outlettype,'Unknown') as Outlettype,
CASE WHEN dp.SourceSystem='Comarch'then dp.[OutletGrade] else ISNULL(dpo.[Outlet Priority],'Unknown') end as outletgrade,
dp.City as City,
dp.PostCode,
isnull(df.Name,'Unknown') as SalesRepName,
df.active as SalesrepStatus,
isnull(dt.territory,'Unknown') AS Territory,
ISNULL(M.[Manager],'Unknown') as Manager,
ISNULL(M.Region,'Unknown') AS Region,
dp.Channel,
dp.OutletId,
dp.OutletName,
fo.[IsResponseOfInterest] as MenuImplemented,
dp.Status as Status,
NULL as MenuImplementedTarget,
CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.Status) as JoinKey

FROM CustomerExecutionWarehouse.[Fct].[Survey] fo
left JOIN CustomerExecutionWarehouse.[Dim].[Market] dm ON dm.MarketKey=fo.MarketKey
left JOIN CustomerExecutionWarehouse.[Dim].[PointOfPurchase] dp ON dp.PointOfPurchaseKey=fo.[PointOfPurchaseKey]
left join CustomerExecutionWarehouse.[Dim].[BusinessRole] db on db.[BusinessRoleKey]=fo.[BusinessRoleKey]
left join CustomerExecutionWarehouse.[Dim].[FieldSalesRep] df on df.[FieldSalesRepKey]=fo.[FieldSalesRepKey]
full outer join CustomerExecutionWarehouse.dim.territory dt on dt.territorykey = fo.territorykey
left join CustomerExecutionWarehouse.[Dim].[Date] dd on dd.[DateKey]=fo.[DateKey]
left join CustomerExecutionWarehouse.[Dim].[CallType] dc on dc.[CallTypeKey]=fo.[CallTypeKey]
left join CustomerExecutionWarehouse.[Dim].[Question] dq
on fo.[QuestionKey]=dq.[QuestionKey]
full outer join
( select distinct [OutletGrade], [Country],[Outlet Priority] from
COPS.[dbo].[OutletGrade_Rawdata] )
dpo on dpo.[OutletGrade]=dp.OutletGrade
and dpo.Country=dp.Country
left join  COPS.dbo.Salesrep_Rawdata m
on ((m.territory = dt.territory) or (m.Name = df.Name)) and (m.Country = dt.Country)
and fo.datekey <= m.enddate
full outer join COPS.dbo.CallTypes_Rawdata mc
on dc.[CallTypeCode]=mc.code
and dc.Country=mc.Country
and fo.datekey<=m.enddate
full outer join cops.dbo.businessroles_Rawdata mb
on db.[BusinessRoleCode]=mb.code
and db.Country=mb.Country

WHERE  dp.country not in ('Unknown','Kenya','N/A')
and dp.County is not null
and mb.includedincalculationcore = 3
and dd.fiscalPeriodName is not null
and dp.channel not like 'Unknown'
and dd.[datekey] > '20190701'
and lower(dq.QuestionName) like '%implemented%menu%'

group by
dd.FiscalYearId,
dd.[date],
dd.CalendarMonthName,
dd.FiscalPeriodName,
dd.FiscalQuarterName,
dm.Continent,
dm.Region,
dm.SuperCluster,
CASE WHEN dp.Country='Ireland' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Iberia' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Germany' THEN 'GAS'
WHEN dp.Country='Denmark' THEN 'Nordics' ELSE dp.Country  END,
Isnull(dp.PrimaryCDOS,'Unknown'),
Isnull(dp.outlettype,'Unknown'),
CASE WHEN dp.SourceSystem='Comarch'then dp.[OutletGrade] else ISNULL(dpo.[Outlet Priority],'Unknown')end ,
dp.City,
dp.PostCode,
isnull(df.Name,'Unknown'),
df.active,
isnull(dt.territory,'Unknown'),
ISNULL(M.[Manager],'Unknown'),
ISNULL(M.Region,'Unknown'),
dp.Channel,
dp.OutletId,
dp.Outletname,
dp.Status,
CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.Status),
ISNULL(m.subcountry,dp.country),
fo.[IsResponseOfInterest]

drop table COPS_Cluster.dbo.StaffIncentive_FoodLed
CREATE TABLE COPS_Cluster.[dbo].[StaffIncentive_FoodLed](
       [Year] [int] NULL,
       [date] [date] NULL,
       [Month] [varchar](30) NULL,
       [FiscalMonth] [varchar](30) NULL,
       [Quarter] [varchar](30) NULL,
       [Continent] [varchar](25) NULL,
       [BusinessUnit] [varchar](20) NULL,
       [Cluster] [varchar](100) NULL,
       [Country] [varchar](150) NULL,
       [SubCountry] [varchar](100) NULL,
       [Segment] [nvarchar](255) NULL,
       [Outlettype] [nvarchar] (255) NULL,
       [OutletGrade] [nvarchar](255) NULL,
       [City] [nvarchar](150) NULL,
       [PostCode] [nvarchar](150) NULL,
       [SalesRepName] [nvarchar](255) NULL,
       [SalesrepStatus] [nvarchar] (255) NULL,
       [Territory] [nvarchar](255) NULL,
       [Manager] [nvarchar](255) NULL,
       [Region] [nvarchar](255) NULL,
       [Channel] [varchar](50) NULL,
       [OutletId] [varchar](50) NULL,
       [OutletName] [nvarchar](250) NULL,
       StaffIncentive [float] NULL,
       [Status] [nvarchar] (50) NULL,
	     StaffIncentiveTarget [float] NULL,
       [JoinKey] [nvarchar](340) NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO



INSERT INTO [COPS_Cluster].[dbo].[StaffIncentive_FoodLed]
( [Year]
      ,[date]
      ,[Month]
      ,[FiscalMonth]
      ,[Quarter]
      ,[Continent]
      ,[BusinessUnit]
      ,[Cluster]
      ,[Country]
      ,[SubCountry]
      ,[Segment]
      ,[Outlettype]
      ,[OutletGrade]
      ,[City]
      ,[PostCode]
      ,[SalesRepName]
      ,[SalesrepStatus]
      ,[Territory]
      ,[Manager]
      ,[Region]
      ,[Channel]
		  ,[OutletId]
		  ,[OutletName]
      ,StaffIncentive
      ,[Status]
	    ,StaffIncentiveTarget
      ,[JoinKey]
)
SELECT dd.FiscalYearId AS Year,
dd.[date],
dd.CalendarMonthName AS Month,
dd.FiscalPeriodName AS FiscalMonth,
dd.FiscalQuarterName AS Quarter,
dm.Continent,
dm.Region AS BusinessUnit,
dm.SuperCluster AS Cluster,
CASE WHEN dp.Country='Ireland' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Iberia' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Germany' THEN 'GAS'
WHEN dp.Country='Denmark' THEN 'Nordics' ELSE dp.Country  END AS Country,
ISNULL(m.subcountry,dp.country) AS Subcountry,
Isnull(dp.PrimaryCDOS,'Unknown')  as Segment,
ISNULL(dp.outlettype,'Unknown') as Outlettype,
CASE WHEN dp.SourceSystem='Comarch'then dp.[OutletGrade] else ISNULL(dpo.[Outlet Priority],'Unknown') end as outletgrade,
dp.City as City,
dp.PostCode,
isnull(df.Name,'Unknown') as SalesRepName,
df.active as SalesrepStatus,
isnull(dt.territory,'Unknown') AS Territory,
ISNULL(M.[Manager],'Unknown') as Manager,
ISNULL(M.Region,'Unknown') AS Region,
dp.Channel,
dp.OutletId,
dp.OutletName,
fo.[IsResponseOfInterest] as StaffIncentive,
dp.Status as Status,
NULL as StaffIncentiveTarget,
CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.Status) as JoinKey

FROM CustomerExecutionWarehouse.[Fct].[Survey] fo
left JOIN CustomerExecutionWarehouse.[Dim].[Market] dm ON dm.MarketKey=fo.MarketKey
left JOIN CustomerExecutionWarehouse.[Dim].[PointOfPurchase] dp ON dp.PointOfPurchaseKey=fo.[PointOfPurchaseKey]
left join CustomerExecutionWarehouse.[Dim].[BusinessRole] db on db.[BusinessRoleKey]=fo.[BusinessRoleKey]
left join CustomerExecutionWarehouse.[Dim].[FieldSalesRep] df on df.[FieldSalesRepKey]=fo.[FieldSalesRepKey]
full outer join CustomerExecutionWarehouse.dim.territory dt on dt.territorykey = fo.territorykey
left join CustomerExecutionWarehouse.[Dim].[Date] dd on dd.[DateKey]=fo.[DateKey]
left join CustomerExecutionWarehouse.[Dim].[CallType] dc on dc.[CallTypeKey]=fo.[CallTypeKey]
left join CustomerExecutionWarehouse.[Dim].[Question] dq
on fo.[QuestionKey]=dq.[QuestionKey]
full outer join
( select distinct [OutletGrade], [Country],[Outlet Priority] from
COPS.[dbo].[OutletGrade_Rawdata] )
dpo on dpo.[OutletGrade]=dp.OutletGrade
and dpo.Country=dp.Country
left join  COPS.dbo.Salesrep_Rawdata m
on ((m.territory = dt.territory) or (m.Name = df.Name)) and (m.Country = dt.Country)
and fo.datekey <= m.enddate
full outer join COPS.dbo.CallTypes_Rawdata mc
on dc.[CallTypeCode]=mc.code
and dc.Country=mc.Country
and fo.datekey<=m.enddate
full outer join cops.dbo.businessroles_Rawdata mb
on db.[BusinessRoleCode]=mb.code
and db.Country=mb.Country

WHERE  dp.country not in ('Unknown','Kenya','N/A')
and dp.County is not null
and mb.includedincalculationcore = 3
and dd.fiscalPeriodName is not null
and dp.channel not like 'Unknown'
and dd.[datekey] > '20190701'
and lower(dq.QuestionName) like '%staff%incentivized%'

group by
dd.FiscalYearId,
dd.[date],
dd.CalendarMonthName,
dd.FiscalPeriodName,
dd.FiscalQuarterName,
dm.Continent,
dm.Region,
dm.SuperCluster,
CASE WHEN dp.Country='Ireland' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Iberia' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Germany' THEN 'GAS'
WHEN dp.Country='Denmark' THEN 'Nordics' ELSE dp.Country  END,
Isnull(dp.PrimaryCDOS,'Unknown'),
Isnull(dp.outlettype,'Unknown'),
CASE WHEN dp.SourceSystem='Comarch'then dp.[OutletGrade] else ISNULL(dpo.[Outlet Priority],'Unknown')end ,
dp.City,
dp.PostCode,
isnull(df.Name,'Unknown'),
df.active,
isnull(dt.territory,'Unknown'),
ISNULL(M.[Manager],'Unknown'),
ISNULL(M.Region,'Unknown'),
dp.Channel,
dp.OutletId,
dp.Outletname,
dp.Status,
CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.Status),
ISNULL(m.subcountry,dp.country),
fo.[IsResponseOfInterest]

drop table COPS_Cluster.dbo.MenuandTraining_FoodLed
CREATE TABLE COPS_Cluster.[dbo].[MenuandTraining_FoodLed](
       [Year] [int] NULL,
       [date] [date] NULL,
       [Month] [varchar](30) NULL,
       [FiscalMonth] [varchar](30) NULL,
       [Quarter] [varchar](30) NULL,
       [Continent] [varchar](25) NULL,
       [BusinessUnit] [varchar](20) NULL,
       [Cluster] [varchar](100) NULL,
       [Country] [varchar](150) NULL,
       [SubCountry] [varchar](100) NULL,
       [Segment] [nvarchar](255) NULL,
       [Outlettype] [nvarchar] (255) NULL,
       [OutletGrade] [nvarchar](255) NULL,
       [City] [nvarchar](150) NULL,
       [PostCode] [nvarchar](150) NULL,
       [SalesRepName] [nvarchar](255) NULL,
       [SalesrepStatus] [nvarchar] (255) NULL,
       [Territory] [nvarchar](255) NULL,
       [Manager] [nvarchar](255) NULL,
       [Region] [nvarchar](255) NULL,
       [Channel] [varchar](50) NULL,
       [OutletId] [varchar](50) NULL,
       [OutletName] [nvarchar](250) NULL,
       MenuandTraining [float] NULL,
       [Status] [nvarchar] (50) NULL,
	     MenuandTrainingTarget [float] NULL,
       [JoinKey] [nvarchar](340) NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO



INSERT INTO [COPS_Cluster].[dbo].[MenuandTraining_FoodLed]
( [Year]
      ,[date]
      ,[Month]
      ,[FiscalMonth]
      ,[Quarter]
      ,[Continent]
      ,[BusinessUnit]
      ,[Cluster]
      ,[Country]
      ,[SubCountry]
      ,[Segment]
      ,[Outlettype]
      ,[OutletGrade]
      ,[City]
      ,[PostCode]
      ,[SalesRepName]
      ,[SalesrepStatus]
      ,[Territory]
      ,[Manager]
      ,[Region]
      ,[Channel]
		  ,[OutletId]
		  ,[OutletName]
      ,MenuandTraining
      ,[Status]
	    ,MenuandTrainingTarget
      ,[JoinKey]
)
SELECT dd.FiscalYearId AS Year,
dd.[date],
dd.CalendarMonthName AS Month,
dd.FiscalPeriodName AS FiscalMonth,
dd.FiscalQuarterName AS Quarter,
dm.Continent,
dm.Region AS BusinessUnit,
dm.SuperCluster AS Cluster,
CASE WHEN dp.Country='Ireland' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Iberia' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Germany' THEN 'GAS'
WHEN dp.Country='Denmark' THEN 'Nordics' ELSE dp.Country  END AS Country,
ISNULL(m.subcountry,dp.country) AS Subcountry,
Isnull(dp.PrimaryCDOS,'Unknown')  as Segment,
ISNULL(dp.outlettype,'Unknown') as Outlettype,
CASE WHEN dp.SourceSystem='Comarch'then dp.[OutletGrade] else ISNULL(dpo.[Outlet Priority],'Unknown') end as outletgrade,
dp.City as City,
dp.PostCode,
isnull(df.Name,'Unknown') as SalesRepName,
df.active as SalesrepStatus,
isnull(dt.territory,'Unknown') AS Territory,
ISNULL(M.[Manager],'Unknown') as Manager,
ISNULL(M.Region,'Unknown') AS Region,
dp.Channel,
dp.OutletId,
dp.OutletName,
fo.[IsResponseOfInterest] as MenuandTraining,
dp.Status as Status,
NULL as MenuandTrainingTarget,
CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.Status) as JoinKey

FROM CustomerExecutionWarehouse.[Fct].[Survey] fo
left JOIN CustomerExecutionWarehouse.[Dim].[Market] dm ON dm.MarketKey=fo.MarketKey
left JOIN CustomerExecutionWarehouse.[Dim].[PointOfPurchase] dp ON dp.PointOfPurchaseKey=fo.[PointOfPurchaseKey]
left join CustomerExecutionWarehouse.[Dim].[BusinessRole] db on db.[BusinessRoleKey]=fo.[BusinessRoleKey]
left join CustomerExecutionWarehouse.[Dim].[FieldSalesRep] df on df.[FieldSalesRepKey]=fo.[FieldSalesRepKey]
full outer join CustomerExecutionWarehouse.dim.territory dt on dt.territorykey = fo.territorykey
left join CustomerExecutionWarehouse.[Dim].[Date] dd on dd.[DateKey]=fo.[DateKey]
left join CustomerExecutionWarehouse.[Dim].[CallType] dc on dc.[CallTypeKey]=fo.[CallTypeKey]
left join CustomerExecutionWarehouse.[Dim].[Question] dq
on fo.[QuestionKey]=dq.[QuestionKey]
full outer join
( select distinct [OutletGrade], [Country],[Outlet Priority] from
COPS.[dbo].[OutletGrade_Rawdata] )
dpo on dpo.[OutletGrade]=dp.OutletGrade
and dpo.Country=dp.Country
left join  COPS.dbo.Salesrep_Rawdata m
on ((m.territory = dt.territory) or (m.Name = df.Name)) and (m.Country = dt.Country)
and fo.datekey <= m.enddate
full outer join COPS.dbo.CallTypes_Rawdata mc
on dc.[CallTypeCode]=mc.code
and dc.Country=mc.Country
and fo.datekey<=m.enddate
full outer join cops.dbo.businessroles_Rawdata mb
on db.[BusinessRoleCode]=mb.code
and db.Country=mb.Country

WHERE  dp.country not in ('Unknown','Kenya','N/A')
and dp.County is not null
and mb.includedincalculationcore = 3
and dd.fiscalPeriodName is not null
and dp.channel not like 'Unknown'
and dd.[datekey] > '20190701'
and lower(dq.MasterQuestionName) like '%Menu%and%training%'

group by
dd.FiscalYearId,
dd.[date],
dd.CalendarMonthName,
dd.FiscalPeriodName,
dd.FiscalQuarterName,
dm.Continent,
dm.Region,
dm.SuperCluster,
CASE WHEN dp.Country='Ireland' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Iberia' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Germany' THEN 'GAS'
WHEN dp.Country='Denmark' THEN 'Nordics' ELSE dp.Country  END,
Isnull(dp.PrimaryCDOS,'Unknown'),
Isnull(dp.outlettype,'Unknown'),
CASE WHEN dp.SourceSystem='Comarch'then dp.[OutletGrade] else ISNULL(dpo.[Outlet Priority],'Unknown')end ,
dp.City,
dp.PostCode,
isnull(df.Name,'Unknown'),
df.active,
isnull(dt.territory,'Unknown'),
ISNULL(M.[Manager],'Unknown'),
ISNULL(M.Region,'Unknown'),
dp.Channel,
dp.OutletId,
dp.Outletname,
dp.Status,
CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.Status),
ISNULL(m.subcountry,dp.country),
fo.[IsResponseOfInterest]

drop table COPS_Cluster.dbo.GLGT_FoodLed
CREATE TABLE COPS_Cluster.[dbo].[GLGT_FoodLed](
       [Year] [int] NULL,
       [date] [date] NULL,
       [Month] [varchar](30) NULL,
       [FiscalMonth] [varchar](30) NULL,
       [Quarter] [varchar](30) NULL,
       [Continent] [varchar](25) NULL,
       [BusinessUnit] [varchar](20) NULL,
       [Cluster] [varchar](100) NULL,
       [Country] [varchar](150) NULL,
       [SubCountry] [varchar](100) NULL,
       [Segment] [nvarchar](255) NULL,
       [Outlettype] [nvarchar] (255) NULL,
       [OutletGrade] [nvarchar](255) NULL,
       [City] [nvarchar](150) NULL,
       [PostCode] [nvarchar](150) NULL,
       [SalesRepName] [nvarchar](255) NULL,
       [SalesrepStatus] [nvarchar] (255) NULL,
       [Territory] [nvarchar](255) NULL,
       [Manager] [nvarchar](255) NULL,
       [Region] [nvarchar](255) NULL,
       [Channel] [varchar](50) NULL,
       [OutletId] [varchar](50) NULL,
       [OutletName] [nvarchar](250) NULL,
       GLGT [float] NULL,
       [Status] [nvarchar] (50) NULL,
	     GLGTTarget [float] NULL,
       [JoinKey] [nvarchar](340) NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO



INSERT INTO [COPS_Cluster].[dbo].[GLGT_FoodLed]
( [Year]
      ,[date]
      ,[Month]
      ,[FiscalMonth]
      ,[Quarter]
      ,[Continent]
      ,[BusinessUnit]
      ,[Cluster]
      ,[Country]
      ,[SubCountry]
      ,[Segment]
      ,[Outlettype]
      ,[OutletGrade]
      ,[City]
      ,[PostCode]
      ,[SalesRepName]
      ,[SalesrepStatus]
      ,[Territory]
      ,[Manager]
      ,[Region]
      ,[Channel]
		  ,[OutletId]
		  ,[OutletName]
      ,GLGT
      ,[Status]
	    ,GLGTTarget
      ,[JoinKey]
)
SELECT dd.FiscalYearId AS Year,
dd.[date],
dd.CalendarMonthName AS Month,
dd.FiscalPeriodName AS FiscalMonth,
dd.FiscalQuarterName AS Quarter,
dm.Continent,
dm.Region AS BusinessUnit,
dm.SuperCluster AS Cluster,
CASE WHEN dp.Country='Ireland' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Iberia' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Germany' THEN 'GAS'
WHEN dp.Country='Denmark' THEN 'Nordics' ELSE dp.Country  END AS Country,
ISNULL(m.subcountry,dp.country) AS Subcountry,
Isnull(dp.PrimaryCDOS,'Unknown')  as Segment,
ISNULL(dp.outlettype,'Unknown') as Outlettype,
CASE WHEN dp.SourceSystem='Comarch'then dp.[OutletGrade] else ISNULL(dpo.[Outlet Priority],'Unknown') end as outletgrade,
dp.City as City,
dp.PostCode,
isnull(df.Name,'Unknown') as SalesRepName,
df.active as SalesrepStatus,
isnull(dt.territory,'Unknown') AS Territory,
ISNULL(M.[Manager],'Unknown') as Manager,
ISNULL(M.Region,'Unknown') AS Region,
dp.Channel,
dp.OutletId,
dp.OutletName,
fo.[IsResponseOfInterest] as GLGT,
dp.Status as Status,
NULL as GLGTTarget,
CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.Status) as JoinKey

FROM CustomerExecutionWarehouse.[Fct].[Survey] fo
left JOIN CustomerExecutionWarehouse.[Dim].[Market] dm ON dm.MarketKey=fo.MarketKey
left JOIN CustomerExecutionWarehouse.[Dim].[PointOfPurchase] dp ON dp.PointOfPurchaseKey=fo.[PointOfPurchaseKey]
left join CustomerExecutionWarehouse.[Dim].[BusinessRole] db on db.[BusinessRoleKey]=fo.[BusinessRoleKey]
left join CustomerExecutionWarehouse.[Dim].[FieldSalesRep] df on df.[FieldSalesRepKey]=fo.[FieldSalesRepKey]
full outer join CustomerExecutionWarehouse.dim.territory dt on dt.territorykey = fo.territorykey
left join CustomerExecutionWarehouse.[Dim].[Date] dd on dd.[DateKey]=fo.[DateKey]
left join CustomerExecutionWarehouse.[Dim].[CallType] dc on dc.[CallTypeKey]=fo.[CallTypeKey]
left join CustomerExecutionWarehouse.[Dim].[Question] dq
on fo.[QuestionKey]=dq.[QuestionKey]
full outer join
( select distinct [OutletGrade], [Country],[Outlet Priority] from
COPS.[dbo].[OutletGrade_Rawdata] )
dpo on dpo.[OutletGrade]=dp.OutletGrade
and dpo.Country=dp.Country
left join  COPS.dbo.Salesrep_Rawdata m
on ((m.territory = dt.territory) or (m.Name = df.Name)) and (m.Country = dt.Country)
and fo.datekey <= m.enddate
full outer join COPS.dbo.CallTypes_Rawdata mc
on dc.[CallTypeCode]=mc.code
and dc.Country=mc.Country
and fo.datekey<=m.enddate
full outer join cops.dbo.businessroles_Rawdata mb
on db.[BusinessRoleCode]=mb.code
and db.Country=mb.Country

WHERE  dp.country not in ('Unknown','Kenya','N/A')
and dp.County is not null
and mb.includedincalculationcore = 3
and dd.fiscalPeriodName is not null
and dp.channel not like 'Unknown'
and dd.[datekey] > '20190701'
and lower(dq.MasterQuestionName) like '%glgt%'

group by
dd.FiscalYearId,
dd.[date],
dd.CalendarMonthName,
dd.FiscalPeriodName,
dd.FiscalQuarterName,
dm.Continent,
dm.Region,
dm.SuperCluster,
CASE WHEN dp.Country='Ireland' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Iberia' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Germany' THEN 'GAS'
WHEN dp.Country='Denmark' THEN 'Nordics' ELSE dp.Country  END,
Isnull(dp.PrimaryCDOS,'Unknown'),
Isnull(dp.outlettype,'Unknown'),
CASE WHEN dp.SourceSystem='Comarch'then dp.[OutletGrade] else ISNULL(dpo.[Outlet Priority],'Unknown')end ,
dp.City,
dp.PostCode,
isnull(df.Name,'Unknown'),
df.active,
isnull(dt.territory,'Unknown'),
ISNULL(M.[Manager],'Unknown'),
ISNULL(M.Region,'Unknown'),
dp.Channel,
dp.OutletId,
dp.Outletname,
dp.Status,
CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.Status),
ISNULL(m.subcountry,dp.country),
fo.[IsResponseOfInterest]

drop table COPS_Cluster.dbo.FSETraining_FoodLed
CREATE TABLE COPS_Cluster.[dbo].[FSETraining_FoodLed](
       [Year] [int] NULL,
       [date] [date] NULL,
       [Month] [varchar](30) NULL,
       [FiscalMonth] [varchar](30) NULL,
       [Quarter] [varchar](30) NULL,
       [Continent] [varchar](25) NULL,
       [BusinessUnit] [varchar](20) NULL,
       [Cluster] [varchar](100) NULL,
       [Country] [varchar](150) NULL,
       [SubCountry] [varchar](100) NULL,
       [Segment] [nvarchar](255) NULL,
       [Outlettype] [nvarchar] (255) NULL,
       [OutletGrade] [nvarchar](255) NULL,
       [City] [nvarchar](150) NULL,
       [PostCode] [nvarchar](150) NULL,
       [SalesRepName] [nvarchar](255) NULL,
       [SalesrepStatus] [nvarchar] (255) NULL,
       [Territory] [nvarchar](255) NULL,
       [Manager] [nvarchar](255) NULL,
       [Region] [nvarchar](255) NULL,
       [Channel] [varchar](50) NULL,
       [OutletId] [varchar](50) NULL,
       [OutletName] [nvarchar](250) NULL,
       FSETraining [float] NULL,
       [Status] [nvarchar] (50) NULL,
	     FSETrainingTarget [float] NULL,
       [JoinKey] [nvarchar](340) NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO



INSERT INTO [COPS_Cluster].[dbo].[FSETraining_FoodLed]
( [Year]
      ,[date]
      ,[Month]
      ,[FiscalMonth]
      ,[Quarter]
      ,[Continent]
      ,[BusinessUnit]
      ,[Cluster]
      ,[Country]
      ,[SubCountry]
      ,[Segment]
      ,[Outlettype]
      ,[OutletGrade]
      ,[City]
      ,[PostCode]
      ,[SalesRepName]
      ,[SalesrepStatus]
      ,[Territory]
      ,[Manager]
      ,[Region]
      ,[Channel]
		  ,[OutletId]
		  ,[OutletName]
      ,FSETraining
      ,[Status]
	    ,FSETrainingTarget
      ,[JoinKey]
)
SELECT dd.FiscalYearId AS Year,
dd.[date],
dd.CalendarMonthName AS Month,
dd.FiscalPeriodName AS FiscalMonth,
dd.FiscalQuarterName AS Quarter,
dm.Continent,
dm.Region AS BusinessUnit,
dm.SuperCluster AS Cluster,
CASE WHEN dp.Country='Ireland' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Iberia' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Germany' THEN 'GAS'
WHEN dp.Country='Denmark' THEN 'Nordics' ELSE dp.Country  END AS Country,
ISNULL(m.subcountry,dp.country) AS Subcountry,
Isnull(dp.PrimaryCDOS,'Unknown')  as Segment,
ISNULL(dp.outlettype,'Unknown') as Outlettype,
CASE WHEN dp.SourceSystem='Comarch'then dp.[OutletGrade] else ISNULL(dpo.[Outlet Priority],'Unknown') end as outletgrade,
dp.City as City,
dp.PostCode,
isnull(df.Name,'Unknown') as SalesRepName,
df.active as SalesrepStatus,
isnull(dt.territory,'Unknown') AS Territory,
ISNULL(M.[Manager],'Unknown') as Manager,
ISNULL(M.Region,'Unknown') AS Region,
dp.Channel,
dp.OutletId,
dp.OutletName,
fo.[IsResponseOfInterest] as FSETraining,
dp.Status as Status,
NULL as FSETrainingTarget,
CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.Status) as JoinKey

FROM CustomerExecutionWarehouse.[Fct].[Survey] fo
left JOIN CustomerExecutionWarehouse.[Dim].[Market] dm ON dm.MarketKey=fo.MarketKey
left JOIN CustomerExecutionWarehouse.[Dim].[PointOfPurchase] dp ON dp.PointOfPurchaseKey=fo.[PointOfPurchaseKey]
left join CustomerExecutionWarehouse.[Dim].[BusinessRole] db on db.[BusinessRoleKey]=fo.[BusinessRoleKey]
left join CustomerExecutionWarehouse.[Dim].[FieldSalesRep] df on df.[FieldSalesRepKey]=fo.[FieldSalesRepKey]
full outer join CustomerExecutionWarehouse.dim.territory dt on dt.territorykey = fo.territorykey
left join CustomerExecutionWarehouse.[Dim].[Date] dd on dd.[DateKey]=fo.[DateKey]
left join CustomerExecutionWarehouse.[Dim].[CallType] dc on dc.[CallTypeKey]=fo.[CallTypeKey]
left join CustomerExecutionWarehouse.[Dim].[Question] dq
on fo.[QuestionKey]=dq.[QuestionKey]
full outer join
( select distinct [OutletGrade], [Country],[Outlet Priority] from
COPS.[dbo].[OutletGrade_Rawdata] )
dpo on dpo.[OutletGrade]=dp.OutletGrade
and dpo.Country=dp.Country
left join  COPS.dbo.Salesrep_Rawdata m
on ((m.territory = dt.territory) or (m.Name = df.Name)) and (m.Country = dt.Country)
and fo.datekey <= m.enddate
full outer join COPS.dbo.CallTypes_Rawdata mc
on dc.[CallTypeCode]=mc.code
and dc.Country=mc.Country
and fo.datekey<=m.enddate
full outer join cops.dbo.businessroles_Rawdata mb
on db.[BusinessRoleCode]=mb.code
and db.Country=mb.Country

WHERE  dp.country not in ('Unknown','Kenya','N/A')
and dp.County is not null
and mb.includedincalculationcore = 3
and dd.fiscalPeriodName is not null
and dp.channel not like 'Unknown'
and dd.[datekey] > '20190701'
and lower(dq.QuestionName) like '%spirits%food%training%'

group by
dd.FiscalYearId,
dd.[date],
dd.CalendarMonthName,
dd.FiscalPeriodName,
dd.FiscalQuarterName,
dm.Continent,
dm.Region,
dm.SuperCluster,
CASE WHEN dp.Country='Ireland' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Iberia' THEN isnull(m.subcountry,dp.Country)
WHEN dp.Country='Germany' THEN 'GAS'
WHEN dp.Country='Denmark' THEN 'Nordics' ELSE dp.Country  END,
Isnull(dp.PrimaryCDOS,'Unknown'),
Isnull(dp.outlettype,'Unknown'),
CASE WHEN dp.SourceSystem='Comarch'then dp.[OutletGrade] else ISNULL(dpo.[Outlet Priority],'Unknown')end ,
dp.City,
dp.PostCode,
isnull(df.Name,'Unknown'),
df.active,
isnull(dt.territory,'Unknown'),
ISNULL(M.[Manager],'Unknown'),
ISNULL(M.Region,'Unknown'),
dp.Channel,
dp.OutletId,
dp.Outletname,
dp.Status,
CONCAT(dd.[date],df.FieldSalesRepKey,dp.PointOfPurchaseKey,ISNULL(m.manager,'Unknown'),ISNULL(m.subcountry,dp.country),dp.Status),
ISNULL(m.subcountry,dp.country),
fo.[IsResponseOfInterest]


