-- GPT -------------------------------------------------------------------------

BEGIN;

CREATE MATERIALIZED VIEW mv_orders_grouped AS
SELECT
  o_custkey,
  o_orderstatus,
  SUM(o_totalprice) AS total_price
FROM
  public.orders
GROUP BY
  o_custkey,
  o_orderstatus
ORDER BY
  o_custkey ASC,
  o_orderstatus ASC;

CREATE INDEX idx_mv_orders_grouped ON mv_orders_grouped (o_custkey, o_orderstatus);

SELECT * FROM mv_orders_grouped;

"Finalize GroupAggregate  (cost=99953.05..139830.50 rows=150000 width=38)"
"  Group Key: o_custkey, o_orderstatus"
"  ->  Gather Merge  (cost=99953.05..134955.50 rows=300000 width=38)"
"        Workers Planned: 2"
"        ->  Sort  (cost=98953.03..99328.03 rows=150000 width=38)"
"              Sort Key: o_custkey, o_orderstatus"
"              ->  Partial HashAggregate  (cost=73976.56..81955.08 rows=150000 width=38)"
"                    Group Key: o_custkey, o_orderstatus"
"                    Planned Partitions: 8"
"                    ->  Parallel Seq Scan on orders  (cost=0.00..32375.00 rows=625000 width=14)"

"Seq Scan on mv_orders_grouped  (cost=0.00..3585.40 rows=230540 width=44)"

ROLLBACK;


-- Result OK

----------------------------------------------------------------------------------------------------
-- Gemini ------------------------------------------------------------------------------------------

BEGIN;

CREATE INDEX IF NOT EXISTS idx_orders_custkey_status 
ON "public".orders (o_custkey, o_orderstatus);
   
SELECT
    o_custkey,
    o_orderstatus,
    SUM(o_totalprice) AS "Total price"
FROM
    "public".orders
GROUP BY
    o_custkey,
    o_orderstatus
ORDER BY
    o_custkey,
    o_orderstatus;

ROLLBACK;

"Finalize GroupAggregate  (cost=99953.05..139830.50 rows=150000 width=38)"
"  Group Key: o_custkey, o_orderstatus"
"  ->  Gather Merge  (cost=99953.05..134955.50 rows=300000 width=38)"
"        Workers Planned: 2"
"        ->  Sort  (cost=98953.03..99328.03 rows=150000 width=38)"
"              Sort Key: o_custkey, o_orderstatus"
"              ->  Partial HashAggregate  (cost=73976.56..81955.08 rows=150000 width=38)"
"                    Group Key: o_custkey, o_orderstatus"
"                    Planned Partitions: 8"
"                    ->  Parallel Seq Scan on orders  (cost=0.00..32375.00 rows=625000 width=14)"


-- Result 

----------------------------------------------------------------------------------------------------
-- DeepSeek ----------------------------------------------------------------------------------------

BEGIN;

CREATE INDEX idx_orders_grouping ON public.orders (o_custkey, o_orderstatus) INCLUDE (o_totalprice); 

CREATE TEMPORARY TABLE grouped_orders AS
SELECT 
    o_custkey,
    o_orderstatus,
    SUM(o_totalprice) AS total_price
FROM 
    public.orders
GROUP BY 
    o_custkey, o_orderstatus
ORDER BY 
    o_custkey, o_orderstatus;

SELECT * FROM grouped_orders;

ROLLBACK;

-- Result OK

"GroupAggregate  (cost=0.43..58737.43 rows=150000 width=38)"
"  Group Key: o_custkey, o_orderstatus"
"  ->  Index Only Scan using idx_orders_grouping on orders  (cost=0.43..45612.43 rows=1500000 width=14)"

"Seq Scan on grouped_orders  (cost=0.00..2726.40 rows=144640 width=44)"


----------------------------------------------------------------------------------------------------
-- Claude ------------------------------------------------------------------------------------------

CREATE INDEX CONCURRENTLY idx_orders_custkey_orderstatus ON public.orders (o_custkey, o_orderstatus);

BEGIN;

SELECT 
    o_custkey,
    o_orderstatus,
    SUM(o_totalprice) AS "Total price"
FROM public.orders
GROUP BY o_custkey, o_orderstatus
ORDER BY o_custkey, o_orderstatus;

ROLLBACK;

-- Result OK

"Finalize GroupAggregate  (cost=99953.05..139830.50 rows=150000 width=38)"
"  Group Key: o_custkey, o_orderstatus"
"  ->  Gather Merge  (cost=99953.05..134955.50 rows=300000 width=38)"
"        Workers Planned: 2"
"        ->  Sort  (cost=98953.03..99328.03 rows=150000 width=38)"
"              Sort Key: o_custkey, o_orderstatus"
"              ->  Partial HashAggregate  (cost=73976.56..81955.08 rows=150000 width=38)"
"                    Group Key: o_custkey, o_orderstatus"
"                    Planned Partitions: 8"
"                    ->  Parallel Seq Scan on orders  (cost=0.00..32375.00 rows=625000 width=14)"