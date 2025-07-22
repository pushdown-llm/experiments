-- GPT -------------------------------------------------------------------------

BEGIN;

CREATE INDEX IF NOT EXISTS idx_orders_orderpriority ON public.orders (o_orderpriority);

SELECT
    o_orderkey,
    o_custkey,
    o_orderstatus,
    o_totalprice,
    o_orderdate,
    o_orderpriority,
    o_clerk,
    o_shippriority,
    o_comment
  FROM public.orders
  WHERE o_orderpriority LIKE '%LOW%'

ROLLBACK;

"Seq Scan on orders  (cost=0.00..44875.00 rows=300450 width=107)"
"  Filter: (o_orderpriority ~~ '%LOW%'::text)"

-- Result OK

----------------------------------------------------------------------------------------------------
-- Gemini ------------------------------------------------------------------------------------------

BEGIN;

-- This command enables the pg_trgm extension, which provides functions and operators 
-- for determining the similarity of text based on trigram matching.
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- This command creates a GIN (Generalized Inverted Index) on the o_orderpriority column 
-- using trigram operations, which is highly effective for accelerating LIKE queries with leading wildcards.
CREATE INDEX IF NOT EXISTS idx_gin_orders_orderpriority ON public.orders USING gin (o_orderpriority::text) gin_trgm_ops);

-- This query selects all specified columns from the orders table where the o_orderpriority 
-- column contains the substring 'LOW', leveraging the database for filtering.
SELECT
  o_orderkey,
  o_custkey,
  o_orderstatus,
  o_totalprice,
  o_orderdate,
  o_orderpriority,
  o_clerk,
  o_shippriority,
  o_comment
FROM
  "public".orders
WHERE
  o_orderpriority::text LIKE '%LOW%';

ROLLBACK;

"Bitmap Heap Scan on orders  (cost=500.91..27525.91 rows=60000 width=107)"
"  Recheck Cond: ((o_orderpriority)::text ~~ '%LOW%'::text)"
"  ->  Bitmap Index Scan on idx_gin_orders_orderpriority  (cost=0.00..485.91 rows=60000 width=0)"
"        Index Cond: ((o_orderpriority)::text ~~ '%LOW%'::text)"

-- Result OK

----------------------------------------------------------------------------------------------------
-- DeepSeek ----------------------------------------------------------------------------------------

BEGIN;

-- Create an index to speed up the LIKE filter on o_orderpriority
CREATE INDEX idx_orders_orderpriority_low ON orders (o_orderpriority) 
WHERE o_orderpriority LIKE '%LOW%';

-- Pushdown query to execute on PostgreSQL
EXPLAIN SELECT 
  o_orderkey,
  o_custkey,
  o_orderstatus,
  o_totalprice,
  o_orderdate,
  o_orderpriority,
  o_clerk,
  o_shippriority,
  o_comment
FROM orders
WHERE o_orderpriority LIKE '%LOW%';

ROLLBACK;

"Bitmap Heap Scan on orders  (cost=2621.79..32502.41 rows=300450 width=107)"
"  Recheck Cond: (o_orderpriority ~~ '%LOW%'::text)"
"  ->  Bitmap Index Scan on idx_orders_orderpriority_low  (cost=0.00..2546.67 rows=300450 width=0)"

-- Result OK

----------------------------------------------------------------------------------------------------
-- Claude ------------------------------------------------------------------------------------------

BEGIN;

CREATE INDEX IF NOT EXISTS idx_orders_orderpriority_like 
ON public.orders USING btree (o_orderpriority bpchar_pattern_ops)
WHERE o_orderpriority LIKE '%LOW%';

-- Optimized query with pushed-down filter
EXPLAIN SELECT 
    o_orderkey,
    o_custkey,
    o_orderstatus,
    o_totalprice,
    o_orderdate,
    o_orderpriority,
    o_clerk,
    o_shippriority,
    o_comment
FROM public.orders
WHERE o_orderpriority LIKE '%LOW%';

ROLLBACK;

-- Result OK

"Bitmap Heap Scan on orders  (cost=2621.79..32502.41 rows=300450 width=107)"
"  Recheck Cond: (o_orderpriority ~~ '%LOW%'::text)"
"  ->  Bitmap Index Scan on idx_orders_orderpriority_like  (cost=0.00..2546.67 rows=300450 width=0)"