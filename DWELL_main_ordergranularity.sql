WITH stop_union as (
	SELECT
		shipmentid
		,orderid
		,driverid
		,arrive
		,depart
		,srccode
		,destcode
		,stoptype
		,stopnum
		,row_number() over (
			partition by orderid order by stopnum asc, stoptype asc
			) as adj_stopnum
	FROM (

		SELECT DISTINCT
			shipmentid
			,orderid
			,substr(driverid, 5, 10) as driverid
			,pickuparrive as arrive
			,pickupdepart as depart
			,srccode
			,case when srccode is not null
			then srccode
			end as destcode
			,case when shipmentid is not null
			and orderid is not null
			then 'P'
			end as stoptype
			,case when shipmentid is not null
			then 1
			end as stopnum

		FROM
			orderlevel

		WHERE
			date(starttime) > '2019-08-01'
			--AND Mode IN ("TL", "LTL", "")
			AND CancelStatus = 'Not Cancelled'
			AND OrderType = 'Sales'
			AND Carrier NOT IN ("DO_NOT_TENDER", "TEMP")
			AND CarrierType IN ("3PL", "Fleet")
			AND TenderStatus IN ("", "Accepted", "Pickup_Notification")
			AND OrderId NOT LIKE '%TONU%'

		UNION ALL

		SELECT DISTINCT
			shipmentid
			,orderid
			,substr(driverid, 5, 10)
			,deliveryarrive as arrive
			,deliverydepart as depart
			,srccode
			,destcode
			,case when shipmentid is not null
			and orderid is not null
			then 'D'
			end as stoptype
			,case when stop_num is null 
			then 2
			else stop_num
			end as stopnum

		FROM
			orderlevel

		WHERE
			date(starttime) > '2019-08-01'
			--AND Mode IN ("TL", "LTL", "")
			AND CancelStatus = 'Not Cancelled'
			AND OrderType = 'Sales'
			AND Carrier NOT IN ("DO_NOT_TENDER", "TEMP")
			AND CarrierType IN ("3PL", "Fleet")
			AND TenderStatus IN ("", "Accepted", "Pickup_Notification")
			AND OrderId NOT LIKE '%TONU%'

		UNION ALL

		SELECT DISTINCT
			sl.shipmentid
			,ol.orderid
			,sl.driverid
			,sl.actualarrive as arrive
			,sl.actualdepart as depart
			,sl.srccode
			,sl.destcode
			,sl.stoptype
			,sl.stopnum
		FROM
			stoplevel_nfr sl
		INNER JOIN ( 
			SELECT DISTINCT
			shipmentid
			,orderid
		FROM
			orderlevel
			) ol
			on sl.shipmentid = ol.shipmentid

		WHERE
			date(starttime) > '2019-08-01'
			--AND Mode IN ("TL", "LTL", "")
			AND OrderType = 'Sales'
			AND Carrier NOT IN ("DO_NOT_TENDER", "TEMP")
			AND CarrierType IN ("3PL", "Fleet")
			AND TenderStatus IN ("", "Accepted", "Pickup_Notification")
			AND OrderId NOT LIKE '%TONU%'
		)
	)

SELECT
	s.shipmentid
	,s.orderid
	,s.driverid
	,s.arrive
	,s.depart
	,s.srccode
	,s.destcode
	,s.stoptype
	,s.stopnum
	,s.adj_stopnum
	,pi.punchin
	,po.punchout
	,od.ordertype
	,od.mode
	,od.equipment
	,od.carrier
	,od.carriertype
	,od.business_unit
	,od.planpickupwk
	,od.plandelivdate
	,od.plandelivdate
	,od.starttime
	,od.srcname
	,od.srccity
	,od.srcstate
	,od.srccountry
	,od.srczip
	,od.srclat
	,od.srclong
	,od.destcode
	,od.destname
	,od.desstcity
	,od.deststate
	,od.destcountry
	,od.destzip
	,od.destlat
	,od.destlong
	,od.intlflag
	,od.miles
	,od.distunload
	,od.distload
	,od.fuelcost
	,od.linehaul
	,od.totcost
	,o.arrive as arrive_offset
FROM
	stop_union s

INNER JOIN (
	SELECT DISTINCT
		orderid
		,shipmentid
		,ordertype as ordertype
		,mode as mode
		,equipment as equipment
		,carrier as carrier
		,carriertype as carriertype
		,busunit as business_unit
		,planpickupwk as planpickupwk
		,planpickupdate as plandelivdate
		,plandelivdate as plandelivdate
		,starttime as starttime
		,srcname as srcname
		,srccity as srccity
		,srcstate as srcstate
		,srccountry as srccountry
		,srczip as srczip
		,srclat as srclat
		,srclon as srclong
		,destcode as destcode
		,destname as destname
		,destcity as desstcity
		,deststate as deststate
		,destcountry as destcountry
		,destzip as destzip
		,destlat as destlat
		,destlon as destlong
		,intlflag as intlflag
		,miles as miles
		,distunload as distunload
		,distload as distload
		,fuelcost as fuelcost
		,linehaul as linehaul
		,totcost as totcost

	FROM
		orderlevel

	WHERE
		date(starttime) > '2019-08-01'
		--AND Mode IN ("TL", "LTL", "")
		AND CancelStatus = 'Not Cancelled'
		AND OrderType = 'Sales'
		AND Carrier NOT IN ("DO_NOT_TENDER", "TEMP")
		AND CarrierType IN ("3PL", "Fleet")
		AND TenderStatus IN ("", "Accepted", "Pickup_Notification")
		AND OrderId NOT LIKE '%TONU%'
	) od
	on s.shipmentid = od.shipmentid
	and s.orderid = od.orderid

LEFT JOIN (
	SELECT
		su.shipmentid
		,su.orderid
		,etd.punchin

	FROM (
		SELECT
			orderid
			,shipmentid
			,driverid
			,date(min(arrive)) as min_arrive
		FROM
			stop_union
		WHERE
			driverid <> ""
		GROUP BY
			orderid
			,shipmentid
			,driverid
		) su
	LEFT JOIN employeetimedetail etd
		on su.min_arrive = date(etd.punchin)
		and su.driverid = etd.otmid	
) pi
	on s.shipmentid = pi.shipmentid
	and s.orderid = pi.orderid

LEFT JOIN (
	SELECT
		su.shipmentid
		,su.orderid
		,etd.punchout

	FROM (
		SELECT
			orderid
			,shipmentid
			,driverid
			,date(max(depart)) as max_depart
		FROM 
			stop_union
		WHERE
			driverid <> ""
		GROUP BY
			orderid
			,shipmentid
			,driverid
		) su
	LEFT JOIN employeetimedetail etd
		on su.max_depart = date(etd.punchout)
		and su.driverid = etd.otmid
) po
	on s.shipmentid = po.shipmentid
	and s.orderid = po.orderid

LEFT JOIN stop_union o
	on s.orderid = o.orderid
	and s.shipmentid = o.shipmentid
	and s.adj_stopnum = o.adj_stopnum-1;