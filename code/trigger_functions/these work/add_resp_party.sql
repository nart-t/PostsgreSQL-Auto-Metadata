-- Function: public.add_resp_party()

-- DROP FUNCTION public.add_resp_party();

CREATE OR REPLACE FUNCTION public.add_resp_party()
  RETURNS trigger AS
$BODY$


-- this trigger function adds the contact details for the responsible organisation of the dataset (similar details to metadata contact)
declare
	table_name text; --variable that holds the name of the table (i.e. dataset) being used to extract information from
	user_name text; --variable that contains the database defined user name that has imported a specific dataset to the database
	user_id integer; --variable that contains the system user ID for the user name


begin

	--storing in the table_name variable the name of the newly added table (dataset) to the database
	SELECT dataset_name from metadata where NEW.dataset_name = dataset_name INTO table_name;

	--storing in the user_name variable the name of the database defined user that uploaded the table name stored in table_name
	select tableowner from pg_tables where tablename = table_name into user_name;

	--storing in the user_id variable the system generated id of the user_name user
	select usesysid from pg_user where usename = user_name into user_id;

	--inserting in the metadatacontact_name field of the metadata table, the organisation_name value as stored in the database_groups lookup table
	execute 'UPDATE metadata SET respparty_name = (SELECT organisation_name FROM database_groups, pg_group, pg_user,
		pg_tables
		WHERE group_id = pg_group.grosysid 
			AND pg_user.usesysid = ' || user_id ||
				' AND pg_user.usename = ' || quote_literal(user_name) ||
					' AND pg_tables.tablename = ' || quote_literal(table_name) || ');';


	--inserting in the metadatacontact_email field of the metadata table, the contact email address as stored in the database_groups lookup table
	EXECUTE 'UPDATE metadata SET respparty_email = (SELECT email FROM database_groups, pg_group, pg_user, pg_tables
		WHERE group_id = pg_group.grosysid 
			AND pg_user.usesysid = ' || user_id ||
				' AND pg_user.usename = ' || quote_literal(user_name) ||
					' AND pg_tables.tablename = ' || quote_literal(table_name) || ');';

	return null;

end;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.add_resp_party()
  OWNER TO postgres;
