import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Scanner;

@SuppressWarnings({"SqlNoDataSourceInspection", "Duplicates", "ConstantConditions", "EmptyCatchBlock"})
public class SephoraApplication {
    private static String url ="jdbc:postgresql://comp421.cs.mcgill.ca:5432/cs421";
    private static String usernamestring = "cs421g06";
    private static String passwordstring = "GLLZ6cs421";
    private static Scanner sc = new Scanner(System.in);

    private static boolean notDone = true;
    private static int cid;


    public static void main(String[] args){
        try {
            Class.forName("org.postgresql.Driver");
        } catch (Exception cnfe){
            System.out.println("Class not found");
        }
        int type = login();
        while(notDone){
            switch(type){
                //case 1 means this is the admin's domain
                case 1:
                    System.out.println("Dear Administrator, welcome back to our system, please select the option you want to make:");
                    System.out.println("1 - Search customer's information");
                    System.out.println("2 - Change stock");
                    System.out.println("3 - Operate the cart items");
                    System.out.println("0 - Quit the application");
                    System.out.println("Please type the number of the option :");
                    int operation = -1;
                    boolean loops = true;
                    while(loops){
                        try{
                            operation = Integer.parseInt(sc.nextLine());
                            if(operation >= 0 && operation <= 3) loops = false;
                            else System.out.println("Please enter a valid option");
                        }catch(IllegalArgumentException e){
                            System.out.println("Please enter a valid option");
                        }
                    }

                    switch(operation) {
                        case 0:
                            System.out.println(" Have a nice day :) ");
                            notDone = false;
                            break;
                        case 1:
                            listCustomers();
                            break;
                        case 2:
                            changeStock();
                            break;
                        case 3:
                            deleteFromCartitem();
                            break;
                    }
                    break;
                //case 2 means this is the customer's domain
                case 2:
                    System.out.println("---------- Sephora ----------");
                    System.out.println("1 - Search Product");
                    System.out.println("2 - Most popular Product");
                    System.out.println("3 - Ordered Items");
                    System.out.println("4 - Cart Items");
                    System.out.println("5 - Rate");
                    System.out.println("6 - Submit Payment");
                    System.out.println("0 - Quit the application");
                    System.out.println("Please type the number of the option :");

                    int op = -1;
                    boolean loop = true;
                    while(loop){
                        try{
                            op = Integer.parseInt(sc.nextLine());
                            if(op >= 0 && op <= 6) loop = false;
                            else System.out.println("Please enter a valid option");
                        }catch(IllegalArgumentException e){
                            System.out.println("Please enter a valid option");
                        }
                    }

                    switch(op) {
                        case 0:
                            System.out.println("Have a nice day :) ");
                            notDone = false;
                            break;
                        case 1:
                            search();
                            break;
                        case 2:
                            bestProduct();
                            break;
                        case 3:
                            orderedItems();
                            break;
                        case 4:
                            cartItems();
                            break;
                        case 5:
                            rate();
                            break;
                        case 6:
                            submitPayment();
                            break;
                    }
                    break;
            }
        }


        System.out.println("Thank you for using our online system!");
    }



    /*login function that let the user to log into their account and
     * return 1 if he/she is a Administrator
     * return 2 if he/she is a Customer*/
    public static int login(){
        final String password = "GLLZ";
        int returntype = 0;
        System.out.println("--------Welcome to Sephora Online System--------");
        System.out.println("Please select your role:");
        System.out.println("1 - Administrator");
        System.out.println("2 - Customer");
        int role = sc.nextInt();
        String garbage = sc.nextLine();
        Connection con = null;
        Statement statement = null;
        ResultSet rs = null;
        try{
            switch(role){
                //For the role as Administrator we have to let them enter the password
                case 1:
                    boolean result = false;
                    while(!result){
                        System.out.println("Please enter the Administrator Password: ");
                        String enterpassword = sc.nextLine();
                        if(enterpassword.equals(password)){
                            System.out.println("You successfully logged in!");
                            result = true;
                        }
                        else{
                            System.out.println("You entered the wrong password. And please do again!");
                        }
                    }
                    returntype = 1;
                    break;
                //For the role as Customer we have to search whether the customer exists in our database or not
                case 2:
                    boolean validcustomer = false;
                    while(!validcustomer){
                        System.out.println("Please enter your user email: ");
                        String useremail = sc.nextLine();
                        con = DriverManager.getConnection (url,usernamestring, passwordstring);
                        statement = con.createStatement() ;
                        rs = statement.executeQuery("SELECT * FROM customers WHERE email LIKE '" + useremail + "';");
                        //if rs.next() is true means we have more than one row then we got a valid user
                        if(rs.next()){
                            cid = Integer.parseInt(rs.getString(1));
                            System.out.println("You successfully logged in!");
                            validcustomer = true;
                        }
                        //else the user entered email is not true
                        else{
                            System.out.println("Your user email does not exist please try again.");
                        }
                    }
                    returntype = 2;
                    break;
            }
        }
        catch (SQLException e){
            System.err.println("msg: " + e.getMessage() +
                    "code: " + e.getErrorCode() +
                    "state: " + e.getSQLState());
        }finally{
            try{ rs.close();} catch (Exception e) {/*ignored*/}
            try{ statement.close();} catch (Exception e) {/*ignored*/}
            try{ con.close();} catch (Exception e){/*ignored*/}
        }
        return returntype;
    }

    /******************************************************************************************
     *                                  ADMIN FUNCTIONS                                       *
     ******************************************************************************************


     /*List customer function that we just list the full information of one customer the Administrator want to access*/
    public static void listCustomers(){
        System.out.println("Please select the options you want to search: ");
        System.out.println("1 - By Full Name.");
        System.out.println("2 - By First Name.");
        System.out.println("3 - By Last Name.");
        int option = sc.nextInt();
        String garbage = sc.nextLine();
        String name ="";
        Connection con = null;
        Statement statement = null;
        ResultSet rs = null;
        try{
            switch(option){
                case 1:
                    boolean result = false;
                    while(!result){
                        System.out.println("Please enter the full name of user:");
                        name = sc.nextLine();
                        con = DriverManager.getConnection (url,usernamestring, passwordstring);
                        statement = con.createStatement ( ) ;
                        rs = statement.executeQuery("SELECT * FROM customers WHERE fullname LIKE '" + name + "';");
                        if(rs.next()){
                            result = true;
                            break;
                        }
                        else{
                            System.out.println("The user name you entered is not valid, please try again.");
                        }
                    }
                    break;
                case 2:
                    boolean seresult = false;
                    while(!seresult){
                        System.out.println("Please enter the first name of user:");
                        name = sc.nextLine();
                        con = DriverManager.getConnection (url,usernamestring, passwordstring);
                        statement = con.createStatement ( ) ;
                        rs = statement.executeQuery("SELECT * FROM customers WHERE fullname LIKE '" + name + "%';");
                        if(rs.next()){
                            seresult = true;
                            break;
                        }
                        else{
                            System.out.println("The user name you entered is not valid, please try again.");
                        }
                    }
                    break;
                case 3:
                    boolean thresult = false;
                    while(!thresult){
                        System.out.println("Please enter the last name of user:");
                        name = sc.nextLine();
                        con = DriverManager.getConnection (url,usernamestring, passwordstring);
                        statement = con.createStatement ( ) ;
                        rs = statement.executeQuery("SELECT * FROM customers WHERE fullname LIKE '%" + name + "';");
                        if(rs.next()){
                            thresult = true;
                            break;
                        }
                        else{
                            System.out.println("The user name you entered is not valid, please try again.");
                        }
                    }
                    break;
            }
            System.out.println("Here is the information you want to find from this name:");
            System.out.println(String.format("%s %-10s %-30s %-20s %s","","cid","email","birthday","fullname"));
            System.out.println("------------------------------------------------------------------------------");
            System.out.println(String.format("%s %-10s %-30s %-20s %s","",rs.getString("cid"),rs.getString("email"),rs.getString("birthday"),rs.getString("fullname")));
            System.out.println();
        }
        catch (SQLException e){
            System.err.println("msg: " + e.getMessage() +
                    "code: " + e.getErrorCode() +
                    "state: " + e.getSQLState());
        }finally{
            try{ rs.close();} catch (Exception e) {/*ignored*/}
            try{ statement.close();} catch (Exception e) {/*ignored*/}
            try{ con.close();} catch (Exception e){/*ignored*/}
        }
    }


    /*changeStock function that first list to the Administrator all the stock information then ask the Administrator
     * which specific item that he/she want to change the stock and then update the information*/
    public static void changeStock(){
        Connection con = null;
        Statement statement = null;
        ResultSet rs = null;
        try{
            //First print all the information about the stock
            System.out.println("Here is all the details about out of stock products:");
            con = DriverManager.getConnection (url,usernamestring, passwordstring);
            statement = con.createStatement ( ) ;
            rs = statement.executeQuery("SELECT orderqty.pname, ordered_qty, stock FROM (SELECT pname, SUM(quantity) as ordered_qty FROM orderitems GROUP BY pname)as orderqty INNER JOIN forsale ON orderqty.pname = forsale.pname WHERE ordered_qty > stock;");
            System.out.println(String.format("%s %-40s %-20s %s","","pname","ordered quantity","stock"));
            System.out.println("---------------------------------------------------------------------");
            while(rs.next()){
                System.out.println(String.format("%s %-40s %-20s %s","",rs.getString("pname"),rs.getString("ordered_qty"),rs.getString("stock")));
            }
            //Then ask the customer the operation and then change the stock accordingly
            System.out.println("Please enter the name of the product that you want to change stock:");
            String pname = sc.nextLine();
            System.out.println("Please enter the option that you want to do with the stock:");
            System.out.println("1 - Increase");
            System.out.println("2 - Decrease");
            int operation = sc.nextInt();
            String gar = sc.nextLine();
            System.out.println("Please enter the quantity you want to change with the stock:");
            String quantity = sc.nextLine();
            switch(operation){
                case 1:
                    statement.executeUpdate("UPDATE forsale SET stock = stock +" + quantity  + "WHERE forsale.pname = '" +pname + "';");
                    break;
                case 2:
                    statement.executeUpdate("UPDATE forsale SET stock = stock -" + quantity + "WHERE forsale.pname = '"+ pname +"';");
                    break;
            }
        }
        catch (SQLException e){
            System.err.println("msg: " + e.getMessage() +
                    "code: " + e.getErrorCode() +
                    "state: " + e.getSQLState());
        }finally{
            try{ rs.close();} catch (Exception e) {/*ignored*/}
            try{ statement.close();} catch (Exception e) {/*ignored*/}
            try{ con.close();} catch (Exception e){/*ignored*/}
        }
        System.out.println("You successfully changed stock!");
    }


    /*Delete from the cartitem after the customer checks out*/
    public static void deleteFromCartitem(){
        Connection con = null;
        Statement statement = null;
        ResultSet rs = null;
        try{
            con = DriverManager.getConnection (url,usernamestring, passwordstring);
            statement = con.createStatement ( ) ;
            statement.executeUpdate("DELETE FROM CartItems WHERE cid IN ( SELECT c.cid FROM customers c, payments p WHERE c.cid = p.cid);");
        }
        catch (SQLException e){
            System.err.println("msg: " + e.getMessage() +
                    "code: " + e.getErrorCode() +
                    "state: " + e.getSQLState());
        }finally{
            try{ rs.close();} catch (Exception e) {/*ignored*/}
            try{ statement.close();} catch (Exception e) {/*ignored*/}
            try{ con.close();} catch (Exception e){/*ignored*/}
        }
        System.out.println("You successfully delete all entries from cartitem after customer checks out!");
    }




    /******************************************************************************************
     *                                  CLIENT FUNCTIONS                                      *
     ******************************************************************************************/

    //search product info
    private static void search(){
        Connection con = null;
        Statement statement = null;
        ResultSet rs = null;

        boolean loop = true;
        int op = -1;
        String searchString = null;

        System.out.println("Search by: ");
        System.out.println("1. Brand");
        System.out.println("2. Category");
        System.out.println("3. Product name");

        while(loop){
            try{
                op = Integer.parseInt(sc.nextLine());
                if(op >= 1 && op <= 3) loop = false;
            }catch(Exception e){
                System.out.println("Please enter a valid number within [1,3]");
            }
        }

        try{
            con = DriverManager.getConnection(url,usernamestring,passwordstring);
            statement = con.createStatement();

            switch(op){
                case 1:
                    System.out.println("Enter Brand name");
                    searchString = sc.nextLine();
                    rs = statement.executeQuery("SELECT pname, category, bname FROM products\n" +
                            "WHERE bname LIKE '%" + searchString + "%';");
                    break;
                case 2:
                    System.out.println("Enter Category name");
                    searchString = sc.nextLine();
                    rs = statement.executeQuery("SELECT pname, category,bname FROM products\n" +
                            "WHERE category LIKE '%" + searchString + "%';");
                    break;
                case 3:
                    System.out.println("Enter Product name");
                    searchString = sc.nextLine();
                    rs = statement.executeQuery("SELECT pname, category, bname FROM products\n" +
                            "WHERE pname LIKE '%" + searchString + "%';");
                    break;
            }

            System.out.print("\n");
            System.out.print("-----------------------------------------------------------------------");
            System.out.print("\n");
            System.out.println(String.format("%s %-40s %-20s %s","","Product","Category","Brand"));
            System.out.println("-----------------------------------------------------------------------");

            while(rs.next()){
                System.out.println(String.format("%s %-40s %-20s %s","",rs.getString("pname"),rs.getString("category"),rs.getString("bname")));
            }
            System.out.print("\n");

        }catch(SQLException e){
            System.err.println("msg: " + e.getMessage() +
                    "code: " + e.getErrorCode() +
                    "state: " + e.getSQLState());
        }catch(IllegalArgumentException e){
            e.printStackTrace();
        }finally{
            try { rs.close(); } catch (Exception e) { /* ignored */ }
            try { statement.close(); } catch (Exception e) { /* ignored */ }
            try { con.close(); } catch (Exception e) { /* ignored */ }
        }
    }

    /*
      1. create a payment with id for this customer
      2. add all product bought by him in cart into orderItems associate with new payment id
      3. generate details in payment id (item bought, quantity, and total cost)
      4. remove product from cartItems
      5. if no cart items, then cannot submit payment
    */
    private static void submitPayment(){
        Connection con = null;
        Statement statement = null;
        ResultSet rs = null;

        try{
            con = DriverManager.getConnection(url,usernamestring,passwordstring);
            statement = con.createStatement();

            statement.executeUpdate("CREATE OR REPLACE FUNCTION submit_payment (IN input_cid INT) RETURNS TEXT\n" +
                    "AS $$\n" +
                    "DECLARE new_pid INT;\n" +
                    "DECLARE all_items_quan INT;\n" +
                    "DECLARE r_quan INT;\n" +
                    "DECLARE r_pname VARCHAR(30);\n" +
                    "DECLARE r_bname VARCHAR(30);\n" +
                    "DECLARE p_price DECIMAL(7, 2);\n" +
                    "DECLARE cur_stock INT;\n" +
                    "DECLARE total_cost INT DEFAULT 0;\n" +
                    "DECLARE payment_detail VARCHAR(1000) DEFAULT 'Ordered Items: ';\n" +
                    "DECLARE cursor_cart CURSOR FOR \n" +
                    "\tSELECT quantity, pname, bname FROM CartItems WHERE cid = input_cid;\n" +
                    "BEGIN\n" +
                    "\tSELECT COUNT(*) INTO all_items_quan FROM CartItems WHERE cid = input_cid;\n" +
                    "\tIF (all_items_quan <= 0)\n" +
                    "\tTHEN\n" +
                    "\t\tRETURN 'No item in cart for this customer';\n" +
                    "\tELSE\n" +
                    "\t\t--create a new payment and get its id\n" +
                    "\t\tINSERT INTO Payments (cid) VALUES (input_cid) RETURNING pid INTO new_pid;\n" +
                    "\t\t--select all the item in cart\n" +
                    "\t\tOPEN cursor_cart;\n" +
                    "\t\tLOOP\n" +
                    "\t\t\tFETCH cursor_cart INTO r_quan, r_pname, r_bname;\n" +
                    "\t\t\tEXIT WHEN NOT FOUND;\n" +
                    "\n" +
                    "\t\t\tSELECT stock, price INTO cur_stock, p_price FROM ForSale WHERE pname = r_pname AND bname = r_bname; \n" +
                    "\t\t\tINSERT INTO OrderItems (quantity, pname, bname, pid, cid) VALUES (r_quan, r_pname, r_bname, new_pid, input_cid);\n" +
                    "\t\t\tpayment_detail := payment_detail || r_pname || ' ' || r_bname || ' * ' || r_quan || ', ';\n" +
                    "\t\t\ttotal_cost = total_cost + p_price;\t--calculate total cost\n" +
                    "\t\t\t--delete entry\n" +
                    "\t\t\tDELETE FROM CartItems WHERE CURRENT OF cursor_cart;\n" +
                    "\t\tEND LOOP;\n" +
                    "\t\tCLOSE cursor_cart;\n" +
                    "\t\tpayment_detail := payment_detail || 'Total cost: ' || total_cost;\n" +
                    "\t\t--update the payment detail about what the customer bought and the cost\n" +
                    "\t\tUPDATE Payments SET orderDetail = payment_detail WHERE pid = new_pid;\n" +
                    "\n" +
                    "\t\tRETURN 'Success';\n" +
                    "\tEND IF;\n" +
                    "END\n" +
                    "$$ LANGUAGE plpgsql;");
            rs = statement.executeQuery("SELECT submit_payment(" + cid + ");");
            System.out.println("All your cart items have now been paid");
        }catch(SQLException e){
            System.err.println("msg: " + e.getMessage() +
                    "code: " + e.getErrorCode() +
                    "state: " + e.getSQLState());
        }catch(IllegalArgumentException e){
            e.printStackTrace();
        }finally{
            try { rs.close(); } catch (Exception e) { /* ignored */ }
            try { statement.close(); } catch (Exception e) { /* ignored */ }
            try { con.close(); } catch (Exception e) { /* ignored */ }
        }

    }

    //1. list all cart items they ordered
    //2. update table to delete/add if they want
    private static void cartItems(){
        Connection con = null;
        Statement statement = null;
        ResultSet rs = null;
        boolean loop;
        String pname, bname;
        int qty;
        boolean notDone = true;

        try{
            con = DriverManager.getConnection(url,usernamestring,passwordstring);
            statement = con.createStatement();

            int op = -1;
            while(notDone){
                System.out.println("1. View cart");
                System.out.println("2. Add to cart");
                System.out.println("3. Delete from cart");
                System.out.println("4. Return to Main menu");

                loop = true;
                while(loop){
                    try{
                        op = Integer.parseInt(sc.nextLine());
                        if(op >= 1 && op <= 4) {
                            loop = false;
                        }else{
                            System.out.println("Please enter a valid number within [1,4]");
                        }
                    }catch(Exception e){
                        System.out.println("Please enter a valid number within [1,4]");
                    }
                }
                if(op == 4) notDone = false;

                switch(op){
                    case 1:
                        rs = statement.executeQuery("SELECT item_id,pname,bname,quantity\n" +
                                "FROM CartItems\n" +
                                "WHERE cid = " + cid + "\n" +
                                "ORDER BY quantity;");

                        System.out.print("\n");
                        System.out.print("----------------------------------------------------------------------");
                        System.out.print("\n");
                        System.out.println(String.format("%s %-10s %-30s %-20s %s","","Item ID","Product","Brand","Qty"));
                        System.out.println("----------------------------------------------------------------------");

                        while(rs.next()){
                            System.out.println(String.format("%s %-10s %-30s %-20s %s","",rs.getString("item_id"),rs.getString("pname"),
                                    rs.getString("bname"),rs.getString("quantity")));
                        }
                        System.out.print("\n");
                        break;

                    case 2:
                        System.out.print("Enter the product: ");
                        pname = sc.nextLine();
                        System.out.print("Enter the Brand: ");
                        bname = sc.nextLine();
                        System.out.print("Enter the quantity: ");
                        qty = Integer.parseInt(sc.nextLine());
                        if(qty <= 0){
                            System.out.println("Qty cannot be less than 0");
                            return;
                        }

                        rs = statement.executeQuery("select item_id\n" +
                                "from cartitems\n" +
                                "where pname = '" + pname + "' \n" +
                                "  AND bname = '" + bname + "' \n" +
                                "  AND cid = " + cid + ";");
                        if(rs.next()){
                            String id = rs.getString("item_id");
                            statement.executeUpdate("update cartitems set quantity = quantity + "+ qty + " where item_id = " + id + ";");
                        }else{
                            rs = statement.executeQuery("SELECT * FROM ForSale WHERE pname = '" + pname + "' AND bname = '" + bname + "';");
                            if(rs.next()){
                                statement.executeUpdate("INSERT INTO CartItems (quantity, pname, bname, cid) VALUES (" +
                                        qty + ",'" + pname + "','" + bname + "'," + cid + ");");
                            }else{
                                System.out.println("No such product exists");
                            }
                        }
                        System.out.println("");
                        break;

                    case 3:
                        System.out.print("Enter the Item ID: ");
                        int id = Integer.parseInt(sc.nextLine());
                        System.out.print("Enter the qty to delete: ");
                        qty = Integer.parseInt(sc.nextLine());
                        int curQty = -1;

                        rs = statement.executeQuery("select quantity\n" +
                                "from cartitems \n" +
                                "where item_id = " + id + ";");

                        if(rs.next()){
                            curQty = rs.getInt("quantity");
                        }
                        if(qty > curQty){
                            System.out.println("cannot delete more than the current qty");
                            return;
                        }
                        else if (curQty > qty){
                            statement.executeUpdate("Update cartitems\n" +
                                    "set quantity = quantity - " + qty + "\n" +
                                    "where item_id = "+ id + ";");
                        }
                        else if (curQty == qty){
                            statement.executeUpdate("DELETE FROM cartitems\n" +
                                    "WHERE item_id = " + id + ";");
                        }else{
                            System.out.println("Something went wrong");
                            return;
                        }
                        System.out.println("");
                        break;
                }
            }
        }catch(SQLException e){
            System.err.println("msg: " + e.getMessage() +
                    "code: " + e.getErrorCode() +
                    "state: " + e.getSQLState());
        }finally{
            try { rs.close(); } catch (Exception e) { /* ignored */ }
            try { statement.close(); } catch (Exception e) { /* ignored */ }
            try { con.close(); } catch (Exception e) { /* ignored */ }
        }
    }


    //provide rating for a product
    //or view your ratings
    private static void rate(){
        Connection con = null;
        Statement statement = null;
        ResultSet rs = null;
        boolean loop;
        String pname, bname;
        String comment;

        int op = -1;
        System.out.println("1. Add Rating");
        System.out.println("2. View My Ratings");

        loop = true;
        while(loop){
            try{
                op = Integer.parseInt(sc.nextLine());
                if(op == 1 || op == 2) {
                    loop = false;
                }else{
                    System.out.println("Please enter a valid number within [1,2]");
                }
            }catch(Exception e){
                System.out.println("Please enter a valid number within [1,2]");
            }
        }

        try {
            con = DriverManager.getConnection(url, usernamestring, passwordstring);
            statement = con.createStatement();

            switch(op){
                case 1:
                    System.out.print("Enter the Product: ");
                    pname = sc.nextLine();
                    System.out.print("Enter the Brand: ");
                    bname = sc.nextLine();
                    System.out.print("Enter your rating: ");
                    int rate = Integer.parseInt(sc.nextLine());
                    if(rate < 0 || rate > 5){
                        System.out.println("Rating must be integer and cannot be less than 0 or greater than 5");
                        return;
                    }
                    System.out.print("Enter your comment: ");
                    comment = sc.nextLine();

                    statement.executeUpdate("insert into rate (pname,bname,cid,rating,rate_comment) values('" +
                            pname + "', '" + bname + "' , " + cid + ", " + rate + ", '"+ comment + "');");

                    //update new overall rating in Forsale
                    statement.executeUpdate("UPDATE ForSale\n" +
                            "SET overallRating = r.average\n" +
                            "FROM (SELECT pname, bname, AVG(rating) AS average FROM Rate GROUP BY (pname, bname)) AS r\n" +
                            "WHERE ForSale.pname = '" + pname + "' AND ForSale.bname = '" + bname + "';");
                    break;
                case 2:
                    rs = statement.executeQuery("select pname,bname,rating as rate, rate_comment as comment from rate\n" +
                            "where cid = " + cid + ";");

                    System.out.print("\n");
                    System.out.print("-----------------------------------------------------------------------");
                    System.out.print("\n");
                    System.out.println(String.format("%s %-30s %-15s %-6s %s","","Product","Brand","Rate","Comment"));
                    System.out.println("-----------------------------------------------------------------------");
                    while(rs.next()){
                        System.out.println(String.format("%s %-30s %-15s %-6s %s","",rs.getString("pname"),rs.getString("bname"),rs.getString("rate"), rs.getString("comment")));
                    }
                    break;
            }
        }catch(SQLException e){
            System.err.println("msg: " + e.getMessage() +
                    "code: " + e.getErrorCode() +
                    "state: " + e.getSQLState());
        }catch(NumberFormatException e){
            System.out.println("Must enter a number");
        }
        finally{
            try { rs.close(); } catch (Exception e) { /* ignored */ }
            try { statement.close(); } catch (Exception e) { /* ignored */ }
            try { con.close(); } catch (Exception e) { /* ignored */ }
        }
    }

    //view the items you have ordered
    private static void orderedItems(){
        Connection con = null;
        Statement statement = null;
        ResultSet rs = null;

        try{
            con = DriverManager.getConnection(url,usernamestring,passwordstring);
            statement = con.createStatement();
            rs = statement.executeQuery("SELECT pname,bname,quantity,pid\n" +
                    "FROM OrderItems\n" +
                    "WHERE cid = " + cid +"\n" +
                    "ORDER BY pid,pname;");

            System.out.print("\n");
            System.out.print("---------------------------------------------------------");
            System.out.print("\n");
            System.out.println(String.format("%s %-30s %-10s %-8s %s","","Product","Brand","Qty", "PID"));
            System.out.println("---------------------------------------------------------");

            while(rs.next()){
                System.out.println(String.format("%s %-30s %-10s %-8s %s","",rs.getString("pname"),rs.getString("bname"),rs.getString("quantity"), rs.getString("pid")));
            }
            System.out.print("\n");
        }catch(SQLException e){
            System.err.println("msg: " + e.getMessage() +
                    "code: " + e.getErrorCode() +
                    "state: " + e.getSQLState());
        }finally{
            try { rs.close(); } catch (Exception e) { /* ignored */ }
            try { statement.close(); } catch (Exception e) { /* ignored */ }
            try { con.close(); } catch (Exception e) { /* ignored */ }
        }
    }

    //get the product that is the most popular (ie. most #sells)
    private static void bestProduct() {
        Connection con = null;
        Statement statement = null;
        ResultSet rs = null;

        try {
            con = DriverManager.getConnection(url, usernamestring, passwordstring);
            statement = con.createStatement();
            rs = statement.executeQuery("SELECT r.pname, SUM(quantity) as qty, r.rating\n" +
                    "FROM OrderItems o, Rate r\n" +
                    "WHERE o.pname = r.pname\n" +
                    "GROUP BY r.pname, r.rating\n" +
                    "HAVING SUM(quantity) >= ALL(\n" +
                    "  SELECT MAX(totalqty)\n" +
                    "  FROM (\n" +
                    "         SELECT pname, SUM(quantity) totalqty\n" +
                    "         FROM OrderItems\n" +
                    "         GROUP BY pname\n" +
                    "       )AS bar\n" +
                    ");");

            System.out.print("\n");
            System.out.print("-----------------------------------------------------");
            System.out.print("\n");
            System.out.println(String.format("%s %-30s %-8s %s", "", "Product", "#Sells", "Rating"));
            System.out.println("-----------------------------------------------------");

            while (rs.next()) {
                System.out.println(String.format("%s %-30s %-8s %s", "", rs.getString("pname"), rs.getString("qty"), rs.getString("rating")));
            }
            System.out.print("\n");
        } catch (SQLException e) {
            System.err.println("msg: " + e.getMessage() +
                    "code: " + e.getErrorCode() +
                    "state: " + e.getSQLState());
        }finally{
            try { rs.close(); } catch (Exception e) { /* ignored */ }
            try { statement.close(); } catch (Exception e) { /* ignored */ }
            try { con.close(); } catch (Exception e) { /* ignored */ }
        }
    }
}