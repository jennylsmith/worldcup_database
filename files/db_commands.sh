#!/bin/bash

psql --username=freecodecamp --dbname=postgres -c 'create database worldcup;'
pg_dump -cC --inserts -U freecodecamp worldcup > worldcup.sql
psql -U postgres < worldcup.sql