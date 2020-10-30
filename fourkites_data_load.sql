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

-----------------

create index shipmentidarrive_ix
	on arrivals (shipment_id);

--------------
--formatting should be col1=shipmentid, col2=dest_code, col3=stop_num, col4=arrive.  Remove all rows where arrive is blank.
--save sams sheet after formatting to this path
.import 'C:\Mitchell\sqlite\Data\arrivals_no_headers.csv' arrivals

------------------

--*******************************************i ran the update only for ActualDelivDate on 10/29/20 i still need to do the ActualShipDate

update orderlevel
	set
		DeliveryArrive = (select arrivals.arrive
			--this is geofence entry - actualarrive in sams sheet
							from arrivals
							where arrivals.shipment_id = orderlevel.shipmentid
							and arrivals.dest_code = orderlevel.destcode
							and arrivals.stop_num = orderlevel.stop_num
							and arrivals.stop_num > 1),
							--this looks only for the delivery stops
		PickupArrive = (select arrivals.arrive
			--this is the geofence entry - actual arrive in sams sheet
							from arrivals
							where arrivals.shipment_id = orderlevel.shipmentid
							and arrivals.stop_num = 1)
							--this looks only for the pickup stops
							--we want to apply this date to all rows for a shipment
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
---------------

create index shipmentiddepart_ix
	on departs (shipment_id);
--------------
--formatting should be col1=shipmentid, col2=dest_code, col3=stop_num, col4=arrive.  Remove all rows where arrive is blank.
--save sams sheet after formatting to this path
.import 'C:\Mitchell\sqlite\Data\depart_no_headers.csv' departs

----------------

update orderlevel
	set
		DeliveryDepart = (select departs.depart
			--this is the geofence exit - actual depart in sams sheet
							from departs
							where departs.shipment_id = orderlevel.shipmentid
							and departs.dest_code = orderlevel.destcode
							and departs.stop_num = orderlevel.stop_num
							and departs.stop_num > 1),
							--this looks only for the delivery stops

		PickupDepart = (select departs.depart
			--this is the geofence exit - actual depart in sams sheet
							from departs
							where departs.shipment_id = orderlevel.shipmentid
							and departs.stop_num = 1)			
							--this looks only for the pickup stops
							--we want to apply this date to all rows for a shipment
where
	exists (
		select *
		from departs
		where departs.shipment_id = orderlevel.shipmentid
		and departs.dest_code = orderlevel.destcode
		and departs.stop_num = orderlevel.stop_num);