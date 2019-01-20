-- Function: public.add_group_id()

-- DROP FUNCTION public.add_group_id();

CREATE OR REPLACE FUNCTION public.add_group_id()
  RETURNS trigger AS
$BODY$


--this trigger function adds the system  identifier for a group of users into the database_groups table, once at least the group_name field is manually inserted in the database_goups table. The group_name value has to be equivalent to the name given to the group when initially created via SQL commnads. For more info over the database_groups table, please see the documentation
declare
	groups text; --variable that holds the name of the group of users being subject to processing

begin
	
	--selects the newly (manually) added group name in the database_groups table
	select group_name from database_groups where NEW.group_name = group_name into groups;

	--based on the name of the group of users (which should coincide with the name initially given to the group when created), the system identifier of the group is added to the database_groups table
	execute 'UPDATE database_groups
		SET group_id = (SELECT grosysid FROM pg_group WHERE groname = ' || quote_literal(groups) || ')';

	return null;

end;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.add_group_id()
  OWNER TO postgres;
