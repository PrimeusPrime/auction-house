# auction-house
    
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;The aim of following project was to get familiar with SQL language. Postgres SQL
language was chosen because of its popularity - Postgres community is growing and
documentation is easily accessible. The subject of creating auction-house not only gave 
an opportunity to learn SQL from scratch but also brought more complex tasks to solve.

Still, the code does not include some functionalities which are typical for such
systems since it was intended to be a small hobby-like project. On the other hand, It
contains some essential features like: 

* Tables with users, auctions and bid data
![uml diagram](https://raw.githubusercontent.com/PrimeusPrime/auction-house/image_container/uml%20diagram.png)
* Regular and premium auction creation which differ in activity time -
premium auction function allows the user to post the item for 14 days, instead of
regular time of 7 days for normal auctions. Regular auctions are free, unlike premium
ones which are charged depending on sales amount.
  
* Expanded biding function which includes multiple conditions preventing from,
 for instance, biding auctions by unregistered users, bidinig auctions with lower
 amount than current, biding inactive auctions. 
 
* Option of adding comments - available for each auction to enable its owner and its 
winner to comment after the auction is finished. 

* Total cash preview for auction-house owner, which calculates and presents income from
premium auctions.

The projects lacks in functionalities such as payment status, delivery options and status,
more category types and from technical point of view - transactions.

