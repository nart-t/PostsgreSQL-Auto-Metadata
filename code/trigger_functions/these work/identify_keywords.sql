-- Function: public.identify_keywords()

-- DROP FUNCTION public.identify_keywords();

CREATE OR REPLACE FUNCTION public.identify_keywords()
  RETURNS trigger AS
$BODY$


-- this trigger function looks at all the text (char) columns in a table, and finds the 10 most used individual words, inserting them in the metadata keywords field 
declare 
        table_name text; --variable that holds the name of the table (i.e. dataset) being used to extract information from
        field_name text;
        curs1 refcursor;
        field_list text;
        final_query text;
        key_word text;
        key_words text;
        key_num text;
begin



        --variable that holds the name of the table (i.e. dataset) being used to extract information from
        select dataset_name from metadata where NEW.dataset_name = dataset_name into table_name;



        field_list = '';
        Open curs1 FOR EXECUTE 'SELECT column_name, data_type FROM information_schema.columns WHERE table_name = ' || quote_literal(table_name) ||' and data_type like ' || quote_literal('%char%');
         loop
          fetch curs1 into field_name;
                  if not found then
                     exit ;
                  else
                     -- add a union all statement
                     if length(field_list) > 0 then
                        field_list := field_list || ' UNION ALL ';
                     end if;
                  end if;
                  
                  -- now build up the SQL list of fields for our next query
                  field_list := field_list || 'select regexp_split_to_table(' || field_name || ', ' || quote_literal('\s+') || ') as words from ' || table_name ;
                  -- select regexp_split_to_table("NAME", E'\\s+') as words from united_kingdom_poi_subset
         end loop;
        close curs1;

        if length(field_list) = 0 then
                key_words = 'No text in table for automatic keyword detection';
                EXECUTE 'UPDATE metadata SET keyword= ' || quote_literal(key_words) || ' where dataset_name = ' || quote_literal(table_name);
        
        else
                RAISE NOTICE 'field_list is currently %', field_list; 

                key_word = '';
                key_words = '';
                key_num = '';
                RAISE NOTICE 'query is %', 'select b.words, count(*) as num_occur from (' || field_list || ') b group by b.words order by num_occur desc limit 10'; 

                Open curs1 for execute 'select b.words, count(*) as num_occur from (' || field_list || ') b where b.words not in (' || quote_literal('') ||',' || quote_literal('and') ||',' || quote_literal('yes') || ',' || quote_literal('no') ||','|| quote_literal('or') ||')  group by b.words order by num_occur desc limit 10';

                         loop
                          fetch curs1 into key_word, key_num;
                                  if not found then
                                     exit ;
                                  else
                                        if length(key_words) > 0 then
                                                key_words := key_words || ',' || key_word || '(' || key_num ||')';
                                        else
                                                key_words := key_word || '(' || key_num || ')';
                                        end if; 
                                  end if;       
                         end loop;
                        close curs1;

                -- add the keywords list, comma separated, into the metadata table
                EXECUTE 'UPDATE metadata SET keyword= ' || quote_literal(key_words) || ' where dataset_name = ' || quote_literal(table_name);
        
        
        end if;
        return null;
END;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.identify_keywords()
  OWNER TO postgres;
