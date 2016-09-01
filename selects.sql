\timing
SELECT * FROM account LIMIT 10;
SELECT state, count(account_number) FROM account GROUP BY state LIMIT 10;
