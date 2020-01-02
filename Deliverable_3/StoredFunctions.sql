CREATE OR REPLACE FUNCTION refund(IN refund_cid INT, IN refund_pid INT, IN refund_pname VARCHAR(30), IN refund_bname VARCHAR(30), IN refund_quantity INT) 
RETURNS VARCHAR(30)
AS $$
DECLARE quan INT;
DECLARE msg TEXT;
BEGIN
	IF EXISTS (SELECT quantity FROM OrderItems WHERE pname = refund_pname AND bname = refund_bname AND pid = refund_pid)
	THEN
		SELECT quantity INTO quan FROM OrderItems WHERE pname = refund_pname AND bname = refund_bname AND pid = refund_pid;
		IF (quan = refund_quantity) 
		THEN
			DELETE FROM OrderItems WHERE pname = refund_pname AND bname = refund_bname AND pid = refund_pid;
			msg := 'Refund successfully';
		ELSE 
			UPDATE OrderItems SET quantity = quan - refund_quantity WHERE pname = refund_pname AND bname = refund_bname AND pid = refund_pid;
			msg := 'Refund successfully';
		END IF;
		-- insert a record into refund
		INSERT INTO Refund (cid, pid) VALUES (refund_cid, refund_pid);
	ELSE
		msg := 'No record of this item or this pid was found';
	END IF;
	RETURN msg;
END
$$ LANGUAGE plpgsql;







CREATE OR REPLACE FUNCTION submit_payment (IN input_cid INT) RETURNS TEXT
AS $$
DECLARE new_pid INT;
DECLARE all_items_quan INT;
DECLARE r_quan INT;
DECLARE r_pname VARCHAR(30);
DECLARE r_bname VARCHAR(30);
DECLARE p_price DECIMAL(7, 2);
DECLARE cur_stock INT;
DECLARE total_cost INT DEFAULT 0;
DECLARE payment_detail VARCHAR(1000) DEFAULT 'Ordered Items: ';
DECLARE cursor_cart CURSOR FOR 
	SELECT quantity, pname, bname FROM CartItems WHERE cid = input_cid;
BEGIN
	SELECT COUNT(*) INTO all_items_quan FROM CartItems WHERE cid = input_cid;
	IF (all_items_quan <= 0)
	THEN
		RETURN 'No item in cart for this customer';
	ELSE
		--create a new payment and get its id
		INSERT INTO Payments (cid) VALUES (input_cid) RETURNING pid INTO new_pid;
		--select all the item in cart
		OPEN cursor_cart;
		LOOP
			FETCH cursor_cart INTO r_quan, r_pname, r_bname;
			EXIT WHEN NOT FOUND;

			SELECT stock, price INTO cur_stock, p_price FROM ForSale WHERE pname = r_pname AND bname = r_bname; 
			INSERT INTO OrderItems (quantity, pname, bname, pid, cid) VALUES (r_quan, r_pname, r_bname, new_pid, input_cid);
			payment_detail := payment_detail || r_pname || ' ' || r_bname || ' * ' || r_quan || ', ';
			total_cost = total_cost + p_price;	--calculate total cost
			--delete entry
			DELETE FROM CartItems WHERE CURRENT OF cursor_cart;
		END LOOP;
		CLOSE cursor_cart;
		payment_detail := payment_detail || 'Total cost: ' || total_cost;
		--update the payment detail about what the customer bought and the cost
		UPDATE Payments SET orderDetail = payment_detail WHERE pid = new_pid;

		RETURN 'Success';
	END IF;
END
$$ LANGUAGE plpgsql;