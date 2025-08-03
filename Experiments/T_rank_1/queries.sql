-- GPT -------------------------------------------------------------------------

BEGIN;

CREATE INDEX IF NOT EXISTS idx_orders_custkey ON public.orders (o_custkey);
CREATE INDEX IF NOT EXISTS idx_customer_custkey ON public.customer (c_custkey);
CREATE INDEX IF NOT EXISTS idx_customer_nationkey ON public.customer (c_nationkey);
CREATE INDEX IF NOT EXISTS idx_nation_nationkey ON public.nation (n_nationkey);

SELECT
  n.n_name,
  ranked.customer_position,
  ranked.o_custkey,
  ranked.total_price
FROM (
  SELECT
    c.c_nationkey,
    o.o_custkey,
    SUM(o.o_totalprice) AS total_price,
    ROW_NUMBER() OVER (
      PARTITION BY c.c_nationkey
      ORDER BY SUM(o.o_totalprice) DESC
    ) AS customer_position
  FROM
    public.orders o
    INNER JOIN public.customer c ON o.o_custkey = c.c_custkey
  GROUP BY
    c.c_nationkey,
    o.o_custkey
) AS ranked
INNER JOIN public.nation n ON ranked.c_nationkey = n.n_nationkey
WHERE ranked.customer_position <= 3;

ROLLBACK;

"Hash Join  (cost=237662.59..448367.16 rows=187500 width=148)"
"  Hash Cond: (c.c_nationkey = n.n_nationkey)"
"  ->  WindowAgg  (cost=237661.02..429344.66 rows=1500000 width=48)"
"        Run Condition: (row_number() OVER (?) <= 3)"
"        ->  Incremental Sort  (cost=237660.90..403094.66 rows=1500000 width=40)"
"              Sort Key: c.c_nationkey, (sum(o.o_totalprice)) DESC"
"              Presorted Key: c.c_nationkey"
"              ->  GroupAggregate  (cost=231549.09..265299.09 rows=1500000 width=40)"
"                    Group Key: c.c_nationkey, o.o_custkey"
"                    ->  Sort  (cost=231549.09..235299.09 rows=1500000 width=16)"
"                          Sort Key: c.c_nationkey, o.o_custkey"
"                          ->  Hash Join  (cost=6975.00..52037.61 rows=1500000 width=16)"
"                                Hash Cond: (o.o_custkey = c.c_custkey)"
"                                ->  Seq Scan on orders o  (cost=0.00..41125.00 rows=1500000 width=12)"
"                                ->  Hash  (cost=5100.00..5100.00 rows=150000 width=8)"
"                                      ->  Seq Scan on customer c  (cost=0.00..5100.00 rows=150000 width=8)"
"  ->  Hash  (cost=1.25..1.25 rows=25 width=108)"
"        ->  Seq Scan on nation n  (cost=0.00..1.25 rows=25 width=108)"

-- Result

----------------------------------------------------------------------------------------------------
-- Gemini ------------------------------------------------------------------------------------------

BEGIN;

WITH ranked_customers AS (
  SELECT
    c.c_custkey,
    n.n_name,
    SUM(o.o_totalprice) AS total_price,
    RANK() OVER (PARTITION BY n.n_name ORDER BY SUM(o.o_totalprice) DESC) AS customer_position
  FROM
    public.orders AS o
    JOIN public.customer AS c ON o.o_custkey = c.c_custkey
    JOIN public.nation AS n ON c.c_nationkey = n.n_nationkey
  GROUP BY
    n.n_name,
    c.c_custkey
)
SELECT
  n_name,
  customer_position,
  c_custkey,
  total_price
FROM
  ranked_customers
WHERE
  customer_position <= 3
ORDER BY
  n_name,
  customer_position;

ROLLBACK;

"Incremental Sort  (cost=198453.98..770669.07 rows=1500000 width=148)"
"  Sort Key: ranked_customers.n_name, ranked_customers.customer_position"
"  Presorted Key: ranked_customers.n_name"
"  ->  Subquery Scan on ranked_customers  (cost=195672.77..655370.01 rows=1500000 width=148)"
"        ->  WindowAgg  (cost=195672.77..640370.01 rows=1500000 width=148)"
"              Run Condition: (rank() OVER (?) <= 3)"
"              ->  Incremental Sort  (cost=195672.48..614120.01 rows=1500000 width=140)"
"                    Sort Key: n.n_name, (sum(o.o_totalprice)) DESC"
"                    Presorted Key: n.n_name"
"                    ->  Finalize GroupAggregate  (cost=179018.43..368611.95 rows=1500000 width=140)"
"                          Group Key: n.n_name, c.c_custkey"
"                          ->  Gather Merge  (cost=179018.43..337361.95 rows=1250000 width=140)"
"                                Workers Planned: 2"
"                                ->  Partial GroupAggregate  (cost=178018.41..192080.91 rows=625000 width=140)"
"                                      Group Key: n.n_name, c.c_custkey"
"                                      ->  Sort  (cost=178018.41..179580.91 rows=625000 width=116)"
"                                            Sort Key: n.n_name, c.c_custkey"
"                                            ->  Hash Join  (cost=5007.81..40942.23 rows=625000 width=116)"
"                                                  Hash Cond: (c.c_nationkey = n.n_nationkey)"
"                                                  ->  Parallel Hash Join  (cost=5006.25..39021.92 rows=625000 width=16)"
"                                                        Hash Cond: (o.o_custkey = c.c_custkey)"
"                                                        ->  Parallel Seq Scan on orders o  (cost=0.00..32375.00 rows=625000 width=12)"
"                                                        ->  Parallel Hash  (cost=4225.00..4225.00 rows=62500 width=8)"
"                                                              ->  Parallel Seq Scan on customer c  (cost=0.00..4225.00 rows=62500 width=8)"
"                                                  ->  Hash  (cost=1.25..1.25 rows=25 width=108)"
"                                                        ->  Seq Scan on nation n  (cost=0.00..1.25 rows=25 width=108)"

-- Result 

----------------------------------------------------------------------------------------------------
-- DeepSeek ----------------------------------------------------------------------------------------

BEGIN;

CREATE INDEX idx_customer_custkey ON customer(c_custkey); 
CREATE INDEX idx_orders_custkey ON orders(o_custkey); 
CREATE INDEX idx_nation_nationkey ON nation(n_nationkey);
CREATE INDEX idx_customer_nationkey ON customer(c_nationkey);

ANALYZE customer; 
ANALYZE orders; 
ANALYZE nation;

WITH customer_orders AS (
    SELECT 
        c.c_nationkey,
        c.c_custkey,
        SUM(o.o_totalprice) AS total_price
    FROM 
        customer c
    JOIN 
        orders o ON c.c_custkey = o.o_custkey
    GROUP BY 
        c.c_nationkey, c.c_custkey
),
ranked_customers AS (
    SELECT 
        c_nationkey,
        c_custkey,
        total_price,
        ROW_NUMBER() OVER (PARTITION BY c_nationkey ORDER BY total_price DESC) AS customer_position
    FROM 
        customer_orders
)
SELECT 
    n.n_name,
    rc.customer_position,
    rc.c_custkey,
    rc.total_price AS "Total price"
FROM 
    ranked_customers rc
JOIN 
    nation n ON rc.c_nationkey = n.n_nationkey
WHERE 
    rc.customer_position <= 3
ORDER BY 
    n.n_name, rc.customer_position;

ROLLBACK;

"Sort  (cost=167397.27..167444.14 rows=18750 width=70)"
"  Sort Key: n.n_name, (row_number() OVER (?))"
"  ->  Hash Join  (cost=161164.45..166066.53 rows=18750 width=70)"
"        Hash Cond: (customer_orders.c_nationkey = n.n_nationkey)"
"        ->  WindowAgg  (cost=161162.89..164162.87 rows=150000 width=48)"
"              Run Condition: (row_number() OVER (?) <= 3)"
"              ->  Sort  (cost=161162.87..161537.87 rows=150000 width=40)"
"                    Sort Key: customer_orders.c_nationkey, customer_orders.total_price DESC"
"                    ->  Subquery Scan on customer_orders  (cost=105037.47..144164.92 rows=150000 width=40)"
"                          ->  Finalize GroupAggregate  (cost=105037.47..144164.92 rows=150000 width=40)"
"                                Group Key: c.c_custkey"
"                                ->  Gather Merge  (cost=105037.47..140039.92 rows=300000 width=40)"
"                                      Workers Planned: 2"
"                                      ->  Sort  (cost=104037.45..104412.45 rows=150000 width=40)"
"                                            Sort Key: c.c_custkey"
"                                            ->  Partial HashAggregate  (cost=79060.98..87039.50 rows=150000 width=40)"
"                                                  Group Key: c.c_custkey"
"                                                  Planned Partitions: 8"
"                                                  ->  Parallel Hash Join  (cost=5006.25..39021.92 rows=625000 width=16)"
"                                                        Hash Cond: (o.o_custkey = c.c_custkey)"
"                                                        ->  Parallel Seq Scan on orders o  (cost=0.00..32375.00 rows=625000 width=12)"
"                                                        ->  Parallel Hash  (cost=4225.00..4225.00 rows=62500 width=8)"
"                                                              ->  Parallel Seq Scan on customer c  (cost=0.00..4225.00 rows=62500 width=8)"
"        ->  Hash  (cost=1.25..1.25 rows=25 width=30)"
"              ->  Seq Scan on nation n  (cost=0.00..1.25 rows=25 width=30)"


-- Result 



----------------------------------------------------------------------------------------------------
-- Claude ------------------------------------------------------------------------------------------

BEGIN;

CREATE INDEX IF NOT EXISTS idx_orders_custkey ON public.orders(o_custkey);
CREATE INDEX IF NOT EXISTS idx_customer_custkey ON public.customer(c_custkey);
CREATE INDEX IF NOT EXISTS idx_customer_nationkey ON public.customer(c_nationkey);
CREATE INDEX IF NOT EXISTS idx_nation_nationkey ON public.nation(n_nationkey);

WITH customer_totals AS (
    SELECT 
        c.c_nationkey,
        o.o_custkey,
        SUM(o.o_totalprice) as total_price
    FROM public.orders o
    INNER JOIN public.customer c ON o.o_custkey = c.c_custkey
    GROUP BY c.c_nationkey, o.o_custkey
),
ranked_customers AS (
    SELECT 
        c_nationkey,
        o_custkey,
        total_price,
        ROW_NUMBER() OVER (PARTITION BY c_nationkey ORDER BY total_price DESC) as customer_position
    FROM customer_totals
)
SELECT 
    n.n_name,
    rc.customer_position,
    rc.o_custkey,
    rc.total_price
FROM ranked_customers rc
INNER JOIN public.nation n ON rc.c_nationkey = n.n_nationkey
WHERE rc.customer_position <= 3
ORDER BY rc.c_nationkey, rc.customer_position;

ROLLBACK;

-- Result 

"Incremental Sort  (cost=233225.16..439078.49 rows=187500 width=152)"
"  Sort Key: customer_totals.c_nationkey, (row_number() OVER (?))"
"  Presorted Key: customer_totals.c_nationkey"
"  ->  Merge Join  (cost=232202.52..427475.11 rows=187500 width=152)"
"        Merge Cond: (customer_totals.c_nationkey = n.n_nationkey)"
"        ->  WindowAgg  (cost=232200.69..406848.16 rows=1500000 width=48)"
"              Run Condition: (row_number() OVER (?) <= 3)"
"              ->  Incremental Sort  (cost=232200.57..380598.16 rows=1500000 width=40)"
"                    Sort Key: customer_totals.c_nationkey, customer_totals.total_price DESC"
"                    Presorted Key: customer_totals.c_nationkey"
"                    ->  Subquery Scan on customer_totals  (cost=231549.09..265299.09 rows=1500000 width=40)"
"                          ->  GroupAggregate  (cost=231549.09..265299.09 rows=1500000 width=40)"
"                                Group Key: c.c_nationkey, o.o_custkey"
"                                ->  Sort  (cost=231549.09..235299.09 rows=1500000 width=16)"
"                                      Sort Key: c.c_nationkey, o.o_custkey"
"                                      ->  Hash Join  (cost=6975.00..52037.61 rows=1500000 width=16)"
"                                            Hash Cond: (o.o_custkey = c.c_custkey)"
"                                            ->  Seq Scan on orders o  (cost=0.00..41125.00 rows=1500000 width=12)"
"                                            ->  Hash  (cost=5100.00..5100.00 rows=150000 width=8)"
"                                                  ->  Seq Scan on customer c  (cost=0.00..5100.00 rows=150000 width=8)"
"        ->  Sort  (cost=1.83..1.89 rows=25 width=108)"
"              Sort Key: n.n_nationkey"
"              ->  Seq Scan on nation n  (cost=0.00..1.25 rows=25 width=108)"