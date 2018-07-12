DROP VIEW IF EXISTS users_winning_auctions;
DROP VIEW IF EXISTS turnover_per_category;
DROP VIEW IF EXISTS current_prices;

DROP TABLE IF EXISTS comments;
DROP TABLE IF EXISTS bid;
DROP TABLE IF EXISTS auction;
DROP TABLE IF EXISTS auction_user;
DROP TABLE IF EXISTS auction_category;
DROP TABLE IF EXISTS income;

CREATE TABLE income (
  income_id   SERIAL      PRIMARY KEY,
  income_type VARCHAR(40),
  total_cash  REAL        NOT NULL
);

CREATE TABLE auction_category (
  category_id   SERIAL      PRIMARY KEY,
  category_name VARCHAR(40) NOT NULL
);

CREATE TABLE auction_user (
  login         VARCHAR(20) PRIMARY KEY,
  email         VARCHAR(40) NOT NULL,
  user_password VARCHAR(40) NOT NULL
);

CREATE TABLE auction (
  auction_id      SERIAL             PRIMARY KEY,
  title           VARCHAR(40)        UNIQUE NOT NULL,
  description     TEXT               NOT NULL,
  auction_owner   VARCHAR(20)        NOT NULL REFERENCES auction_user (login),
  category_id     INTEGER            NOT NULL REFERENCES auction_category (category_id),
  adding_date     DATE,
  expiration_date DATE,
  is_active       BOOLEAN            NOT NULL,
  was_charged     BOOLEAN            NOT NULL
);

CREATE TABLE bid (
  bid_id     SERIAL      PRIMARY KEY,
  auction_id INTEGER     NOT NULL REFERENCES auction (auction_id),
  bid_price  REAL        NOT NULL,
  bidder     VARCHAR(20) NOT NULL REFERENCES auction_user (login)
);

CREATE TABLE comment (
  comment_id          SERIAL      PRIMARY KEY,
  auction_id          INTEGER     NOT NULL REFERENCES auction (auction_id),
  content_of_comment  TEXT        NOT NULL,
  comment_author      VARCHAR(20) NOT NULL REFERENCES auction_user (login),
  comment_adding_date TIMESTAMP
);

CREATE VIEW current_prices AS
	SELECT title, MAX(bid_price) AS max_price
		FROM auction
		LEFT JOIN bid b
				ON auction.auction_id = b.auction_id
		GROUP BY title;

CREATE VIEW users_winning_auctions AS
	SELECT login, email, a.title, bid_price
		FROM auction_user au
		LEFT JOIN bid b
				ON au.login = b.bidder
		LEFT JOIN auction a
				ON b.auction_id = a.auction_id
		LEFT JOIN  current_prices
				ON b.bid_price = current_prices.max_price
				AND a.title = current_prices.title
  	WHERE max_price IS NOT NULL OR a.title IS NULL;

CREATE VIEW turnover_per_category AS
	SELECT category_name, SUM(bid_price)
		FROM auction_category
		LEFT JOIN auction
			ON auction_category.category_id = auction.category_id
		LEFT JOIN  bid
			ON auction.auction_id = bid.auction_id
		LEFT JOIN  current_prices
			ON bid.bid_price = current_prices.max_price
			AND auction.title = current_prices.title
		WHERE max_price IS NOT NULL OR bid_price IS NULL
		GROUP BY category_name
		ORDER BY CASE WHEN SUM(bid_price) IS NULL THEN 1 ELSE 0 END, SUM(bid_price) DESC, category_name;
