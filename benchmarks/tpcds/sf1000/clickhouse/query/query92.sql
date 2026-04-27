SET max_execution_time=600;
-- SET partial_merge_join = 1, partial_merge_join_optimizations = 1, max_bytes_before_external_group_by = 5000000000, max_bytes_before_external_sort = 5000000000;
select  
   sum(ws_ext_discount_amt)  as "Excess Discount Amount" 
from 
    web_sales 
   ,item 
   ,date_dim
where
i_manufact_id = 714
and i_item_sk = ws_item_sk 
and d_date between '2000-02-01' and 
        (cast('2000-02-01' as date) + interval 90 day)
and d_date_sk = ws_sold_date_sk 
and ws_ext_discount_amt  
     > ( 
         SELECT 
            1.3 * avg(ws_ext_discount_amt) 
         FROM 
            web_sales 
           ,date_dim
         WHERE 
              ws_item_sk = i_item_sk 
          and d_date between '2000-02-01' and
                             (cast('2000-02-01' as date) + interval 90 day)
          and d_date_sk = ws_sold_date_sk 
      ) 
order by sum(ws_ext_discount_amt)
limit 100;
