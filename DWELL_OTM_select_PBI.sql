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
			ordertype = 'Sales'
			and date(starttime) > '2019-08-01'

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
			ordertype = 'Sales'
			and date(starttime) > '2019-08-01'

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
			ordertype = 'Sales'
			and date(starttime) > '2019-08-01'
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