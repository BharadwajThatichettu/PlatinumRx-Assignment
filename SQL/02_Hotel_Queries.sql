-- Q1: Last booked room for every user

SELECT user_id, room_no 
FROM bookings 
WHERE (user_id, booking_date) IN (SELECT user_id, MAX(booking_date) FROM bookings GROUP BY user_id);

-- Q2: Booking ID and total billing amount for November 2021

SELECT b.booking_id, SUM(bc.item_quantity * i.item_rate) AS total_billing
FROM bookings b
JOIN booking_commercials bc ON b.booking_id = bc.booking_id
JOIN items i ON bc.item_id = i.item_id
WHERE bc.bill_date LIKE '2021-11%'
GROUP BY b.booking_id;

-- Q3: Bill ID and amount for October 2021 with amount > 1000

SELECT bill_id, SUM(item_quantity * item_rate) AS bill_amount
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
WHERE bc.bill_date LIKE '2021-10%'
GROUP BY bill_id
HAVING bill_amount > 1000;

-- Q4: Most and Least ordered item of each month in 2021

WITH MonthlyOrders AS (
    SELECT 
        strftime('%m', bill_date) AS month,
        item_id,
        SUM(item_quantity) AS total_qty,
        RANK() OVER(PARTITION BY strftime('%m', bill_date) ORDER BY SUM(item_quantity) DESC) as rank_desc,
        RANK() OVER(PARTITION BY strftime('%m', bill_date) ORDER BY SUM(item_quantity) ASC) as rank_asc
    FROM booking_commercials
    WHERE bill_date LIKE '2021%'
    GROUP BY month, item_id
)
SELECT month, item_id, total_qty,
       CASE WHEN rank_desc = 1 THEN 'Most Ordered' ELSE 'Least Ordered' END as status
FROM MonthlyOrders
WHERE rank_desc = 1 OR rank_asc = 1;

-- Q5: Customers with the 2nd highest bill value of each month in 2021

WITH MonthlyBills AS (
    SELECT 
        strftime('%m', bc.bill_date) as month,
        b.user_id,
        SUM(bc.item_quantity * i.item_rate) as total_bill,
        DENSE_RANK() OVER(PARTITION BY strftime('%m', bc.bill_date) ORDER BY SUM(bc.item_quantity * i.item_rate) DESC) as rnk
    FROM bookings b
    JOIN booking_commercials bc ON b.booking_id = bc.booking_id
    JOIN items i ON bc.item_id = i.item_id
    WHERE bc.bill_date LIKE '2021%'
    GROUP BY month, b.user_id
)
SELECT month, user_id, total_bill
FROM MonthlyBills
WHERE rnk = 2;
