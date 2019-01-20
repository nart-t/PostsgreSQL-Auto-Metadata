-- Loader. Copyright (c) Nart Tamash.
-- Licensed under [GNU GPLv3](https://bit.ly/2HGhaNl).



-- Function: public.create_dataset_update_trigger()

-- DROP FUNCTION public.create_dataset_update_trigger();

CREATE OR REPLACE FUNCTION public.create_dataset_update_trigger()
  RETURNS trigger AS
$BODY$


-- this trigger function creates another trigger and trigger function on each new dataset added to the database to monitor any changes on the geometry that would then reflect over the bounding box details of the specific dataset in the metadadata table (both coordinate values and metadata geometry)
declare 
	table_name text; --variable that holds the name of the table (i.e. dataset) being used to extract information from
	func_body text; --variable that contains the body of the dynamic function to be created for each dataset
	func_cmd text; -- variable that contains the final dynamic function to be created for each dataset
	part_of_query text; --variable that contains part of the dynamic function to be created fo each dataset
	bounding_box text;
	bounding_box1 text;
	bounding_box2 text;
	bounding_box3 text;
	boundingboxa text;
	boundingbox1a text;
	boundingbox2a text;
	boundingbox3a text;
	boundingboxb text;
	boundingbox1b text;
	boundingbox2b text;
	boundingbox3b text;
	boundingboxc text;
	boundingbox1c text;
	boundingbox2c text;
	boundingbox3c text;
	table_nameString text;

begin

	--variable that holds the name of the table (i.e. dataset) being used to extract information from
	select dataset_name from metadata where NEW.dataset_name = dataset_name into table_name;

	--defining first part of the dynamic function. variables are declared that would contain the bounding box coordinates
	func_body := '<< variable >> 
			DECLARE
				xmin REAL;
				ymin REAL;
				xmax REAL;
				ymax REAL;
				curs1 refcursor;
				the_coord real; -- used to store the west most longitude
				table_name text;

			BEGIN ';



	--defining the part of the dynamic function that re-calculates the geometry of the metadata table (bounding box) based on the new coordinates after and edit session
	part_of_query := '''POLYGON(('' || variable.xmin || '' '' || variable.ymin || '','' || 
						variable.xmin || '' '' || variable.ymax || '','' || 
							variable.xmax || '' '' || variable.ymax || '','' || 
								variable.xmax || '' '' || variable.ymin || '','' || 
									variable.xmin || '' '' || variable.ymin || ''))'',4326)';
	
	-- get the table name set up
	table_nameString := 'table_name :=' || quote_literal(table_name) ||';';

	--calculate the Xmin coordinate of the newly added table (dataset) and insert it into the metadata table
	bounding_box := 'Open curs1 FOR EXECUTE ' || quote_literal('SELECT ST_XMin(ST_Extent(ST_Transform(the_geom,4326))) as the_coord FROM ' || table_name) ||';'; 
	bounding_box1 := 'FETCH curs1 into the_coord;';
	bounding_box2 := 'EXECUTE ' 	|| quote_literal('UPDATE metadata SET bb_westbound_long = ') 	|| ' || the_coord || ' 	|| quote_literal(' WHERE dataset_name = ')|| '|| quote_literal(table_name);';
	bounding_box3 := 'CLOSE curs1;';


	boundingboxa := 'Open curs1 FOR EXECUTE ' || quote_literal('SELECT ST_XMax(ST_Extent(ST_Transform(the_geom,4326))) as the_coord FROM ' || table_name) ||';'; 
	boundingbox1a := 'FETCH curs1 into the_coord;';
	boundingbox2a := 'EXECUTE ' 	|| quote_literal('UPDATE metadata SET bb_eastbound_long = ') 	|| ' || the_coord || ' 	|| quote_literal(' WHERE dataset_name = ')|| '|| quote_literal(table_name);';
	boundingbox3a := 'CLOSE curs1;';


	boundingboxb := 'Open curs1 FOR EXECUTE ' || quote_literal('SELECT ST_YMax(ST_Extent(ST_Transform(the_geom,4326))) as the_coord FROM ' || table_name) ||';'; 
	boundingbox1b := 'FETCH curs1 into the_coord;';
	boundingbox2b := 'EXECUTE ' 	|| quote_literal('UPDATE metadata SET bb_northbound_lat = ') 	|| ' || the_coord || ' 	|| quote_literal(' WHERE dataset_name = ')|| '|| quote_literal(table_name);';
	boundingbox3b := 'CLOSE curs1;';
	
		boundingboxc := 'Open curs1 FOR EXECUTE ' || quote_literal('SELECT ST_YMin(ST_Extent(ST_Transform(the_geom,4326))) as the_coord FROM ' || table_name) ||';'; 
		boundingbox1c := 'FETCH curs1 into the_coord;';
		boundingbox2c := 'EXECUTE ' 	|| quote_literal('UPDATE metadata SET bb_southbound_lat = ') 	|| ' || the_coord || ' 	|| quote_literal(' WHERE dataset_name = ')|| '|| quote_literal(table_name);';
		boundingbox3c := 'CLOSE curs1;';


	
	--updating the metadata fields that contain the actual coordinate values of the bounding box
	func_body := func_body || table_nameString || bounding_box || bounding_box1 || bounding_box2 || bounding_box3 ||
			boundingboxa || boundingbox1a || boundingbox2a || boundingbox3a ||
			boundingboxb || boundingbox1b || boundingbox2b || boundingbox3b ||
			boundingboxc || boundingbox1c || boundingbox2c || boundingbox3c ||
		'

		


		'--derives the actual coordinate values for the bounding box again to be stored in the defined variables that are then used in part_of_query
		'
		SELECT ST_XMin(ST_Extent(ST_Transform(the_geom,4326))) FROM ' || quote_ident(table_name) || ' INTO xmin;
		SELECT ST_XMax(ST_Extent(ST_Transform(the_geom,4326))) FROM ' || quote_ident(table_name) || ' INTO xmax;
		SELECT ST_YMax(ST_Extent(ST_Transform(the_geom,4326))) FROM ' || quote_ident(table_name) || ' INTO ymax;
		SELECT ST_YMin(ST_Extent(ST_Transform(the_geom,4326))) FROM ' || quote_ident(table_name) || ' INTO ymin;

	
		'--the actual update of the metadata geometry
		'
		UPDATE metadata SET geom = ST_GeomFromText(' || part_of_query ||
			'
			WHERE dataset_name = ' || quote_literal(table_name) || ';';


	--additions to the dynamic function
	func_body := func_body || ' RETURN NULL; END;';

	--final additions to the body of the dynamic function
	func_cmd := 'CREATE OR REPLACE FUNCTION update_bounding_box_' || table_name || '() RETURNS TRIGGER AS $$'
		|| func_body || ' $$ LANGUAGE plpgsql;';

	--execution of the dynamic function
	EXECUTE func_cmd;


	--execution of the trigger creation for each new dataset (table) added to the database
	execute 'CREATE TRIGGER ' || table_name || '_bb_update AFTER INSERT OR UPDATE OR DELETE on ' || quote_ident(table_name)
		|| ' FOR EACH ROW EXECUTE PROCEDURE update_bounding_box_' || table_name || '();';


	return null;
END;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.create_dataset_update_trigger()
  OWNER TO postgres;
