-- GPT -------------------------------------------------------------------------

BEGIN;

CREATE MATERIALIZED VIEW mv_orders_grouped_sorted AS
SELECT 
  o_orderpriority,
  COUNT(*) AS order_count
FROM 
  public.orders
GROUP BY 
  o_orderpriority
ORDER BY 
  o_orderpriority;

CREATE INDEX idx_mv_orders_grouped_sorted_orderpriority
ON mv_orders_grouped_sorted (o_orderpriority);

SELECT * FROM mv_orders_grouped_sorted;


ROLLBACK;

"Finalize GroupAggregate  (cost=36500.13..36501.40 rows=5 width=24)"
"  Group Key: o_orderpriority"
"  ->  Gather Merge  (cost=36500.13..36501.30 rows=10 width=24)"
"        Workers Planned: 2"
"        ->  Sort  (cost=35500.11..35500.12 rows=5 width=24)"
"              Sort Key: o_orderpriority"
"              ->  Partial HashAggregate  (cost=35500.00..35500.05 rows=5 width=24)"
"                    Group Key: o_orderpriority"
"                    ->  Parallel Seq Scan on orders  (cost=0.00..32375.00 rows=625000 width=16)"


"Seq Scan on mv_orders_grouped_sorted  (cost=0.00..18.10 rows=810 width=72)"

-- Result OK

----------------------------------------------------------------------------------------------------
-- Gemini ------------------------------------------------------------------------------------------

BEGIN;

SELECT
  o_orderpriority,
  COUNT(o_orderkey) AS "Count"
FROM
  public.orders
GROUP BY
  o_orderpriority
ORDER BY
  o_orderpriority;

ROLLBACK;

"Finalize GroupAggregate  (cost=36500.13..36501.40 rows=5 width=24)"
"  Group Key: o_orderpriority"
"  ->  Gather Merge  (cost=36500.13..36501.30 rows=10 width=24)"
"        Workers Planned: 2"
"        ->  Sort  (cost=35500.11..35500.12 rows=5 width=24)"
"              Sort Key: o_orderpriority"
"              ->  Partial HashAggregate  (cost=35500.00..35500.05 rows=5 width=24)"
"                    Group Key: o_orderpriority"
"                    ->  Parallel Seq Scan on orders  (cost=0.00..32375.00 rows=625000 width=20)"

-- Result 

----------------------------------------------------------------------------------------------------
-- DeepSeek ----------------------------------------------------------------------------------------

BEGIN;

CREATE MATERIALIZED VIEW IF NOT EXISTS orders_priority_count AS
SELECT 
    o_orderpriority,
    COUNT(o_orderkey) AS order_count
FROM 
    public.orders
GROUP BY 
    o_orderpriority
ORDER BY 
    o_orderpriority ASC;

REFRESH MATERIALIZED VIEW orders_priority_count;

SELECT * FROM orders_priority_count;

ROLLBACK;

-- Result OK

"Finalize GroupAggregate  (cost=36500.13..36501.40 rows=5 width=24)"
"  Group Key: o_orderpriority"
"  ->  Gather Merge  (cost=36500.13..36501.30 rows=10 width=24)"
"        Workers Planned: 2"
"        ->  Sort  (cost=35500.11..35500.12 rows=5 width=24)"
"              Sort Key: o_orderpriority"
"              ->  Partial HashAggregate  (cost=35500.00..35500.05 rows=5 width=24)"
"                    Group Key: o_orderpriority"
"                    ->  Parallel Seq Scan on orders  (cost=0.00..32375.00 rows=625000 width=20)"


"Seq Scan on orders_priority_count  (cost=0.00..18.10 rows=810 width=72)"


----------------------------------------------------------------------------------------------------
-- Claude ------------------------------------------------------------------------------------------


CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_orders_orderpriority 
ON "public".orders (o_orderpriority);

BEGIN;

ANALYZE "public".orders;

SELECT 
    o_orderpriority,
    COUNT(o_orderkey) AS count_o_orderkey
FROM "public".orders
GROUP BY o_orderpriority
ORDER BY o_orderpriority;


ROLLBACK;

-- Result OK

"Finalize GroupAggregate  (cost=36500.13..36501.40 rows=5 width=24)"
"  Group Key: o_orderpriority"
"  ->  Gather Merge  (cost=36500.13..36501.30 rows=10 width=24)"
"        Workers Planned: 2"
"        ->  Sort  (cost=35500.11..35500.12 rows=5 width=24)"
"              Sort Key: o_orderpriority"
"              ->  Partial HashAggregate  (cost=35500.00..35500.05 rows=5 width=24)"
"                    Group Key: o_orderpriority"
"                    ->  Parallel Seq Scan on orders  (cost=0.00..32375.00 rows=625000 width=20)"
