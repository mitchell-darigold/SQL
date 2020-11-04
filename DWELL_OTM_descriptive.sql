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
	,case when shipmentid is not null
		then 1
		end as stopnum
FROM
	orderlevel
WHERE
	ordertype = 'Sales'
	and date(starttime) > '2019-08-01'

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
	,0
	,nfr.srczip
	,0
	,0
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
	ol.ordertype = 'Sales'
	and date(ol.starttime) > '2019-08-01'




	--union all three together create a stop type field set as p or d or nfr
	--in powerbi join on orderid, shipmentid, destcode, srccode and stoptype and stopnum
	--will that result in cartesian? I want it to be 1:1
	--at this moment 11/4/20 9:50am i think it will be 1:1