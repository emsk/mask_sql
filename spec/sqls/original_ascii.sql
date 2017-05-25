INSERT INTO `cats` (`code`, `name`) VALUES ('01','Sora'),('02','Hana'),('03','Leo');
INSERT INTO `cats` (`code`, `name`) VALUES (',0,1,',',S,o,r,a,'),('0,2,','H,a,n,a,'),(',0,3',',L,e,o');
INSERT INTO `cats` (`code`, `name`) VALUES ('01','Sora'),('02','Hana'),('03','Leo')
INSERT INTO `cats` (`code`, `name`)VALUES('01','Sora'),('02','Hana'),('03','Leo');
INSERT INTO cats (`code`, `name`) VALUES ('01','Sora'),('02','Hana'),('03','Leo');
INSERT INTO `cats` VALUES ('01','Sora'),('02','Hana'),('03','Leo');
INSERT INTO `cats` VALUES ('01','Sora'),('02','Hana'),('03','Leo')
INSERT INTO `cats`VALUES('01','Sora'),('02','Hana'),('03','Leo');
INSERT INTO cats VALUES ('01','Sora'),('02','Hana'),('03','Leo');

insert into `cats` (`code`, `name`) values ('01','Sora'),('02','Hana'),('03','Leo');
insert into `cats` (`code`, `name`) values (',0,1,',',S,o,r,a,'),('0,2,','H,a,n,a,'),(',0,3',',L,e,o');
insert into `cats` (`code`, `name`) values ('01','Sora'),('02','Hana'),('03','Leo')
insert into `cats` (`code`, `name`)values('01','Sora'),('02','Hana'),('03','Leo');
insert into cats (`code`, `name`) values ('01','Sora'),('02','Hana'),('03','Leo');
insert into `cats` values ('01','Sora'),('02','Hana'),('03','Leo');
insert into `cats` values ('01','Sora'),('02','Hana'),('03','Leo')
insert into `cats`values('01','Sora'),('02','Hana'),('03','Leo');
insert into cats values ('01','Sora'),('02','Hana'),('03','Leo');

INSERT `cats` (`code`, `name`) VALUES ('01','Sora'),('02','Hana'),('03','Leo');
INSERT `cats` (`code`, `name`) VALUES (',0,1,',',S,o,r,a,'),('0,2,','H,a,n,a,'),(',0,3',',L,e,o');
INSERT `cats` (`code`, `name`) VALUES ('01','Sora'),('02','Hana'),('03','Leo')
INSERT `cats` (`code`, `name`)VALUES('01','Sora'),('02','Hana'),('03','Leo');
INSERT cats (`code`, `name`) VALUES ('01','Sora'),('02','Hana'),('03','Leo');
INSERT `cats` VALUES ('01','Sora'),('02','Hana'),('03','Leo');
INSERT `cats` VALUES ('01','Sora'),('02','Hana'),('03','Leo')
INSERT `cats`VALUES('01','Sora'),('02','Hana'),('03','Leo');
INSERT cats VALUES ('01','Sora'),('02','Hana'),('03','Leo');

INSERT INTO `dogs` (`code`, `name`, `house_id`, `room_id`) VALUES ('01','Pochi',1,1),('02','Rose',1,1),('03','Momo',1,1),('04','Sakura',1,1);
INSERT INTO `dogs` (`code`, `name`, `house_id`, `room_id`) VALUES ('01','Pochi',1,1),('02','Rose',2,1),('03','Momo',1,1),('04','Sakura',1,2);

REPLACE INTO `cats` (`code`, `name`) VALUES ('01','Sora'),('02','Hana'),('03','Leo');
REPLACE INTO `cats` (`code`, `name`) VALUES (',0,1,',',S,o,r,a,'),('0,2,','H,a,n,a,'),(',0,3',',L,e,o');
REPLACE INTO `cats` (`code`, `name`) VALUES ('01','Sora'),('02','Hana'),('03','Leo')
REPLACE INTO `cats` (`code`, `name`)VALUES('01','Sora'),('02','Hana'),('03','Leo');
REPLACE INTO cats (`code`, `name`) VALUES ('01','Sora'),('02','Hana'),('03','Leo');
REPLACE INTO `cats` VALUES ('01','Sora'),('02','Hana'),('03','Leo');
REPLACE INTO `cats` VALUES ('01','Sora'),('02','Hana'),('03','Leo')
REPLACE INTO `cats`VALUES('01','Sora'),('02','Hana'),('03','Leo');
REPLACE INTO cats VALUES ('01','Sora'),('02','Hana'),('03','Leo');

replace into `cats` (`code`, `name`) values ('01','Sora'),('02','Hana'),('03','Leo');
replace into `cats` (`code`, `name`) values (',0,1,',',S,o,r,a,'),('0,2,','H,a,n,a,'),(',0,3',',L,e,o');
replace into `cats` (`code`, `name`) values ('01','Sora'),('02','Hana'),('03','Leo')
replace into `cats` (`code`, `name`)values('01','Sora'),('02','Hana'),('03','Leo');
replace into cats (`code`, `name`) values ('01','Sora'),('02','Hana'),('03','Leo');
replace into `cats` values ('01','Sora'),('02','Hana'),('03','Leo');
replace into `cats` values ('01','Sora'),('02','Hana'),('03','Leo')
replace into `cats`values('01','Sora'),('02','Hana'),('03','Leo');
replace into cats values ('01','Sora'),('02','Hana'),('03','Leo');

REPLACE `cats` (`code`, `name`) VALUES ('01','Sora'),('02','Hana'),('03','Leo');
REPLACE `cats` (`code`, `name`) VALUES (',0,1,',',S,o,r,a,'),('0,2,','H,a,n,a,'),(',0,3',',L,e,o');
REPLACE `cats` (`code`, `name`) VALUES ('01','Sora'),('02','Hana'),('03','Leo')
REPLACE `cats` (`code`, `name`)VALUES('01','Sora'),('02','Hana'),('03','Leo');
REPLACE cats (`code`, `name`) VALUES ('01','Sora'),('02','Hana'),('03','Leo');
REPLACE `cats` VALUES ('01','Sora'),('02','Hana'),('03','Leo');
REPLACE `cats` VALUES ('01','Sora'),('02','Hana'),('03','Leo')
REPLACE `cats`VALUES('01','Sora'),('02','Hana'),('03','Leo');
REPLACE cats VALUES ('01','Sora'),('02','Hana'),('03','Leo');

REPLACE INTO `dogs` (`code`, `name`, `house_id`, `room_id`) VALUES ('01','Pochi',1,1),('02','Rose',1,1),('03','Momo',1,1),('04','Sakura',1,1);
REPLACE INTO `dogs` (`code`, `name`, `house_id`, `room_id`) VALUES ('01','Pochi',1,1),('02','Rose',2,1),('03','Momo',1,1),('04','Sakura',1,2);

COPY cats (code, name) FROM stdin;
01	Sora
02	Hana
03	Leo
\.

copy cats (code, name) from stdin;
01	Sora
02	Hana
03	Leo
\.

COPY dogs (code, name, house_id, room_id) FROM stdin;
01	Pochi	1	1
02	Rose	1	1
03	Momo	1	1
04	Sakura	1	1
\.

COPY dogs (code, name, house_id, room_id) FROM stdin;
01	Pochi	1	1
02	Rose	2	1
03	Momo	1	1
04	Sakura	1	2
\.
