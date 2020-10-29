----------------- 
--arrivals
----------------

drop table arrivals;

--------------

create table arrivals(
	--this is the arrival for delivery and pickup table
	shipment_id text,
	dest_code text,
	stop_num integer,
	arrive timestamp);

--------------
--formatting should be col1=shipmentid, col2=dest_code, col3=stop_num, col4=arrive.  Remove all rows where arrive is blank.
--save sams sheet after formatting to this path
.import 'C:\Mitchell\sqlite\Data\arrivals_no_headers.csv' arrivals;

------------------

update orderlevel
	set
		ActualDelivDate = (select arrivals.arrive
			--this ActualDelivDate in OrderLevel naming convetion will be updated soon to delivery_arrive
			--this is geofence entry - actualarrive in sams sheet
							from arrivals
							where arrivals.shipment_id = orderlevel.shipmentid
							and arrivals.dest_code = orderlevel.destcode
							and arrivals.stop_num = orderlevel.stop_num
							and arrivals.stop_num > 1)
							--this looks only for the delivery stops
		ActualShipDate = (select arrivals.arrive
			--this ActualShipDate in Orderlevel naming convetion will be updated soon to pickup_arrive
			--this is the geofence entry - actual arrive in sams sheet
							from arrivals
							where arrivals.shipment_id = orderlevel.shipmentid
							and arrivals.dest_code = orderlevel.destcode
							and arrivals.stop_num = orderlevel.stop_num
							and arrivals.stop_num = 1)
							--this looks only for the pickup stops
	where
		exists (
			select *
			from arrivals
			where arrivals.shipment_id = orderlevel.shipmentid
			and arrivals.dest_code = orderlevel.destcode
			and arrivals.stop_num = orderlevel.stop_num);


----------------- 
--departures
----------------

drop table departs;

----------------

create table departs(
	shipment_id text,
	dest_code text,
	stop_num integer,
	depart timestamp);

--------------
--formatting should be col1=shipmentid, col2=dest_code, col3=stop_num, col4=arrive.  Remove all rows where arrive is blank.
--save sams sheet after formatting to this path
.import 'C:\Mitchell\sqlite\Data\depart_no_headers.csv' departs;

----------------

update orderlevel
	set
		actual_deliv_depart = (select departs.depart
			--this actual_deliv_depart in Orderlevel naming convetion will be updated soon to delivery_depart
			--this is the geofence exit - actual depart in sams sheet
							from departs
							where departs.shipment_id = orderlevel.shipmentid
							and departs.dest_code = orderlevel.destcode
							and departs.stop_num = orderlevel.stop_num
							and departs.stop_num > 1)
							--this looks only for the delivery stops

		actual_ship_depart = (select departs.depart
			--this actual_ship_depart in Orderlevel naming convetion will be updated soon to pickup_depart
			--this is the geofence exit - actual depart in sams sheet
							from departs
							where departs.shipment_id = orderlevel.shipmentid
							and departs.dest_code = orderlevel.destcode
							and departs.stop_num = orderlevel.stop_num
							and departs.stop_num = 1)
							--this looks only for the pickup stops
where
	exists (
		select *
		from departs
		where departs.shipment_id = orderlevel.shipmentid
		and departs.dest_code = orderlevel.destcode
		and departs.stop_num = orderlevel.stop_num);