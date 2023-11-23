-- Заполняем данными shipping_country_rates, только уникальные пары значений
insert into
	public.shipping_country_rates (shipping_country,
	shipping_country_base_rate)
select distinct s.shipping_country, 
		s.shipping_country_base_rate
from public.shipping s;

-- Заполняем данными shipping_agreement, значения строки уникальны
insert into public.shipping_agreement 
select cols[1]::bigint as agreement_id, 
		cols[2]::varchar as agreement_number,
		cols[3]::numeric as agreement_rate, 
		cols[4]::numeric as agreement_commission
from (
select distinct regexp_split_to_array(s.vendor_agreement_description, '\:+') cols
from public.shipping s
) t
order by agreement_id;

-- Заполняем данными shipping_transfer, значения строки уникальны
insert into public.shipping_transfer (transfer_type, transfer_model, shipping_transfer_rate)
select cols[1] as transfer_type,
		cols[2] as transfer_model,
		shipping_transfer_rate
from (
	select distinct regexp_split_to_array(s.shipping_transfer_description, '\:+') cols, shipping_transfer_rate 
	from public.shipping s) t;

-- Заполняем таблицу с заказами shipping_info
insert into public.shipping_info 
select s.shipping_id, 
		scr.id as shipping_country_rates, 
		sa.agreement_id as shipping_agreement, 
		st.id as shipping_transfer, 
		s.shipping_plan_datetime, 
		s.payment_amount, 
		s.vendor_id 
from (select distinct shipping_country,
			shipping_id,
			regexp_split_to_array(vendor_agreement_description, '\:+') cols_sa,
			regexp_split_to_array(shipping_transfer_description, '\:+') cols_st,
			shipping_transfer_rate,
			shipping_plan_datetime,
			payment_amount,
			vendor_id
	from public.shipping) s --324770 
inner join public.shipping_country_rates scr on scr.shipping_country = s.shipping_country 
inner join public.shipping_agreement sa on sa.agreement_id  = cols_sa[1]::bigint 
	and sa.agreement_number = cols_sa[2]::varchar
	and sa.agreement_rate = cols_sa[3]::numeric
	and sa.agreement_commission  = cols_sa[4]::numeric
inner join public.shipping_transfer st on st.transfer_type = cols_st[1]
and st.transfer_model = cols_st[2]
and st.shipping_transfer_rate  = s.shipping_transfer_rate;

-- Наполняем данными таблицу статусов shipping_status
insert into public.shipping_status 
with s2 as (select shipping_id, 
			FIRST_VALUE (status) OVER (PARTITION BY shipping_id ORDER BY state_datetime DESC) status,
			FIRST_VALUE (state) OVER (PARTITION BY shipping_id ORDER BY state_datetime DESC) state
			from public.shipping)

select s.shipping_id,
		s2.status,
		s2.state,
		max(CASE WHEN s.state = 'booked' THEN s.state_datetime END) AS shipping_start_fact_datetime,
		max(CASE WHEN s.state = 'recieved' THEN s.state_datetime END) AS shipping_end_fact_datetime
from public.shipping s
inner join s2 on s2.shipping_id = s.shipping_id 
group by s.shipping_id,
		 s2.status,
		 s2.state;