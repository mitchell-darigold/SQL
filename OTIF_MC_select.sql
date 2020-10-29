/*
QUERY SEARCHES FOR MOBILE CONDUCTOR TICKETS
FOR DSD DELIVERIES COMPLETED BY DG DRIVERS

ORIGINAL TABLE SC_RAHH_MC_ticket CONTAINS
MULTIPLE ROWS FOR SOME ORDER NO.

QUERY ASSIGNS A UNIQUE ROW NUMBER TO ROWS
IN DESC ORDER OF ModifiedOn COLUMN AND SELECTS
ROW WITH MOST LATEST ModifiedOn. THIS GIVES 
A UNIQUE ROW FOR EACH ORDER NUMBER.
*/


SELECT TicketID
	,TicketDate
	,TicketStatus
	,DeliveryDate
	,TicketNumber
	,OrderNo
	,CompletionTime
	,ActualArrival
	,ActualDeparture
	,ActualTimeMinutes
	,StopCount
	,RouteNumber
	,Departure
	,DepartureTypeID
	,DepartureType
	,RouteFunctionID
	,RouteFunctionDesc
	,RouteOrgWhsName
	,OrgWhsName
	,ToWhsName
	,CustomerNumber
	,CustomerName
	,CustomerCity
	,CustomerState
	,CustomerZip
	,[DriverName]
    ,TruckID
    ,[TruckNumber]
    ,[Status]
    ,TrailerID
    ,[TrailerNo]
    ,[TrailerActive]
    ,[ModifiedOn]
	,RowNumber

FROM (SELECT [ticket_id] as 'TicketID'
      ,[ticket_date] as 'TicketDate'
      ,[delivery_date] as 'DeliveryDate'
      --,[ShipDate]
      ,[ticket_number] as 'TicketNumber'
      --,[InvoiceNumber]
      ,[OrderNo]
      ,[completion_time] as 'CompletionTime'
      ,[ActualArrival]
      ,[ActualDeparture]
      ,[StopCount]
      ,[ActualTimeMinutes]
      ,[ticketStatus] as 'TicketStatus'
      --,[route_id]
      ,[RouteNumber]
	  ,LEFT([RouteNumber], CHARINDEX(' ', RouteNumber)) as 'Departure'
      ,[RouteType] as 'DepartureTypeID'
      ,[RouteTypeDesc] as 'DepartureType'
      ,[RouteFunction] as 'RouteFunctionID'
      ,[RouteFunctionDesc] as 'RouteFunctionDesc'
      --,[RouteOrg_Wh_No]
      ,[RouteOrg_Wh_Name] as 'RouteOrgWhsName'
      --,[Org_Wh_No]
      ,[Org_Wh_Name] as 'OrgWhsName'
      --,[ToWarehouse]
      --,[ToWarehouse_RegionNo]
      ,[ToWarehouse_Name] as 'ToWhsName'
      --,[ToWarehouse_city]
      --,[ToWarehouse_State]
      --,[customer_id]
      ,[CustomerNum] as 'CustomerNumber'
      --,[StoreNumber]
      ,[customerName] as 'CustomerName'
      --,[Customer_address_line_1]
      --,[Customer_address_line_2]
      ,[Customer_City] as 'CustomerCity'
      ,[Customer_State] as 'CustomerState'
      ,[Customer_Zip] as 'CustomerZip'
      --,[total]
      --,[totalWithTax]
      --,[Sales]
      --,[SalesWithTax]
      --,[PiecesDelivered]
      --,[Pieces]
      --,[TotalCases]
      --,[TotalWeight]
      --,[type]
      --,[payment_type]
      --,[po_number]
      --,[legacy_id]
      ,[DriverName]
      ,[TruckId] as 'TruckID'
      ,[TruckNumber]
      ,[Status]
      ,[TrailerId] as 'TrailerID'
      ,[TrailerNo]
      ,[TrailerActive]
      ,[ModifiedOn]
	  ,row_number() over(partition by OrderNo ORDER BY ModifiedOn desc) as RowNumber
      --,[ModifiedBy]
      --,[insert_date]
	FROM [Logistics].[dbo].[SC_RAHH_MC_ticket]
  ) main

  WHERE 1=1
	AND RowNumber = 1
	AND DeliveryDate >= '2019-08-01'
        AND CompletionTime >= '2019-08-01'

  ORDER BY OrderNo, ModifiedOn DESC