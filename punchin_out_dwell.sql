
SELECT
d.*
,e.punchin
,f.punchout

FROM (
	SELECT
		*
		,a.driverid||"-"||date(b.min_actualarrive) as var_arrive
		,a.driverid||"-"||date(c.max_actualdepart) as var_depart

	FROM
		stoplevel a

	LEFT JOIN (
		SELECT
			OrderIds
			,ShipmentId
			,min(actualarrive) as min_actualarrive
		FROM
			stoplevel
		) b
		ON a.ShipmentId = b.ShipmentId
		AND a.actualarrive = b.min_actualarrive

	LEFT JOIN (
		SELECT
			OrderIds
			,ShipmentId
			,max(actualdepart) as max_actualdepart
		FROM
			stoplevel
		) c
		ON a.ShipmentId = c.ShipmentId
		AND a.actualdepart = c.max_actualdepart
	) d

LEFT JOIN (
	SELECT
		otmid||"-"||date(punchin) as var_arrive
		,punchin
	FROM
		employeetimedetail
	) e
	ON d.var_arrive = e.var_arrive

LEFT JOIN (
	SELECT
		otmid||"-"||date(punchout) as var_depart
		,punchout
	FROM
		employeetimedetail
	) f
	ON d.var_depart = f.var_depart
