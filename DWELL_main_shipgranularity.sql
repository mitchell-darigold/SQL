WITH stop_union as (
	SELECT
		a.shipmentid
		,a.driverid
		,a.arrive
		,a.depart
		,a.srccode
		,a.destcode
		,a.stoptype
		,a.stopnum
		,a.mode
		,a.equipment
		,a.carrier
		,a.carriertype
		,a.business_unit
		,a.starttime
		,a.srcname
		,a.srccity
		,a.srcstate
		,a.srccountry
		,a.srczip
		,a.srclat
		,a.srclon
		,a.destname
		,a.destcity
		,a.deststate
		,a.destcountry
		,a.destzip
		,a.destlat
		,a.destlong
		,a.intlflag
		,a.miles
		,a.distunload
		,a.distload
		,a.fuelcost
		,a.linehaul
		,a.totcost
		,row_number() over (
			partition by shipmentid order by stopnum asc, stoptype asc
			) as adj_stopnum
	FROM (
		SELECT DISTINCT
			shipmentid
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
			,mode as mode
			,equipment as equipment
			,carrier as carrier
			,carriertype as carriertype
			,busunit as business_unit
			,starttime as starttime
			,srcname as srcname
			,srccity as srccity
			,srcstate as srcstate
			,srccountry as srccountry
			,srczip as srczip
			,srclat as srclat
			,srclon as srclon
			,srcname as destname
			,srccity as destcity
			,srcstate as deststate
			,srccountry as destcountry
			,srczip as destzip
			,srclat as destlat
			,srclon as destlong
			,intlflag as intlflag
			,0 as miles
			,0 as distunload
			,0 as distload
			,0 as fuelcost
			,0 as linehaul
			,0 as totcost

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
			,mode as mode
			,equipment as equipment
			,carrier as carrier
			,carriertype as carriertype
			,busunit as business_unit
			,starttime as starttime
			,srcname as srcname
			,srccity as srccity
			,srcstate as srcstate
			,srccountry as srccountry
			,srczip as srczip
			,srclat as srclat
			,srclon as srclong
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
			,sl.driverid
			,sl.actualarrive as arrive
			,sl.actualdepart as depart
			,sl.srccode
			,sl.destcode
			,sl.stoptype
			,sl.stopnum
			,sl.mode as mode
			,sl.eqpgrp as equipment
			,case when sl.carrier = "RAINIER FLEET" then "RAINIER_FLEET"
				when sl.carrier = "BOISE FLEET" then "BOISE_FLEET"
				when sl.carrier = "SPOKANE FLEET" then "SPOKANE_FLEET"
				when sl.carrier = "BOZEMAN FLEET" then "BOZEMAN_FLEET"
				when sl.carrier = "PORTLAND FLEET" then "PORTLAND_FLEET"
				when sl.carrier = "SUNNYSIDE FLEET" then "SUNNYSIDE_FLEET"
				END as carrier
			,sl.carriertype as carriertype
			,sl.busunit as business_unit
			,sl.starttime as starttime
			,sl.srcname as srcname
			,sl.srccity as srccity
			,sl.srcstate as srcstate
			,0 as srccountry
			,sl.srczip as srczip
			,0
			,0
			,sl.destname as destname
			,sl.destcity as destcity
			,sl.deststate as deststate
			,0 as destcountry
			,sl.destzip
			,0
			,0
			,0
			,0
			,0
			,0
			,0
			,0
			,0

		FROM
			stoplevel_nfr sl
		WHERE
			date(starttime) > '2019-08-01'
			AND ordertype = 'Sales'
			AND TenderStatus IN ("", "Accepted", "Pickup_Notification")
			AND OrderIds NOT LIKE '%TONU%'
		) a
)

SELECT
	s.shipmentid
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
	,e.firstname
	,e.lastname
	,e.fullname
	,o.arrive as arrive_offset
	,fa.final_arrive
	,s.mode
	,s.equipment
	,s.carrier
	,s.carriertype
	,s.business_unit
	,s.starttime
	,s.srcname
	,s.srccity
	,s.srcstate
	,s.srccountry
	,s.srczip
	,s.srclat
	,s.srclon
	,s.destname
	,s.destcity
	,s.deststate
	,s.destcountry
	,s.destzip
	,s.destlat
	,s.destlong
	,s.intlflag
	,s.miles
	,s.distunload
	,s.distload
	,s.fuelcost
	,s.linehaul
	,s.totcost

FROM
	stop_union s

LEFT JOIN (
	SELECT
		su.shipmentid
		,etd.punchin

	FROM (
		SELECT
			shipmentid
			,driverid
			,min(depart) as min_depart
		FROM
			stop_union
		WHERE
			driverid <> ""
		GROUP BY
			shipmentid
			,driverid
			) su
	LEFT JOIN employeetimedetail etd
		on etd.punchin >= datetime(su.min_depart, '-12 hours') 
		and etd.punchin <= su.min_depart
		and su.driverid = etd.otmid	
) pi
	on s.shipmentid = pi.shipmentid

LEFT JOIN (
	SELECT
		su.shipmentid
		,etd.punchout

	FROM (
		SELECT
			shipmentid
			,driverid
			,max(arrive) as max_arrive
		FROM 
			stop_union
		WHERE
			driverid <> ""
		GROUP BY
			shipmentid
			,driverid
			) su
	LEFT JOIN employeetimedetail etd
		on etd.punchout >= su.max_arrive 
		and etd.punchout <= datetime(su.max_arrive, '+12 hours')
		and su.driverid = etd.otmid
) po
	on s.shipmentid = po.shipmentid

LEFT JOIN stop_union o
	on s.shipmentid = o.shipmentid
	and s.adj_stopnum = o.adj_stopnum-1

LEFT JOIN (
	SELECT DISTINCT
		otmid
		,firstname
		,lastname
		,fullname
	FROM
		employeetimedetail
	) e
	on s.driverid = e.otmid

LEFT JOIN (
	SELECT
		sa.shipmentid
		,sa.arrive as final_arrive
	FROM
		stop_union sa
	INNER JOIN
		(
			SELECT
				shipmentid
				,max(adj_stopnum) as max_stopnum
			FROM
				stop_union
			GROUP BY
				shipmentid
		) ms
		on sa.shipmentid = ms.shipmentid
		and sa.adj_stopnum = ms.max_stopnum
) fa
	on s.shipmentid = fa.shipmentid
