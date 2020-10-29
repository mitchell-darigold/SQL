SELECT
glog_util.remove_domain(ship.shipment_gid) shipment_id,
glog_util.remove_domain(ship.servprov_gid) servprov,
glog_util.remove_domain(ship.transport_mode_gid) transport_mode,
glog_util.remove_domain(ship.first_equipment_group_gid) first_equipment_group_id,
utc.get_local_date(ship.start_time,ship.source_location_gid) start_time,
utc.get_local_date(ship.end_time,ship.dest_location_gid) end_time,
ship.is_spot_costed,
ship.loaded_distance,
ship.loaded_distance_uom_code,
ship.unloaded_distance,
ship.unloaded_distance_uom_code,
ship.total_distance,
ship.weight_utilization,
ship.volume_utilization,
ship.power_unit_gid,
ship.driver_gid,
ship.Accessorials,
ship.Fuel,
ship.Line_haul,
glog_util.remove_domain(orl.order_release_line_gid) order_release_line_id,
glog_util.remove_domain(orl.packaged_item_gid) packaged_item_id,
glog_util.remove_domain(orl.order_release_gid) order_release,
orl.weight,
orl.weight_uom_code,
ship.total_actual_cost,
glog_util.remove_domain(ship.source_location_gid) source_location_id,
glog_util.remove_domain(ord.dest_location_gid) dest_location_id,
glog_util.remove_domain(ord.payment_method_code_gid) Freight_Terms,
utc.get_local_date(ord.insert_date,nvl(ord.source_location_gid,'DGI.100')) order_insert_date,
(SELECT location_name FROM location WHERE location.location_gid=ship.source_location_gid) source_location_name,
(SELECT city FROM location WHERE location.location_gid=ship.source_location_gid) source_city,
(SELECT province_code FROM location WHERE location.location_gid=ship.source_location_gid) source_province_code,
(SELECT postal_code FROM location WHERE location.location_gid=ship.source_location_gid) source_postal_code,
(SELECT country_code3_gid FROM location WHERE location.location_gid=ship.source_location_gid) source_country,
(SELECT lat FROM location WHERE location.location_gid=ship.source_location_gid) source_lat,
(SELECT lon FROM location WHERE location.location_gid=ship.source_location_gid) source_lon,
(SELECT location_name FROM location WHERE location.location_gid=ord.dest_location_gid) dest_location_name,
(SELECT city FROM location WHERE location.location_gid=ord.dest_location_gid) dest_city,
(SELECT province_code FROM location WHERE location.location_gid=ord.dest_location_gid) dest_province_code,
(SELECT postal_code FROM location WHERE location.location_gid=ord.dest_location_gid) dest_postal_code,
(SELECT country_code3_gid FROM location WHERE location.location_gid=ord.dest_location_gid) dest_country,
(SELECT lat FROM location WHERE location.location_gid=ord.dest_location_gid) dest_lat,
(SELECT lon FROM location WHERE location.location_gid=ord.dest_location_gid) dest_lon,
ord.attribute2 business_unit,
glog_util.remove_domain(ord.order_release_type_gid) order_release_type_id,
glog_util.remove_domain(ord.equipment_group_profile_gid) equipment_group_profile_id,
ord.ship_with_group,
ord.attribute10 international_flag,
-- gl code
(
	SELECT listagg(ssu.tag_1,';') within group (ORDER BY ssu.tag_1) 
	FROM s_ship_unit ssu, 
		s_ship_unit_line ssul,
		shipment_s_equipment_join ssej,
		s_equipment_s_ship_unit_join sessj 
	WHERE ssul.s_ship_unit_gid=ssu.s_ship_unit_gid 
		AND ssu.s_ship_unit_gid=sessj.s_ship_unit_gid 
		AND ssej.s_equipment_gid=sessj.s_equipment_gid 
		AND orl.order_release_line_gid=ssul.or_line_gid 
		AND ship.shipment_gid=ssej.shipment_gid
		) gl_code,
-- shipment_gl_cost
(
	SELECT listagg(ssu.tag_2,';') within group (ORDER BY ssu.tag_2) 
	FROM s_ship_unit ssu, 
		s_ship_unit_line ssul,
		shipment_s_equipment_join ssej,
		s_equipment_s_ship_unit_join sessj 
	WHERE ssul.s_ship_unit_gid=ssu.s_ship_unit_gid 
		AND ssu.s_ship_unit_gid=sessj.s_ship_unit_gid 
			AND ssej.s_equipment_gid=sessj.s_equipment_gid 
			AND orl.order_release_line_gid=ssul.or_line_gid 
			AND ship.shipment_gid=ssej.shipment_gid
			) shipment_gl_cost,
-- invoice_gl_cost
(
	SELECT listagg(ssu.tag_3,';') within group (ORDER BY ssu.tag_3) 
	FROM s_ship_unit ssu, 
		s_ship_unit_line ssul,
		shipment_s_equipment_join ssej,
		s_equipment_s_ship_unit_join sessj 
	WHERE ssul.s_ship_unit_gid=ssu.s_ship_unit_gid 
		AND ssu.s_ship_unit_gid=sessj.s_ship_unit_gid 
		AND ssej.s_equipment_gid=sessj.s_equipment_gid 
		AND orl.order_release_line_gid=ssul.or_line_gid 
		AND ship.shipment_gid=ssej.shipment_gid
		) invoice_gl_cost,
-- Product Group
(
	SELECT attribute1 product_group 
	FROM packaged_item pi 
	WHERE orl.packaged_item_gid=pi.packaged_item_gid
	) product_group,
-- Product Description
(SELECT description FROM packaged_item pi WHERE orl.packaged_item_gid=pi.packaged_item_gid) item_description,
-- Order Cancel Status
(
	SELECT decode(status_value_gid,
		'DGI.CANCELLED_NOT CANCELLED',
		'Not Cancelled',
		'DGI.CANCELLED_CANCELLED',
		'Cancelled') 
	FROM order_release_status order_status 
	WHERE order_status.order_release_gid=ord.order_release_gid 
		AND order_status.status_type_gid='DGI.CANCELLED'
		) Cancel_status,
-- Location Change Flag
(
	SELECT order_release_refnum_value 
	FROM order_release_refnum order_refnum 
	WHERE order_release_refnum_qual_gid='DGI.LOCATION CHANGE' 
		AND order_refnum.order_release_gid=ord.order_release_gid
	) Location_change_flag,
-- Lead Time Flag
(
	SELECT order_release_refnum_value 
	FROM order_release_refnum order_refnum 
	WHERE order_release_refnum_qual_gid='DGI.LEAD TIME' 
		AND order_refnum.order_release_gid=ord.order_release_gid
		) Lead_time_flag,
-- Accepted Tender Cost
(
	SELECT planned_cost 
	FROM tender_collaboration tender_collab, 
		tender_collaboration_status tender_status 
	WHERE ship.shipment_gid=tender_collab.shipment_gid 
		AND tender_collab.i_transaction_no=tender_status.i_transaction_no 
		AND tender_status.status_value_gid='DGI.TENDER.SECURE RESOURCES_ACCEPTED'
		) Accepted_tender_cost,
 -- Tender Status
(
	SELECT decode(status_value_gid,
		'DGI.TENDER.SECURE RESOURCES_ACCEPTED','Accepted',
		'DGI.TENDER.SECURE RESOURCES_WITHDRAWN','Withdrawn',
		'DGI.TENDER.SECURE RESOURCES_TIMED OUT','Timed_Out',
		'DGI.TENDER.SECURE RESOURCES_TENDER RESPONSE OPEN','Response_Open',
		'DGI.TENDER.SECURE RESOURCES_PICKUP NOTIFICATION','Pickup_Notification',
		'DGI.TENDER.SECURE RESOURCES_DECLINED','Declined',
		'DGI.TENDER.SECURE RESOURCES_TENDERED','Tendered',
		NULL,'Not_Tendered') 
	FROM (
		SELECT status_value_gid
		FROM tender_collaboration_status tender_status, 
			tender_collaboration tender_collab 
		WHERE ship.shipment_gid=tender_collab.shipment_gid 
			AND tender_collab.i_transaction_no=tender_status.i_transaction_no 
		ORDER BY tender_collab.i_transaction_no DESC
		)
	WHERE rownum=1

	) tender_status,

-- Planned Ship Date
(
	SELECT utc.get_local_date(planned_arrival,location_gid) 
	FROM shipment_stop 
	WHERE shipment_gid=ship.shipment_gid 
		AND stop_num=(
			SELECT MIN(stop_num) 
			FROM shipment_stop 
			WHERE shipment_gid=ship.shipment_gid 
				AND stop_type='P'
				)
		) Planned_Ship_date,

-- Actual Ship Date aka actual_arrival_src
(
	SELECT utc.get_local_date(actual_arrival,location_gid) 
	FROM shipment_stop 
	WHERE shipment_gid=ship.shipment_gid 
		AND stop_num=(
			SELECT MIN(stop_num) 
			FROM shipment_stop 
			WHERE shipment_gid=ship.shipment_gid 
				AND stop_type='P'
				)
		) Actual_Ship_date,

-- Planned Delivery Date
utc.get_local_date(ord.late_delivery_date, ord.dest_location_gid) late_delivery_date,

-- Actual Delivery Date aka actual_arrival_dest
(
	SELECT utc.get_local_date(actual_arrival,location_gid) 
	FROM shipment_stop 
	WHERE shipment_gid=ship.shipment_gid 
		AND stop_type='D'
		AND location_gid=ord.dest_location_gid
	) Actual_Delv_Date, 

--Actual Delivery Date Depart aka actual_depart_dest
(
	SELECT utc.get_local_date(actual_departure,location_gid) 
	FROM shipment_stop 
	WHERE shipment_gid=ship.shipment_gid 
		AND stop_type='D'
		AND location_gid=ord.dest_location_gid
	) Actual_Delv_Date_Depart, 

--Actual Ship Date Depart aka actual_dept_src

(
	SELECT utc.get_local_date(actual_departure,location_gid) 
	FROM shipment_stop 
	WHERE shipment_gid=ship.shipment_gid 
		AND stop_num=(
			SELECT MIN(stop_num) 
			FROM shipment_stop 
			WHERE shipment_gid=ship.shipment_gid 
				AND stop_type='P'
				)
		) Actual_Ship_date_depart,

case when to_char(:P_FROM_DAY,'DDD') is NULL then (to_char(sysdate-5,'DDD')) else to_char(:P_FROM_DAY,'DDD') end FROM_DAY,
case when to_char(:P_TO_DAY,'DDD') is NULL then (to_char(sysdate-1,'DDD')) else to_char(:P_TO_DAY,'DDD') end TO_DAY,
case when :P_YEAR is NULL then to_char(sysdate,'YYYY') else :P_YEAR end year


FROM
(
	SELECT ship.shipment_gid,
		ship.servprov_gid,
		ship.transport_mode_gid,
		ship.first_equipment_group_gid,
		ship.start_time,ship.end_time,
		ship.is_spot_costed,
		ship.loaded_distance,
		ship.loaded_distance_uom_code,
		ship.unloaded_distance,
		ship.unloaded_distance_uom_code,
		ship.loaded_distance+ship.unloaded_distance total_distance,
		ship.weight_utilization,ship.volume_utilization,
		ship.power_unit_gid,ship.driver_gid,
		ship.attribute_number8 Accessorials,
		ship.attribute_number9 Fuel,
		ship.attribute_number10 Line_haul,
		ship.total_actual_cost,
		ship.source_location_gid,
		ship.dest_location_gid,
		order_movement.order_release_gid 
	FROM shipment ship,
		order_movement 
	WHERE order_movement.shipment_gid=ship.shipment_gid
	) ship,
(
	SELECT order_release_line_gid,
		packaged_item_gid,
		order_release_gid,
		weight,
		weight_uom_code 
	FROM order_release_line
	) orl,
(
	SELECT source_location_gid, 
		dest_location_gid, 
		attribute2, 
		order_release_type_gid, 
		equipment_group_profile_gid, 
		ship_with_group,
		attribute10,
		order_release_gid,
		insert_date,
		late_delivery_date, 
PAYMENT_METHOD_CODE_GID
	FROM order_release
	) ord

WHERE ord.order_release_gid=ship.order_release_gid
	AND ord.order_release_gid=orl.order_release_gid
	AND (ord.attribute2 in (:P_Business_Unit) or :P_Business_Unit is NULL)
	AND ((SELECT decode(status_value_gid,'DGI.TENDER.SECURE RESOURCES_ACCEPTED','Accepted','DGI.TENDER.SECURE RESOURCES_WITHDRAWN','Withdrawn','DGI.TENDER.SECURE RESOURCES_TIMED OUT','Timed_Out','DGI.TENDER.SECURE RESOURCES_TENDER RESPONSE OPEN','Response_Open','DGI.TENDER.SECURE RESOURCES_PICKUP NOTIFICATION','Pickup_Notification','DGI.TENDER.SECURE RESOURCES_DECLINED','Declined','DGI.TENDER.SECURE RESOURCES_TENDERED','Tendered',NULL,'Not_Tendered') FROM tender_collaboration_status tender_status, tender_collaboration tender_collab WHERE ship.shipment_gid=tender_collab.shipment_gid AND tender_collab.i_transaction_no=tender_status.i_transaction_no AND rownum=1) in (:P_Tender_Status) or :P_tender_status is NULL)
	AND (ord.order_release_type_gid in (:P_Order_Type) or :P_order_type is NULL)
	AND ((SELECT decode(status_value_gid,'DGI.CANCELLED_NOT CANCELLED','Not Cancelled','DGI.CANCELLED_CANCELLED','Cancelled') FROM order_release_status order_status WHERE order_status.order_release_gid=ord.order_release_gid AND order_status.status_type_gid='DGI.CANCELLED') in (:P_Cancelled) or :P_Cancelled is NULL)
	AND ((SELECT decode(is_fleet,'Y','FLEET','N','3PL') FROM servprov WHERE ship.servprov_gid=servprov.servprov_gid) in(:P_Carrier_Type) or :P_Carrier_type is NULL)
	AND to_char(utc.get_local_date(ship.start_time,ship.source_location_gid),'DDD') between nvl(to_char(:P_FROM_DAY,'DDD'), to_char(sysdate-5,'DDD')) AND nvl(to_char(:P_TO_DAY,'DDD'),to_char(sysdate-1,'DDD'))
	AND to_char(utc.get_local_date(ship.start_time,ship.source_location_gid),'YYYY') = nvl(:P_YEAR,to_char(sysdate,'YYYY'))