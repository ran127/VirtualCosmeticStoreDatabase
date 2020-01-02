--QUESTION 2--
CREATE TABLE Customers
(
 cid SERIAL,
 email VARCHAR(100) NOT NULL UNIQUE,
 birthday DATE NOT NULL,
 fullName VARCHAR(100) NOT NULL,
 PRIMARY KEY(cid)
);

/*
                                 Table "cs421g06.customers"
  Column  |          Type          |                        Modifiers
----------+------------------------+---------------------------------------------------------
 cid      | integer                | not null default nextval('customers_cid_seq'::regclass)
 email    | character varying(100) | not null
 birthday | date                   | not null
 fullname | character varying(100) | not null
Indexes:
    "customers_pkey" PRIMARY KEY, btree (cid)
    "uniqueemail" UNIQUE CONSTRAINT, btree (email)
Referenced by:
    TABLE "cartitems" CONSTRAINT "cartitems_cid_fkey" FOREIGN KEY (cid) REFERENCES customers(cid)
    TABLE "orderitems" CONSTRAINT "orderitems_cid_fkey" FOREIGN KEY (cid) REFERENCES customers(cid)
    TABLE "payments" CONSTRAINT "payments_cid_fkey" FOREIGN KEY (cid) REFERENCES customers(cid)
    TABLE "rate" CONSTRAINT "rate_cid_fkey" FOREIGN KEY (cid) REFERENCES customers(cid)
    TABLE "refund" CONSTRAINT "refund_cid_fkey" FOREIGN KEY (cid) REFERENCES customers(cid)
*/

CREATE TABLE Brands
(
	bname VARCHAR(3000) NOT NULL,
	address VARCHAR(1000) NOT NULL,
	PRIMARY KEY(bname)
);
/*
           Table "cs421g06.brands"
 Column  |          Type          | Modifiers
---------+------------------------+-----------
 bname   | character varying(30)  | not null
 address | character varying(100) | not null
Indexes:
    "brands_pkey" PRIMARY KEY, btree (bname)
Referenced by:
    TABLE "products" CONSTRAINT "products_bname_fkey" FOREIGN KEY (bname) REFERENCES brands(bname)
*/


/*stock and volume attribute are stored separately in the ForSale table
and the Sample table because the same product could be either ForSale and
sample so its stock and volume will be different*/
CREATE TABLE Products
(
	pname VARCHAR(100) NOT NULL,
	bname VARCHAR(30) NOT NULL,
	category VARCHAR(30) NOT NULL,
	PRIMARY KEY (pname,bname),
	FOREIGN KEY (bname) REFERENCES Brands
);
/*
           Table "cs421g06.products"
  Column  |          Type          | Modifiers
----------+------------------------+-----------
 pname    | character varying(100) | not null
 bname    | character varying(30)  | not null
 category | character varying(30)  | not null
Indexes:
    "products_pkey" PRIMARY KEY, btree (pname, bname)
Foreign-key constraints:
    "products_bname_fkey" FOREIGN KEY (bname) REFERENCES brands(bname)
Referenced by:
    TABLE "cartitems" CONSTRAINT "cartitems_pname_fkey" FOREIGN KEY (pname, bname) REFERENCES products(pname, bname)
    TABLE "forsale" CONSTRAINT "forsale_pname_fkey" FOREIGN KEY (pname, bname) REFERENCES products(pname, bname)
    TABLE "orderitems" CONSTRAINT "orderitems_pname_fkey" FOREIGN KEY (pname, bname) REFERENCES products(pname, bname)
    TABLE "rate" CONSTRAINT "rate_pname_fkey" FOREIGN KEY (pname, bname) REFERENCES products(pname, bname)
    TABLE "sample" CONSTRAINT "sample_pname_fkey" FOREIGN KEY (pname, bname) REFERENCES products(pname, bname)
*/

CREATE TABLE Sample
(
	pname VARCHAR(100) NOT NULL,
	bname VARCHAR(30) NOT NULL,
	PRIMARY KEY (pname,bname),
	FOREIGN KEY (pname,bname) REFERENCES Products,
	stock INTEGER NOT NULL,
	volume_ml FLOAT NOT NULL
);
/*
            Table "cs421g06.sample"
  Column   |          Type          | Modifiers
-----------+------------------------+-----------
 pname     | character varying(100) | not null
 bname     | character varying(30)  | not null
 stock     | integer                | not null
 volume_ml | double precision       | not null
Indexes:
    "sample_pkey" PRIMARY KEY, btree (pname, bname)
Foreign-key constraints:
    "sample_pname_fkey" FOREIGN KEY (pname, bname) REFERENCES products(pname, bname)
*/

CREATE TABLE ForSale
(
	pname VARCHAR(100) NOT NULL,
	bname VARCHAR(30) NOT NULL,
	price DECIMAL(7,2) NOT NULL,
	stock INTEGER NOT NULL,
	volume_ml FLOAT NOT NULL,
	overallRating FLOAT,
	PRIMARY KEY (pname,bname),
	FOREIGN KEY (pname,bname) REFERENCES Products
);
/*
              Table "cs421g06.forsale"
    Column     |          Type          | Modifiers
---------------+------------------------+-----------
 pname         | character varying(100) | not null
 bname         | character varying(30)  | not null
 price         | numeric(7,2)           | not null
 stock         | integer                | not null
 volume_ml     | double precision       | not null
 overallrating | double precision       |
Indexes:
    "forsale_pkey" PRIMARY KEY, btree (pname, bname)
Foreign-key constraints:
    "forsale_pname_fkey" FOREIGN KEY (pname, bname) REFERENCES products(pname, bname)
*/

CREATE TABLE Payments
(
	pid SERIAL,
	cid INTEGER NOT NULL,
	trackingNumber INTEGER UNIQUE,
	pdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	orderDetail VARCHAR(1000) DEFAULT 'generating details...',
	PRIMARY KEY(pid),
	FOREIGN KEY (cid) REFERENCES Customers
);
/*
                                       Table "cs421g06.payments"
     Column     |            Type             |                       Modifiers
----------------+-----------------------------+--------------------------------------------------------
 pid            | integer                     | not null default nextval('payments_pid_seq'::regclass)
 cid            | integer                     | not null
 trackingnumber | integer                     |
 pdate          | timestamp without time zone | default now()
 orderdetail    | character varying(1000)     | default 'generating details...'::character varying
Indexes:
    "payments_pkey" PRIMARY KEY, btree (pid)
    "payments_trackingnumber_key" UNIQUE CONSTRAINT, btree (trackingnumber)
Foreign-key constraints:
    "payments_cid_fkey" FOREIGN KEY (cid) REFERENCES customers(cid)
Referenced by:
    TABLE "orderitems" CONSTRAINT "orderitems_pid_fkey" FOREIGN KEY (pid) REFERENCES payments(pid)
    TABLE "refund" CONSTRAINT "refund_pid_fkey" FOREIGN KEY (pid) REFERENCES payments(pid)
*/

CREATE TABLE CartItems 
(
	item_id SERIAL,
	quantity INT NOT NULL CONSTRAINT ratage CHECK(quantity>0),
	pname VARCHAR(30) NOT NULL,
	bname VARCHAR(30) NOT NULL,
	cid INT NOT NULL,
	PRIMARY KEY (item_id),
	FOREIGN KEY (pname, bname) REFERENCES Products,
	FOREIGN KEY (cid) REFERENCES Customers
);
/*
                                   Table "cs421g06.cartitems"
  Column  |         Type          |                          Modifiers
----------+-----------------------+-------------------------------------------------------------
 item_id  | integer               | not null default nextval('cartitems_item_id_seq'::regclass)
 quantity | integer               | not null
 pname    | character varying(30) | not null
 bname    | character varying(30) | not null
 cid      | integer               | not null
Indexes:
    "cartitems_pkey" PRIMARY KEY, btree (item_id)
Check constraints:
    "ratage" CHECK (quantity > 0)
Foreign-key constraints:
    "cartitems_cid_fkey" FOREIGN KEY (cid) REFERENCES customers(cid)
    "cartitems_pname_fkey" FOREIGN KEY (pname, bname) REFERENCES products(pname, bname)
*/

CREATE TABLE OrderItems 
(
	orderItem_id SERIAL,
	quantity INT NOT NULL,
	pname VARCHAR(30) NOT NULL,
	bname VARCHAR(30) NOT NULL,
	pid INT NOT NULL,
	cid INT NOT NULL,
	PRIMARY KEY (orderItem_id),
	FOREIGN KEY (pname, bname) REFERENCES Products,
	FOREIGN KEY (cid) REFERENCES Customers,
	FOREIGN KEY (pid) REFERENCES Payments
);
/*
                                       Table "cs421g06.orderitems"
    Column    |         Type          |                             Modifiers
--------------+-----------------------+-------------------------------------------------------------------
 orderitem_id | integer               | not null default nextval('orderitems_orderitem_id_seq'::regclass)
 quantity     | integer               | not null
 pname        | character varying(30) | not null
 bname        | character varying(30) | not null
 pid          | integer               | not null
 cid          | integer               | not null
Indexes:
    "orderitems_pkey" PRIMARY KEY, btree (orderitem_id)
Foreign-key constraints:
    "orderitems_cid_fkey" FOREIGN KEY (cid) REFERENCES customers(cid)
    "orderitems_pid_fkey" FOREIGN KEY (pid) REFERENCES payments(pid)
    "orderitems_pname_fkey" FOREIGN KEY (pname, bname) REFERENCES products(pname, bname)
*/

CREATE TABLE Refund 
(
	cid INT NOT NULL,
	pid INT NOT NULL,
	refund_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (cid, pid),
	FOREIGN KEY (cid) REFERENCES Customers,
	FOREIGN KEY (pid) REFERENCES Payments
);
/*
                  Table "cs421g06.refund"
   Column    |            Type             |   Modifiers
-------------+-----------------------------+---------------
 cid         | integer                     | not null
 pid         | integer                     | not null
 refund_date | timestamp without time zone | default now()
Indexes:
    "refund_pkey" PRIMARY KEY, btree (cid, pid)
Foreign-key constraints:
    "refund_cid_fkey" FOREIGN KEY (cid) REFERENCES customers(cid)
    "refund_pid_fkey" FOREIGN KEY (pid) REFERENCES payments(pid)
*/

CREATE TABLE Rate
(
	pname VARCHAR(30) NOT NULL,
	bname VARCHAR(30) NOT NULL,
	cid INTEGER NOT NULL,
	rating INTEGER NOT NULL CONSTRAINT rat CHECK (rating >= 0 AND rating <=5),
	rate_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	rate_comment VARCHAR(1000),
	FOREIGN KEY (pname,bname) REFERENCES Products,
	FOREIGN KEY (cid) REFERENCES Customers,
	PRIMARY KEY(rate_date, pname,bname,cid)
);
/*
                        Table "cs421g06.rate"
    Column    |            Type             |       Modifiers
--------------+-----------------------------+------------------------
 pname        | character varying(30)       | not null
 bname        | character varying(30)       | not null
 cid          | integer                     | not null
 rating       | integer                     | not null
 rate_date    | timestamp without time zone | not null default now()
 rate_comment | character varying(1000)     |
Indexes:
    "rate_pkey" PRIMARY KEY, btree (rate_date, pname, bname, cid)
Check constraints:
    "rat" CHECK (rating >= 0 AND rating <= 5)
Foreign-key constraints:
    "rate_cid_fkey" FOREIGN KEY (cid) REFERENCES customers(cid)
    "rate_pname_fkey" FOREIGN KEY (pname, bname) REFERENCES products(pname, bname)
*/


--QUESTION 3--
INSERT INTO brands VALUES('Dior','Holt Renfrew 1300 Rue Sherbrooke Ouest, Montréal, QC H3G 1H9');
INSERT INTO brands VALUES('Channel','Holt Renfrew 1301 Rue Sherbrooke Ouest, Montréal, QC H3G 1H8');
INSERT INTO brands VALUES('MAC','Holt Renfrew 1302 Rue Sherbrooke Ouest, Montréal, QC H3G 1H7');
INSERT INTO brands VALUES('Lancome','Holt Renfrew 1303 Rue Sherbrooke Ouest, Montréal, QC H3G 1H6');
INSERT INTO brands VALUES('Fresh','Holt Renfrew 1304 Rue Sherbrooke Ouest, Montréal, QC H3G 1H5');
INSERT INTO brands VALUES('Origins','Holt Renfrew 1305 Rue Sherbrooke Ouest, Montréal, QC H3G 1H4');
INSERT INTO brands VALUES('TOM FORD','Holt Renfrew 1303 Rue Sherbrooke Ouest, Montréal, QC H3G 1H3');
/*
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1

  bname   |                           address
----------+--------------------------------------------------------------
 Dior     | Holt Renfrew 1300 Rue Sherbrooke Ouest, Montréal, QC H3G 1H9
 MAC      | Holt Renfrew 1302 Rue Sherbrooke Ouest, Montréal, QC H3G 1H7
 Lancome  | Holt Renfrew 1303 Rue Sherbrooke Ouest, Montréal, QC H3G 1H6
 Fresh    | Holt Renfrew 1304 Rue Sherbrooke Ouest, Montréal, QC H3G 1H5
 Origins  | Holt Renfrew 1305 Rue Sherbrooke Ouest, Montréal, QC H3G 1H4
 TOM FORD | Holt Renfrew 1303 Rue Sherbrooke Ouest, Montréal, QC H3G 1H3
 Channel  | Holt Renfrew 1301 Rue Sherbrooke Ouest, Montréal, QC H3G 1H8
*/

--QUESTION 4--
INSERT INTO Customers (email, birthday, fullname) VALUES('annie.liang@gmail.com','1998-04-12','Annie Liang');
INSERT INTO Customers (email, birthday, fullname) VALUES('anna.chen@gmail.com','1998-05-16','Anna Chen');
INSERT INTO Customers (email, birthday, fullname) VALUES('anndy.li@gmail.com','1998-05-12','Anndy Li');
INSERT INTO Customers (email, birthday, fullname) VALUES('bessie.luo@gmail.com','1998-01-26','Bessie Luo');
INSERT INTO Customers (email, birthday, fullname) VALUES('zhuoran.zhao@gmail.com','1998-05-15','Zhuoran Zhao');
INSERT INTO Customers (email, birthday, fullname) VALUES('xintong.li@mail.mcgill.ca','1998-09-05','Xintong Li');

/*auto generate 100 customers and insert multiple records with one INSERT*/
INSERT INTO customers (email,birthday,fullname) VALUES ('eu@malesuada.com','12/24/1995','Meghan Riggs'),('sagittis.Duis.gravida@euaugueporttitor.ca','08/07/1994','Kirestin Shepard'),('blandit.Nam@eteuismod.ca','09/17/2002','Macy Whitney'),('fringilla.Donec.feugiat@antelectus.net','11/11/2001','May Jordan'),('fermentum.metus@tristiquesenectuset.com','11/08/2003','Alisa Hudson'),('ante@id.edu','12/08/1993','Ingrid Morse'),('lorem.vitae@Proinnislsem.ca','11/14/1990','September Crane'),('tincidunt.nibh@sem.edu','01/20/2003','Bianca Hays'),('Curabitur.dictum.Phasellus@maurisanunc.net','10/17/1999','Dora Nicholson'),('commodo@nullaIntegervulputate.edu','11/09/2003','Alyssa Goodman');
INSERT INTO customers (email,birthday,fullname) VALUES ('in.sodales@tristiquesenectus.co.uk','12/06/1995','Ainsley Guzman'),('metus.In@nibhsitamet.org','11/27/1993','Rebekah Golden'),('cursus.Nunc@pedenonummy.com','07/20/1995','Hadley Baird'),('auctor.quis@a.edu','08/20/1995','Hanna Reed'),('augue.ut.lacus@metus.net','10/05/2003','Myra Pitts'),('Vivamus.euismod@Aenean.net','06/11/1995','Nola Price'),('torquent@aliquetlobortisnisi.org','01/13/1993','Deborah Solomon'),('convallis.in.cursus@urnaUttincidunt.edu','08/16/2002','Shafira Miranda'),('facilisis.magna@ligula.edu','04/28/1991','Hillary Bean'),('mauris.sapien@enimcommodohendrerit.net','09/18/1991','Janna Mcclain');
INSERT INTO customers (email,birthday,fullname) VALUES ('pharetra.nibh.Aliquam@enimsit.net','08/13/1995','Claire Mcconnell'),('dui@et.ca','11/17/1997','Destiny Branch'),('laoreet.ipsum.Curabitur@ametmassaQuisque.net','06/02/1996','Piper Ferguson'),('Phasellus.nulla.Integer@venenatisvel.net','04/04/1994','Elizabeth Kline'),('dapibus.rutrum.justo@quisarcuvel.com','07/19/1999','Dara Oliver'),('mauris.ut.mi@eros.com','11/06/1994','Kelsey Matthews'),('ultrices.mauris@luctus.net','12/27/1990','Ora Rhodes'),('dictum@odioPhasellus.ca','06/02/2000','Dahlia David'),('nec.ante@utaliquam.ca','12/27/1992','Jamalia Ferrell'),('erat.Etiam@Craslorem.net','03/03/1999','Wynne Glass');
INSERT INTO customers (email,birthday,fullname) VALUES ('aliquet@adui.org','12/26/1995','Amaya Dillon'),('Cum.sociis@nisidictum.com','03/19/1992','Lacota Bridges'),('sit.amet@ullamcorpernislarcu.ca','06/25/1992','Charity Scott'),('vulputate.nisi@PhasellusornareFusce.org','05/05/1992','Laura Copeland'),('mauris.erat.eget@vitaeerat.co.uk','03/16/1991','Lareina Armstrong'),('mauris.blandit@ullamcorperDuisat.edu','05/11/2002','Basia Morrow'),('elit@Cras.ca','07/22/1994','Idola Dominguez'),('egestas@blanditviverraDonec.org','02/20/1996','Cherokee Dean'),('adipiscing.non.luctus@mollisInteger.edu','09/20/1997','Hayfa Ayala'),('id@quis.net','11/28/1990','Jena Bauer');
INSERT INTO customers (email,birthday,fullname) VALUES ('sodales@lectuspedeet.org','07/09/1993','Lacota Leach'),('scelerisque@semNulla.org','02/03/1999','Melanie Holman'),('mauris.sit@molestiepharetranibh.co.uk','11/15/1992','Francesca Fields'),('sem.Pellentesque@sociisnatoquepenatibus.net','03/30/1997','Jolene Vincent'),('erat.in.consectetuer@elementumpurus.ca','06/06/1991','Alexis Hansen'),('feugiat@Quisquefringillaeuismod.com','05/01/1995','Daphne Tran'),('et@nulla.com','04/05/1995','Quintessa Yang'),('Nunc.ullamcorper.velit@dolorvitae.net','07/05/2002','Mara Kinney'),('eget@necdiamDuis.edu','08/19/1998','Jorden Hudson'),('malesuada.fringilla@velitAliquamnisl.com','05/22/1998','Gay Cook');
INSERT INTO customers (email,birthday,fullname) VALUES ('auctor@elementum.net','09/02/1993','Abigail Floyd'),('velit.eu.sem@etipsumcursus.edu','01/07/2001','Marah Miles'),('rhoncus.id.mollis@natoque.net','08/23/1991','Cally Long'),('Aliquam.tincidunt@libero.co.uk','08/31/2002','Lenore Juarez'),('convallis.ante@risusDuis.co.uk','02/12/2000','Aretha Mccarthy'),('Vestibulum.accumsan@elitNullafacilisi.org','11/20/1994','Leslie Booth'),('ridiculus.mus.Aenean@acmetusvitae.edu','10/22/1990','Serina Neal'),('tincidunt.pede.ac@liberoIntegerin.edu','03/28/1995','Kirestin Barr'),('dignissim@pellentesqueeget.net','12/06/1997','Josephine Wood'),('natoque.penatibus@nuncnulla.co.uk','01/26/1997','Jolene Marks');
INSERT INTO customers (email,birthday,fullname) VALUES ('sapien.Aenean@pretiumnequeMorbi.net','11/09/1993','Flavia Steele'),('ut@infelis.org','11/26/1993','Nola Walls'),('felis.purus@magna.com','09/14/1996','Freya Malone'),('ante.lectus@nec.edu','10/13/1997','Casey Hudson'),('arcu.Sed.eu@Suspendissecommodotincidunt.com','04/07/1997','Ingrid Davis'),('aliquam.enim@aaliquetvel.org','03/19/2002','Regina Charles'),('Aliquam.tincidunt@Vivamuseuismod.net','02/19/1990','Camilla Small'),('lobortis.nisi@pedemalesuadavel.ca','08/25/1994','Elizabeth Huff'),('laoreet.posuere@gravida.net','06/17/1999','Sigourney Kerr'),('Cras.vulputate@acfermentumvel.com','08/25/2001','Macy Banks');
INSERT INTO customers (email,birthday,fullname) VALUES ('ac.feugiat.non@fringillaestMauris.edu','09/23/1999','Daphne Orr'),('consectetuer.cursus@Fuscealiquamenim.co.uk','10/05/1994','Giselle Poole'),('Proin@ategestas.org','11/18/2000','Fallon Wilkerson'),('non@lorem.ca','07/20/2001','Idola Nieves'),('tellus.Phasellus.elit@Sedmolestie.edu','11/16/1993','Emma Mcneil'),('eu@musDonecdignissim.co.uk','05/09/1993','Chantale Ramirez'),('dolor.Fusce@cubiliaCurae.org','07/14/2001','Joy Joyner'),('sit.amet@fermentumfermentumarcu.org','07/23/2000','Ingrid Tyler'),('Curabitur.dictum.Phasellus@bibendum.net','12/27/1991','Wynter Mack'),('id.libero@nisi.org','11/24/2000','Brooke Hinton');
INSERT INTO customers (email,birthday,fullname) VALUES ('Cum.sociis.natoque@ridiculusmusProin.co.uk','04/30/1997','Kaye Sharp'),('Nunc@felis.org','03/03/1997','Heather Stephenson'),('Curae@sem.edu','05/08/2003','Sonia Durham'),('rhoncus.Nullam@necante.net','12/09/1997','Jessamine Pate'),('sagittis@Aliquamgravidamauris.net','04/21/2003','Riley Fitzpatrick'),('eu.elit@vulputateeu.com','07/24/2003','Hayley Daugherty'),('Sed@aliquam.co.uk','10/04/1991','Lydia Wyatt'),('dapibus@Etiamgravidamolestie.ca','07/25/1999','Cameran Long'),('libero.lacus.varius@Aenean.net','10/24/1994','Hillary Hogan'),('non.feugiat.nec@ligula.com','04/22/1990','Athena Vaughan');
INSERT INTO customers (email,birthday,fullname) VALUES ('volutpat@Loremipsum.org','03/06/1994','Margaret Cervantes'),('volutpat@Phasellusnulla.net','03/16/1994','Audra Willis'),('Nullam.nisl@velit.org','01/07/1993','Grace Cooper'),('enim.non@venenatisa.org','10/15/2000','Indigo Lott'),('Sed.malesuada.augue@FuscemollisDuis.org','05/24/1997','Margaret Boyle'),('orci.luctus.et@auguemalesuada.org','06/12/1996','Brianna Wilson'),('nisi.nibh@ornaresagittis.com','09/10/1994','Donna Emerson'),('ut.odio.vel@torquentperconubia.ca','02/29/1992','Yen Camacho'),('quis.massa@tellusNunclectus.com','03/11/1999','Patricia Kerr'),('Donec.vitae@Proin.edu','10/26/1993','Cameran Hammond');

/*auto generate 100 brands and insert multiple records with one INSERT*/
INSERT INTO brands (bname,address) VALUES ('Acqua Di Parma','Ap #715-2633 Tellus Rd.'),('AERIN','P.O. Box 143, 5719 Massa Street'),('Aether Beauty','P.O. Box 849, 6729 Tortor Avenue'),('AHAVA','969-8526 Eu Av.'),('Algenist','P.O. Box 256, 2659 Phasellus Rd.'),('Natoque Penatibus Et Corporation','Ap #933-1342 Sagittis Ave'),('Erat Volutpat Company','P.O. Box 154, 134 Proin Avenue'),('Mollis Corp.','7264 Egestas. Av.'),('Enim Suspendisse Aliquet Incorporated','1889 Proin Street'),('Egestas A Scelerisque Ltd','Ap #774-7630 Dis Rd.');
INSERT INTO brands (bname,address) VALUES ('Vulputate Mauris Sagittis PC','161-5903 Pede Street'),('Est Limited','970-9196 Eu St.'),('Morbi Inc.','165-7986 Enim St.'),('Augue Eu Tellus Foundation','Ap #109-4631 Libero. St.'),('Orci Luctus Et Foundation','Ap #730-6954 Vivamus Road'),('Accumsan Ltd','P.O. Box 237, 1356 Proin Avenue'),('Varius Foundation','Ap #631-4022 In Av.'),('Proin LLC','P.O. Box 727, 9330 Maecenas St.'),('In Magna Corp.','808-5384 Orci. St.'),('Tincidunt Congue Corp.','P.O. Box 704, 5183 Sed Street');
INSERT INTO brands (bname,address) VALUES ('Pellentesque Ut Ipsum LLC','435-8705 Augue Avenue'),('Facilisis Vitae Corporation','Ap #699-6070 Lacus. Avenue'),('Arcu Limited','3576 Fusce Avenue'),('Commodo Hendrerit Donec Inc.','P.O. Box 846, 5975 Non, Road'),('Mi Inc.','P.O. Box 670, 1130 Lacus. St.'),('Imperdiet Institute','P.O. Box 350, 6189 Aenean Avenue'),('Leo Morbi Neque Inc.','P.O. Box 564, 1613 Orci, Rd.'),('Libero Proin Corp.','Ap #280-6024 Ligula. Av.'),('Lacinia At Consulting','P.O. Box 872, 5141 Ac, St.'),('Tellus Imperdiet Non Limited','Ap #560-8388 Proin Av.');
INSERT INTO brands (bname,address) VALUES ('Id Risus LLC','627-2562 A, Rd.'),('Dictum Ltd','750 Maecenas Avenue'),('In Lorem Associates','Ap #686-2378 Dolor St.'),('Eu Limited','731-8380 Eget, Ave'),('Et Commodo Ltd','P.O. Box 449, 7340 Integer Av.'),('Blandit Enim Consequat Institute','328-5188 Vitae Avenue'),('Mauris Non Dui Inc.','517-1116 Aliquam Rd.'),('Amet Ornare Consulting','Ap #967-9319 Gravida St.'),('Mauris Foundation','P.O. Box 176, 1634 Nam Street'),('Imperdiet Ornare Inc.','897-5834 Proin Road');
INSERT INTO brands (bname,address) VALUES ('Lacinia Corporation','P.O. Box 695, 9287 Nulla Road'),('Nulla Ante Iaculis Company','674-4990 Quam. Ave'),('Sit Corporation','559-7540 Arcu. St.'),('Quam Company','Ap #411-4661 Mi Av.'),('Elementum Sem PC','P.O. Box 756, 6676 Nunc St.'),('Et Euismod Et Associates','7547 Dolor St.'),('Quam Corp.','Ap #412-3265 Libero Road'),('Facilisis Facilisis Industries','1194 Eu, St.'),('Praesent Interdum Ligula LLC','P.O. Box 751, 8632 Curae; Ave'),('Dis Parturient Associates','3767 Metus. Ave');
INSERT INTO brands (bname,address) VALUES ('Nunc Sollicitudin Ltd','Ap #673-9256 Malesuada Rd.'),('Amazing Cosmetics','Ap #674-8915 Pulvinar St.'),('Tincidunt LLP','3633 Sem Street'),('Anatasia Beverly Hills','3549 Scelerisque Rd.'),('Sed Libero Associates','522 Ultrices St.'),('Risus A Ultricies LLP','Ap #791-1393 Purus. Ave'),('Egestas Limited','316-7324 Sapien, St.'),('Ultrices Incorporated','223-2870 Tortor, Avenue'),('Ornare Associates','Ap #766-2924 Non Street'),('Vitae Limited','P.O. Box 873, 1790 Felis. St.');
INSERT INTO brands (bname,address) VALUES ('Donec Elementum Lorem Ltd','P.O. Box 948, 7601 Etiam St.'),('Nunc Sit Amet Associates','9587 Eu St.'),('Ridiculus Foundation','P.O. Box 895, 2835 Nec, Av.'),('Non Dapibus Rutrum Associates','5714 Sed Avenue'),('A Neque Incorporated','502-4066 Magna Avenue'),('Elit Pretium Et Industries','P.O. Box 508, 2676 Donec Street'),('Cras Inc.','P.O. Box 765, 2309 Ligula. Rd.'),('Enim Sit Amet LLC','Ap #369-3051 Egestas Rd.'),('Nunc Ltd','9230 Neque. Ave'),('Ullamcorper Viverra Company','356 Faucibus St.');
INSERT INTO brands (bname,address) VALUES ('Ullamcorper Ltd','Ap #641-4258 At, Av.'),('Malesuada Integer Id Incorporated','Ap #695-5578 Est Road'),('Cras Eget Corp.','283-5846 Consectetuer Rd.'),('Nec Industries','P.O. Box 359, 8893 Eget Street'),('Varius Company','6135 Arcu. Avenue'),('Duis Volutpat LLC','P.O. Box 833, 9599 Aliquet Av.'),('Sed Institute','461-3033 Inceptos Av.'),('Id Enim Foundation','5027 Porttitor St.'),('Nullam Enim Sed Industries','165-8130 Urna Street'),('Non Quam Pellentesque Inc.','512-9077 A Avenue');
INSERT INTO brands (bname,address) VALUES ('Dolor Company','Ap #950-5843 Neque. Rd.'),('Vel Faucibus Id LLC','Ap #474-3985 Ipsum. Rd.'),('Pharetra Incorporated','P.O. Box 225, 6968 Molestie Av.'),('Nulla Donec Foundation','3998 Mollis. St.'),('Donec PC','3387 Vel, Avenue'),('Luctus Foundation','865 Etiam Rd.'),('Magnis Dis PC','Ap #140-6718 Aliquam Avenue'),('Vitae Dolor Donec Inc.','7577 Lorem, Ave'),('Metus Incorporated','9059 Sed Avenue'),('Lacinia Vitae Sodales Associates','P.O. Box 472, 2542 Sapien St.');

INSERT INTO Products VALUES ('Soy Face Cleanser','Fresh','Facial Cleanser');
INSERT INTO Products VALUES ('Rouge Dior Ultra Lipstick','Dior','Lipstick');
INSERT INTO Products VALUES ('Lotus Youth Preserve Moisturizer','Fresh','Moisturizer');
INSERT INTO Products VALUES ('Powder Kiss Lipstick','MAC','Lipstick');
INSERT INTO Products VALUES ('Ultra Long Wear Foundation','Lancome','Foundation');
INSERT INTO Products VALUES ('Refreshing Eye Cream','Origins','Eye Cream');
INSERT INTO Products VALUES ('Lip Color','TOM FORD','Lipstick');
INSERT INTO Products VALUES ('Channel 5','Channel','Perfume');

INSERT INTO Sample VALUES('Soy Face Cleanser', 'Fresh', 10, 15);
INSERT INTO Sample VALUES('Rouge Dior Ultra Lipstick', 'Dior', 14, 12);
INSERT INTO Sample VALUES('Powder Kiss Lipstick', 'MAC', 17, 10);
INSERT INTO Sample VALUES('Ultra Long Wear Foundation', 'Lancome', 13, 7);
INSERT INTO Sample VALUES('Refreshing Eye Cream', 'Origins', 12, 6);

INSERT INTO ForSale VALUES('Soy Face Cleanser', 'Fresh', 20.5, 10, 45);
INSERT INTO ForSale VALUES('Rouge Dior Ultra Lipstick', 'Dior',45, 14, 36);
INSERT INTO ForSale VALUES('Powder Kiss Lipstick', 'MAC',35, 17, 40);
INSERT INTO ForSale VALUES('Ultra Long Wear Foundation', 'Lancome',76, 13, 40);
INSERT INTO ForSale VALUES('Refreshing Eye Cream', 'Origins',37, 12, 52);

INSERT INTO CartItems (quantity, pname, bname, cid) VALUES(1, 'Soy Face Cleanser','Fresh',605);
INSERT INTO CartItems (quantity, pname, bname, cid) VALUES(16, 'Soy Face Cleanser','Fresh',560);
INSERT INTO CartItems (quantity, pname, bname, cid) VALUES(1, 'Powder Kiss Lipstick','MAC',564);
INSERT INTO CartItems (quantity, pname, bname, cid) VALUES(1, 'Ultra Long Wear Foundation','Lancome',598);
INSERT INTO CartItems (quantity, pname, bname, cid) VALUES(1, 'Refreshing Eye Cream','Origins', 564);
INSERT INTO CartItems (quantity, pname, bname, cid) VALUES(2, 'Refreshing Eye Cream','Origins', 599);

INSERT INTO payments(cid, trackingNumber, orderDetail) VALUES (543, '27576245','Refreshing Eye Cream * 2, Total cost $70.00');
INSERT INTO payments(cid, trackingNumber, orderDetail) VALUES (605, '854586','Soy Face Cleanser * 1, Total cost $20.50');
INSERT INTO payments(cid, trackingNumber, orderDetail) VALUES (566, '854590','Refreshing Eye Cream * 1, Total cost $37.00');
INSERT INTO payments(cid, trackingNumber, orderDetail) VALUES (625, '854589','Refreshing Eye Cream * 1, Total cost $37.00');
INSERT INTO payments(cid, trackingNumber, orderDetail) VALUES (560, '45628734','Soy Face Cleanser * 1, Total cost $20.50');
INSERT INTO payments(cid, trackingNumber, orderDetail) VALUES (598, '854585','Ultra Long Wear Foundation * 3, Total cost $228.00');
INSERT INTO payments(cid, trackingNumber, orderDetail) VALUES (625, '854587','Soy Face Cleanser * 1, Total cost $20.50');
INSERT INTO payments(cid, trackingNumber, orderDetail) VALUES (603, '45628735','Soy Face Cleanser * 1, Total cost $20.50');
INSERT INTO payments(cid, trackingNumber, orderDetail) VALUES (612, '4857659','Ultra Long Wear Foundation * 1, Total cost $76.00');
INSERT INTO payments(cid, trackingNumber, orderDetail) VALUES (564, '27576234','Powder Kiss Lipstick * 1, Total cost $35.00');
INSERT INTO payments(cid, trackingNumber, orderDetail) VALUES (599, '823594','Refreshing Eye Cream * 1, Total cost $37.00');

INSERT INTO OrderItems (quantity, pname, bname, pid, cid) VALUES(1, 'Refreshing Eye Cream','Origins',26, 543);
INSERT INTO OrderItems (quantity, pname, bname, pid, cid) VALUES(1, 'Soy Face Cleanser','Fresh',27, 605);
INSERT INTO OrderItems (quantity, pname, bname, pid, cid) VALUES(16, 'Soy Face Cleanser','Fresh',30, 560);
INSERT INTO OrderItems (quantity, pname, bname, pid, cid) VALUES(1, 'Ultra Long Wear Foundation','Lancome',31, 598);
INSERT INTO OrderItems (quantity, pname, bname, pid, cid) VALUES(1, 'Powder Kiss Lipstick','MAC',35,564);

INSERT INTO refund(cid,pid) Values (543,26);
INSERT INTO refund(cid,pid) Values (605,27);
INSERT INTO refund(cid,pid) Values (560,30);
INSERT INTO refund(cid,pid) Values (598,31);
INSERT INTO refund(cid,pid) Values (564,35);

INSERT INTO Rate (pname, bname, cid, rating, rate_comment) 
VALUES (
	'Soy Face Cleanser',
	'Fresh',
	543,
	1,
	'this worked more as a makeup remover for me. i have dry skin and felt like my cleanser was not working anymore so I wanted to switch it up. i was told in store that this was great, but I wont be buying it again. It made me break out more than I ever have before (I am 25 and really do not have acne - I even started using my clarisonic with it a few times a week). It also has made my skin feel a lot more dry. I would not recommend to anyone who has naturally dry skin/ wants something that is going to help keep your skin clear. quite a disappointment to say the least.'
);
INSERT INTO Rate (pname, bname, cid, rating, rate_comment) 
VALUES (
	'Rouge Dior Ultra Lipstick',
	'Dior',
	605,
	5,
	'A must buy product for modern beautiful women.'
);
INSERT INTO Rate (pname, bname, cid, rating, rate_comment) 
VALUES (
	'Powder Kiss Lipstick',
	'MAC',
	560,
	5,
	'Best red lipstick Ive ever tried (and Ive tried A LOT)! Not blue, not orange, perfectly neutral red. Feels smooth going on, doesnt bleed and lasts a solid 3 hrs., including eating/drinking. Worth the $$$$.'
);
INSERT INTO Rate (pname, bname, cid, rating, rate_comment) 
VALUES (
	'Lip Color',
	'TOM FORD',
	578,
	4,
	'I tried this lipstick on at Nordstrom last Sunday and bought it from Sephora online that evening; I know youre probably looking at the price and yes, its a pretty steep one but the quality of this lipstick is impressive An issue I have with lipstick colors is that they wear out unevenly; I prefer to try colors and monitor how the color wears throughout the duration of the application: this is a good one This lipstick is lovely but Ive never seen this manufacturer displayed in a Sephora store so I wouldnt have purchased it had I not had the opportunity to try it out first This color Casablanca may look bright in the swatch in the photograph but its really kind of a dark earthy rose (not quite mauve); the blush I use is Exposed by Tarte and they match perfectly.'
);
INSERT INTO Rate (pname, bname, cid, rating, rate_comment) 
VALUES (
	'Channel 5',
	'Channel',
	588,
	5,
	'Good good good'
);
INSERT INTO Rate (pname, bname, cid, rating, rate_comment) 
VALUES (
	'Lip Color',
	'TOM FORD',
	553,
	5,
	'This looks nice on my grilfriend’s lip. I couldn’t even believe this much change!!!.'
);
INSERT INTO Rate (pname, bname, cid, rating, rate_comment) 
VALUES (
	'Ultra Long Wear Foundation',
	'Lancome',
	545,
	4,
	'I love foundation and really try to sample whats out there. I have tried this before but chose to try it again. This time, I learned from my mistakes. You need to moisturize your face and use primer!! When you do that, this is an amazing foundation that truly lasts. If you are thinking about trying it out, try it...samples are even better.'
);
INSERT INTO Rate (pname, bname, cid, rating, rate_comment) 
VALUES (
	'Ultra Long Wear Foundation',
	'Lancome',
	536,
	5,
	'The main reason I bought this is because it has SPF and is noncomedogenic (doesnt clog pores). I was on the hunt for a new foundation and tried a few others and they all seemed to cause problems for my skin - which is generally clear and without problems. This one is perfect! Makes my skin look beautiful and even, without making any problems where there arent any! Plus SPF!'
);
INSERT INTO Rate (pname, bname, cid, rating, rate_comment) 
VALUES (
	'Ultra Long Wear Foundation',
	'Lancome',
	573,
	1,
	'I hope that Lancome will come back to their senses and return 14 hour formula (or something similar to it). This DOES NOT replace the old 14 hour formula because its loaded with a whole bunch of stuff + more SPF which is not good for some of us, acne prone folks. I have sensitive, acne prone, oily skin and this broke me horribly! I could not believe it! Why fix something if it aint broken? Very, very disappointed.'
);
INSERT INTO Rate (pname, bname, cid, rating, rate_comment) 
VALUES (
	'Ultra Long Wear Foundation',
	'Lancome',
	533,
	1,
	'I was very disappointed in this product considering its pretty pricey. After trying it out I felt I had residue on my skin and looked like it. It says that it is full coverage but its the opposite. I bought this in hopes of covering my imperfections but it did not do the job. I would only suggest buying this if you have perfect skin and are looking for light coverage. Also you need at least 3 pumps for medium coverage. I will be returning. However I did like the bottle anyways, I do not recommend. Save your money (btw I have combination skin)'
);
INSERT INTO Rate (pname, bname, cid, rating, rate_comment) 
VALUES (
	'Lip Color',
	'TOM FORD',
	577,
	2,
	'I thought this was going to be my Holy Grail lipstick. I was so excited to try it!!! Love the color in the tube, its perfect! Then I applied it... first I noticed the old musty, granny lipstick smell to it. (Thats a star off) ... then I noticed it really didnt have much pigment to it (another star off) so I applied it twice and the staying power is horrible (another star off). All in all, Im super disappointed in this product. I will NOT repurchase at $58 a tube. its maybe worth $15 at best!.'
);

SELECT * FROM Customers limit 5;
/*
 cid |         email          |  birthday  |   fullname
-----+------------------------+------------+--------------
 531 | annie.liang@gmail.com  | 1998-04-12 | Annie Liang
 532 | anna.chen@gmail.com    | 1998-05-16 | Anna Chen
 533 | anndy.li@gmail.com     | 1998-05-12 | Anndy Li
 534 | bessie.luo@gmail.com   | 1998-01-26 | Bessie Luo
 535 | zhuoran.zhao@gmail.com | 1998-05-15 | Zhuoran Zhao
(5 rows)
*/
SELECT * FROM Brands limit 5;
/*
  bname  |                           address
---------+--------------------------------------------------------------
 Dior    | Holt Renfrew 1300 Rue Sherbrooke Ouest, Montréal, QC H3G 1H9
 Channel | Holt Renfrew 1301 Rue Sherbrooke Ouest, Montréal, QC H3G 1H8
 MAC     | Holt Renfrew 1302 Rue Sherbrooke Ouest, Montréal, QC H3G 1H7
 Lancome | Holt Renfrew 1303 Rue Sherbrooke Ouest, Montréal, QC H3G 1H6
 Fresh   | Holt Renfrew 1304 Rue Sherbrooke Ouest, Montréal, QC H3G 1H5
(5 rows)
*/
SELECT * FROM Products limit 5;
/*
              pname               |  bname  |    category
----------------------------------+---------+-----------------
 Soy Face Cleanser                | Fresh   | Facial Cleanser
 Rouge Dior Ultra Lipstick        | Dior    | Lipstick
 Lotus Youth Preserve Moisturizer | Fresh   | Moisturizer
 Powder Kiss Lipstick             | MAC     | Lipstick
 Ultra Long Wear Foundation       | Lancome | Foundation
(5 rows)
*/
SELECT * FROM Sample limit 5;
/*
           pname            |  bname  | stock | volume_ml
----------------------------+---------+-------+-----------
 Soy Face Cleanser          | Fresh   |    10 |        15
 Rouge Dior Ultra Lipstick  | Dior    |    14 |        12
 Powder Kiss Lipstick       | MAC     |    17 |        10
 Ultra Long Wear Foundation | Lancome |    13 |         7
 Refreshing Eye Cream       | Origins |    12 |         6
(5 rows)
*/
SELECT * FROM ForSale limit 5;
/*
           pname            |  bname  | price | stock | volume_ml | overallrating
----------------------------+---------+-------+-------+-----------+---------------
 Soy Face Cleanser          | Fresh   | 20.50 |    10 |        45 |
 Rouge Dior Ultra Lipstick  | Dior    | 45.00 |    14 |        36 |
 Powder Kiss Lipstick       | MAC     | 35.00 |    17 |        40 |
 Ultra Long Wear Foundation | Lancome | 76.00 |    13 |        40 |
 Refreshing Eye Cream       | Origins | 37.00 |    12 |        52 |
(5 rows)
*/
SELECT * FROM CartItems limit 5;
/*
 item_id | quantity |           pname            |  bname  | cid
---------+----------+----------------------------+---------+-----
      12 |        1 | Soy Face Cleanser          | Fresh   | 605
      13 |       16 | Soy Face Cleanser          | Fresh   | 560
      14 |        1 | Powder Kiss Lipstick       | MAC     | 564
      15 |        1 | Ultra Long Wear Foundation | Lancome | 598
      16 |        1 | Refreshing Eye Cream       | Origins | 564
(5 rows)
*/
SELECT * FROM OrderItems limit 5;
/*
 orderitem_id | quantity |           pname            |  bname  | pid | cid
--------------+----------+----------------------------+---------+-----+-----
            4 |        1 | Refreshing Eye Cream       | Origins |  26 | 543
            5 |        1 | Soy Face Cleanser          | Fresh   |  27 | 605
            6 |       16 | Soy Face Cleanser          | Fresh   |  30 | 560
            7 |        1 | Ultra Long Wear Foundation | Lancome |  31 | 598
            8 |        1 | Powder Kiss Lipstick       | MAC     |  35 | 564
(5 rows)
*/
SELECT * FROM Payments limit 5;
/*
 pid | cid | trackingnumber |           pdate           |                 orderdetail
-----+-----+----------------+---------------------------+---------------------------------------------
  26 | 543 |       27576245 | 2019-03-01 19:23:46.88284 | Refreshing Eye Cream * 2, Total cost $70.00
  27 | 605 |         854586 | 2019-03-01 19:23:46.88284 | Soy Face Cleanser * 1, Total cost $20.50
  28 | 566 |         854590 | 2019-03-01 19:23:46.88284 | Refreshing Eye Cream * 1, Total cost $37.00
  29 | 625 |         854589 | 2019-03-01 19:23:46.88284 | Refreshing Eye Cream * 1, Total cost $37.00
  30 | 560 |       45628734 | 2019-03-01 19:23:46.88284 | Soy Face Cleanser * 1, Total cost $20.50
(5 rows)
*/
SELECT * FROM Refund limit 5;
/*
 cid | pid |        refund_date
-----+-----+----------------------------
 543 |  26 | 2019-03-01 19:45:50.570983
 605 |  27 | 2019-03-01 19:45:50.570983
 560 |  30 | 2019-03-01 19:45:50.570983
 598 |  31 | 2019-03-01 19:45:50.570983
 564 |  35 | 2019-03-01 19:45:50.570983
(5 rows)
*/
SELECT * FROM Rate limit 5;
/*
           pname           |  bname   | cid | rating |         rate_date          |                                                                                                                                                                                                                                                                                                                                                                                            rate_comment                                                                                                                                                                                                                                                                                   
---------------------------+----------+-----+--------+----------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 Soy Face Cleanser         | Fresh    | 543 |      1 | 2019-03-01 19:47:42.208492 | this worked more as a makeup remover for me. i have dry skin and felt like my cleanser was not working anymore so I wanted to switch it up. i was told in store that this was great, but I wont be buying it again. It made me break out more than I ever have before (I am 25 and really do not have acne - I even started using my clarisonic with it a few times a week). It also has made my skin feel a lot more dry. I would not recommend to anyone who has naturally dry skin/ wants something that is going to help keep your skin clear. quite a disappointment to say the least.
 Rouge Dior Ultra Lipstick | Dior     | 605 |      5 | 2019-03-01 19:47:42.208492 | A must buy product for modern beautiful women.
 Powder Kiss Lipstick      | MAC      | 560 |      5 | 2019-03-01 19:47:42.208492 | Best red lipstick Ive ever tried (and Ive tried A LOT)! Not blue, not orange, perfectly neutral red. Feels smooth going on, doesnt bleed and lasts a solid 3 hrs., including eating/drinking. Worth the $$$$.
 Lip Color                 | TOM FORD | 578 |      4 | 2019-03-01 19:47:42.208492 | I tried this lipstick on at Nordstrom last Sunday and bought it from Sephora online that evening; I know youre probably looking at the price and yes, its a pretty steep one but the quality of this lipstick is impressive An issue I have with lipstick colors is that they wear out unevenly; I prefer to try colors and monitor how the color wears throughout the duration of the application: this is a good one This lipstick is lovely but Ive never seen this manufacturer displayed in a Sephora store so I wouldnt have purchased it had I not had the opportunity to try it out first This color Casablanca may look bright in the swatch in the photograph but its really kind of a dark earthy rose (not quite mauve); the blush I use is Exposed by Tarte and they match perfectly.
 Channel 5                 | Channel  | 588 |      5 | 2019-03-01 19:47:42.208492 | Good good good
*/



--QUESTION 5--
/*
                  Table "cs421g06.refund"
   Column    |            Type             |   Modifiers
-------------+-----------------------------+---------------
 cid         | integer                     | not null
 pid         | integer                     | not null
 refund_date | timestamp without time zone | default now()
Indexes:
    "refund_pkey" PRIMARY KEY, btree (cid, pid)
Foreign-key constraints:
    "refund_cid_fkey" FOREIGN KEY (cid) REFERENCES customers(cid)
    "refund_pid_fkey" FOREIGN KEY (pid) REFERENCES payments(pid)

                                 Table "cs421g06.customers"
  Column  |          Type          |                        Modifiers
----------+------------------------+---------------------------------------------------------
 cid      | integer                | not null default nextval('customers_cid_seq'::regclass)
 email    | character varying(100) | not null
 birthday | date                   | not null
 fullname | character varying(100) | not null
Indexes:
    "customers_pkey" PRIMARY KEY, btree (cid)
    "uniqueemail" UNIQUE CONSTRAINT, btree (email)
Referenced by:
    TABLE "cartitems" CONSTRAINT "cartitems_cid_fkey" FOREIGN KEY (cid) REFERENCES customers(cid)
    TABLE "orderitems" CONSTRAINT "orderitems_cid_fkey" FOREIGN KEY (cid) REFERENCES customers(cid)
    TABLE "payments" CONSTRAINT "payments_cid_fkey" FOREIGN KEY (cid) REFERENCES customers(cid)
    TABLE "rate" CONSTRAINT "rate_cid_fkey" FOREIGN KEY (cid) REFERENCES customers(cid)
    TABLE "refund" CONSTRAINT "refund_cid_fkey" FOREIGN KEY (cid) REFERENCES customers(cid)


(1) FIND ALL CUSTOMERS THAT HAS REFUND AND ORDER BY THEIR ID*/
SELECT  customers.cid,fullname,pid,refund_date
FROM customers, refund 
WHERE customers.cid = refund.cid
ORDER BY customers.cid DESC;
/*
 cid |    fullname     | pid |        refund_date
-----+-----------------+-----+----------------------------
 605 | Sigourney Kerr  |  27 | 2019-03-01 19:45:50.570983
 598 | Nola Walls      |  31 | 2019-03-01 19:45:50.570983
 564 | Dahlia David    |  35 | 2019-03-01 19:45:50.570983
 560 | Elizabeth Kline |  30 | 2019-03-01 19:45:50.570983
 543 | September Crane |  26 | 2019-03-01 19:45:50.570983
(5 rows)
*/




/*
              Table "cs421g06.forsale"
    Column     |          Type          | Modifiers
---------------+------------------------+-----------
 pname         | character varying(100) | not null
 bname         | character varying(30)  | not null
 price         | numeric(7,2)           | not null
 stock         | integer                | not null
 volume_ml     | double precision       | not null
 overallrating | double precision       |
Indexes:
    "forsale_pkey" PRIMARY KEY, btree (pname, bname)
Foreign-key constraints:
    "forsale_pname_fkey" FOREIGN KEY (pname, bname) REFERENCES products(pname, bname)


(2) GET THE AVG RATING FOR ALL THE PRODUCTS IN A PRICE RANGE*/
SELECT AVG(overallrating) 
FROM forsale 
WHERE (price > 45 AND price < 100);
/*
 avg
------
 2.75
(1 row)
*/



/*
              Table "cs421g06.forsale"
    Column     |          Type          | Modifiers
---------------+------------------------+-----------
 pname         | character varying(100) | not null
 bname         | character varying(30)  | not null
 price         | numeric(7,2)           | not null
 stock         | integer                | not null
 volume_ml     | double precision       | not null
 overallrating | double precision       |
Indexes:
    "forsale_pkey" PRIMARY KEY, btree (pname, bname)
Foreign-key constraints:
    "forsale_pname_fkey" FOREIGN KEY (pname, bname) REFERENCES products(pname, bname)

(3) GET THE PRODUCT AND ITS OVERALL RATING OF THE FORSALE PRODUCT WITH THE HIGHEST RATING*/
SELECT pname, overallrating 
FROM ForSale 
WHERE overallrating = (
	SELECT MAX(overallrating)
	From ForSale
);
/*
           pname           | overallrating
---------------------------+---------------
 Rouge Dior Ultra Lipstick |             5
 Powder Kiss Lipstick      |             5
(2 rows)
*/




/*
                                       Table "cs421g06.orderitems"
    Column    |         Type          |                             Modifiers
--------------+-----------------------+-------------------------------------------------------------------
 orderitem_id | integer               | not null default nextval('orderitems_orderitem_id_seq'::regclass)
 quantity     | integer               | not null
 pname        | character varying(30) | not null
 bname        | character varying(30) | not null
 pid          | integer               | not null
 cid          | integer               | not null
Indexes:
    "orderitems_pkey" PRIMARY KEY, btree (orderitem_id)
Foreign-key constraints:
    "orderitems_cid_fkey" FOREIGN KEY (cid) REFERENCES customers(cid)
    "orderitems_pid_fkey" FOREIGN KEY (pid) REFERENCES payments(pid)
    "orderitems_pname_fkey" FOREIGN KEY (pname, bname) REFERENCES products(pname, bname)

(4) GET THE MOST POPULAR PRODUCT(WITH MOST QUANTITY ORDERED)*/
SELECT pname as most_popular, totalqty 
FROM(
	/*
	first get the drived table that calculates 
	the total quantity ordered for each product
	*/
	SELECT pname, SUM(quantity) totalqty
	FROM OrderItems
	GROUP BY pname
)AS foo
WHERE totalqty = (
	/*
	second derived table to calculate the max 
	b/c foo relation doesn't preserve 
	*/
	SELECT MAX(totalqty) 
	FROM (
		SELECT pname, SUM(quantity) totalqty
		FROM OrderItems
		GROUP BY pname
	)AS bar
);
/*
   most_popular    | totalqty
-------------------+----------
 Soy Face Cleanser |       17
(1 row)
*/




/*
                                       Table "cs421g06.orderitems"
    Column    |         Type          |                             Modifiers
--------------+-----------------------+-------------------------------------------------------------------
 orderitem_id | integer               | not null default nextval('orderitems_orderitem_id_seq'::regclass)
 quantity     | integer               | not null
 pname        | character varying(30) | not null
 bname        | character varying(30) | not null
 pid          | integer               | not null
 cid          | integer               | not null
Indexes:
    "orderitems_pkey" PRIMARY KEY, btree (orderitem_id)
Foreign-key constraints:
    "orderitems_cid_fkey" FOREIGN KEY (cid) REFERENCES customers(cid)
    "orderitems_pid_fkey" FOREIGN KEY (pid) REFERENCES payments(pid)
    "orderitems_pname_fkey" FOREIGN KEY (pname, bname) REFERENCES products(pname, bname)

(5) FIND ALL PRODUCTS THAT WILL BE OUT-OF STOCK*/
SELECT orderqty.pname, ordered_qty, stock
FROM (
	SELECT pname, SUM(quantity) as ordered_qty
	FROM orderitems
	GROUP BY pname
)as orderqty
INNER JOIN forsale
ON orderqty.pname = forsale.pname
WHERE ordered_qty > stock;
/*
       pname       | ordered_qty | stock
-------------------+-------------+-------
 Soy Face Cleanser |          17 |    10
(1 row)
*/


--QUESTION 6--

/*
(1) Add all the products for a specific Customer from CartItems to OrderItems, 
associated with the corresponding payment id reference. 
This is the operation performed after the customer pays his items in his cart. 
(This case is for a specific customer with his id = 599)*/
INSERT INTO OrderItems (quantity, pname, bname, pid, cid) (
SELECT quantity, pname, bname, pid, c.cid 
FROM CartItems c JOIN (
	/*select MAX pid because pid is type SERIAL so the payment 
    with the largest pid is the most recent payment*/
SELECT cid, MAX(pid) AS pid 
FROM Payments 
WHERE cid = 599
GROUP BY cid) AS p 
ON p.cid = c.cid 
);
/*INSERT 0 1*/
/*
                -------BEFORE-------
 orderitem_id | quantity |           pname            |  bname  | pid | cid
--------------+----------+----------------------------+---------+-----+-----
            4 |        1 | Refreshing Eye Cream       | Origins |  26 | 543
            5 |        1 | Soy Face Cleanser          | Fresh   |  27 | 605
            6 |       16 | Soy Face Cleanser          | Fresh   |  30 | 560
            7 |        1 | Ultra Long Wear Foundation | Lancome |  31 | 598
            8 |        1 | Powder Kiss Lipstick       | MAC     |  35 | 564
(5 rows)
                -------AFTER-------
 orderitem_id | quantity |           pname            |  bname  | pid | cid
--------------+----------+----------------------------+---------+-----+-----
            4 |        1 | Refreshing Eye Cream       | Origins |  26 | 543
            5 |        1 | Soy Face Cleanser          | Fresh   |  27 | 605
            6 |       16 | Soy Face Cleanser          | Fresh   |  30 | 560
            7 |        1 | Ultra Long Wear Foundation | Lancome |  31 | 598
            8 |        1 | Powder Kiss Lipstick       | MAC     |  35 | 564
            9 |        2 | Refreshing Eye Cream       | Origins |  36 | 599
(6 rows)
*/


/*
(2) Delete entries from CartItems after customers checks out
    because now these items have been added to OrderItems
*/
DELETE FROM CartItems
WHERE cid IN ( SELECT c.cid FROM customers c, payments p
                 WHERE c.cid = p.cid);
/*DELETE 6*/
/*
                     --------BEFORE------
 item_id | quantity |           pname            |  bname  | cid
---------+----------+----------------------------+---------+-----
      12 |        1 | Soy Face Cleanser          | Fresh   | 605
      13 |       16 | Soy Face Cleanser          | Fresh   | 560
      14 |        1 | Powder Kiss Lipstick       | MAC     | 564
      15 |        1 | Ultra Long Wear Foundation | Lancome | 598
      16 |        1 | Refreshing Eye Cream       | Origins | 564
      17 |        2 | Refreshing Eye Cream       | Origins | 599
(6 rows)
                     --------AFTER------
 item_id | quantity | pname | bname | cid
---------+----------+-------+-------+-----
(0 rows)                    
*/


/*
(3) Calculate the overall rating of all forsale products by querying data in Rate table */
UPDATE ForSale 
SET overallRating = r.average
FROM (SELECT pname, bname, AVG(rating) AS average FROM Rate GROUP BY (pname, bname)) AS r 
WHERE ForSale.pname = r.pname AND ForSale.bname = r.bname;
/*UPDATE 4*/
/*  
                     --------BEFORE------
           pname            |  bname  | price | stock | volume_ml | overallrating
----------------------------+---------+-------+-------+-----------+---------------
 Soy Face Cleanser          | Fresh   | 20.50 |    10 |        45 |
 Rouge Dior Ultra Lipstick  | Dior    | 45.00 |    14 |        36 |
 Powder Kiss Lipstick       | MAC     | 35.00 |    17 |        40 |
 Ultra Long Wear Foundation | Lancome | 76.00 |    13 |        40 |
 Refreshing Eye Cream       | Origins | 37.00 |    12 |        52 |
(5 rows)

                     --------AFTER------
           pname            |  bname  | price | stock | volume_ml | overallrating
----------------------------+---------+-------+-------+-----------+---------------
 Refreshing Eye Cream       | Origins | 37.00 |    12 |        52 |
 Soy Face Cleanser          | Fresh   | 20.50 |    10 |        45 |             1
 Rouge Dior Ultra Lipstick  | Dior    | 45.00 |    14 |        36 |             5
 Powder Kiss Lipstick       | MAC     | 35.00 |    17 |        40 |             5
 Ultra Long Wear Foundation | Lancome | 76.00 |    13 |        40 |          2.75
(5 rows)
*/

/*
(4) Change the stock for the forsale products when customer order these items*/
UPDATE forsale
SET stock = stock - orderitems.quantity
FROM
Orderitems 
WHERE
forsale.pname = orderitems.pname;
/*UPDATE 4*/
/*
                     --------BEFORE------
           pname            |  bname  | price | stock | volume_ml | overallrating
----------------------------+---------+-------+-------+-----------+---------------
 Powder Kiss Lipstick       | MAC     | 35.00 |    17 |        40 |             5
 Refreshing Eye Cream       | Origins | 37.00 |    12 |        52 |
 Rouge Dior Ultra Lipstick  | Dior    | 45.00 |    14 |        36 |             5
 Soy Face Cleanser          | Fresh   | 20.50 |    10 |        45 |             1
 Ultra Long Wear Foundation | Lancome | 76.00 |    13 |        40 |          2.75
(5 rows)

                     --------AFTER------
           pname            |  bname  | price | stock | volume_ml | overallrating
----------------------------+---------+-------+-------+-----------+---------------
 Powder Kiss Lipstick       | MAC     | 35.00 |    16 |        40 |             5
 Refreshing Eye Cream       | Origins | 37.00 |    11 |        52 |
 Rouge Dior Ultra Lipstick  | Dior    | 45.00 |    14 |        36 |             5
 Soy Face Cleanser          | Fresh   | 20.50 |     9 |        45 |             1
 Ultra Long Wear Foundation | Lancome | 76.00 |    12 |        40 |          2.75
(5 rows)
*/


--QUESTION 7--
/*
(1)
Given the positiveCustomers VIEW, we know the person who gives a 5 score rating to a product. 
We could email this person some recommendation and other samples 
by using the fact that she/he likes this product.*/
CREATE VIEW positiveCustomers(fullname,email, pname,bname)
	AS SELECT c.fullname, c.email, r.pname, r.bname
	FROM customers c, rate r
	WHERE c.cid = r.cid AND r.rating = 5;

SELECT * FROM positiveCustomers LIMIT 5;
/*
    fullname     |                  email                   |           pname            |  bname
-----------------+------------------------------------------+----------------------------+----------
 Xintong Li      | xintong.li@mail.mcgill.ca                | Ultra Long Wear Foundation | Lancome
 Deborah Solomon | torquent@aliquetlobortisnisi.org         | Lip Color                  | TOM FORD
 Elizabeth Kline | Phasellus.nulla.Integer@venenatisvel.net | Powder Kiss Lipstick       | MAC
 Marah Miles     | velit.eu.sem@etipsumcursus.edu           | Channel 5                  | Channel
 Sigourney Kerr  | laoreet.posuere@gravida.net              | Rouge Dior Ultra Lipstick  | Dior
(5 rows)
*/

UPDATE positiveCustomers
SET fullname = 'Lauren Yang'
WHERE fullname = 'Zena Vazquez';
/*cannot update view because this view selects data from 2 relations*/
/*
ERROR:  cannot update view "positivecustomers"
DETAIL:  Views that do not select from a single table or view are not automatically updatable.
HINT:  To enable updating the view, provide an INSTEAD OF UPDATE trigger or an unconditional ON UPDATE DO INSTEAD rule.
cs421=>
*/


/* 
(2)
Given a bad comment, we can track the rate score and the comment for the rating that is smaller than 3*/
CREATE VIEW badcomment
AS SELECT pname,rating,rate_comment FROM RATE WHERE RATING<3;

SELECT * FROM badcomment LIMIT 5;
/*
           pname            | rating |                                                                                                                                                                                                                                                                                        rate_comment                                                                                                                                                                                                                                                                              
----------------------------+--------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 Soy Face Cleanser          |      1 | this worked more as a makeup remover for me. i have dry skin and felt like my cleanser was not working anymore so I wanted to switch it up. i was told in store that this was great, but I wont be buying it again. It made me break out more than I ever have before (I am 25 and really do not have acne - I even started using my clarisonic with it a few times a week). It also has made my skin feel a lot more dry. I would not recommend to anyone who has naturally dry skin/ wants something that is going to help keep your skin clear. quite a disappointment to say the least.
 Ultra Long Wear Foundation |      1 | I hope that Lancome will come back to their senses and return 14 hour formula (or something similar to it). This DOES NOT replace the old 14 hour formula because its loaded with a whole bunch of stuff + more SPF which is not good for some of us, acne prone folks. I have sensitive, acne prone, oily skin and this broke me horribly! I could not believe it! Why fix something if it aint broken? Very, very disappointed.
 Ultra Long Wear Foundation |      1 | I was very disappointed in this product considering its pretty pricey. After trying it out I felt I had residue on my skin and looked like it. It says that it is full coverage but its the opposite. I bought this in hopes of covering my imperfections but it did not do the job. I would only suggest buying this if you have perfect skin and are looking for light coverage. Also you need at least 3 pumps for medium coverage. I will be returning. However I did like the bottle anyways, I do not recommend. Save your money (btw I have combination skin)
 Lip Color                  |      2 | I thought this was going to be my Holy Grail lipstick. I was so excited to try it!!! Love the color in the tube, its perfect! Then I applied it... first I noticed the old musty, granny lipstick smell to it. (Thats a star off) ... then I noticed it really didnt have much pigment to it (another star off) so I applied it twice and the staying power is horrible (another star off). All in all, Im super disappointed in this product. I will NOT repurchase at $58 a tube. its maybe worth $15 at best!.
(4 rows)
*/

UPDATE badcomment
SET rating = 5
WHERE pname = 'Lip Color';
/*update is possible because this view only selects from a single table */
/*
           pname            | rating |                                                                                                                                                                                                                                                                                        rate_comment                                                                                                                                                                                                                                                                              
----------------------------+--------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 Soy Face Cleanser          |      1 | this worked more as a makeup remover for me. i have dry skin and felt like my cleanser was not working anymore so I wanted to switch it up. i was told in store that this was great, but I wont be buying it again. It made me break out more than I ever have before (I am 25 and really do not have acne - I even started using my clarisonic with it a few times a week). It also has made my skin feel a lot more dry. I would not recommend to anyone who has naturally dry skin/ wants something that is going to help keep your skin clear. quite a disappointment to say the least.
 Ultra Long Wear Foundation |      1 | I hope that Lancome will come back to their senses and return 14 hour formula (or something similar to it). This DOES NOT replace the old 14 hour formula because its loaded with a whole bunch of stuff + more SPF which is not good for some of us, acne prone folks. I have sensitive, acne prone, oily skin and this broke me horribly! I could not believe it! Why fix something if it aint broken? Very, very disappointed.
 Ultra Long Wear Foundation |      1 | I was very disappointed in this product considering its pretty pricey. After trying it out I felt I had residue on my skin and looked like it. It says that it is full coverage but its the opposite. I bought this in hopes of covering my imperfections but it did not do the job. I would only suggest buying this if you have perfect skin and are looking for light coverage. Also you need at least 3 pumps for medium coverage. I will be returning. However I did like the bottle anyways, I do not recommend. Save your money (btw I have combination skin)
(3 rows)
*/

/*
   Conditions for a view to be updatable:
1. The view is defined based on one and only one table.
2. The view must include the PRIMARY KEY of the table based upon which the view has been created.
3. The view should not have any field made out of aggregate functions.
4. The view must not have any DISTINCT clause in its definition.
5. The view must not have any GROUP BY or HAVING clause in its definition.
6. The view must not have any SUBQUERIES in its definitions.
7. If the view you want to update is based upon another view, the later should be updatable.
8. Any of the selected output fields (of the view) must not use constants, strings or value expressions.
*/


--QUESTION 8--
/* the rating has to be between 0 and 5*/
ALTER TABLE Rate ADD CONSTRAINT rat CHECK (rating >= 0 AND rating <=5);
/*ALTER TABLE*/
CREATE TABLE Rate
(
	pname  VARCHAR(30) NOT NULL,
	bname VARCHAR(30) NOT NULL,
	cid INTEGER NOT NULL,
	rating INTEGER NOT NULL CONSTRAINT rat CHECK (rating >= 0 AND rating <=5),
	rate_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	rate_comment VARCHAR(1000),
	FOREIGN KEY (pname,bname) REFERENCES Products,
	FOREIGN KEY (cid) REFERENCES Customers,
	PRIMARY KEY(rate_date, pname,bname,cid)
);

/*inserting negative rating will output an error*/
INSERT INTO Rate (pname, bname, cid, rating, rate_comment) 
VALUES (
	'Lip Color',
	'TOM FORD',
	529,
	-1,
	'The worse thing ever!!!!!');
/*
ERROR:  new row for relation "rate" violates check constraint "rat"
DETAIL:  Failing row contains (Lip Color, TOM FORD, 529, -1, 2019-03-01 21:19:40.34744, The worse thing ever!!!!!).
*/


/* a Cart item’s quantity should be greater than 1 when added into the carts*/
ALTER TABLE CartItems ADD CONSTRAINT ratage CHECK(quantity > 0);
/*ALTER TABLE*/
CREATE TABLE CartItems 
(
	item_id SERIAL,
	quantity INT NOT NULL CONSTRAINT ratage CHECK(quantity > 0),
	pname VARCHAR(30) NOT NULL,
	bname VARCHAR(30) NOT NULL,
	cid INT NOT NULL,
	PRIMARY KEY (item_id),
	FOREIGN KEY (pname, bname) REFERENCES Products,
	FOREIGN KEY (cid) REFERENCES Customers
);
/*When trying to insert a cart item whose quantity is -1, it will occur an error*/
INSERT INTO CartItems (quantity, pname, bname, cid) VALUES(-1, 'Refreshing Eye Cream','Origins', 20);
/*ERROR:  new row for relation "cartitems" violates check constraint "ratage"
DETAIL:  Failing row contains (1, -1, Refreshing Eye Cream, Origins, 20).*/


--QUESTION 9--
/*
To populate the tables, we used a website that generate random data (https://generatedata.com).
We used this method to generate data for two of our tables (Customer and Brands).
We simply wrote down each attribute of the table along with the type of data we want.
For example, if we want name as an attribute, we were able to select the type "name" as data and
the website was able randomly general names in the correct format.
We then downloaded those data as .sql files where we simply copy-pasted into our own .sql file.
*/
