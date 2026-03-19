--
-- PostgreSQL database dump
--

\restrict mCouRPhpZZJ1evDIZrvZZDHdyGQ028rD5j5rPsekNUS4eao79qJQM3WMfW4koz2

-- Dumped from database version 18.0
-- Dumped by pg_dump version 18.0

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: contractors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.contractors (
    id character varying(20) NOT NULL,
    name character varying(200) NOT NULL,
    inn character varying(20),
    address text,
    phone character varying(50),
    is_buyer boolean DEFAULT false,
    is_supplier boolean DEFAULT false
);


ALTER TABLE public.contractors OWNER TO postgres;

--
-- Name: cost_calculation_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cost_calculation_items (
    id integer NOT NULL,
    calculation_id integer NOT NULL,
    material_id integer NOT NULL,
    quantity numeric(10,3) NOT NULL,
    price numeric(10,2) NOT NULL,
    total numeric(10,2) GENERATED ALWAYS AS ((quantity * price)) STORED
);


ALTER TABLE public.cost_calculation_items OWNER TO postgres;

--
-- Name: cost_calculation_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cost_calculation_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cost_calculation_items_id_seq OWNER TO postgres;

--
-- Name: cost_calculation_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cost_calculation_items_id_seq OWNED BY public.cost_calculation_items.id;


--
-- Name: cost_calculations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cost_calculations (
    id integer NOT NULL,
    product_id integer NOT NULL,
    specification_id integer NOT NULL,
    total numeric(10,2) NOT NULL,
    date date DEFAULT CURRENT_DATE NOT NULL
);


ALTER TABLE public.cost_calculations OWNER TO postgres;

--
-- Name: cost_calculations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cost_calculations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cost_calculations_id_seq OWNER TO postgres;

--
-- Name: cost_calculations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cost_calculations_id_seq OWNED BY public.cost_calculations.id;


--
-- Name: nomenclature; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.nomenclature (
    id integer NOT NULL,
    name character varying(200) NOT NULL,
    unit character varying(20) NOT NULL,
    type character varying(20) NOT NULL,
    CONSTRAINT nomenclature_type_check CHECK (((type)::text = ANY ((ARRAY['product'::character varying, 'material'::character varying])::text[])))
);


ALTER TABLE public.nomenclature OWNER TO postgres;

--
-- Name: nomenclature_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.nomenclature_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.nomenclature_id_seq OWNER TO postgres;

--
-- Name: nomenclature_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.nomenclature_id_seq OWNED BY public.nomenclature.id;


--
-- Name: order_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_items (
    id integer NOT NULL,
    order_id integer NOT NULL,
    product_id integer NOT NULL,
    quantity numeric(10,3) NOT NULL,
    price numeric(10,2) NOT NULL,
    total numeric(10,2) GENERATED ALWAYS AS ((quantity * price)) STORED
);


ALTER TABLE public.order_items OWNER TO postgres;

--
-- Name: order_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.order_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.order_items_id_seq OWNER TO postgres;

--
-- Name: order_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.order_items_id_seq OWNED BY public.order_items.id;


--
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    id integer NOT NULL,
    number character varying(50) NOT NULL,
    date date DEFAULT CURRENT_DATE NOT NULL,
    contractor_id character varying(20) NOT NULL
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- Name: orders_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.orders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.orders_id_seq OWNER TO postgres;

--
-- Name: orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.orders_id_seq OWNED BY public.orders.id;


--
-- Name: prices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.prices (
    id integer NOT NULL,
    nomenclat_id integer NOT NULL,
    price numeric(10,2) NOT NULL,
    date date DEFAULT CURRENT_DATE NOT NULL
);


ALTER TABLE public.prices OWNER TO postgres;

--
-- Name: prices_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.prices_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.prices_id_seq OWNER TO postgres;

--
-- Name: prices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.prices_id_seq OWNED BY public.prices.id;


--
-- Name: production_output; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.production_output (
    id integer NOT NULL,
    production_id integer NOT NULL,
    product_id integer NOT NULL,
    specification_id integer NOT NULL,
    quantity numeric(10,3) NOT NULL
);


ALTER TABLE public.production_output OWNER TO postgres;

--
-- Name: production_output_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.production_output_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.production_output_id_seq OWNER TO postgres;

--
-- Name: production_output_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.production_output_id_seq OWNED BY public.production_output.id;


--
-- Name: productions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.productions (
    id integer NOT NULL,
    number character varying(50) NOT NULL,
    date date DEFAULT CURRENT_DATE NOT NULL,
    order_id integer
);


ALTER TABLE public.productions OWNER TO postgres;

--
-- Name: productions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.productions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.productions_id_seq OWNER TO postgres;

--
-- Name: productions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.productions_id_seq OWNED BY public.productions.id;


--
-- Name: specification_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.specification_items (
    id integer NOT NULL,
    specification_id integer NOT NULL,
    material_id integer NOT NULL,
    quantity numeric(10,3) NOT NULL
);


ALTER TABLE public.specification_items OWNER TO postgres;

--
-- Name: specification_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.specification_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.specification_items_id_seq OWNER TO postgres;

--
-- Name: specification_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.specification_items_id_seq OWNED BY public.specification_items.id;


--
-- Name: specifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.specifications (
    id integer NOT NULL,
    name character varying(200) NOT NULL,
    product_id integer NOT NULL,
    quantity numeric(10,3) DEFAULT 1 NOT NULL
);


ALTER TABLE public.specifications OWNER TO postgres;

--
-- Name: specifications_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.specifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.specifications_id_seq OWNER TO postgres;

--
-- Name: specifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.specifications_id_seq OWNED BY public.specifications.id;


--
-- Name: cost_calculation_items id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cost_calculation_items ALTER COLUMN id SET DEFAULT nextval('public.cost_calculation_items_id_seq'::regclass);


--
-- Name: cost_calculations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cost_calculations ALTER COLUMN id SET DEFAULT nextval('public.cost_calculations_id_seq'::regclass);


--
-- Name: nomenclature id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nomenclature ALTER COLUMN id SET DEFAULT nextval('public.nomenclature_id_seq'::regclass);


--
-- Name: order_items id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items ALTER COLUMN id SET DEFAULT nextval('public.order_items_id_seq'::regclass);


--
-- Name: orders id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders ALTER COLUMN id SET DEFAULT nextval('public.orders_id_seq'::regclass);


--
-- Name: prices id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prices ALTER COLUMN id SET DEFAULT nextval('public.prices_id_seq'::regclass);


--
-- Name: production_output id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.production_output ALTER COLUMN id SET DEFAULT nextval('public.production_output_id_seq'::regclass);


--
-- Name: productions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productions ALTER COLUMN id SET DEFAULT nextval('public.productions_id_seq'::regclass);


--
-- Name: specification_items id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.specification_items ALTER COLUMN id SET DEFAULT nextval('public.specification_items_id_seq'::regclass);


--
-- Name: specifications id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.specifications ALTER COLUMN id SET DEFAULT nextval('public.specifications_id_seq'::regclass);


--
-- Data for Name: contractors; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.contractors (id, name, inn, address, phone, is_buyer, is_supplier) FROM stdin;
000000001	ООО "Поставка"		г.Пятигорск	+79198634592	t	t
000000002	ООО "Кинотеатр Квант"	26320045123	г. Железноводск, ул. Мира, 123	+79884581555	f	t
000000008	ООО "Новый JDTO"	26320045111	г. Железноводсу	+79884581555	f	t
000000003	ООО "Ромашка"	4140784214	г. Омск, ул. Строителей, 294	+79882584546	t	f
000000009	ООО "Ипподром"	5874045632	г. Уфа, ул. Набережная, 37	+79627486389	t	t
000000010	ООО "Ассоль"	2629011278	г. Калуга, ул. Пушкина, 94	+79184572398	t	f
\.


--
-- Data for Name: cost_calculation_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cost_calculation_items (id, calculation_id, material_id, quantity, price) FROM stdin;
\.


--
-- Data for Name: cost_calculations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cost_calculations (id, product_id, specification_id, total, date) FROM stdin;
\.


--
-- Data for Name: nomenclature; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.nomenclature (id, name, unit, type) FROM stdin;
1	Сметана классическая 15% 540г.	шт	product
2	Кефир 2,5% 900г.	шт	product
3	Кефир 3,2% 900г.	шт	product
4	Молоко 2,5% 900г.	шт	product
5	Молоко нормализованное	кг	material
6	Закваска сметанная	кг	material
\.


--
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_items (id, order_id, product_id, quantity, price) FROM stdin;
1	1	2	12.000	80.00
2	1	3	9.000	82.00
3	1	4	10.000	79.00
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orders (id, number, date, contractor_id) FROM stdin;
1	Заказ покупателя № 2 от 6 июня 2025 г.	2025-06-06	000000010
\.


--
-- Data for Name: prices; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.prices (id, nomenclat_id, price, date) FROM stdin;
1	5	34.00	2025-06-01
2	6	45.00	2025-06-01
\.


--
-- Data for Name: production_output; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.production_output (id, production_id, product_id, specification_id, quantity) FROM stdin;
\.


--
-- Data for Name: productions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.productions (id, number, date, order_id) FROM stdin;
\.


--
-- Data for Name: specification_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.specification_items (id, specification_id, material_id, quantity) FROM stdin;
1	1	5	0.900
2	1	6	0.070
3	2	5	0.900
4	2	6	0.060
5	3	5	0.900
6	3	6	0.060
7	4	5	0.900
\.


--
-- Data for Name: specifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.specifications (id, name, product_id, quantity) FROM stdin;
1	Основная Сметана 15%	1	1.000
2	Спецификация Кефир 2,5%	2	1.000
3	Спецификация Кефир 3,2%	3	1.000
4	Спецификация Молоко 2,5%	4	1.000
\.


--
-- Name: cost_calculation_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cost_calculation_items_id_seq', 1, false);


--
-- Name: cost_calculations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cost_calculations_id_seq', 1, false);


--
-- Name: nomenclature_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.nomenclature_id_seq', 1, false);


--
-- Name: order_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.order_items_id_seq', 1, false);


--
-- Name: orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.orders_id_seq', 1, false);


--
-- Name: prices_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.prices_id_seq', 1, false);


--
-- Name: production_output_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.production_output_id_seq', 1, false);


--
-- Name: productions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.productions_id_seq', 1, false);


--
-- Name: specification_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.specification_items_id_seq', 1, false);


--
-- Name: specifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.specifications_id_seq', 1, false);


--
-- Name: contractors contractors_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contractors
    ADD CONSTRAINT contractors_pkey PRIMARY KEY (id);


--
-- Name: cost_calculation_items cost_calculation_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cost_calculation_items
    ADD CONSTRAINT cost_calculation_items_pkey PRIMARY KEY (id);


--
-- Name: cost_calculations cost_calculations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cost_calculations
    ADD CONSTRAINT cost_calculations_pkey PRIMARY KEY (id);


--
-- Name: nomenclature nomenclature_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nomenclature
    ADD CONSTRAINT nomenclature_pkey PRIMARY KEY (id);


--
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: prices prices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prices
    ADD CONSTRAINT prices_pkey PRIMARY KEY (id);


--
-- Name: production_output production_output_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.production_output
    ADD CONSTRAINT production_output_pkey PRIMARY KEY (id);


--
-- Name: productions productions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productions
    ADD CONSTRAINT productions_pkey PRIMARY KEY (id);


--
-- Name: specification_items specification_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.specification_items
    ADD CONSTRAINT specification_items_pkey PRIMARY KEY (id);


--
-- Name: specifications specifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.specifications
    ADD CONSTRAINT specifications_pkey PRIMARY KEY (id);


--
-- Name: idx_cost_calculation_items_calc; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_cost_calculation_items_calc ON public.cost_calculation_items USING btree (calculation_id);


--
-- Name: idx_cost_calculations_product; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_cost_calculations_product ON public.cost_calculations USING btree (product_id);


--
-- Name: idx_order_items_order; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_order_items_order ON public.order_items USING btree (order_id);


--
-- Name: idx_orders_contractor; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_orders_contractor ON public.orders USING btree (contractor_id);


--
-- Name: idx_prices_nomenclature; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_prices_nomenclature ON public.prices USING btree (nomenclat_id);


--
-- Name: idx_production_output_production; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_production_output_production ON public.production_output USING btree (production_id);


--
-- Name: idx_specification_items_spec; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_specification_items_spec ON public.specification_items USING btree (specification_id);


--
-- Name: idx_specifications_product; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_specifications_product ON public.specifications USING btree (product_id);


--
-- Name: cost_calculation_items cost_calculation_items_calculation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cost_calculation_items
    ADD CONSTRAINT cost_calculation_items_calculation_id_fkey FOREIGN KEY (calculation_id) REFERENCES public.cost_calculations(id) ON DELETE CASCADE;


--
-- Name: cost_calculation_items cost_calculation_items_material_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cost_calculation_items
    ADD CONSTRAINT cost_calculation_items_material_id_fkey FOREIGN KEY (material_id) REFERENCES public.nomenclature(id) ON DELETE RESTRICT;


--
-- Name: cost_calculations cost_calculations_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cost_calculations
    ADD CONSTRAINT cost_calculations_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.nomenclature(id) ON DELETE RESTRICT;


--
-- Name: cost_calculations cost_calculations_specification_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cost_calculations
    ADD CONSTRAINT cost_calculations_specification_id_fkey FOREIGN KEY (specification_id) REFERENCES public.specifications(id) ON DELETE RESTRICT;


--
-- Name: orders fk_orders_contractor; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT fk_orders_contractor FOREIGN KEY (contractor_id) REFERENCES public.contractors(id);


--
-- Name: order_items order_items_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- Name: order_items order_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.nomenclature(id) ON DELETE RESTRICT;


--
-- Name: prices prices_nomenclat_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.prices
    ADD CONSTRAINT prices_nomenclat_id_fkey FOREIGN KEY (nomenclat_id) REFERENCES public.nomenclature(id) ON DELETE CASCADE;


--
-- Name: production_output production_output_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.production_output
    ADD CONSTRAINT production_output_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.nomenclature(id) ON DELETE RESTRICT;


--
-- Name: production_output production_output_production_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.production_output
    ADD CONSTRAINT production_output_production_id_fkey FOREIGN KEY (production_id) REFERENCES public.productions(id) ON DELETE CASCADE;


--
-- Name: production_output production_output_specification_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.production_output
    ADD CONSTRAINT production_output_specification_id_fkey FOREIGN KEY (specification_id) REFERENCES public.specifications(id) ON DELETE RESTRICT;


--
-- Name: productions productions_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.productions
    ADD CONSTRAINT productions_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE SET NULL;


--
-- Name: specification_items specification_items_material_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.specification_items
    ADD CONSTRAINT specification_items_material_id_fkey FOREIGN KEY (material_id) REFERENCES public.nomenclature(id) ON DELETE RESTRICT;


--
-- Name: specification_items specification_items_specification_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.specification_items
    ADD CONSTRAINT specification_items_specification_id_fkey FOREIGN KEY (specification_id) REFERENCES public.specifications(id) ON DELETE CASCADE;


--
-- Name: specifications specifications_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.specifications
    ADD CONSTRAINT specifications_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.nomenclature(id) ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

\unrestrict mCouRPhpZZJ1evDIZrvZZDHdyGQ028rD5j5rPsekNUS4eao79qJQM3WMfW4koz2

