--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: tasktrackr; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE tasktrackr WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'C' LC_CTYPE = 'C';


ALTER DATABASE tasktrackr OWNER TO postgres;

\connect tasktrackr

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: v0; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA v0;


ALTER SCHEMA v0 OWNER TO postgres;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = v0, pg_catalog;

--
-- Name: perm_satisfies_condition(integer, json); Type: FUNCTION; Schema: v0; Owner: postgres
--

CREATE FUNCTION perm_satisfies_condition(userid integer, condition json) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
	ckey character varying;
	cval json;
	res boolean;
BEGIN
	FOR ckey, cval IN SELECT * FROM json_each(condition) LOOP
		CASE ckey
			WHEN 'allof' THEN
				FOR res IN SELECT v0.perm_satisfies_condition(userid, value) FROM json_array_elements(cval) LOOP
					IF res == false THEN
						RETURN false;
					END IF;
				END LOOP;
				RETURN true;
			WHEN 'anyof' THEN
				FOR res IN SELECT v0.perm_satisfies_condition(userid, value) FROM json_array_elements(cval) LOOP					IF res == true THEN						RETURN true;					END IF;				END LOOP;				RETURN false;
			WHEN 'noneof' THEN
				FOR res IN SELECT v0.perm_satisfies_condition(userid, value) FROM json_array_elements(cval) LOOP					IF res == true THEN						RETURN false;					END IF;				END LOOP;				RETURN true;
			
			WHEN 'not' THEN
				RETURN NOT(v0.perm_satisfies_condition(userid, value));
			
			WHEN 'userid_equals' THEN
				RETURN (cval::int == userid);
			
		END CASE;
	END LOOP;
	RETURN NULL;
END;
$$;


ALTER FUNCTION v0.perm_satisfies_condition(userid integer, condition json) OWNER TO postgres;

--
-- Name: task_permissions(integer); Type: FUNCTION; Schema: v0; Owner: postgres
--

CREATE FUNCTION task_permissions(userid integer) RETURNS json
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
	
	
	RETURN NULL;
END;
$$;


ALTER FUNCTION v0.task_permissions(userid integer) OWNER TO postgres;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: vs_database_diagrams; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE vs_database_diagrams (
    name character varying(80),
    diadata text,
    comment character varying(1022),
    preview text,
    lockinfo character varying(80),
    locktime timestamp with time zone,
    version character varying(80)
);


ALTER TABLE vs_database_diagrams OWNER TO postgres;

SET search_path = v0, pg_catalog;

--
-- Name: discussion; Type: TABLE; Schema: v0; Owner: postgres; Tablespace: 
--

CREATE TABLE discussion (
    commentid integer NOT NULL,
    userid integer NOT NULL,
    comment_ts timestamp without time zone NOT NULL,
    taskid integer NOT NULL,
    body text NOT NULL
);


ALTER TABLE discussion OWNER TO postgres;

--
-- Name: tags; Type: TABLE; Schema: v0; Owner: postgres; Tablespace: 
--

CREATE TABLE tags (
    tagid integer NOT NULL,
    label_en character varying(2044) NOT NULL,
    color character varying(3) DEFAULT '000'::character varying NOT NULL,
    text_bold boolean DEFAULT false NOT NULL,
    text_italic boolean DEFAULT false NOT NULL,
    text_underline boolean DEFAULT false NOT NULL,
    border_size integer DEFAULT 1 NOT NULL,
    border_color character varying(3) DEFAULT '000'::character varying NOT NULL,
    border_dashed boolean DEFAULT false NOT NULL
);


ALTER TABLE tags OWNER TO postgres;

--
-- Name: task_actions; Type: TABLE; Schema: v0; Owner: postgres; Tablespace: 
--

CREATE TABLE task_actions (
    actionid integer NOT NULL,
    stateid_start integer NOT NULL,
    stateid_end integer NOT NULL,
    label_en character varying(2044) NOT NULL,
    permissions json
);


ALTER TABLE task_actions OWNER TO postgres;

--
-- Name: task_state_tags; Type: TABLE; Schema: v0; Owner: postgres; Tablespace: 
--

CREATE TABLE task_state_tags (
    stateid integer NOT NULL,
    tagid integer NOT NULL
);


ALTER TABLE task_state_tags OWNER TO postgres;

--
-- Name: task_states; Type: TABLE; Schema: v0; Owner: postgres; Tablespace: 
--

CREATE TABLE task_states (
    stateid integer NOT NULL,
    label_en character varying(2044) NOT NULL,
    permissions json,
    attr_needs_attention boolean,
    attr_urgent boolean,
    attr_complete boolean
);


ALTER TABLE task_states OWNER TO postgres;

--
-- Name: COLUMN task_states.permissions; Type: COMMENT; Schema: v0; Owner: postgres
--

COMMENT ON COLUMN task_states.permissions IS 'This value is overlaid onto any task with this status.';


--
-- Name: task_tags; Type: TABLE; Schema: v0; Owner: postgres; Tablespace: 
--

CREATE TABLE task_tags (
    taskid integer NOT NULL,
    tagid integer NOT NULL
);


ALTER TABLE task_tags OWNER TO postgres;

--
-- Name: tasks; Type: TABLE; Schema: v0; Owner: postgres; Tablespace: 
--

CREATE TABLE tasks (
    taskid integer NOT NULL,
    title character varying(2044) NOT NULL,
    created_ts timestamp without time zone NOT NULL,
    created_userid integer NOT NULL,
    stateid integer DEFAULT 0 NOT NULL,
    parentid integer DEFAULT 0 NOT NULL
);


ALTER TABLE tasks OWNER TO postgres;

--
-- Name: tasks_taskid_seq; Type: SEQUENCE; Schema: v0; Owner: postgres
--

CREATE SEQUENCE tasks_taskid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE tasks_taskid_seq OWNER TO postgres;

--
-- Name: tasks_taskid_seq; Type: SEQUENCE OWNED BY; Schema: v0; Owner: postgres
--

ALTER SEQUENCE tasks_taskid_seq OWNED BY tasks.taskid;


--
-- Name: users; Type: TABLE; Schema: v0; Owner: postgres; Tablespace: 
--

CREATE TABLE users (
    userid integer NOT NULL,
    username character varying(2044) NOT NULL,
    details json,
    permissions json
);


ALTER TABLE users OWNER TO postgres;

--
-- Name: COLUMN users.permissions; Type: COMMENT; Schema: v0; Owner: postgres
--

COMMENT ON COLUMN users.permissions IS 'A task can have special permissions applied uniquely.';


--
-- Name: users_userid_seq; Type: SEQUENCE; Schema: v0; Owner: postgres
--

CREATE SEQUENCE users_userid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE users_userid_seq OWNER TO postgres;

--
-- Name: users_userid_seq; Type: SEQUENCE OWNED BY; Schema: v0; Owner: postgres
--

ALTER SEQUENCE users_userid_seq OWNED BY users.userid;


--
-- Name: vs_database_diagrams; Type: TABLE; Schema: v0; Owner: postgres; Tablespace: 
--

CREATE TABLE vs_database_diagrams (
    name character varying(80),
    diadata text,
    comment character varying(1022),
    preview text,
    lockinfo character varying(80),
    locktime timestamp with time zone,
    version character varying(80)
);


ALTER TABLE vs_database_diagrams OWNER TO postgres;

--
-- Name: taskid; Type: DEFAULT; Schema: v0; Owner: postgres
--

ALTER TABLE ONLY tasks ALTER COLUMN taskid SET DEFAULT nextval('tasks_taskid_seq'::regclass);


--
-- Name: userid; Type: DEFAULT; Schema: v0; Owner: postgres
--

ALTER TABLE ONLY users ALTER COLUMN userid SET DEFAULT nextval('users_userid_seq'::regclass);


--
-- Name: discussion_pkey; Type: CONSTRAINT; Schema: v0; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY discussion
    ADD CONSTRAINT discussion_pkey PRIMARY KEY (commentid);


--
-- Name: tags_pkey; Type: CONSTRAINT; Schema: v0; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (tagid);


--
-- Name: task_actions_pkey; Type: CONSTRAINT; Schema: v0; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY task_actions
    ADD CONSTRAINT task_actions_pkey PRIMARY KEY (actionid);


--
-- Name: task_state_tags_pkey; Type: CONSTRAINT; Schema: v0; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY task_state_tags
    ADD CONSTRAINT task_state_tags_pkey PRIMARY KEY (stateid, tagid);


--
-- Name: task_states_pkey; Type: CONSTRAINT; Schema: v0; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY task_states
    ADD CONSTRAINT task_states_pkey PRIMARY KEY (stateid);


--
-- Name: task_tags_pkey; Type: CONSTRAINT; Schema: v0; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY task_tags
    ADD CONSTRAINT task_tags_pkey PRIMARY KEY (tagid, taskid);


--
-- Name: tasks_pkey; Type: CONSTRAINT; Schema: v0; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (taskid);


--
-- Name: unique_username; Type: CONSTRAINT; Schema: v0; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT unique_username UNIQUE (username);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: v0; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (userid);


--
-- Name: discussion_taskid_idx; Type: INDEX; Schema: v0; Owner: postgres; Tablespace: 
--

CREATE INDEX discussion_taskid_idx ON discussion USING btree (taskid);


--
-- Name: discussion_userid_idx; Type: INDEX; Schema: v0; Owner: postgres; Tablespace: 
--

CREATE INDEX discussion_userid_idx ON discussion USING btree (userid);


--
-- Name: index_created_ts; Type: INDEX; Schema: v0; Owner: postgres; Tablespace: 
--

CREATE INDEX index_created_ts ON tasks USING btree (created_ts);


--
-- Name: index_stateid; Type: INDEX; Schema: v0; Owner: postgres; Tablespace: 
--

CREATE INDEX index_stateid ON task_state_tags USING btree (stateid);


--
-- Name: index_tagid; Type: INDEX; Schema: v0; Owner: postgres; Tablespace: 
--

CREATE INDEX index_tagid ON task_state_tags USING btree (tagid);


--
-- Name: task_actions_stateid_end_idx; Type: INDEX; Schema: v0; Owner: postgres; Tablespace: 
--

CREATE INDEX task_actions_stateid_end_idx ON task_actions USING btree (stateid_end);


--
-- Name: task_actions_stateid_start_idx; Type: INDEX; Schema: v0; Owner: postgres; Tablespace: 
--

CREATE INDEX task_actions_stateid_start_idx ON task_actions USING btree (stateid_start);


--
-- Name: task_tags_tagid_idx; Type: INDEX; Schema: v0; Owner: postgres; Tablespace: 
--

CREATE INDEX task_tags_tagid_idx ON task_tags USING btree (tagid);


--
-- Name: task_tags_taskid_idx; Type: INDEX; Schema: v0; Owner: postgres; Tablespace: 
--

CREATE INDEX task_tags_taskid_idx ON task_tags USING btree (taskid);


--
-- Name: tasks_created_userid_idx; Type: INDEX; Schema: v0; Owner: postgres; Tablespace: 
--

CREATE INDEX tasks_created_userid_idx ON tasks USING btree (created_userid);


--
-- Name: tasks_parentid_idx; Type: INDEX; Schema: v0; Owner: postgres; Tablespace: 
--

CREATE INDEX tasks_parentid_idx ON tasks USING btree (parentid);


--
-- Name: tasks_stateid_idx; Type: INDEX; Schema: v0; Owner: postgres; Tablespace: 
--

CREATE INDEX tasks_stateid_idx ON tasks USING btree (stateid);


--
-- Name: lnk_discussion_tasks2; Type: FK CONSTRAINT; Schema: v0; Owner: postgres
--

ALTER TABLE ONLY discussion
    ADD CONSTRAINT lnk_discussion_tasks2 FOREIGN KEY (taskid) REFERENCES tasks(taskid) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: lnk_discussion_users2; Type: FK CONSTRAINT; Schema: v0; Owner: postgres
--

ALTER TABLE ONLY discussion
    ADD CONSTRAINT lnk_discussion_users2 FOREIGN KEY (userid) REFERENCES users(userid) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: lnk_task_actions_task_states2; Type: FK CONSTRAINT; Schema: v0; Owner: postgres
--

ALTER TABLE ONLY task_actions
    ADD CONSTRAINT lnk_task_actions_task_states2 FOREIGN KEY (stateid_start) REFERENCES task_states(stateid) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: lnk_task_actions_task_states3; Type: FK CONSTRAINT; Schema: v0; Owner: postgres
--

ALTER TABLE ONLY task_actions
    ADD CONSTRAINT lnk_task_actions_task_states3 FOREIGN KEY (stateid_end) REFERENCES task_states(stateid) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: lnk_task_state_tags_tags; Type: FK CONSTRAINT; Schema: v0; Owner: postgres
--

ALTER TABLE ONLY task_state_tags
    ADD CONSTRAINT lnk_task_state_tags_tags FOREIGN KEY (tagid) REFERENCES tags(tagid) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: lnk_task_state_tags_task_states; Type: FK CONSTRAINT; Schema: v0; Owner: postgres
--

ALTER TABLE ONLY task_state_tags
    ADD CONSTRAINT lnk_task_state_tags_task_states FOREIGN KEY (stateid) REFERENCES task_states(stateid) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: lnk_task_tags_tags; Type: FK CONSTRAINT; Schema: v0; Owner: postgres
--

ALTER TABLE ONLY task_tags
    ADD CONSTRAINT lnk_task_tags_tags FOREIGN KEY (tagid) REFERENCES tags(tagid) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: lnk_task_tags_tasks; Type: FK CONSTRAINT; Schema: v0; Owner: postgres
--

ALTER TABLE ONLY task_tags
    ADD CONSTRAINT lnk_task_tags_tasks FOREIGN KEY (taskid) REFERENCES tasks(taskid) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: lnk_tasks_task_states2; Type: FK CONSTRAINT; Schema: v0; Owner: postgres
--

ALTER TABLE ONLY tasks
    ADD CONSTRAINT lnk_tasks_task_states2 FOREIGN KEY (stateid) REFERENCES task_states(stateid) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: lnk_tasks_tasks; Type: FK CONSTRAINT; Schema: v0; Owner: postgres
--

ALTER TABLE ONLY tasks
    ADD CONSTRAINT lnk_tasks_tasks FOREIGN KEY (parentid) REFERENCES tasks(taskid) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: lnk_tasks_users2; Type: FK CONSTRAINT; Schema: v0; Owner: postgres
--

ALTER TABLE ONLY tasks
    ADD CONSTRAINT lnk_tasks_users2 FOREIGN KEY (created_userid) REFERENCES users(userid) MATCH FULL ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

