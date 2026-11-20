#!/usr/bin/env python3
import subprocess
import re
import sys

def get_network_info():
    env = {"LC_ALL": "C"}
    
    # 1. Status do rádio Wi-Fi
    wifi_enabled = "1"
    try:
        radio_out = subprocess.check_output(
            ["nmcli", "radio", "wifi"],
            env=env, text=True, timeout=1
        ).strip().lower()
        wifi_enabled = "1" if "enabled" in radio_out else "0"
    except Exception:
        wifi_enabled = "1"

    # 2. Status dos dispositivos
    net_type = "none"
    net_name = "Disconnected"
    net_iface = ""
    tailscale = "0"
    
    try:
        dev_out = subprocess.check_output(
            ["nmcli", "-t", "-f", "TYPE,STATE,CONNECTION,DEVICE", "device"],
            env=env, text=True, timeout=1
        )
        for line in dev_out.strip().split("\n"):
            parts = line.split(":")
            if len(parts) >= 4:
                t, st, conn, dev = parts[0], parts[1], parts[2], parts[3]
                if dev == "tailscale0" and "connected" in st:
                    tailscale = "1"
                elif t == "ethernet" and st == "connected":
                    net_type = "ethernet"
                    net_name = conn or "Ethernet"
                    net_iface = dev
                elif t == "wifi" and st == "connected" and net_type != "ethernet":
                    net_type = "wifi"
                    net_name = conn or "Wi-Fi"
                    net_iface = dev
    except Exception:
        pass

    # 3. Wi-Fi SSID real e sinal em %
    wifi_signal = 0
    if net_type == "wifi" and net_iface:
        # Tenta pegar via 'iw dev <iface> link' (muito mais rápido que scan)
        try:
            iw_out = subprocess.check_output(
                ["iw", "dev", net_iface, "link"],
                env=env, text=True, timeout=1
            )
            ssid_m = re.search(r"SSID:\s*(.+)", iw_out)
            if ssid_m:
                net_name = ssid_m.group(1).strip()
            
            sig_m = re.search(r"signal:\s*(-?\d+)\s*dBm", iw_out)
            if sig_m:
                dbm = int(sig_m.group(1))
                # -100 dBm = 0%, -50 dBm = 100%
                wifi_signal = min(100, max(0, int(2 * (dbm + 100))))
        except Exception:
            pass

        # Fallback de sinal via /proc/net/wireless se iw não trouxer sinal
        if wifi_signal == 0:
            try:
                with open("/proc/net/wireless", "r") as f:
                    for line in f:
                        if net_iface in line:
                            parts = line.split()
                            # coluna de qualidade: ex: "45."
                            qual = float(parts[2].replace(".", ""))
                            wifi_signal = min(100, max(0, int((qual / 70.0) * 100)))
                            break
            except Exception:
                pass

    # 4. IP global IPv4 primário
    net_ip = ""
    try:
        ip_cmd = 'ip -4 -o addr show up scope global | awk \'$2 !~ /^(docker|br-|veth|lo|tailscale)/ {split($4,a,"/"); print a[1]; exit}\''
        ip_out = subprocess.check_output(
            ["sh", "-c", ip_cmd],
            env=env, text=True, timeout=1
        ).strip()
        net_ip = ip_out
    except Exception:
        pass

    print(f"NET|{net_type}|{net_name}|{net_iface}|{net_ip}|{wifi_signal}|{tailscale}|{wifi_enabled}")

if __name__ == "__main__":
    get_network_info()
