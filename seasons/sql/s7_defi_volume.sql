with swaps as (
  select * from parsed.dex_swap_parsed dsp 
  where swap_utime  >= 1732705200 and swap_utime < 1734433200
  and volume_usd > 0
), rainbow_traces as (
  select distinct trace_id from swaps where referral_address =upper('0:413d5ae7e18e85d05722e23d265ee4805e6443784fa764244822742c342f7fff')
), rainbow_swaps as (
  select tx_hash, swap_user as address, volume_usd, swap_utime from swaps join rainbow_traces using(trace_id)
), rainbow_volume as (
  select 'rainbow' as project, address,
    sum(volume_usd) as volume_usd, count(volume_usd), min(swap_utime) as min_utime, max(swap_utime) as max_utime
  from rainbow_swaps group by 1, 2
), gaspump as (
  select tx_hash, trader_address as address, event_time,
  ton_amount / 1e9 * (select price from prices.ton_price where price_ts < event_time order by price_ts desc limit 1)
  as volume_usd from parsed.gaspump_trade
  where event_time >= 1732705200 and event_time < 1734433200
), gaspump_volume as (
  select 'gaspump' as project, address,
    sum(volume_usd) as volume_usd, count(volume_usd), min(event_time) as min_utime, max(event_time) as max_utime
  from gaspump group by 1, 2
), swapcoffee_referral_addresses as (
  select '0:99FE957A109352AFA5E9BCF69AF885644FA226AA488F7ED44C3880893F507FEF' as referral_address
  union all
  select '0:3C3A2CA0C0BA2D29E850BE9DBCE4B8D3BD5B138FA3AE1D9C440F1C53A3A3E525' as referral_address
  union all
  select '0:A814842E94C5F559C88B629ECF52BC45AB321FB1A50DA3F14B0F2D670C3D1A93' as referral_address
  union all
  select '0:A8D9FB483FAFC657D0F504F11CB499AB4A9C961348BB0EEBFD5542AB52029BFB' as referral_address
  union all
  select '0:19A22A7054B59FAA02249529AC2916E6467F9238795D747ECBE8C4AD96B3F586' as referral_address
  union all
  select '0:FFB817D0AF446BDBF81B05594312009BE8227E764A132ACED108A799CAD7DFC5' as referral_address
  union all
  select '0:B25B654A46851C5545E5F6973D015E69ADDAD06BDECC314AF9B4D36F0ED121EA' as referral_address
  union all
  select '0:5576DCF154B0EF74AE0C3B982888D7865C9E26D1FB03DFCBB66E8FFDF7FC8A37' as referral_address
  union all
  select '0:9BA0BDF7B79182F40F100DBC4FEF0A91D212153A10E6010C03D272560B67BA4F' as referral_address
  union all
  select '0:E904CB739D2D2D5ED3AC87E7476C291DA78F517A1F7A247C62B710D22CF50050' as referral_address
  union all
  select '0:06FE05FEA040552CE0090CFA9A93A53FECF7639B71F8EB4ABEDBE8398C9A98B7' as referral_address
  union all
  select '0:B67E0727EF8865A6F0B16D576D6798135523961D76075465DBA82F6E07924141' as referral_address
  union all
  select '0:9709D1D0BBD1D037E7C42133143D503C21C101E73D143245E5362DA62FA86534' as referral_address
  union all
  select '0:9377B76695282372355B58F39C95DA1E5C180FE8D9997119E94085A58A86DEDF' as referral_address
  union all
  select '0:085C1BC2C8561D4D35DD8E035E739BF2FBD4E39EAB30FE527E445272036E4CAF' as referral_address
), swapcoffee_traces as (
  select distinct trace_id from swaps 
  join swapcoffee_referral_addresses using(referral_address)
), swapcoffee_swaps as (
  select tx_hash, swap_user as address, volume_usd, swap_utime from swaps join swapcoffee_traces using(trace_id)
), swapcoffee_volume as (
  select 'swap.coffee' as project, address,
    sum(volume_usd) as volume_usd, count(volume_usd), min(swap_utime) as min_utime, max(swap_utime) as max_utime
  from swapcoffee_swaps group by 1, 2
), memepads_projects as (
  select 'TONPump by HOT Wallet' as project, upper('0:71ae4a9bf6c55518156a349cc95bd94370ac2186079a9a404936dd678e0a3fb5') as partner_address
  union all
  select 'Blum' as project, upper('0:c2705ca692beefa522895cc0522c3ca88c95d32298e427583e66319c211090ea') as partner_address
  union all
  select 'BigPump by PocketFi' as project, upper('0:3ddbd4759309d89ca5e5d3b5cff3071c70c2f49cd27ea96d01b5f0094264ae95') as partner_address
  union all
  select 'Wagmi' as project, upper('0:4ad7249b18ed2bcd96efe6f8e3d0dedcdf3d17678f8faaee2e5c305ef3618564') as partner_address
), memepads_trades as (
  select project, tx_hash, trader_address as address, event_time,
  ton_amount / 1e9 * (select price from prices.ton_price where price_ts < event_time order by price_ts desc limit 1) as volume_usd
  from parsed.tonfun_bcl_trade
  join memepads_projects using (partner_address)
  where event_time >= 1732705200 and event_time < 1734433200
), memepads_volume as (
  select project, address,
    sum(volume_usd) as volume_usd, count(volume_usd), min(event_time) as min_utime, max(event_time) as max_utime
  from memepads_trades group by 1, 2
), moki_traces as (
  select distinct trace_id from swaps where referral_address = '0:4DF40C3711AB8B7143D28E44D5FC198B77E6D76B102E8B06A4EFDCE3B3C83EF0'
), moki_swaps as (
  select tx_hash, swap_user as address, volume_usd, swap_utime from swaps join moki_traces using(trace_id)
), moki_volume as (
  select 'Moki' as project, address,
    sum(volume_usd) as volume_usd, count(volume_usd), min(swap_utime) as min_utime, max(swap_utime) as max_utime
  from moki_swaps group by 1, 2
), titan_traces as (
  select distinct trace_id from swaps where referral_address = '0:4F9174B92BE97346C53A4B3FFEA8EED46D7535F1055A62B27510C99D9017CF69'
), titan_swaps as (
  select tx_hash, swap_user as address, volume_usd, swap_utime from swaps join titan_traces using(trace_id)
), titan_volume as (
  select 'Titan' as project, address,
    sum(volume_usd) as volume_usd, count(volume_usd), min(swap_utime) as min_utime, max(swap_utime) as max_utime
  from titan_swaps group by 1, 2
), degens as (
  select distinct address from tol.enrollment_degen ed 
), volume_points as (
  select *, floor(volume_usd / 20.) * 1 as points from rainbow_volume
  union all
  select *, floor(volume_usd / 20.) * 5 as points from gaspump_volume
  union all
  select *, floor(volume_usd / 20.) * 1 as points from swapcoffee_volume
  union all
  select *, floor(volume_usd / 20.) * 5 as points from memepads_volume
  union all
  select *, floor(volume_usd / 20.) * 1 as points from moki_volume
  union all
  select *, floor(volume_usd / 20.) * 1 as points from titan_volume
)
select extract(epoch from now())::integer as score_time, address, project, points, volume_usd as "value", "count", min_utime, max_utime
from volume_points
join degens using(address)