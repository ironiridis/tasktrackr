#!/bin/bash
pg_dump -sC -d tasktrackr -U postgres > schema.sql
