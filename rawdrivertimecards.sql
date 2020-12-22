drop table if exists rawtimecards;

create table rawtimecards(
	rowindex int,
	timecardnum int,
	timecardrow int,
	filename text,
	home_terminal text,
	dispatch_date date,
	name text,
	tractornum int,
	trailernum int,
	destination text,
	arrival time,
	departure time
);

create index rawindex on rawtimecards (rowindex);
create index rawtimecardnum on rawtimecards (timecardnum);

.mode csv
.import...

--i manually fixed some of the weird rows of the query results which is faster than trying to make this perfect							
SELECT								
	r.timecardnum							
	r.name						
	r.dispatch_date						
	r.first_stop						
	case when fraw.dwelltime<0						
	then fraw.dwelladj						
	else fraw.dwelltime 						
	end as BoD							
	fraw.arrival as BoD_arrival						
	fraw.departure as BoD_departure						
	r.last_stop						
	case when lraw.dwelltime<0						
	then lraw.dwelladj						
	else lraw.dwelltime						
	end as EoD							
	lraw.arrival as EoD_arrival						
	lraw.departure as EoD_departure						
								
FROM (								
								
	SELECT								
		timecardnum							
		name						
		dispatch_date						
		max(timecardrow) as last_stop						
		min(timecardrow) as first_stop						
		count(timecardrow)						
	FROM 								
		rawtimecards							
	GROUP BY								
		timecardnum							
			name						
	HAVING								
		count(timecardrow)>1							
		) r							
								
LEFT JOIN (								
	SELECT								
		timecardnum							
		timecardrow						
		dispatch_date						
		name						
		departure						
		arrival						
		(strftime('%s'	time(departure))-strftime('%s'	time(arrival))) / 60	0 as dwelltime			
		abs((strftime('%s'	time(arrival))-strftime('%s'	'24:00:00')) / 60	0) + abs((strftime('%s'	time(departure))-strftime('%s'	'00:00:00')) / 60	0) as dwelladj
	FROM								
		rawtimecards							
		) lraw							
		on r.timecardnum = lraw.timecardnum					
		and r.name = lraw.name					
		and r.last_stop = lraw.timecardrow					
								
LEFT JOIN (								
	SELECT								
		timecardnum							
		timecardrow						
		dispatch_date						
		name						
		departure						
		arrival						
		(strftime('%s'	time(departure))-strftime('%s'	time(arrival))) / 60	0 as dwelltime			
		abs((strftime('%s'	time(arrival))-strftime('%s'	'24:00:00')) / 60	0) + abs((strftime('%s'	time(departure))-strftime('%s'	'00:00:00')) / 60	0) as dwelladj
	FROM								
		rawtimecards							
		) fraw							
		on r.timecardnum = fraw.timecardnum					
		and r.name = fraw.name					
		and r.first_stop = fraw.timecardrow					
