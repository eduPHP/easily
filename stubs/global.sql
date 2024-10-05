CREATE DATABASE IF NOT EXISTS easily;

create table if not exists easily.projects
(
    id            int auto_increment primary key,
    name          varchar(50)  null,
    slug          varchar(50)  not null,
    domain        varchar(50)  not null,
    php           varchar(10)  not null,
    root          varchar(255) not null,
    created_at    datetime     null,
    last_start_at datetime     null,
    constraint slug
        unique (slug)
);

