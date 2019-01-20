-- Loader. Copyright (c) Nart Tamash.
-- Licensed under [GNU GPLv3](https://bit.ly/2HGhaNl).



-- Function: public.add_default_resource_title()

-- DROP FUNCTION public.add_default_resource_title();

CREATE OR REPLACE FUNCTION public.add_default_resource_title()
  RETURNS trigger AS
$BODY$


-- this trigger function checks if the resource_title field in the metadata table is empty (can be added manually via the front-end QGIS plugin), and if it is, it inserts into it, by default, the file name of the respective dataset (table name)
declare
	table_name text; --variable that holds the name of the table (i.e. dataset) being used to extract information from
	
begin

	--storing in the table_name variable the newly added table (dataset) to the database
	select dataset_name from metadata where NEW.dataset_name = dataset_name into table_name;

	--checks if resource_title field in metadata table for the newly added dataset is empty. If it is, the name of the dataset (table) is added. If it's not, no action is required
	if resource_title is null from metadata where dataset_name = table_name
		then update metadata set resource_title = table_name where dataset_name = table_name;
	end if;

	return null;
	
end;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.add_default_resource_title()
  OWNER TO postgres;
