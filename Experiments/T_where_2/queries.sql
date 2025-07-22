-- GPT -------------------------------------------------------------------------

BEGIN;

CREATE INDEX IF NOT EXISTS idx_orders_orderdate ON public.orders (o_orderdate);

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
  public.orders
WHERE
  o_orderdate >= DATE '1997-01-01'
  AND o_orderdate <= DATE '1997-12-31';

ROLLBACK;

"Bitmap Heap Scan on orders  (cost=3168.29..32735.04 rows=229450 width=107)"
"  Recheck Cond: ((o_orderdate >= '1997-01-01'::date) AND (o_orderdate <= '1997-12-31'::date))"
"  ->  Bitmap Index Scan on idx_orders_orderdate  (cost=0.00..3110.93 rows=229450 width=0)"
"        Index Cond: ((o_orderdate >= '1997-01-01'::date) AND (o_orderdate <= '1997-12-31'::date))"

-- Result OK

----------------------------------------------------------------------------------------------------
-- Gemini ------------------------------------------------------------------------------------------

BEGIN;

CREATE INDEX IF NOT EXISTS idx_orders_o_orderdate ON "public".orders (o_orderdate);

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
    o_orderdate >= '1997-01-01' AND o_orderdate < '1998-01-01';

ROLLBACK;

"Bitmap Heap Scan on orders  (cost=3167.79..32733.80 rows=229401 width=107)"
"  Recheck Cond: ((o_orderdate >= '1997-01-01'::date) AND (o_orderdate < '1998-01-01'::date))"
"  ->  Bitmap Index Scan on idx_orders_o_orderdate  (cost=0.00..3110.44 rows=229401 width=0)"
"        Index Cond: ((o_orderdate >= '1997-01-01'::date) AND (o_orderdate < '1998-01-01'::date))"

-- Result OK

----------------------------------------------------------------------------------------------------
-- DeepSeek ----------------------------------------------------------------------------------------

BEGIN;

CREATE INDEX IF NOT EXISTS idx_orders_orderdate ON "public".orders(o_orderdate);

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
WHERE o_orderdate BETWEEN '1997-01-01' AND '1997-12-31';

ROLLBACK;

"Bitmap Heap Scan on orders  (cost=3168.29..32735.04 rows=229450 width=107)"
"  Recheck Cond: ((o_orderdate >= '1997-01-01'::date) AND (o_orderdate <= '1997-12-31'::date))"
"  ->  Bitmap Index Scan on idx_orders_orderdate  (cost=0.00..3110.93 rows=229450 width=0)"
"        Index Cond: ((o_orderdate >= '1997-01-01'::date) AND (o_orderdate <= '1997-12-31'::date))"

-- Result OK

----------------------------------------------------------------------------------------------------
-- Claude ------------------------------------------------------------------------------------------

-- Nie może zostać uruchomione w transakcji
CREATE INDEX CONCURRENTLY idx_orders_orderdate ON public.orders (o_orderdate);

BEGIN;

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
WHERE o_orderdate >= '1997-01-01'::date 
  AND o_orderdate < '1998-01-01'::date;

ROLLBACK;

"Bitmap Heap Scan on orders  (cost=3167.79..32733.80 rows=229401 width=107)"
"  Recheck Cond: ((o_orderdate >= '1997-01-01'::date) AND (o_orderdate < '1998-01-01'::date))"
"  ->  Bitmap Index Scan on idx_orders_orderdate  (cost=0.00..3110.44 rows=229401 width=0)"
"        Index Cond: ((o_orderdate >= '1997-01-01'::date) AND (o_orderdate < '1998-01-01'::date))"

-- Result OK