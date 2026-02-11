-- public.flat_rates definition

-- Drop table

-- DROP TABLE public.flat_rates;

CREATE TABLE public.flat_rates (
	id bigserial NOT NULL,
	sub_package_id int8 NOT NULL,
	source_id int8 NOT NULL,
	vehicle_submodel_id int8 NOT NULL,
	manufacture_id int8 NOT NULL,
	vehicle_age_from int4 NOT NULL,
	vehicle_age_to int4 NOT NULL,
	term int4 NOT NULL,
	flat_rate_per_term numeric(10, 2) NOT NULL,
	created_at timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
	created_by varchar(100) NOT NULL,
	updated_at timestamp NULL,
	updated_by varchar(100) NULL,
	deleted_at timestamp NULL,
	deleted_by varchar(100) NULL,
	CONSTRAINT flat_rates_pkey PRIMARY KEY (id)
);
CREATE INDEX idx_flat_rates_manufacture_id ON public.flat_rates USING btree (manufacture_id);
CREATE INDEX idx_flat_rates_source_id ON public.flat_rates USING btree (source_id);
CREATE INDEX idx_flat_rates_sub_package_id ON public.flat_rates USING btree (sub_package_id);
CREATE INDEX idx_flat_rates_vehicle_submodel_id ON public.flat_rates USING btree (vehicle_submodel_id);