-- GPT -------------------------------------------------------------------------

BEGIN;

CREATE INDEX IF NOT EXISTS idx_customer_custkey_nationkey ON public.customer (c_custkey, c_nationkey);

SELECT 
  o.*,
  c.c_name,
  c.c_address,
  c.c_nationkey,
  c.c_phone,
  c.c_acctbal,
  c.c_mktsegment,
  c.c_comment
FROM 
  public.orders o
JOIN 
  public.customer c
  ON o.o_custkey = c.c_custkey
WHERE 
  c.c_nationkey = 10;

ROLLBACK;

"Gather  (cost=5411.77..45287.44 rows=58600 width=266)"
"  Workers Planned: 2"
"  ->  Parallel Hash Join  (cost=4411.77..38427.44 rows=24417 width=266)"
"        Hash Cond: (o.o_custkey = c.c_custkey)"
"        ->  Parallel Seq Scan on orders o  (cost=0.00..32375.00 rows=625000 width=107)"
"        ->  Parallel Hash  (cost=4381.25..4381.25 rows=2442 width=159)"
"              ->  Parallel Seq Scan on customer c  (cost=0.00..4381.25 rows=2442 width=159)"
"                    Filter: (c_nationkey = 10)"

-- Result

----------------------------------------------------------------------------------------------------
-- Gemini ------------------------------------------------------------------------------------------

BEGIN;

CREATE INDEX IF NOT EXISTS idx_customer_nationkey ON public.customer (c_nationkey);
CREATE INDEX IF NOT EXISTS idx_customer_custkey ON public.customer (c_custkey);
CREATE INDEX IF NOT EXISTS idx_orders_custkey ON public.orders (o_custkey);

SELECT
    -- Columns from the 'orders' table
    o.o_orderkey,
    o.o_custkey,
    o.o_orderstatus,
    o.o_totalprice,
    o.o_orderdate,
    o.o_orderpriority,
    o.o_clerk,
    o.o_shippriority,
    o.o_comment AS o_comment,

    -- Columns from the 'customer' table
    c.c_custkey,
    c.c_name,
    c.c_address,
    c.c_nationkey,
    c.c_phone,
    c.c_acctbal,
    c.c_mktsegment,
    c.c_comment AS c_comment
FROM
    public.orders AS o
INNER JOIN
    public.customer AS c ON o.o_custkey = c.c_custkey
WHERE
    c.c_nationkey = 10;

ROLLBACK;

"Gather Merge  (cost=43757.60..49455.30 rows=48834 width=266)"
"  Workers Planned: 2"
"  ->  Sort  (cost=42757.58..42818.62 rows=24417 width=266)"
"        Sort Key: orders.o_custkey"
"        ->  Parallel Hash Join  (cost=3871.95..37887.62 rows=24417 width=266)"
"              Hash Cond: (orders.o_custkey = customer.c_custkey)"
"              ->  Parallel Seq Scan on orders  (cost=0.00..32375.00 rows=625000 width=107)"
"              ->  Parallel Hash  (cost=3841.42..3841.42 rows=2442 width=159)"
"                    ->  Parallel Bitmap Heap Scan on customer  (cost=69.71..3841.42 rows=2442 width=159)"
"                          Recheck Cond: (c_nationkey = 10)"
"                          ->  Bitmap Index Scan on idx_customer_nationkey  (cost=0.00..68.24 rows=5860 width=0)"
"                                Index Cond: (c_nationkey = 10)"

-- Result 

----------------------------------------------------------------------------------------------------
-- DeepSeek ----------------------------------------------------------------------------------------

BEGIN;

CREATE INDEX IF NOT EXISTS idx_customer_custkey_nationkey ON "public".customer(c_custkey, c_nationkey);
CREATE INDEX IF NOT EXISTS idx_orders_custkey ON "public".orders(o_custkey);

SELECT o.*, c.*
FROM "public".orders o
JOIN "public".customer c ON o.o_custkey = c.c_custkey
WHERE c.c_nationkey = 10
ORDER BY o.o_custkey, c.c_custkey;

ROLLBACK;

"Gather Merge  (cost=44297.43..49995.13 rows=48834 width=266)"
"  Workers Planned: 2"
"  ->  Sort  (cost=43297.41..43358.45 rows=24417 width=266)"
"        Sort Key: o.o_custkey"
"        ->  Parallel Hash Join  (cost=4411.77..38427.44 rows=24417 width=266)"
"              Hash Cond: (o.o_custkey = c.c_custkey)"
"              ->  Parallel Seq Scan on orders o  (cost=0.00..32375.00 rows=625000 width=107)"
"              ->  Parallel Hash  (cost=4381.25..4381.25 rows=2442 width=159)"
"                    ->  Parallel Seq Scan on customer c  (cost=0.00..4381.25 rows=2442 width=159)"
"                          Filter: (c_nationkey = 10)"

-- Result 



----------------------------------------------------------------------------------------------------
-- Claude ------------------------------------------------------------------------------------------

CREATE INDEX CONCURRENTLY idx_customer_nationkey_custkey 
ON public.customer (c_nationkey, c_custkey) 
WHERE c_nationkey = 10;

BEGIN;

SELECT 
    o.o_orderkey,
    o.o_custkey,
    o.o_orderstatus,
    o.o_totalprice,
    o.o_orderdate,
    o.o_orderpriority,
    o.o_clerk,
    o.o_shippriority,
    o.o_comment,
    c.c_custkey,
    c.c_name,
    c.c_address,
    c.c_nationkey,
    c.c_phone,
    c.c_acctbal,
    c.c_mktsegment,
    c.c_comment
FROM public.orders o
INNER JOIN public.customer c ON o.o_custkey = c.c_custkey
WHERE c.c_nationkey = 10;

ROLLBACK;

"Gather  (cost=5411.77..45287.44 rows=58600 width=266)"
"  Workers Planned: 2"
"  ->  Parallel Hash Join  (cost=4411.77..38427.44 rows=24417 width=266)"
"        Hash Cond: (o.o_custkey = c.c_custkey)"
"        ->  Parallel Seq Scan on orders o  (cost=0.00..32375.00 rows=625000 width=107)"
"        ->  Parallel Hash  (cost=4381.25..4381.25 rows=2442 width=159)"
"              ->  Parallel Seq Scan on customer c  (cost=0.00..4381.25 rows=2442 width=159)"
"                    Filter: (c_nationkey = 10)"

-- Result 
