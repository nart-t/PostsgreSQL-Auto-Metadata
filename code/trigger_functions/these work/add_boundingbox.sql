-- Function: public.add_boundingbox()

-- DROP FUNCTION public.add_boundingbox();

CREATE OR REPLACE FUNCTION public.add_boundingbox()
  RETURNS trigger AS
$BODY$


-- this trigger function calculates the bounding box (Xmin, Xmax, Ymin, Ymax) of a new dataset added to the database and inserts it in the metadata table
declare
	table_name text; --variable that holds the name of the table (i.e. dataset) being used to extract information from
	the_coord real; -- used to store the west most longitude
	curs1 refcursor;
begin




	--storing in the table_name variable the newly added table (dataset) to the database
	select dataset_name from metadata where NEW.dataset_name = dataset_name into table_name;

	--calculate the Xmin coordinate of the newly added table (dataset) and insert it into the metadata table
	Open curs1 FOR EXECUTE 'SELECT ST_XMin(ST_Extent(ST_Transform(the_geom,4326))) as the_coord FROM  '|| table_name; 
	FETCH curs1 into the_coord;
	EXECUTE 'UPDATE metadata 
			SET bb_westbound_long = ' || the_coord ||'
			 WHERE dataset_name =  '|| quote_literal(table_name);
	CLOSE curs1;
	


		

		



	--same for Xmax coordinate
	Open curs1 FOR EXECUTE 'SELECT ST_XMax(ST_Extent(ST_Transform(the_geom,4326))) as the_coord FROM  '|| table_name; 
	FETCH curs1 into the_coord;
	EXECUTE 'UPDATE metadata 
			SET bb_eastbound_long = ' || the_coord ||'
			 WHERE dataset_name =  '|| quote_literal(table_name);
	CLOSE curs1;

	--same for Ymax coordinate
	Open curs1 FOR EXECUTE 'SELECT ST_YMax(ST_Extent(ST_Transform(the_geom,4326))) as the_coord FROM  '|| table_name; 
	FETCH curs1 into the_coord;
	EXECUTE 'UPDATE metadata 
			SET bb_northbound_lat = ' || the_coord ||'
			 WHERE dataset_name =  '|| quote_literal(table_name);
	CLOSE curs1;
	
	
	
	--same for Ymin coordinate
	Open curs1 FOR EXECUTE 'SELECT ST_YMin(ST_Extent(ST_Transform(the_geom,4326))) as the_coord FROM  '|| table_name; 
	FETCH curs1 into the_coord;
	EXECUTE 'UPDATE metadata 
			SET bb_southbound_lat = ' || the_coord ||'
			 WHERE dataset_name =  '|| quote_literal(table_name);
	CLOSE curs1;

	return  null;

end;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.add_boundingbox()
  OWNER TO postgres;
