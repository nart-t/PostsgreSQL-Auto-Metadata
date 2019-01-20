-- Loader. Copyright (c) Nart Tamash.
-- Licensed under [GNU GPLv3](https://bit.ly/2HGhaNl).



CREATE TABLE public.database_groups
(
  group_name character varying,
  organisation_name character varying,
  email character varying,
  group_id integer
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.database_groups
  OWNER TO postgres;

-- Trigger: add_group_id on public.database_groups

-- DROP TRIGGER add_group_id ON public.database_groups;

CREATE TRIGGER add_group_id
  AFTER INSERT
  ON public.database_groups
  FOR EACH ROW
  EXECUTE PROCEDURE public.add_group_id();

alter table database_groups add constraint database_groups_pk primary key(email);
