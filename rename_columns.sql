ALTER TABLE orderlevel
RENAME COLUMN ActualShipDate TO PickupArrive;

ALTER TABLE orderlevel
RENAME COLUMN actual_ship_depart TO PickupDepart;

ALTER TABLE orderlevel
RENAME COLUMN ActualDelivDate TO DeliveryArrive;

ALTER TABLE orderlevel
RENAME COLUMN actual_deliv_depart TO DeliveryDepart;

ALTER TABLE orderlevel
RENAME COLUMN PlanShipWk TO PlanPickupWk;

ALTER TABLE orderlevel
RENAME COLUMN PlanShipDate TO PlanPickupDate;
