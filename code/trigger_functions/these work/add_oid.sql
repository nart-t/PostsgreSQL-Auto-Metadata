-- Function: public.add_oid()

-- DROP FUNCTION public.add_oid();

CREATE OR REPLACE FUNCTION public.add_oid()
  RETURNS trigger AS
$BODY$


-- this trigger function adds in the metadata table the system identifier of a dataset (table) added to the database. This way, records from the metadata table can be linked to the datasets (tables) they represent.
DECLARE
	table_name text; --variable that holds the name of the table (i.e. dataset) being used to extract information from

begin

	--storing in the table_name variable the name of the newly added table (dataset) to the database
	select dataset_name from metadata where NEW.dataset_name = dataset_name into table_name;

	--inserts the system identifier of the newly added dataset (table) to the metadata table
	execute 'UPDATE metadata
			SET dataset_oid = 
				(SELECT oid FROM pg_class WHERE relname = ' || quote_literal(table_name) || ')'
					|| 'WHERE dataset_name = ' || quote_literal(table_name);

	return null;

end;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.add_oid()
  OWNER TO postgres;
