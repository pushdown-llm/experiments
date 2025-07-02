-- Table: public.nation

-- DROP TABLE IF EXISTS public.nation;

CREATE TABLE IF NOT EXISTS public.nation
(
    n_nationkey integer NOT NULL,
    n_name character(25) COLLATE pg_catalog."default" NOT NULL,
    n_regionkey integer NOT NULL,
    n_comment character varying(152) COLLATE pg_catalog."default",
    CONSTRAINT nation_pkey PRIMARY KEY (n_nationkey),
    CONSTRAINT nation_n_regionkey_fkey FOREIGN KEY (n_regionkey)
        REFERENCES public.region (r_regionkey) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.nation
    OWNER to postgres;
-- Index: idx_nation_regionkey

-- DROP INDEX IF EXISTS public.idx_nation_regionkey;

CREATE INDEX IF NOT EXISTS idx_nation_regionkey
    ON public.nation USING btree
    (n_regionkey ASC NULLS LAST)
    TABLESPACE pg_default;