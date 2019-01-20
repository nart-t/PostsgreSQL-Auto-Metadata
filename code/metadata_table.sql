CREATE TABLE public.metadata
(
  id integer NOT NULL DEFAULT nextval('metadata_id_seq1'::regclass),
  dataset_oid integer,
  dataset_name character varying,
  resource_title character varying,
  resource_abstract character varying,
  resource_type character varying DEFAULT 'dataset'::character varying,
  resource_locator character varying,
  identifier_code character varying,
  identifier_namespace character varying DEFAULT 'ucl.ac.uk_CEGE_metadata'::character varying,
  resource_language character varying,
  topic_category character varying,
  keyword character varying,
  vocabulary_title character varying,
  vocabulary_reference_date date,
  vocabulary_date_type character varying,
  bb_northbound_lat numeric(7,4),
  bb_eastbound_long numeric(7,4),
  bb_southbound_lat numeric(7,4),
  bb_westbound_long numeric(7,4),
  tempext_start_date date,
  tempext_end_date date,
  creation_date date,
  publication_date date,
  last_revision_date date,
  lineage character varying,
  resolution_scale integer,
  resolution_distance integer,
  resolution_measure_unit character varying,
  conformity_degree character varying DEFAULT 'notEvaluated'::character varying,
  confspec_specification character varying,
  confspec_date date,
  confspec_date_type character varying,
  use_limitations character varying DEFAULT 'no limitations'::character varying,
  use_conditions character varying DEFAULT 'conditions unknown'::character varying,
  respparty_name character varying,
  respparty_email character varying,
  party_role character varying DEFAULT 'user'::character varying,
  metadatacontact_name character varying,
  metadatacontact_email character varying,
  metadata_date date,
  metadata_language character varying(2),
  geom geometry(Polygon,4326),
  CONSTRAINT metadata_pkey1 PRIMARY KEY (id )
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.metadata
  OWNER TO postgres;

-- Trigger: add_boundingbox on public.metadata

-- DROP TRIGGER add_boundingbox ON public.metadata;

CREATE TRIGGER add_boundingbox
  AFTER INSERT
  ON public.metadata
  FOR EACH ROW
  EXECUTE PROCEDURE public.add_boundingbox();

-- Trigger: add_default_resource_title on public.metadata

-- DROP TRIGGER add_default_resource_title ON public.metadata;

CREATE TRIGGER add_default_resource_title
  AFTER INSERT
  ON public.metadata
  FOR EACH ROW
  EXECUTE PROCEDURE public.add_default_resource_title();

-- Trigger: add_id_code on public.metadata

-- DROP TRIGGER add_id_code ON public.metadata;

CREATE TRIGGER add_id_code
  AFTER INSERT
  ON public.metadata
  FOR EACH ROW
  EXECUTE PROCEDURE public.add_id_code();

-- Trigger: add_last_revision_date on public.metadata

-- DROP TRIGGER add_last_revision_date ON public.metadata;

CREATE TRIGGER add_last_revision_date
  AFTER INSERT
  ON public.metadata
  FOR EACH ROW
  EXECUTE PROCEDURE public.add_last_revision_date();

-- Trigger: add_metadata_contact on public.metadata

-- DROP TRIGGER add_metadata_contact ON public.metadata;

CREATE TRIGGER add_metadata_contact
  AFTER INSERT
  ON public.metadata
  FOR EACH ROW
  EXECUTE PROCEDURE public.add_metadata_contact();

-- Trigger: add_metadata_geom on public.metadata

-- DROP TRIGGER add_metadata_geom ON public.metadata;

CREATE TRIGGER add_metadata_geom
  AFTER INSERT
  ON public.metadata
  FOR EACH ROW
  EXECUTE PROCEDURE public.add_metadata_geom();

-- Trigger: add_metadatadate on public.metadata

-- DROP TRIGGER add_metadatadate ON public.metadata;

CREATE TRIGGER add_metadatadate
  AFTER INSERT
  ON public.metadata
  FOR EACH ROW
  EXECUTE PROCEDURE public.add_metadate();

-- Trigger: add_metadatalanguage on public.metadata

-- DROP TRIGGER add_metadatalanguage ON public.metadata;

CREATE TRIGGER add_metadatalanguage
  AFTER INSERT
  ON public.metadata
  FOR EACH ROW
  EXECUTE PROCEDURE public.add_metadatalanguage();

-- Trigger: add_oid on public.metadata

-- DROP TRIGGER add_oid ON public.metadata;

CREATE TRIGGER add_oid
  AFTER INSERT
  ON public.metadata
  FOR EACH ROW
  EXECUTE PROCEDURE public.add_oid();

-- Trigger: add_resp_party on public.metadata

-- DROP TRIGGER add_resp_party ON public.metadata;

CREATE TRIGGER add_resp_party
  AFTER INSERT
  ON public.metadata
  FOR EACH ROW
  EXECUTE PROCEDURE public.add_resp_party();

-- Trigger: create_dataset_update_trigger on public.metadata

-- DROP TRIGGER create_dataset_update_trigger ON public.metadata;

CREATE TRIGGER create_dataset_update_trigger
  AFTER INSERT
  ON public.metadata
  FOR EACH ROW
  EXECUTE PROCEDURE public.create_dataset_update_trigger();



-- Trigger: create_keywords on public.metadata

-- DROP TRIGGER create_keywords ON public.metadata;

CREATE TRIGGER create_keywords
  AFTER INSERT
  ON public.metadata
  FOR EACH ROW
  EXECUTE PROCEDURE public.identify_keywords();
