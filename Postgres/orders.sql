-- Table: public.orders

-- DROP TABLE IF EXISTS public.orders;

CREATE TABLE IF NOT EXISTS public.orders
(
    o_orderkey integer NOT NULL,
    o_custkey integer NOT NULL,
    o_orderstatus character(1) COLLATE pg_catalog."default" NOT NULL,
    o_totalprice numeric(15,2) NOT NULL,
    o_orderdate date NOT NULL,
    o_orderpriority character(15) COLLATE pg_catalog."default" NOT NULL,
    o_clerk character(15) COLLATE pg_catalog."default" NOT NULL,
    o_shippriority integer NOT NULL,
    o_comment character varying(79) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT orders_pkey PRIMARY KEY (o_orderkey),
    CONSTRAINT orders_o_custkey_fkey FOREIGN KEY (o_custkey)
        REFERENCES public.customer (c_custkey) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.orders
    OWNER to postgres;
-- Index: idx_orders_custkey

-- DROP INDEX IF EXISTS public.idx_orders_custkey;

CREATE INDEX IF NOT EXISTS idx_orders_custkey
    ON public.orders USING btree
    (o_custkey ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: idx_orders_orderdate

-- DROP INDEX IF EXISTS public.idx_orders_orderdate;

CREATE INDEX IF NOT EXISTS idx_orders_orderdate
    ON public.orders USING btree
    (o_orderdate ASC NULLS LAST)
    TABLESPACE pg_default;