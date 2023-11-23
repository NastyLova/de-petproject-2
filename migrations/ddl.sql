DROP TABLE IF EXISTS public.shipping_info;
DROP TABLE IF EXISTS public.shipping_country_rates;
DROP TABLE IF EXISTS public.shipping_agreement;
DROP TABLE IF EXISTS public.shipping_transfer;
DROP TABLE IF EXISTS public.shipping_status;

CREATE TABLE public.shipping_country_rates (
	id serial NOT NULL,
	shipping_country varchar NOT NULL,
	shipping_country_base_rate double precision NOT NULL,
	CONSTRAINT shipping_country_rates_id_pkey PRIMARY KEY (id),
	CONSTRAINT shipping_country_rates_shipping_country_base_rate_unkey UNIQUE (shipping_country,shipping_country_base_rate)
);

CREATE TABLE public.shipping_agreement (
	agreement_id bigint NOT NULL,
	agreement_number varchar NOT NULL,
	agreement_rate double precision NOT NULL,
	agreement_commission numeric(14, 2) NOT NULL,
	CONSTRAINT shipping_agreement_agreement_id_pkey PRIMARY KEY (agreement_id)
);

CREATE TABLE public.shipping_transfer (
	id serial NOT NULL,
	transfer_type varchar(10) NOT NULL,
	transfer_model varchar NOT NULL,
	shipping_transfer_rate double precision NOT NULL,
	CONSTRAINT shipping_transfer_pk PRIMARY KEY (id)
);

CREATE TABLE public.shipping_info (
	shipping_id bigint NOT NULL,
	shipping_country_rates bigint NOT NULL,
	shipping_agreement bigint NOT NULL,
	shipping_transfer bigint NOT NULL,
	shipping_plan_datetime timestamp NOT NULL,
	payment_amount numeric(14, 2) NOT NULL,
	vendor_id bigint NOT NULL,
	CONSTRAINT shipping_info_pk PRIMARY KEY (shipping_id),
	CONSTRAINT shipping_info_shipping_country_rates_fkey FOREIGN KEY (shipping_country_rates) REFERENCES public.shipping_country_rates(id),
	CONSTRAINT shipping_info_shipping_agreement_fkey FOREIGN KEY (shipping_agreement) REFERENCES public.shipping_agreement(agreement_id),
	CONSTRAINT shipping_info_shipping_transfer_fkey FOREIGN KEY (shipping_transfer) REFERENCES public.shipping_transfer(id)
);

CREATE TABLE public.shipping_status (
	shipping_id int8 NOT NULL,
	status varchar NOT NULL,
	state varchar NOT NULL,
	shipping_start_fact_datetime timestamp NOT NULL,
	shipping_end_fact_datetime timestamp NULL,
	CONSTRAINT shipping_status_pk PRIMARY KEY (shipping_id)
);
