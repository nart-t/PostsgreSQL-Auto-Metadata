-- Loader. Copyright (c) Nart Tamash.
-- Licensed under [GNU GPLv3](https://bit.ly/2HGhaNl).



-- Function: public.add_id_code()

-- DROP FUNCTION public.add_id_code();

CREATE OR REPLACE FUNCTION public.add_id_code()
  RETURNS trigger AS
$BODY$


-- this trigger function adds in the metadata table the 'code' component of the unique resource identifier as set by the INSPIRE metadata standard. This value coincides with the system identifier of the specific dataset(table), the same identifier used for the dataset_oid field in the metadata table
declare
	table_name text; --variable that holds the name of the table (i.e. dataset) being used to extract information from

begin

	--storing in the table_name variable the name of the newly added table (dataset) to the database
	select dataset_name from metadata where NEW.dataset_name = dataset_name into table_name;

	--inserts the code value, as part of the URI, of the newly added dataset (table) to the metadata table
	execute 'UPDATE metadata
		SET identifier_code = (SELECT oid FROM pg_class WHERE relname = ' || quote_literal(table_name) || ')'
			|| 'WHERE dataset_name = ' || quote_literal(table_name);

	return null;

end;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.add_id_code()
  OWNER TO postgres;
