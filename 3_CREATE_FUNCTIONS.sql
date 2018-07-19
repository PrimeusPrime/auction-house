DROP FUNCTION IF EXISTS get_sum_of_all_commissions ();
DROP FUNCTION IF EXISTS update_auction_status ();
DROP FUNCTION IF EXISTS get_commission_for_user (login VARCHAR(20));
DROP FUNCTION IF EXISTS add_comment (title VARCHAR(40), login VARCHAR(20), content_of_comment TEXT );
DROP FUNCTION IF EXISTS get_winner_by_auction_id (auction_id INTEGER);
DROP FUNCTION IF EXISTS get_login_by_auction_id (auction_id INTEGER);
DROP FUNCTION IF EXISTS bid_auction (bid REAL, login VARCHAR(20), title VARCHAR(40));
DROP FUNCTION IF EXISTS get_auction_id_by_title (title VARCHAR(40));
DROP FUNCTION IF EXISTS get_price_by_title (title VARCHAR(40));
DROP FUNCTION IF EXISTS get_auction_owner_by_title (title VARCHAR(40));
DROP FUNCTION IF EXISTS create_auction (title VARCHAR(40), description TEXT, auction_owner VARCHAR(20),
category_id INTEGER );
DROP FUNCTION IF EXISTS create_premium_auction (title VARCHAR(40), description TEXT, auction_owner VARCHAR(20),
category_id INTEGER );

CREATE FUNCTION create_premium_auction (title VARCHAR(40), description TEXT, auction_owner	VARCHAR (20), category_id  INTEGER)
	RETURNS VOID AS
	$$ INSERT INTO auction (title, description, auction_owner, category_id, adding_date, expiration_date, is_active) VALUES
		($1,$2,$3,$4,(SELECT current_date),(SELECT current_date + 14), true);

		UPDATE income
		SET total_cash = total_cash + 100
		WHERE income_type = 'premium_auctions';
	$$ LANGUAGE SQL;

CREATE FUNCTION create_auction (title VARCHAR(40), description TEXT, auction_owner	VARCHAR (20),
	category_id  INTEGER) RETURNS VOID AS
	$$ INSERT INTO auction (title, description, auction_owner, category_id, adding_date, expiration_date, is_active) VALUES
		($1,$2,$3,$4,(SELECT current_date),(SELECT current_date + 7), true);
	$$ LANGUAGE SQL;

CREATE FUNCTION get_auction_owner_by_title (title VARCHAR(40)) RETURNS VARCHAR(20) AS
	$$ SELECT auction_owner FROM auction WHERE title = $1;
	$$ LANGUAGE SQL;

CREATE FUNCTION get_price_by_title (title VARCHAR(40)) RETURNS REAL AS
	$$ SELECT MAX (bid_price) FROM auction
		JOIN bid ON auction.auction_id = bid.auction_id
		WHERE title = $1;
	$$ LANGUAGE SQL;

CREATE FUNCTION get_auction_id_by_title (title VARCHAR(40)) RETURNS INTEGER AS
	$$ SELECT auction_id
		FROM auction
		WHERE title = $1;
	$$ LANGUAGE SQL;

CREATE FUNCTION bid_auction (bid REAL, login VARCHAR(20), title VARCHAR (40)) RETURNS VOID AS
	$$ BEGIN

		IF get_auction_owner_by_title ($3) = $2 THEN
			RAISE NOTICE 'you cannot bid your own auction';
			RETURN;
		END IF;

		IF NOT (SELECT exists(SELECT 1 FROM auction_user WHERE login = $2)) THEN
			RAISE NOTICE 'user does not exist or wrong login';
			RETURN;
		END IF;

		IF NOT (SELECT exists(SELECT 1 FROM auction WHERE title = $3)) THEN
			RAISE NOTICE 'auction does not exist or wrong title';
			RETURN;
		END IF;

		IF NOT (SELECT is_active FROM auction WHERE title=$3) THEN
			RAISE NOTICE 'you cannot bid inactive auction';
			RETURN;
		END IF;

		IF $1 <= 0 THEN
			RAISE NOTICE 'bid must be greater than zero';
			RETURN;
		END IF;

		IF get_price_by_title ($3) IS NULL THEN
			INSERT INTO bid (bid_price, bidder, auction_id) VALUES ($1, $2, (SELECT get_auction_id_by_title($3)));
			RAISE NOTICE 'bade successfully auction of % with % PLN', $3, $1;
			RETURN;
		END IF;

		IF $1 > (SELECT get_price_by_title ($3)) THEN
			INSERT INTO bid (bid_price, bidder, auction_id) VALUES ($1, $2, (SELECT get_auction_id_by_title($3)));
			RAISE NOTICE 'bade successfully auction of % with % PLN', $3, $1;
			RETURN;
		END IF;

		RAISE NOTICE '% PLN for % is too low', $1, $3;

		END;
	$$ LANGUAGE plpgsql;

CREATE FUNCTION get_login_by_auction_id (auction_id INTEGER) RETURNS VARCHAR(20) AS
	$$ SELECT auction_owner
		FROM auction
		WHERE auction_id = $1;
	$$ LANGUAGE SQL;

CREATE FUNCTION get_winner_by_auction_id (auction_id INTEGER) RETURNS VARCHAR(20) AS
	$$ SELECT bidder FROM bid
		WHERE auction_id = $1
		ORDER BY bid_price DESC
		LIMIT 1;
	$$ LANGUAGE SQL;

CREATE FUNCTION add_comment (title VARCHAR(40), login VARCHAR (20), content_of_comment text) RETURNS VOID AS
	$$ BEGIN
	  IF (SELECT is_active FROM auction WHERE auction.title=$1) THEN
		  RAISE Notice 'you can comment only expired auctions';
		  RETURN;
	  END IF;

	  IF NOT $2 IN (get_login_by_auction_id(get_auction_id_by_title($1)),get_bidder_by_auction_id(get_auction_id_by_title($1))) THEN
		  RAISE NOTICE 'Only auction owners and current winners can add comments';
		  RETURN;
	  END IF;

	    INSERT INTO comment (auction_id, content_of_comment, comment_author, comment_adding_date) VALUES (get_auction_id_by_title($1),$3,$2,now());
      RAISE NOTICE 'comment in auction of % added successfully',$1;

    END;
  $$ LANGUAGE PLPGSQL;

CREATE FUNCTION get_commission_for_user (login varchar(20)) RETURNS TABLE (title VARCHAR(40),maxi DOUBLE PRECISION, comission DOUBLE PRECISION) AS
  $$ SELECT title,
	  max(bid_price) AS maxi,
	  CASE 	WHEN max(bid_price) IS NULL THEN 0
				  WHEN max(bid_price)<=1000 THEN 0
				  WHEN max(bid_price)<=10000 THEN 0.02*max(bid_price)
				  ELSE 0.04*(max(bid_price)-10000)+200
	  END AS commission
	  FROM auction
	  LEFT JOIN bid ON auction.auction_id = bid.auction_id
	  WHERE auction_owner = $1
	  GROUP BY title

    UNION ALL

    SELECT 'avg|sum' AS title, avg(maxi) AS maxi, SUM(commission) AS comission FROM (SELECT title,
	    max(bid_price) AS maxi,
	    CASE 	WHEN max(bid_price) IS NULL THEN 0
				    WHEN max(bid_price)<=1000 THEN 0
				    WHEN max(bid_price)<=10000 THEN 0.02*max(bid_price)
				    ELSE 0.04*(max(bid_price)-10000)+200
	    END AS commission
	      FROM auction
	      LEFT JOIN bid ON auction.auction_id = bid.auction_id
	      WHERE auction_owner = $1
	    GROUP BY title) AS nested;
  $$ LANGUAGE SQL;

CREATE FUNCTION get_sum_of_all_commissions() RETURNS DOUBLE PRECISION AS
  $$ SELECT sum(commission)
    FROM (SELECT
			CASE
					WHEN max(bid_price) IS NULL THEN 0
					WHEN max(bid_price)<=1000 THEN 0
					WHEN max(bid_price)<=10000 THEN 0.02*max(bid_price)
					ELSE 0.04*(max(bid_price)-10000)+200
	 		END AS commission
	  FROM auction
	  LEFT JOIN bid ON auction.auction_id = bid.auction_id
	  WHERE is_active IS FALSE
	  AND was_charged IS FALSE
	  GROUP BY title) AS nested;
  $$ LANGUAGE SQL;

CREATE FUNCTION update_auction_status () RETURNS VOID AS
	$$ BEGIN
	  UPDATE auction
	  SET is_active = FALSE
	  WHERE expiration_date < (SELECT current_date);

	  UPDATE income
	  SET total_cash = total_cash + (SELECT get_sum_of_all_commissions())
    WHERE income_type = 'commissions';

	  UPDATE auction
	  SET was_charged = FALSE
	  WHERE expiration_date < (SELECT current_date);

	  RAISE NOTICE 'auction status updated successfully';
    END
	$$ LANGUAGE PLPGSQL;
