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
			AND Mode IN ("TL", "LTL", "")
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
			AND Mode IN ("TL", "LTL", "")
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
			AND Mode IN ("TL", "LTL", "")
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
	,d.mode
	,d.equipment
	,d.carrier
	,d.carriertype
	,d.business_unit
	,d.planpickupwk
	,d.planpickupdate
	,d.plandelivdate
	,d.srcname
	,d.srccity
	,d.srcstate
	,d.srccountry
	,d.srczip
	,d.srclat
	,d.srclon
	,d.destname
	,d.destcity
	,d.deststate
	,d.destcountry
	,d.destzip
	,d.destlat
	,d.destlon
	,d.intlflag
	,d.miles
	,d.distunload
	,d.distload
	,d.fuelcost
	,d.linehaul
	,d.totcost
	,od.ordertype_ol
	,od.mode_ol
	,od.equipment_ol
	,od.carrier_ol
	,od.carriertype_ol
	,od.business_unit_ol
	,od.planpickupwk_ol
	,od.plandelivdate_ol
	,od.plandelivdate_ol
	,od.srcname_ol
	,od.srccity_ol
	,od.srcstate_ol
	,od.srccountry_ol
	,od.srczip_ol
	,od.srclat_ol
	,od.srclong_ol
	,od.destcode_ol
	,od.destname_ol
	,od.desstcity_ol
	,od.deststate_ol
	,od.destcountry_ol
	,od.destzip_ol
	,od.destlat_ol
	,od.destlong_ol
	,od.intlflag_ol
	,od.miles_ol
	,od.distunload_ol
	,od.distload_ol
	,od.fuelcost_ol
	,od.linehaul_ol
	,od.totcost_ol
	,o.arrive_offset
FROM
	stop_union s
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
LEFT JOIN (
	SELECT DISTINCT --stoplevel delivery stops descriptive info.  For example adding the srcname to only the delivery stops.  Im not sure if this is needed in the report yet
		orderid
		,shipmentid
		,ordertype
		,mode
		,equipment
		,carrier
		,carriertype
		,busunit as business_unit
		,planpickupwk
		,planpickupdate
		,plandelivdate
		,srccode
		,srcname
		,srccity
		,srcstate
		,srccountry
		,srczip
		,srclat
		,srclon
		,destcode
		,destname
		,destcity
		,deststate
		,destcountry
		,destzip
		,destlat
		,destlon
		,intlflag
		,miles
		,distunload
		,distload
		,fuelcost
		,linehaul
		,totcost
		,case when orderid is not null
			and shipmentid is not null
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
		AND Mode IN ("TL", "LTL", "")
		AND CancelStatus = 'Not Cancelled'
		AND OrderType = 'Sales'
		AND Carrier NOT IN ("DO_NOT_TENDER", "TEMP")
		AND CarrierType IN ("3PL", "Fleet")
		AND TenderStatus IN ("", "Accepted", "Pickup_Notification")
		AND OrderId NOT LIKE '%TONU%'

	UNION ALL
	--pickup
	SELECT DISTINCT --stoplevel pickup stops descriptive info.  For example adding the srcname to only the delivery stops.  Im not sure if this is needed in the report yet
		orderid
		,shipmentid
		,ordertype
		,mode
		,equipment
		,carrier
		,carriertype
		,busunit as business_unit
		,planpickupwk
		,planpickupdate
		,plandelivdate
		,srccode
		,srcname
		,srccity
		,srcstate
		,srccountry
		,srczip
		,srclat
		,srclon
		,case when srccode is not null
			then srccode
			end as destcode
		,srcname as destname
		,srccity as destcity
		,srcstate as deststate
		,srccountry as destcountry
		,srczip as destzip
		,srclat as destlat
		,srclon as destlon
		,intlflag
		,miles
		,distunload
		,distload
		,fuelcost
		,linehaul
		,totcost
		,case when orderid is not null
			and shipmentid is not null
			then 'P'
			end as stoptype
		,case when shipmentid is not null
			then 1
			end as stopnum
	FROM
		orderlevel
	WHERE
		date(starttime) > '2019-08-01'
		AND Mode IN ("TL", "LTL", "")
		AND CancelStatus = 'Not Cancelled'
		AND OrderType = 'Sales'
		AND Carrier NOT IN ("DO_NOT_TENDER", "TEMP")
		AND CarrierType IN ("3PL", "Fleet")
		AND TenderStatus IN ("", "Accepted", "Pickup_Notification")
		AND OrderId NOT LIKE '%TONU%'

	UNION ALL
	--nfr
	SELECT DISTINCT  --stoplevel nfr stops descriptive info.  For example adding the srcname to only the delivery stops.  Im not sure if this is needed in the report yet
		ol.orderid
		,ol.shipmentid
		,nfr.ordertype
		,nfr.mode
		,nfr.eqpgrp as equipment
		,nfr.carrier
		,nfr.carriertype
		,nfr.busunit as business_unit
		,ol.planpickupwk
		,ol.planpickupdate
		,ol.plandelivdate
		,ol.srccode
		,nfr.srcname
		,nfr.srccity
		,nfr.srcstate
		,0
		,nfr.srczip
		,0
		,0
		,ol.destcode
		,nfr.destname
		,nfr.destcity
		,nfr.deststate
		,0
		,nfr.destzip
		,0
		,0
		,ol.intlflag
		,ol.miles
		,ol.distunload
		,ol.distload
		,ol.fuelcost
		,ol.linehaul
		,ol.totcost
		,nfr.stoptype
		,nfr.stopnum

	FROM
		orderlevel ol

	JOIN stoplevel_nfr nfr
		on ol.orderid = nfr.orderids
		and ol.shipmentid = nfr.shipmentid

	WHERE
		date(ol.starttime) > '2019-08-01'
		AND ol.Mode IN ("TL", "LTL", "")
		AND ol.CancelStatus = 'Not Cancelled'
		AND ol.OrderType = 'Sales'
		AND ol.Carrier NOT IN ("DO_NOT_TENDER", "TEMP")
		AND ol.CarrierType IN ("3PL", "Fleet")
		AND ol.TenderStatus IN ("", "Accepted", "Pickup_Notification")
		AND ol.OrderId NOT LIKE '%TONU%'
	) d
	on s.shipmentid = d.shipmentid
	and s.orderid = d.orderid
	and s.destcode = d.destcode
	and s.srccode = s.srccode
	and s.stoptype = d.stoptype
	and s.stopnum = d.stopnum
------
LEFT JOIN ( --this creates order level values.  For example to set the srcname for all rows within an order to be the same value
	SELECT DISTINCT
		orderid
		,shipmentid
		,ordertype as ordertype_ol
		,mode as mode_ol
		,equipment as equipment_ol
		,carrier as carrier_ol
		,carriertype as carriertype_ol
		,busunit as business_unit_ol
		,planpickupwk as planpickupwk_ol
		,planpickupdate as plandelivdate_ol
		,plandelivdate as plandelivdate_ol
		,srcname as srcname_ol
		,srccity as srccity_ol
		,srcstate as srcstate_ol
		,srccountry as srccountry_ol
		,srczip as srczip_ol
		,srclat as srclat_ol
		,srclon as srclong_ol
		,destcode as destcode_ol
		,destname as destname_ol
		,destcity as desstcity_ol
		,deststate as deststate_ol
		,destcountry as destcountry_ol
		,destzip as destzip_ol
		,destlat as destlat_ol
		,destlon as destlong_ol
		,intlflag as intlflag_ol
		,miles as miles_ol
		,distunload as distunload_ol
		,distload as distload_ol
		,fuelcost as fuelcost_ol
		,linehaul as linehaul_ol
		,totcost as totcost_ol

	FROM
		orderlevel

	WHERE
		date(starttime) > '2019-08-01'
		AND Mode IN ("TL", "LTL", "")
		AND CancelStatus = 'Not Cancelled'
		AND OrderType = 'Sales'
		AND Carrier NOT IN ("DO_NOT_TENDER", "TEMP")
		AND CarrierType IN ("3PL", "Fleet")
		AND TenderStatus IN ("", "Accepted", "Pickup_Notification")
		AND OrderId NOT LIKE '%TONU%'
	) od
	on s.shipmentid = od.shipmentid
	and s.orderid = od.orderid

LEFT JOIN (--this sets the arrive time next to the correct departure to make an easy depart-arrive_offset = route time
	SELECT
		orderid
		,shipmentid
		,adj_stopnum
		,arrive as arrive_offset
	FROM
		stop_union
	) o
on s.orderid = o.orderid
and s.shipmentid = o.shipmentid
and s.adj_stopnum = o.adj_stopnum-1