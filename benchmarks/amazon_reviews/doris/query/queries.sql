-- Amazon Reviews Benchmark: Baseline (No Inverted Index)
-- These queries run against the table WITHOUT inverted indexes
-- Schema: https://www.velodb.io/blog/inverted-index-it-speeds-up-text

-- Q1: Count total reviews
SELECT COUNT(*) FROM amazon_reviews;

-- Q2: Platform-wide analytics - aggregation by category (traditional OLAP)
-- review_date is epoch days: 16071 = 2014-01-01
SELECT product_category, AVG(star_rating) as avg_rating, COUNT(*) as reviews FROM amazon_reviews WHERE review_date >= 16071 GROUP BY product_category ORDER BY reviews DESC LIMIT 10;

-- Q3: Customer history lookup - high-cardinality point query (FULL SCAN)
SELECT product_category, COUNT(*) as reviews, AVG(star_rating) as avg_rating, SUM(helpful_votes) as total_helpful FROM amazon_reviews WHERE customer_id = 53096570 GROUP BY product_category ORDER BY reviews DESC;

-- Q4: Product review analysis - high-cardinality point query (FULL SCAN)
SELECT star_rating, COUNT(*) as count, AVG(helpful_votes) as avg_helpful FROM amazon_reviews WHERE product_id = 'B00BGGDVOO' GROUP BY star_rating ORDER BY star_rating DESC;

-- Q5: Review lookup by ID - unique identifier lookup (FULL SCAN)
SELECT * FROM amazon_reviews WHERE review_id = 'R1NQ5RXN1LZ0YW';

-- Q6: Range query on ratings - find high-rated reviews (FULL SCAN)
SELECT product_category, COUNT(*) as reviews, AVG(helpful_votes) as avg_helpful FROM amazon_reviews WHERE star_rating >= 4 AND helpful_votes >= 50 AND review_date >= 16071 GROUP BY product_category ORDER BY avg_helpful DESC LIMIT 10;

-- Q7: Multi-dimensional filter - customer + rating range (FULL SCAN)
SELECT product_category, product_title, star_rating, helpful_votes, review_headline FROM amazon_reviews WHERE customer_id = 16378095 AND star_rating <= 2 AND helpful_votes >= 10 ORDER BY helpful_votes DESC LIMIT 20;

-- Q8: Category + product filter (sort key partially helps for category)
SELECT star_rating, COUNT(*) as count FROM amazon_reviews WHERE product_category = 'Digital_Video_Games' AND product_id = 'B00BGGDVOO' GROUP BY star_rating;

-- Q9: Full-text search with MATCH_ALL (AND logic) - battery life issues
SELECT product_id, product_title, star_rating, review_headline, LEFT(review_body, 200) as review_snippet FROM amazon_reviews WHERE review_body MATCH_ALL 'battery life poor' AND product_category = 'Electronics' ORDER BY star_rating ASC LIMIT 20;

-- Q10: Full-text search with MATCH_ANY (OR logic) - noise cancellation
SELECT product_id, product_title, star_rating, review_headline, LEFT(review_body, 200) as review_snippet FROM amazon_reviews WHERE review_body MATCH_ANY 'noise cancellation' AND product_category = 'Electronics' ORDER BY helpful_votes DESC LIMIT 20;

-- Q11: Combined text search with rating filter
SELECT product_id, product_title, star_rating, review_headline FROM amazon_reviews WHERE review_body MATCH_ALL 'great quality' AND star_rating >= 4 AND product_category = 'Electronics' ORDER BY helpful_votes DESC LIMIT 20;

-- Q12: Search in review headline
SELECT product_id, product_title, star_rating, review_headline, helpful_votes FROM amazon_reviews WHERE review_headline MATCH_ANY 'excellent amazing' AND star_rating = 5 ORDER BY helpful_votes DESC LIMIT 20;

-- Q13: Multi-field text search - headline and body
SELECT product_id, product_title, star_rating, review_headline FROM amazon_reviews WHERE (review_headline MATCH_ANY 'disappointing' OR review_body MATCH_ALL 'waste money') AND star_rating <= 2 ORDER BY helpful_votes DESC LIMIT 20;

-- Q14: Customer reviews with text filter
SELECT product_category, product_title, star_rating, review_headline FROM amazon_reviews WHERE customer_id = 16378095 AND review_body MATCH_ANY 'recommend' ORDER BY review_date DESC LIMIT 10;

-- Q15: Product reviews with specific complaint pattern
SELECT review_id, star_rating, review_headline, helpful_votes, LEFT(review_body, 300) as review_snippet FROM amazon_reviews WHERE product_id = 'B00BGGDVOO' AND review_body MATCH_ALL 'stopped working' ORDER BY helpful_votes DESC LIMIT 10;

-- Q16: Category-wide sentiment search
SELECT product_id, product_title, COUNT(*) as negative_reviews, AVG(star_rating) as avg_rating FROM amazon_reviews WHERE product_category = 'Electronics' AND review_body MATCH_ALL 'defective broken' AND star_rating <= 2 GROUP BY product_id, product_title ORDER BY negative_reviews DESC LIMIT 20;
