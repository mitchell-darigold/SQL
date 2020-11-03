----------------
--this table creates a stoplevel report with pickup, delivery, and nfr stops for each order 
----------------
--the stopnum feels a little wonky even though its correct.  There are 4 stops on the the three orders in the shipment each have 3 stops.  The delivery stop for 2 of the orders is the same which gets labeled as the second stop (correctly)
--for the 3rd order it has a different delivery stop which is labeled as the 3rd stop (correctly).  Then there is a 4th stop for all orders which is the NFR stop.  Since this is to the shipment granularity

--a table of pickup rows generated from orderlevel
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
				end as destcode --create a destcode same as srccode
			,case when shipmentid is not null
				and orderid is not null
				then 'P'
				end as stoptype --create a stop_type as P for pickup
			,case when shipmentid is not null
				then 1
				end as stopnum
				-- create a stop_num as 1 for the pickup
				--what happens when the NFR is the first stop and the pickup is the second? Thats why i added the adj_stopnum
		FROM
			orderlevel
		--remove this where, only for testing 
		WHERE
			shipmentid in (1034113, 368652, 431806, 234538, 93221, 1387282, 1425286, 1509321)

		UNION ALL

		--a table of delivery rows generated from orderlevel
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
			,stop_num as stopnum
		FROM
			orderlevel
		--remove this where, only for testing 
		WHERE
			shipmentid in (1034113, 368652, 431806, 234538, 93221, 1387282, 1425286, 1509321)

		UNION ALL

		--a table of NFR rows generated from stoplevel_nfr
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
		INNER JOIN ( --we want a single row per shipment orderid pair since there will be 1 nfr per shipment if there is a nfr at all.  this will cartesian the nfr table out to the orderid granularity.  
					--We can have many of the same nfr row duplicated for each order on the shipment
			SELECT DISTINCT
				shipmentid
				,orderid
			FROM
				orderlevel
			) ol
			on sl.shipmentid = ol.shipmentid

		--remove this where, only for testing and because we dont have the stoplevel_nfr table yet
		WHERE
			sl.shipmentid in (1034113, 368652, 431806, 234538, 93221, 1387282, 1425286, 1509321)
	)
)

-----------------
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
	,s.--put the adj in the with
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

------------------
--this table creates a distinct row table of descriptive values that attach *:1 (stoplevelunion:descriptive_table).
--the descritpive table will join on shipmentid, orderid, src
--write a statement for the descriptive columns which is unique to the orderlevel/destcodes

--write a MC__ticket statment to gather the data to the orderlevel i think, i need to investigate more.  so i can join it to the union above