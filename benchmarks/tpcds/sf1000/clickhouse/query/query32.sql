SET max_execution_time=600;
-- SET partial_merge_join = 1, partial_merge_join_optimizations = 1, max_bytes_before_external_group_by = 5000000000, max_bytes_before_external_sort = 5000000000;
select  sum(cs_ext_discount_amt)  as "excess discount amount" 
from 
   catalog_sales 
   ,item 
   ,date_dim
where
i_manufact_id = 722
and i_item_sk = cs_item_sk 
and d_date between '2001-03-09' and 
        (cast('2001-03-09' as date) + interval 90 day)
and d_date_sk = cs_sold_date_sk 
and cs_ext_discount_amt  
     > ( 
         select 
            1.3 * avg(cs_ext_discount_amt) 
         from 
            catalog_sales 
           ,date_dim
         where 
              cs_item_sk = i_item_sk 
          and d_date between '2001-03-09' and
                             (cast('2001-03-09' as date) + interval 90 day)
          and d_date_sk = cs_sold_date_sk 
      ) 
limit 100;
