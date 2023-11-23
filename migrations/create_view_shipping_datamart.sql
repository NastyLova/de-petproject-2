-- Финальная витрина
create or replace view shipping_datamart as
select si.shipping_id, 
		si.vendor_id,
		st.transfer_type,
		case when ss.shipping_end_fact_datetime is not null 
			 then extract(day from ss.shipping_end_fact_datetime - ss.shipping_start_fact_datetime)
			 end as full_day_at_shipping,
		case when ss.shipping_end_fact_datetime > si.shipping_plan_datetime then 1
			 when ss.shipping_end_fact_datetime <= si.shipping_plan_datetime then 0
			 else null end is_delay,
		case when ss.status = 'finished' then 1 else 0 end is_shipping_finish,
		case when ss.shipping_end_fact_datetime > si.shipping_plan_datetime 
			 then extract(day from coalesce(ss.shipping_end_fact_datetime, CURRENT_TIMESTAMP) - si.shipping_plan_datetime)
			 else 0 end delay_day_at_shipping,
		si.payment_amount,
		si.payment_amount * (scr.shipping_country_base_rate + sa.agreement_rate + shipping_transfer_rate) as vat,
		si.payment_amount * sa.agreement_commission as profit
from public.shipping_info si 
inner join public.shipping_transfer st on st.id  = si.shipping_transfer 
inner join public.shipping_status ss on ss.shipping_id = si.shipping_id 
inner join public.shipping_country_rates scr on scr.id = si.shipping_country_rates 
inner join public.shipping_agreement sa on sa.agreement_id  = si.shipping_agreement;
