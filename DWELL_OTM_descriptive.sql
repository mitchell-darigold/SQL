--delivery
SELECT DISTINCT
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
	,srcname
	,srccity
	,srcstate
	,srccountry
	,srczip
	,srclat
	,srclon
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
		end
FROM
	orderlevel

WHERE
	ordertype = 'Sales'
	and shipmentid in (1034113, 368652, 431806, 234538, 93221, 1387282, 1425286, 1509321)

UNION ALL
--pickup
SELECT DISTINCT
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
	,srcname
	,srccity
	,srcstate
	,srccountry
	,srczip
	,srclat
	,srclon
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
		end
FROM
	orderlevel
WHERE
	ordertype = 'Sales'
	and shipmentid in (1034113, 368652, 431806, 234538, 93221, 1387282, 1425286, 1509321)

UNION ALL
--nfr
SELECT DISTINCT
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
	,nfr.srcname
	,nfr.srccity
	,nfr.srcstate
	,nfr.srccountry
	,nfr.srczip
	,0
	,0
	,nfr.destname
	,nfr.destcity
	,nfr.deststate
	,nfr.destcountry
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

FROM
	orderlevel ol
WHERE
	ordertype = 'Sales'
	and shipmentid in (1034113, 368652, 431806, 234538, 93221, 1387282, 1425286, 1509321)

INNER JOIN stoplevel_nfr nfr
	on ol.orderid = nfr.orderids
	and ol.shipmentid = nfr.shipmentid





	--union all three together create a stop type field set as p or d or nfr
	--in powerbi join on orderid, shipmentid, destcode, srccode and stoptype
	--will that result in cartesian? I want it to be 1:1