--in progress to create a NFR only report

SELECT
stop.shipment_gid,
utc.get_local_date(stop.planned_arrival,loc.location_gid) planned_arrival,
utc.get_local_date(stop.planned_departure,loc.location_gid) planned_departure,
utc.get_local_date(stop.actual_arrival,loc.location_gid) actual_arrival,
utc.get_local_date(stop.actual_departure,loc.location_gid) actual_departure,
stop.stop_num,
stop.stop_type,
stop.dist_FROM_prev_stop,
stop.location_gid,
utc.get_local_date(stop.appointment_pickup,loc.location_gid) appointment_pickup,
utc.get_local_date(stop.appointment_delivery,loc.location_gid) appointment_delivery,
utc.get_local_date(stop.appointment_window_start,loc.location_gid) appointment_window_start,
utc.get_local_date(stop.appointment_window_end,loc.location_gid) appointment_window_end,
stop.wait_time,
stop.activity_time,
stop.rest_time,
loc.location_name,
loc.city,
loc.province_code,
loc.postal_code,
loc.country_code3_gid,
loc.lat,
loc.lon,
loc.time_zone_gid,
ship.planned_servprov_gid,
ship.servprov_gid,
ship.is_preferred_carrier,
ship.is_primary,
ship.is_servprov_fixed,
ship.reporting_scac,
ship.prev_reporting_scac,
ship.driver_gid,
ship.power_unit_gid,
utc.get_local_date(
	ship.start_time, 
	(
		SELECT loc.location_gid
		FROM location loc, shipment_stop stop 
		WHERE stop.location_gid=loc.location_gid
			AND stop.stop_type='P'
			AND stop.shipment_gid=ship.shipment_gid
			AND stop.stop_num=(
				SELECT MIN(stop_num)
				FROM shipment_stop
				WHERE shipment_gid=ship.shipment_gid
					AND stop_type='P'
				)
		)
	) start_time,
utc.get_local_date(
	ship.end_time, 
	(
		SELECT loc.location_gid
		FROM location loc, shipment_stop stop 
		WHERE stop.location_gid=loc.location_gid
			AND stop.stop_type='P'
			AND stop.shipment_gid=ship.shipment_gid
			AND stop.stop_num=(
				SELECT MIN(stop_num)
				FROM shipment_stop
				WHERE shipment_gid=ship.shipment_gid
					AND stop_type='P'
				)
		)
	) end_time,
ship.is_spot_costed,
ship.transport_mode_gid,
ship.first_equipment_group_gid,
ship.unloaded_distance,
nvl(ship.loaded_distance,ship.attribute_number2) loaded_distance,
ship.unloaded_distance+nvl(ship.loaded_distance,ship.attribute_number2) total_distance,
ship.total_actual_cost,
ship.attribute_number8 Accessorials,
ship.attribute_number9 Fuel,
ship.attribute_number10 Line_haul,
ship.weight_utilization,
ship.attribute2 ship_with_group,
-- Accepted Tender Cost
(SELECT planned_cost FROM tender_collaboration tender_collab, tender_collaboration_status tender_status WHERE ship.shipment_gid=tender_collab.shipment_gid AND tender_collab.i_transaction_no=tender_status.i_transaction_no AND tender_status.status_value_gid='DGI.TENDER.SECURE RESOURCES_ACCEPTED') Accepted_tender_cost,
 -- Tender Status
(SELECT decode(tender_status.status_value_gid,'DGI.TENDER.SECURE RESOURCES_ACCEPTED','Accepted','DGI.TENDER.SECURE RESOURCES_WITHDRAWN','Withdrawn','DGI.TENDER.SECURE RESOURCES_TIMED OUT','Timed_Out','DGI.TENDER.SECURE RESOURCES_TENDER RESPONSE OPEN','Response_Open','DGI.TENDER.SECURE RESOURCES_PICKUP NOTIFICATION','Pickup_Notification','DGI.TENDER.SECURE RESOURCES_DECLINED','Declined','DGI.TENDER.SECURE RESOURCES_TENDERED','Tendered',NULL,'Not_Tendered') FROM tender_collaboration_status tender_status, tender_collaboration tender_collab WHERE ship.shipment_gid=tender_collab.shipment_gid AND tender_collab.i_transaction_no=tender_status.i_transaction_no AND tender_collab.i_transaction_no=(SELECT max(i_transaction_no) FROM tender_collaboration tc2 WHERE tender_collab.shipment_gid=tc2.shipment_gid)) tender_status,
driver.first_name,
driver.last_name,
nvl(ship_units.ship_unit_count,'0') ship_unit_count,
nvl(ship_units.net_weight,'0') net_weight,
nvl(ship_units.gross_weight,'0') gross_weight,
-- Souce Location
(SELECT loc.location_gid FROM location loc,shipment_stop stop WHERE stop.location_gid=loc.location_gid AND stop.stop_type='P'AND stop.shipment_gid=ship.shipment_gid AND stop.stop_num=(SELECT min(stop_num) FROM shipment_stop WHERE shipment_gid=ship.shipment_gid AND stop_type='P')) source_location,
-- Souce Location Name
(SELECT loc.location_Name FROM location loc,shipment_stop stop WHERE stop.location_gid=loc.location_gid AND stop.stop_type='P'AND stop.shipment_gid=ship.shipment_gid AND stop.stop_num=(SELECT min(stop_num) FROM shipment_stop WHERE shipment_gid=ship.shipment_gid AND stop_type='P')) source_location_name,
-- Souce Location City
(SELECT loc.city FROM location loc,shipment_stop stop WHERE stop.location_gid=loc.location_gid AND stop.stop_type='P'AND stop.shipment_gid=ship.shipment_gid AND stop.stop_num=(SELECT min(stop_num) FROM shipment_stop WHERE shipment_gid=ship.shipment_gid AND stop_type='P')) source_city,
-- Souce Location Province Code
(SELECT loc.province_code FROM location loc,shipment_stop stop WHERE stop.location_gid=loc.location_gid AND stop.stop_type='P'AND stop.shipment_gid=ship.shipment_gid AND stop.stop_num=(SELECT min(stop_num) FROM shipment_stop WHERE shipment_gid=ship.shipment_gid AND stop_type='P')) source_province_code,
-- Souce Location Postal Code
(SELECT loc.postal_code FROM location loc,shipment_stop stop WHERE stop.location_gid=loc.location_gid AND stop.stop_type='P'AND stop.shipment_gid=ship.shipment_gid AND stop.stop_num=(SELECT min(stop_num) FROM shipment_stop WHERE shipment_gid=ship.shipment_gid AND stop_type='P')) source_postal_code,

-- Source Location Lat
-- Source Location Lon

-- International Flag
(
	SELECT DISTINCT nvl(ord.attribute10, 'NO')
	FROM order_release ord,order_movement ordmove 
	WHERE ordmove.order_release_gid=ord.order_release_gid 
		AND ordmove.shipment_gid=ship.shipment_gid
		) international_flag,

-- Divsion
(SELECT listagg(ordref.order_release_refnum_value,';') within group (ORDER BY ordref.order_release_refnum_value) FROM order_release_refnum ordref,order_movement ordmove WHERE ordmove.order_release_gid=ordref.order_release_gid AND ordref.order_release_refnum_qual_gid='DGI.DIVISION' AND ordmove.shipment_gid=ship.shipment_gid) division,
-- Order Type
(
	SELECT listagg(ord.order_release_type_gid,';') within group (ORDER BY ord.order_release_type_gid)  
	FROM order_release ord,order_movement ordmove 
	WHERE ordmove.order_release_gid=ord.order_release_gid 
		AND ordmove.shipment_gid=ship.shipment_gid
		) ordertype,
gl_cost.ship_gl_cost,
gl_cost.invoice_gl_cost,
-- Line_Haul
(SELECT sum(cost) FROM shipment_cost sc WHERE cost_type IN ('B','D') AND IS_WEIGHTED = 'N' AND ship.shipment_gid=sc.shipment_gid) Line_haul_new,
-- Fuel
(SELECT sum(cost) FROM shipment_cost sc WHERE sc.shipment_gid = ship.shipment_gid AND sc.accessorial_code_gid IN ('DGI.FLEET_FUEL','DGI.405')) Fuel_new,
-- Equipment Group Profile
(SELECT listagg(equipment_group_profile_gid,';') within group (ORDER BY equipment_Group_profile_gid) FROM (SELECT DISTINCT equipment_group_profile_gid FROM order_movement om WHERE om.shipment_gid=ship.shipment_gid)) equipment_group_profile,
-- SOS Refnum
(SELECT listagg(remark_text,';') within group (ORDER BY remark_text) FROM shipment_stop_remark ssr WHERE remark_qual_gid='DGI.SOS' AND shipment_gid=ship.shipment_gid AND stop_num=stop.stop_num) SOS

FROM
shipment_stop stop,
location loc,
shipment ship,
driver,
-- Ship Units
(SELECT sum(ssu.ship_unit_count) ship_unit_count,sum(unit_net_weight)net_weight,sum(total_gross_weight)gross_weight, stopd.shipment_gid, stopd.stop_num FROM s_ship_unit ssu,shipment_stop_d stopd WHERE  stopd.s_ship_unit_gid=ssu.s_ship_unit_gid GROUP BY stopd.shipment_gid, stopd.stop_num) ship_units,
-- GL COSTS
(SELECT sum(ssu.tag_2) ship_gl_cost,sum(ssu.tag_3) invoice_gl_cost,stopd.shipment_gid,stopd.stop_num FROM s_ship_unit ssu, shipment_stop_d stopd WHERE stopd.s_ship_unit_gid=ssu.s_ship_unit_gid GROUP BY stopd.shipment_gid,stopd.stop_num) gl_cost

WHERE stop.location_gid=loc.location_gid
AND stop.shipment_gid=ship.shipment_gid
AND stop.stop_type IS NOT NULL
AND ship.shipment_gid=stop.shipment_gid
AND driver.driver_gid(+)=ship.driver_gid
AND gl_cost.shipment_gid(+)=ship.shipment_gid
AND gl_cost.stop_num(+)=stop.stop_num
AND ship_units.shipment_gid(+)=stop.shipment_gid
AND ship_units.stop_num(+)=stop.stop_num
AND stop.stop_type = 'NFR'
AND (SELECT decode(is_fleet,'Y','FLEET','N','3PL') FROM servprov WHERE ship.servprov_gid=servprov.servprov_gid) IN(:P_Carrier_Type)
AND (SELECT trunc(planned_arrival) FROM shipment_stop WHERE shipment_gid=ship.shipment_gid AND stop_num=(SELECT min(stop_num) FROM shipment_stop WHERE shipment_gid=ship.shipment_gid AND stop_type='P')) between nvl(:P_Planned_From,trunc(sysdate)-60) AND nvl(:P_Planned_To,trunc(sysdate))
ORDER BY  stop.shipment_gid,stop.stop_num