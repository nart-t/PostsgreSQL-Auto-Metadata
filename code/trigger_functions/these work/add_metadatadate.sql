-- Loader. Copyright (c) Nart Tamash.
-- Licensed under [GNU GPLv3](https://bit.ly/2HGhaNl).



-- Function: public.add_metadate()

-- DROP FUNCTION public.add_metadate();

CREATE OR REPLACE FUNCTION public.add_metadate()
  RETURNS trigger AS
$BODY$


--this trigger function inserts the date when the metadata record for a newly added dataset is created
declare
	table_name text; --variable that holds the name of the table (i.e. dataset) being used to extract information from

begin

	--storing in the table_name variable the name of the newly added table (dataset) to the database
	select dataset_name from metadata where NEW.dataset_name = dataset_name into table_name;

	--adds the current date in the metadata_date field of the metadata table
	Execute 'UPDATE metadata
			SET metadata_date = (SELECT current_date)';
	return null;
END

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.add_metadate()
  OWNER TO postgres;
