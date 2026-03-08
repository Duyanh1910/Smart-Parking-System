create database nha_xe_thong_minh;
create table users
(
    id       int auto_increment primary key,
    username varchar(50) unique not null,
    password varchar(255)       not null
);

create table vehicle
(
    id       int auto_increment primary key,
    plate_id varchar(15) unique not null
);

create table parking_id
(
    id           int auto_increment primary key,
    plate_id     varchar(15) not null,
    checkIn_time datetime
);
create table notification
(
    id    int auto_increment primary key,
    title varchar(30) not null
);

SELECT *
FROM users;
SELECT *
FROM vehicle;
SELECT *
FROM parking_id
ORDER BY checkIn_time DESC;

SELECT *
FROM notification;
