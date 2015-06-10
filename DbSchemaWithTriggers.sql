--
-- PostgreSQL database dump
--

-- Dumped from database version 9.3.7
-- Dumped by pg_dump version 9.4.2
-- Started on 2015-06-10 10:25:31 NOVT

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 181 (class 3079 OID 11759)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2012 (class 0 OID 0)
-- Dependencies: 181
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- TOC entry 194 (class 1255 OID 16473)
-- Name: IncDomainSerial(integer); Type: FUNCTION; Schema: public; Owner: dns
--

CREATE FUNCTION "IncDomainSerial"(domid integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $_$DECLARE
  soacursor CURSOR FOR SELECT id,content FROM records WHERE domain_id=$1 AND type='SOA' LIMIT 1;
  soarecid int;
  res_soaserial varchar;
  soacontent varchar;
  res_soacontent varchar;
BEGIN
   OPEN soacursor;
   FETCH FIRST FROM soacursor INTO soarecid,soacontent;
   CLOSE soacursor;
   res_soacontent=split_part(soacontent,' ', 1) || ' ' ||split_part(soacontent,' ', 2);
   res_soaserial=int4(split_part(soacontent,' ', 3))+1;
   UPDATE records SET content=res_soacontent || ' ' || res_soaserial WHERE id=soarecid;
   RETURN res_soaserial;
END;
$_$;


ALTER FUNCTION public."IncDomainSerial"(domid integer) OWNER TO dns;

--
-- TOC entry 195 (class 1255 OID 16474)
-- Name: serialupdateondatachange(); Type: FUNCTION; Schema: public; Owner: dns
--

CREATE FUNCTION serialupdateondatachange() RETURNS trigger
    LANGUAGE plpgsql
    AS $$BEGIN

IF (TG_OP = 'INSERT') OR (TG_OP = 'UPDATE') THEN
    IF NEW.type != 'SOA' THEN
        PERFORM "IncDomainSerial"(NEW.domain_id);
        END IF;
        RETURN NEW;
END IF;

IF (TG_OP = 'DELETE') THEN
        PERFORM "IncDomainSerial"(OLD.domain_id);
        RETURN OLD;
END IF;

END;$$;


ALTER FUNCTION public.serialupdateondatachange() OWNER TO dns;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 178 (class 1259 OID 16444)
-- Name: cryptokeys; Type: TABLE; Schema: public; Owner: dns; Tablespace: 
--

CREATE TABLE cryptokeys (
    id integer NOT NULL,
    domain_id integer,
    flags integer NOT NULL,
    active boolean,
    content text
);


ALTER TABLE cryptokeys OWNER TO dns;

--
-- TOC entry 177 (class 1259 OID 16442)
-- Name: cryptokeys_id_seq; Type: SEQUENCE; Schema: public; Owner: dns
--

CREATE SEQUENCE cryptokeys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE cryptokeys_id_seq OWNER TO dns;

--
-- TOC entry 2013 (class 0 OID 0)
-- Dependencies: 177
-- Name: cryptokeys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dns
--

ALTER SEQUENCE cryptokeys_id_seq OWNED BY cryptokeys.id;


--
-- TOC entry 176 (class 1259 OID 16427)
-- Name: domainmetadata; Type: TABLE; Schema: public; Owner: dns; Tablespace: 
--

CREATE TABLE domainmetadata (
    id integer NOT NULL,
    domain_id integer,
    kind character varying(16),
    content text
);


ALTER TABLE domainmetadata OWNER TO dns;

--
-- TOC entry 175 (class 1259 OID 16425)
-- Name: domainmetadata_id_seq; Type: SEQUENCE; Schema: public; Owner: dns
--

CREATE SEQUENCE domainmetadata_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE domainmetadata_id_seq OWNER TO dns;

--
-- TOC entry 2014 (class 0 OID 0)
-- Dependencies: 175
-- Name: domainmetadata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dns
--

ALTER SEQUENCE domainmetadata_id_seq OWNED BY domainmetadata.id;


--
-- TOC entry 171 (class 1259 OID 16388)
-- Name: domains; Type: TABLE; Schema: public; Owner: dns; Tablespace: 
--

CREATE TABLE domains (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    master character varying(128) DEFAULT NULL::character varying,
    last_check integer,
    type character varying(6) NOT NULL,
    notified_serial integer,
    account character varying(40) DEFAULT NULL::character varying
);


ALTER TABLE domains OWNER TO dns;

--
-- TOC entry 170 (class 1259 OID 16386)
-- Name: domains_id_seq; Type: SEQUENCE; Schema: public; Owner: dns
--

CREATE SEQUENCE domains_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE domains_id_seq OWNER TO dns;

--
-- TOC entry 2015 (class 0 OID 0)
-- Dependencies: 170
-- Name: domains_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dns
--

ALTER SEQUENCE domains_id_seq OWNED BY domains.id;


--
-- TOC entry 173 (class 1259 OID 16399)
-- Name: records; Type: TABLE; Schema: public; Owner: dns; Tablespace: 
--

CREATE TABLE records (
    id integer NOT NULL,
    domain_id integer,
    name character varying(255) DEFAULT NULL::character varying,
    type character varying(10) DEFAULT NULL::character varying,
    content character varying(65535) DEFAULT NULL::character varying,
    ttl integer,
    prio integer,
    change_date integer,
    ordername character varying(255),
    auth boolean
);


ALTER TABLE records OWNER TO dns;

--
-- TOC entry 172 (class 1259 OID 16397)
-- Name: records_id_seq; Type: SEQUENCE; Schema: public; Owner: dns
--

CREATE SEQUENCE records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE records_id_seq OWNER TO dns;

--
-- TOC entry 2016 (class 0 OID 0)
-- Dependencies: 172
-- Name: records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dns
--

ALTER SEQUENCE records_id_seq OWNED BY records.id;


--
-- TOC entry 174 (class 1259 OID 16420)
-- Name: supermasters; Type: TABLE; Schema: public; Owner: dns; Tablespace: 
--

CREATE TABLE supermasters (
    ip character varying(64) NOT NULL,
    nameserver character varying(255) NOT NULL,
    account character varying(40) DEFAULT NULL::character varying
);


ALTER TABLE supermasters OWNER TO dns;

--
-- TOC entry 180 (class 1259 OID 16461)
-- Name: tsigkeys; Type: TABLE; Schema: public; Owner: dns; Tablespace: 
--

CREATE TABLE tsigkeys (
    id integer NOT NULL,
    name character varying(255),
    algorithm character varying(50),
    secret character varying(255)
);


ALTER TABLE tsigkeys OWNER TO dns;

--
-- TOC entry 179 (class 1259 OID 16459)
-- Name: tsigkeys_id_seq; Type: SEQUENCE; Schema: public; Owner: dns
--

CREATE SEQUENCE tsigkeys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE tsigkeys_id_seq OWNER TO dns;

--
-- TOC entry 2017 (class 0 OID 0)
-- Dependencies: 179
-- Name: tsigkeys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dns
--

ALTER SEQUENCE tsigkeys_id_seq OWNED BY tsigkeys.id;


--
-- TOC entry 1874 (class 2604 OID 16447)
-- Name: id; Type: DEFAULT; Schema: public; Owner: dns
--

ALTER TABLE ONLY cryptokeys ALTER COLUMN id SET DEFAULT nextval('cryptokeys_id_seq'::regclass);


--
-- TOC entry 1873 (class 2604 OID 16430)
-- Name: id; Type: DEFAULT; Schema: public; Owner: dns
--

ALTER TABLE ONLY domainmetadata ALTER COLUMN id SET DEFAULT nextval('domainmetadata_id_seq'::regclass);


--
-- TOC entry 1865 (class 2604 OID 16391)
-- Name: id; Type: DEFAULT; Schema: public; Owner: dns
--

ALTER TABLE ONLY domains ALTER COLUMN id SET DEFAULT nextval('domains_id_seq'::regclass);


--
-- TOC entry 1868 (class 2604 OID 16402)
-- Name: id; Type: DEFAULT; Schema: public; Owner: dns
--

ALTER TABLE ONLY records ALTER COLUMN id SET DEFAULT nextval('records_id_seq'::regclass);


--
-- TOC entry 1875 (class 2604 OID 16464)
-- Name: id; Type: DEFAULT; Schema: public; Owner: dns
--

ALTER TABLE ONLY tsigkeys ALTER COLUMN id SET DEFAULT nextval('tsigkeys_id_seq'::regclass);


--
-- TOC entry 1889 (class 2606 OID 16452)
-- Name: cryptokeys_pkey; Type: CONSTRAINT; Schema: public; Owner: dns; Tablespace: 
--

ALTER TABLE ONLY cryptokeys
    ADD CONSTRAINT cryptokeys_pkey PRIMARY KEY (id);


--
-- TOC entry 1887 (class 2606 OID 16435)
-- Name: domainmetadata_pkey; Type: CONSTRAINT; Schema: public; Owner: dns; Tablespace: 
--

ALTER TABLE ONLY domainmetadata
    ADD CONSTRAINT domainmetadata_pkey PRIMARY KEY (id);


--
-- TOC entry 1877 (class 2606 OID 16395)
-- Name: domains_pkey; Type: CONSTRAINT; Schema: public; Owner: dns; Tablespace: 
--

ALTER TABLE ONLY domains
    ADD CONSTRAINT domains_pkey PRIMARY KEY (id);


--
-- TOC entry 1884 (class 2606 OID 16411)
-- Name: records_pkey; Type: CONSTRAINT; Schema: public; Owner: dns; Tablespace: 
--

ALTER TABLE ONLY records
    ADD CONSTRAINT records_pkey PRIMARY KEY (id);


--
-- TOC entry 1893 (class 2606 OID 16469)
-- Name: tsigkeys_pkey; Type: CONSTRAINT; Schema: public; Owner: dns; Tablespace: 
--

ALTER TABLE ONLY tsigkeys
    ADD CONSTRAINT tsigkeys_pkey PRIMARY KEY (id);


--
-- TOC entry 1879 (class 1259 OID 16419)
-- Name: domain_id; Type: INDEX; Schema: public; Owner: dns; Tablespace: 
--

CREATE INDEX domain_id ON records USING btree (domain_id);


--
-- TOC entry 1890 (class 1259 OID 16458)
-- Name: domainidindex; Type: INDEX; Schema: public; Owner: dns; Tablespace: 
--

CREATE INDEX domainidindex ON cryptokeys USING btree (domain_id);


--
-- TOC entry 1885 (class 1259 OID 16441)
-- Name: domainidmetaindex; Type: INDEX; Schema: public; Owner: dns; Tablespace: 
--

CREATE INDEX domainidmetaindex ON domainmetadata USING btree (domain_id);


--
-- TOC entry 1878 (class 1259 OID 16396)
-- Name: name_index; Type: INDEX; Schema: public; Owner: dns; Tablespace: 
--

CREATE UNIQUE INDEX name_index ON domains USING btree (name);


--
-- TOC entry 1891 (class 1259 OID 16470)
-- Name: namealgoindex; Type: INDEX; Schema: public; Owner: dns; Tablespace: 
--

CREATE UNIQUE INDEX namealgoindex ON tsigkeys USING btree (name, algorithm);


--
-- TOC entry 1880 (class 1259 OID 16472)
-- Name: nametype_index; Type: INDEX; Schema: public; Owner: dns; Tablespace: 
--

CREATE INDEX nametype_index ON records USING btree (name, type);


--
-- TOC entry 1881 (class 1259 OID 16417)
-- Name: rec_name_index; Type: INDEX; Schema: public; Owner: dns; Tablespace: 
--

CREATE INDEX rec_name_index ON records USING btree (name);


--
-- TOC entry 1882 (class 1259 OID 16424)
-- Name: recordorder; Type: INDEX; Schema: public; Owner: dns; Tablespace: 
--

CREATE INDEX recordorder ON records USING btree (domain_id, ordername text_pattern_ops);


--
-- TOC entry 1897 (class 2620 OID 16475)
-- Name: UpdateSerial; Type: TRIGGER; Schema: public; Owner: dns
--

CREATE TRIGGER "UpdateSerial" BEFORE INSERT OR DELETE OR UPDATE ON records FOR EACH ROW EXECUTE PROCEDURE serialupdateondatachange();


--
-- TOC entry 1896 (class 2606 OID 16453)
-- Name: cryptokeys_domain_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dns
--

ALTER TABLE ONLY cryptokeys
    ADD CONSTRAINT cryptokeys_domain_id_fkey FOREIGN KEY (domain_id) REFERENCES domains(id) ON DELETE CASCADE;


--
-- TOC entry 1894 (class 2606 OID 16412)
-- Name: domain_exists; Type: FK CONSTRAINT; Schema: public; Owner: dns
--

ALTER TABLE ONLY records
    ADD CONSTRAINT domain_exists FOREIGN KEY (domain_id) REFERENCES domains(id) ON DELETE CASCADE;


--
-- TOC entry 1895 (class 2606 OID 16436)
-- Name: domainmetadata_domain_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dns
--

ALTER TABLE ONLY domainmetadata
    ADD CONSTRAINT domainmetadata_domain_id_fkey FOREIGN KEY (domain_id) REFERENCES domains(id) ON DELETE CASCADE;


--
-- TOC entry 2011 (class 0 OID 0)
-- Dependencies: 5
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2015-06-10 10:26:15 NOVT

--
-- PostgreSQL database dump complete
--

