--a table of pickup rows generated from orderlevel
SELECT DISTINCT
	shipmentid
	,orderid
	,substr(driverid, 5, 10)
	,actualshipdate as arrive
	,actual_ship_depart as depart
	,srccode
	,case when srccode is not null
		then srccode
		end as destscode --create a destcode same as srccode
	,case when shipmentid is not null
		and orderid is not null
		then 'P'
		end as stoptype --create a stop_type as P for pickup
	,case when shipmentid is not null
		then 1
		end as stopnum
		-- create a stop_num as 1 for the pickup
		--what happens when the NFR is the first stop and the pickup is the second?
		--i should find an example where NFR is the first stop and see what happens
FROM
	orderlevel
--remove this where, only for testing 
WHERE
	shipmentid = 28474

UNION ALL

--a table of delivery rows generated from orderlevel
SELECT DISTINCT
	shipmentid
	,orderid
	,substr(driverid, 5, 10)
	,actualdelivdate as arrive
	,actual_deliv_depart as depart
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
	shipmentid = 28474

UNION ALL

--a table of NFR rows generated from stoplevel_nfr
SELECT
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
	stoplevel sl
	--stoplevel_nfr sl
	--once this stoplevel_nfr table is created can fix the from clause
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
	sl.stoptype = 'NFR'
	and sl.shipmentid = 28474;

--this overall query works pretty good once a standard shipment with pickup as stop 1 and nfr as the last stop
--the stop number feels a little wonky even though its correct.  There are 4 stops on the the three orders in the shipment each have 3 stops.  The delivery stop for 2 of the orders is the same which gets labeled as the second stop (correctly)
--for the 3rd order it has a different delivery stop which is labeled as the 3rd stop (correctly).  Then there is a 4th stop for all orders which is the NFR stop.  Since this is to the shipment granularity