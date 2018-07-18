INSERT INTO income (income_type, total_cash) VALUES
  ('premium_auctions', 0),
  ('commissions', 0);

INSERT INTO auction_category (category_name) VALUES
  ('cars'),
  ('bikes'),
  ('trucks');

INSERT INTO auction_user VALUES
  ('johndoe', 'johndoe@gmail.com', 'fish123'),
  ('emilysmith', 'emilysmith88@hotmail.com', 'cat678'),
  ('bobbydickson', 'bobbyd@gmail.com', 'Dog6340'),
  ('jamesmilroy', 'milroyjames@hotmail.com', 'cffgy6');

INSERT INTO auction (title, description, auction_owner, category_id, adding_date, expiration_date, is_active, was_charged)
values
  ('Audi A6', 'new model, 2017', 'johndoe', 1, (SELECT current_date), (SELECT current_date + 7), true, false),
  ('Yamaha R900', 'classic edition from 1980', 'emilysmith', 2, (SELECT current_date), (SELECT current_date + 7), true, false),
  ('Cat ct680', ' 8 set-forward-axle model built to tackle today’s most demanding jobs', 'jamesmilroy', 3, (SELECT current_date), (SELECT current_date + 7), true, false),
  ('Opel Insignia', 'model from 2014, 2.0 engine DIESEL', 'johndoe', 1, (SELECT current_date - 8), (SELECT current_date - 1), false, true);

INSERT INTO bid (auction_id, bid_price, bidder) VALUES
  (1, 20000, 'bobbydickson'),
  (1, 21000, 'jamesmilroy'),
  (1, 22000, 'bobbydickson'),
  (1, 23000, 'jamesmilroy'),
  (1, 24000, 'bobbydickson'),
  (1, 25000, 'jamesmilroy'),
  (1, 30000, 'bobbydickson'),
  (2, 10000, 'jamesmilroy'),
  (2, 12000, 'bobbydickson'),
  (2, 13000, 'jamesmilroy'),
  (4, 15000, 'bobbydickson'),
  (4, 15500, 'emilysmith'),
  (4, 17500, 'bobbydickson');

UPDATE income
SET total_cash = 500
WHERE income_type = 'commissions';

INSERT INTO comment (auction_id, content_of_comment, comment_author, comment_adding_date) VALUES
  (4,'good communication with seller, with the car itself everything is fine', 'bobbydickson', now()),
  (4,'smooth transaction, proper communication with buyer', 'jamesmilroy', now());