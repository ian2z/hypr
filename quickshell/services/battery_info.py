#!/usr/bin/env python3
import os

def read_val(b, f):
    try:
        with open(f'/sys/class/power_supply/{b}/{f}') as fp:
            return fp.read().strip()
    except Exception:
        return ''

def main():
    b0_c = int(read_val('BAT0', 'capacity') or 0)
    b0_s = read_val('BAT0', 'status') or 'Discharging'
    b0_en = float(read_val('BAT0', 'energy_now') or 0)
    b0_ef = float(read_val('BAT0', 'energy_full') or 0)
    b0_p = float(read_val('BAT0', 'power_now') or 0)

    b1_c = int(read_val('BAT1', 'capacity') or 0)
    b1_s = read_val('BAT1', 'status') or 'Discharging'
    b1_en = float(read_val('BAT1', 'energy_now') or 0)
    b1_ef = float(read_val('BAT1', 'energy_full') or 0)
    b1_p = float(read_val('BAT1', 'power_now') or 0)

    total_p = b0_p + b1_p
    total_en = b0_en + b1_en
    total_ef = b0_ef + b1_ef

    is_charging = ('Charging' in (b0_s, b1_s))

    def fmt_time(en, p, charging=False, ef=0):
        if p <= 0:
            return ''
        hrs = max(0, ef - en) / p if charging else en / p
        h = int(hrs)
        m = int((hrs - h) * 60)
        return f'{h}h {m}m'

    t_b0 = fmt_time(b0_en, b0_p, b0_s == 'Charging', b0_ef)
    t_b1 = fmt_time(b1_en, b1_p, b1_s == 'Charging', b1_ef)
    t_total = fmt_time(total_en, total_p, is_charging, total_ef)

    print(f"BAT|{b0_c}|{b0_s}|{t_b0}|{b1_c}|{b1_s}|{t_b1}|{t_total}|{1 if is_charging else 0}")

if __name__ == '__main__':
    main()
