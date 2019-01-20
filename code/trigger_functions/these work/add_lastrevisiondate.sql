-- Loader. Copyright (c) Nart Tamash.
-- Licensed under [GNU GPLv3](https://bit.ly/2HGhaNl).



-- Function: public.add_last_revision_date()

-- DROP FUNCTION public.add_last_revision_date();

CREATE OR REPLACE FUNCTION public.add_last_revision_date()
  RETURNS trigger AS
$BODY$


--this trigger function adds the date of last revision of a specific dataset. By default, when a new dataset (table) is added to the database, the date of last revision is considered to be the date it has been uploaded to the database. This date is then updated with each change (edit) applied on the dataset. To implement this continuous update, the trigger function creates another trigger on each table (dataset) added to the database that would monitor any changes.
declare
	table_name text; --variable that holds the name of the table (i.e. dataset) being used to extract information from
	
begin

	--storing in the table_name variable the name of the newly added table (dataset) to the database
	SELECT dataset_name from metadata where NEW.dataset_name = dataset_name into table_name;

	--adds the date of upload to the database
	execute 'UPDATE metadata SET last_revision_date = (SELECT current_date);';

	--creates the trigger and trigger function on each dataset uploaded to the database that would then monitor any changes and update the last_revision_date field in the metadata table accordingly
	execute 'CREATE OR REPLACE FUNCTION add_last_revision_date_update_' || table_name || '() RETURNS TRIGGER AS $$
	
			BEGIN

				UPDATE metadata SET last_revision_date = (SELECT current_date) WHERE dataset_name = ' || 
					quote_literal(table_name) || ';

				RETURN NULL;

			END;
		     
		$$ LANGUAGE plpgsql;
 
		CREATE TRIGGER ' || table_name || '_last_revision_date AFTER INSERT OR UPDATE OR DELETE on ' || 
		table_name || ' FOR EACH ROW EXECUTE PROCEDURE add_last_revision_date_update_' || table_name || '();';

	return null;

end;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.add_last_revision_date()
  OWNER TO postgres;
