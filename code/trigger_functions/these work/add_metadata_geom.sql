-- Loader. Copyright (c) Nart Tamash.
-- Licensed under [GNU GPLv3](https://bit.ly/2HGhaNl).



-- Function: public.add_metadata_geom()

-- DROP FUNCTION public.add_metadata_geom();

CREATE OR REPLACE FUNCTION public.add_metadata_geom()
  RETURNS trigger AS
$BODY$



-- this trigger function adds the geometry of the datasets bounding boxes in the metadata table. Therefore the metadata table becomes a spatial dataset
declare
	table_name text; --variable that holds the name of the table (i.e. dataset) being used to extract information from
	xmin real; --variable that would hold the Xmin coordinate value of a specific dataset
	ymin real; --variable that would hold the Ymin coordinate value of a specific dataset
	xmax real; --variable that would hold the Xmax coordinate value of a specific dataset
	ymax real; --variable that would hold the Ymax coordinate value of a specific dataset

begin

	--storing in the table_name variable the name of the newly added table (dataset) to the database
	select dataset_name from metadata where NEW.dataset_name = dataset_name into table_name;

	--storing in the Xmin, Xmax, Ymin, Ymax variables the coordinate values already stored in the metadata table
	SELECT bb_northbound_lat from metadata where NEW.dataset_name = dataset_name into ymax;
	select bb_eastbound_long from metadata where NEW.dataset_name = dataset_name into xmax;
	select bb_southbound_lat from metadata where NEW.dataset_name = dataset_name into ymin;
	select bb_westbound_long from metadata where NEW.dataset_name = dataset_name into xmin;


	--defining the bounding box polygon geometry for the newly added dataset based on the stored coordinate values
	execute 'UPDATE metadata SET geom = (ST_GeomFromText(''POLYGON((' || xmin || ' ' || ymin || ','
		|| xmin || ' ' || ymax || ','
			|| xmax || ' ' || ymax || ','
				|| xmax || ' ' || ymin || ','
					|| xmin || ' ' || ymin || '))'',4326))
		WHERE dataset_name = ' || quote_literal(table_name) || ';';

	return null;

end;


$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.add_metadata_geom()
  OWNER TO postgres;
