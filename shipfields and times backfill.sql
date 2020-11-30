ill have to take the data export and break it into two different ones, one without stop numbers
and one with stop numbers

-----------------------------------------

alter table orderlevel add column PlannedDeliveryArrive timestamp;

alter table orderlevel add column PlannedDeliveryDepart timestamp;

alter table orderlevel add column ShipArrive timestamp;

alter table orderlevel add column ShipDepart timestamp;

alter table orderlevel add column PlannedShipArrive timestamp;

alter table orderlevel add column PlannedShipDepart timestamp;

alter table orderlevel add column PlannedPickupDepart timestamp;

alter table orderlevel add column Ship_DestCode text;

alter table orderlevel add column Ship_DestName text;

alter table orderlevel add column Ship_DestCity text;

alter table orderlevel add column Ship_DestState text;

alter table orderlevel add column Ship_DestZip text;

alter table orderlevel add column Ship_DestCountry text;

alter table orderlevel add column Ship_DestLat text;

alter table orderlevel add column Ship_DestLon text;

---------------------------------
--w/ stopnumbers

.mode csv

drop table sn_ship;

create table sn_ship(
	shipmentid text,
	stop_num integer,
	stop_type text,
	ship_destcode text,
	ship_destname text,
	ship_destcity text,
	ship_deststate text,
	ship_destzip text,
	ship_destcountry text,
	ship_destlat real,
	ship_destlon real,
	planned_arrive timestamp,
	planned_departure timestamp,
	actual_arrive timestamp,
	actual_departure timestamp);

create index shipid_ix
	on sn_ship (shipmentid);

.import path--no headers

update orderlevel
	set
		DeliveryArrive = (select sn_ship.actual_arrival
			from sn_ship
			where sn_ship.stop_num=orderlevel.stop_num
				and sn_ship.shipmentid=orderlevel.shipmentid
				and sn_ship.stop_type not in ('P','NFR')
				),
		DeliveryDepart = (select sn_ship.actual_depart
			from sn_ship
			where sn_ship.stop_num=orderlevel.stop_num
				and sn_ship.shipmentid=orderlevel.shipmentid
				and sn_ship.stop_type not in ('P','NFR')
				),
		--this is a new col, dbl check name
		PlannedDeliveryArrive = (select sn_ship.planned_arrive
			from sn_ship
			where sn_ship.stop_num=orderlevel.stop_num
				and sn_ship.shipmentid=orderlevel.shipmentid
				and sn_ship.stop_type not in ('P','NFR')
				),
		--this is a new col, dbl check name
		PlannedDeliveryDepart = (select sn_ship.planned_departure
			from sn_ship
			where sn_ship.stop_num=orderlevel.stop_num
				and sn_ship.shipmentid=orderlevel.shipmentid
				and sn_ship.stop_type not in ('P','NFR')
				),
		--this is a new col, dbl check name
		ShipArrive = (select sn_ship.actual_arrive
			from sn_ship
			where sn_ship.stop_num=orderlevel.stop_num
				and sn_ship.shipmentid=orderlevel.shipmentid
				and sn_ship.stop_type not in ('P','NFR')
				),
		--this is a new col, dbl check name
		PlannedShipArrive = (select sn_ship.planned_arrive
			from sn_ship
			where sn_ship.stop_num=orderlevel.stop_num
				and sn_ship.shipmentid=orderlevel.shipmentid
				and sn_ship.stop_type not in ('P','NFR')
				),
		--this is a new col, dbl check name
		ShipDepart = (select sn_ship.actual_departure
			from sn_ship
			where sn_ship.stop_num=orderlevel.stop_num
				and sn_ship.shipmentid=orderlevel.shipmentid
				and sn_ship.stop_type not in ('P','NFR')
				),
		--this is a new col,dbl check name
		PlannedShipDepart = (select sn_ship.planned_departure
			from sn_ship
			where sn_ship.stop_num=orderlevel.stop_num
				and sn_ship.shipmentid=orderlevel.shipmentid
				and sn_ship.stop_type not in ('P','NFR')
				),
		PickupArrive = (select sn_ship.actual_arrive
			from sn_ship
			where sn_ship.shipmentid=orderlevel.shipmentid
				and sn_ship.stop_type='P'
				),
		PickupDepart = (select sn_ship.actual_depart
			from sn_ship
			where sn_ship.shipmentid=orderlevel.shipmentid
				and sn_ship.stop_type='P'
				),
		PlanPickupDate = (select sn_ship.planned_arrival
			from sn_ship
			where sn_ship.shipmentid=orderlevel.shipmentid
				and sn_ship.stop_type='P'
				),
		--this is a new col, dbl check name
		PlanPickupDepart = (select sn_ship.planned_departure
			from sn_ship
			where sn_ship.shipmentid=orderlevel.shipmentid
				and sn_ship.stop_type='P'
				),
		Ship_DestCode = (select sn_ship.ship_destcode
			from sn_ship
			where sn_ship.stop_num=orderlevel.stop_num
				and sn_ship.shipmentid=orderlevel.shipmentid
				and sn_ship.stop_type not in ('P','NFR')
				),
		Ship_DestName = (select sn_ship.Ship_DestName
			from sn_ship
			where sn_ship.stop_num=orderlevel.stop_num
				and sn_ship.shipmentid=orderlevel.shipmentid
				and sn_ship.stop_type not in ('P','NFR')
				),
		Ship_DestCity = (select sn_ship.Ship_DestCity
			from sn_ship
			where sn_ship.stop_num=orderlevel.stop_num
				and sn_ship.shipmentid=orderlevel.shipmentid
				and sn_ship.stop_type not in ('P','NFR')
				),
		Ship_DestState = (select sn_ship.Ship_DestState
			from sn_ship
			where sn_ship.stop_num=orderlevel.stop_num
				and sn_ship.shipmentid=orderlevel.shipmentid
				and sn_ship.stop_type not in ('P','NFR')
				),
		Ship_DestZip = (select sn_ship.Ship_DestZip
			from sn_ship
			where sn_ship.stop_num=orderlevel.stop_num
				and sn_ship.shipmentid=orderlevel.shipmentid
				and sn_ship.stop_type not in ('P','NFR')
				),
		Ship_DestCountry = (select sn_ship.Ship_DestCountry
			from sn_ship
			where sn_ship.stop_num=orderlevel.stop_num
				and sn_ship.shipmentid=orderlevel.shipmentid
				and sn_ship.stop_type not in ('P','NFR')
				),
		Ship_DestLat = (select sn_ship.Ship_DestLat
			from sn_ship
			where sn_ship.stop_num=orderlevel.stop_num
				and sn_ship.shipmentid=orderlevel.shipmentid
				and sn_ship.stop_type not in ('P','NFR')
				),
		Ship_DestLon = (select sn_ship.Ship_DestLon
			from sn_ship
			where sn_ship.stop_num=orderlevel.stop_num
				and sn_ship.shipmentid=orderlevel.shipmentid
				and sn_ship.stop_type not in ('P','NFR')
				),

	where
	exists (
		select *
		from sn_ship
		where sn_ship.shipment_id = orderlevel.shipmentid
		);
----------------------------

--w/o stopnumbers
------------------------
.mode csv

drop table no_sn_ship;

create table no_sn_ship(
	shipmentid text,
	stop_num integer,
	stop_type text,
	ship_destcode text,
	ship_destname text,
	ship_destcity text,
	ship_deststate text,
	ship_destzip text,
	ship_destcountry text,
	ship_destlat real,
	ship_destlon real,
	planned_arrive timestamp,
	planned_departure timestamp,
	actual_arrive timestamp,
	actual_departure timestamp);

create index shipid_ix
	on no_sn_ship (shipmentid);

.import path--no headers

update orderlevel
	set
		--this is a new col, dbl check name
		PlannedShipArrive = (select no_sn_ship.planned_arrive
			from no_sn_ship
			where no_sn_ship.shipmentid=orderlevel.shipmentid
				and no_sn_ship.stop_type not in ('P','NFR')
				),
		--this is a new col, dbl check name
		PlannedShipDepart = (select no_sn_ship.planned_departure
			from no_sn_ship
			where no_sn_ship.shipmentid=orderlevel.shipmentid
				and no_sn_ship.stop_type not in ('P','NFR')
				),
		--this is a new col, dbl check name
		ShipArrive = (select no_sn_ship.actual_arrive
			from no_sn_ship
			where no_sn_ship.shipmentid=orderlevel.shipmentid
				and no_sn_ship.stop_type not in ('P','NFR')
				),
		--this is a new col, dbl check name
		ShipDepart = (select no_sn_ship.actual_departure
			from no_sn_ship
			where no_sn_ship.shipmentid=orderlevel.shipmentid
				and no_sn_ship.stop_type not in ('P','NFR')
				),
		PickupArrive = (select no_sn_ship.actual_arrive
			from no_sn_ship
			where no_sn_ship.shipmentid=orderlevel.shipmentid
				and no_sn_ship.stop_type='P'
				),
		PickupDepart = (select no_sn_ship.actual_depart
			from no_sn_ship
			where no_sn_ship.shipmentid=orderlevel.shipmentid
				and no_sn_ship.stop_type='P'
				),
		PlanPickupDate = (select no_sn_ship.planned_arrival
			from no_sn_ship
			where no_sn_ship.shipmentid=orderlevel.shipmentid
				and no_sn_ship.stop_type='P'
				),
		--this is a new col, dbl check name
		PlanPickupDepart = (select no_sn_ship.planned_departure
			from no_sn_ship
			where no_sn_ship.shipmentid=orderlevel.shipmentid
				and no_sn_ship.stop_type='P'
				),
		Ship_DestCode = (select sn_ship.ship_destcode
			from sn_ship
			where sn_ship.shipmentid=orderlevel.shipmentid
				and sn_ship.stop_type not in ('P','NFR')
				),
		Ship_DestName = (select sn_ship.Ship_DestName
			from sn_ship
			where sn_ship.shipmentid=orderlevel.shipmentid
				and sn_ship.stop_type not in ('P','NFR')
				),
		Ship_DestCity = (select sn_ship.Ship_DestCity
			from sn_ship
			where sn_ship.shipmentid=orderlevel.shipmentid
				and sn_ship.stop_type not in ('P','NFR')
				),
		Ship_DestState = (select sn_ship.Ship_DestState
			from sn_ship
			where sn_ship.shipmentid=orderlevel.shipmentid
				and sn_ship.stop_type not in ('P','NFR')
				),
		Ship_DestZip = (select sn_ship.Ship_DestZip
			from sn_ship
			where sn_ship.shipmentid=orderlevel.shipmentid
				and sn_ship.stop_type not in ('P','NFR')
				),
		Ship_DestCountry = (select sn_ship.Ship_DestCountry
			from sn_ship
			where sn_ship.shipmentid=orderlevel.shipmentid
				and sn_ship.stop_type not in ('P','NFR')
				),
		Ship_DestLat = (select sn_ship.Ship_DestLat
			from sn_ship
			where sn_ship.shipmentid=orderlevel.shipmentid
				and sn_ship.stop_type not in ('P','NFR')
				),
		Ship_DestLon = (select sn_ship.Ship_DestLon
			from sn_ship
			where sn_ship.shipmentid=orderlevel.shipmentid
				and sn_ship.stop_type not in ('P','NFR')
				),

	where
	exists (
		select *
		from no_sn_ship
		where no_sn_ship.shipment_id = orderlevel.shipmentid
		);


