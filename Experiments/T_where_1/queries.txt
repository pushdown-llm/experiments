-- GPT -------------------------------------------------------------------------

BEGIN;

CREATE INDEX IF NOT EXISTS idx_orders_orderpriority
  ON public.orders (o_orderpriority);

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
WHERE o_orderpriority = '3-MEDIUM';

ROLLBACK;

"Bitmap Heap Scan on orders  (cost=3422.11..33362.74 rows=305250 width=107)"
"  Recheck Cond: (o_orderpriority = '3-MEDIUM'::bpchar)"
"  ->  Bitmap Index Scan on idx_orders_orderpriority  (cost=0.00..3345.80 rows=305250 width=0)"
"        Index Cond: (o_orderpriority = '3-MEDIUM'::bpchar)"

-- Result OK

----------------------------------------------------------------------------------------------------
-- Gemini ------------------------------------------------------------------------------------------

BEGIN;

CREATE INDEX IF NOT EXISTS idx_orders_orderpriority ON "public".orders (o_orderpriority);

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
    o_orderpriority = '3-MEDIUM      ';

ROLLBACK;

"Bitmap Heap Scan on orders  (cost=3422.11..33362.74 rows=305250 width=107)"
"  Recheck Cond: (o_orderpriority = '3-MEDIUM      '::bpchar)"
"  ->  Bitmap Index Scan on idx_orders_orderpriority  (cost=0.00..3345.80 rows=305250 width=0)"
"        Index Cond: (o_orderpriority = '3-MEDIUM      '::bpchar)"

-- Result OK

----------------------------------------------------------------------------------------------------
-- DeepSeek ----------------------------------------------------------------------------------------

BEGIN;

CREATE INDEX IF NOT EXISTS idx_orders_orderpriority ON "public".orders(o_orderpriority);

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
FROM "public".orders
WHERE o_orderpriority = '3-MEDIUM      ';

ROLLBACK;

"Bitmap Heap Scan on orders  (cost=3422.11..33362.74 rows=305250 width=107)"
"  Recheck Cond: (o_orderpriority = '3-MEDIUM      '::bpchar)"
"  ->  Bitmap Index Scan on idx_orders_orderpriority  (cost=0.00..3345.80 rows=305250 width=0)"
"        Index Cond: (o_orderpriority = '3-MEDIUM      '::bpchar)"

-- Result OK

----------------------------------------------------------------------------------------------------
-- Claude ------------------------------------------------------------------------------------------

BEGIN;

CREATE INDEX IF NOT EXISTS idx_orders_orderpriority ON public.orders(o_orderpriority);

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
WHERE o_orderpriority = '3-MEDIUM';

ROLLBACK;

"Bitmap Heap Scan on orders  (cost=3422.11..33362.74 rows=305250 width=107)"
"  Recheck Cond: (o_orderpriority = '3-MEDIUM'::bpchar)"
"  ->  Bitmap Index Scan on idx_orders_orderpriority  (cost=0.00..3345.80 rows=305250 width=0)"
"        Index Cond: (o_orderpriority = '3-MEDIUM'::bpchar)"

-- Result OK