SELECT DISTINCT a.OrderId 'OrderId'
,b.Mode
,b.Equipment
,b.CarrierType
,b.BusUnit
,b.ShipmentId
--,b.OrderId
,b.StartTime
,b.PlanShipDate
,b.PlanDelivDate
,b.ActualDelivDate
,b.SrcCode
,b.SrcName
,b.DestCode
,b.DestName

FROM OrderLevel a

LEFT JOIN (

	SELECT DISTINCT temp5.Mode
	,temp5.Equipment
	,temp5.CarrierType
	,temp5.BusUnit
	,temp5.ShipmentId
	,main.OrderId
	,temp1.StartTime
	,temp2.PlanShipDate
	,temp3.PlanDelivDate
	,temp3.ActualDelivDate
	,temp4.SrcCode
	,temp4.SrcName
	,main.DestCode
	,main.DestName

	FROM (SELECT OrderId
		,ShipmentId
		,DestCode
		,DestName
		FROM OrderLevel
		WHERE PlanShipDate >= '2019-08-01' 
		AND Mode IN ("TL", "LTL", "")
		AND CancelStatus = 'Not Cancelled'
		AND OrderType = 'Sales'
		AND Carrier NOT IN ("DO_NOT_TENDER", "TEMP")
		AND CarrierType IN ("3PL", "Fleet")
		AND TenderStatus IN ("", "Accepted", "Pickup_Notification")
		AND OrderId NOT LIKE '%TONU%'
	) main

	LEFT JOIN (SELECT OrderId ,max(StartTime) 'StartTime' 
	FROM OrderLevel 
	GROUP BY OrderId
	) temp1 

	ON main.OrderId = temp1.OrderId

	LEFT JOIN (SELECT OrderId ,max(PlanShipDate) 'PlanShipDate' 
	FROM OrderLevel 
	GROUP BY OrderId
	) temp2 

	ON main.OrderId = temp2.OrderId

	LEFT JOIN (
		SELECT DISTINCT OrderId
		,ShipmentId
		,StartTime
		,PlanShipDate
		,PlanDelivDate
		,ActualDelivDate
		FROM OrderLevel
	) temp3

	ON main.OrderId = temp3.OrderId
	AND main.ShipmentId = temp3.ShipmentId
	AND temp1.StartTime = temp3.StartTime
	AND temp2.PlanShipDate = temp3.PlanShipDate

	LEFT JOIN (
		SELECT DISTINCT OrderId
		,ShipmentId
		,StartTime
		,PlanShipDate
		,SrcCode
		,SrcName
		FROM OrderLevel
	) temp4

	ON main.OrderId = temp4.OrderId 
	AND main.ShipmentId = temp4.ShipmentId
	AND temp1.StartTime = temp4.StartTime
	AND temp2.PlanShipDate = temp4.PlanShipDate

	INNER JOIN (
		SELECT DISTINCT OrderId
		,Mode
		,Equipment
		,CarrierType
		,BusUnit
		,ShipmentId
		,StartTime
		,PlanShipDate
		FROM OrderLevel
		WHERE PlanShipDate >= '2019-08-01' 
	) temp5

	ON main.OrderId = temp5.OrderId
	AND main.ShipmentId = temp5.ShipmentId
	AND temp1.StartTime = temp5.StartTime
	AND temp2.PlanShipDate = temp5.PlanShipDate
) b

ON a.OrderId = b.OrderId

WHERE a.PlanShipDate >= '2019-08-01' 
AND a.Mode IN ("TL", "LTL", "")
AND a.CancelStatus = 'Not Cancelled'
AND a.OrderType = 'Sales'
AND a.Carrier NOT IN ("DO_NOT_TENDER", "TEMP")
AND a.CarrierType IN ("3PL", "Fleet")
AND a.TenderStatus IN ("", "Accepted", "Pickup_Notification")
AND a.OrderId NOT LIKE '%TONU%'