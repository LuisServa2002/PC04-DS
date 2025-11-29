#!/usr/bin/env python3
# services/attacker/scanner.py
"""
Network Scanner - Zero Trust Network Sandbox
Escanea servicios para validar segmentacion de red.
"""

import json
import os
import socket
import sys
from datetime import datetime


def scan_target(host, port, timeout=2):
    """
    Intenta conectarse a un target especifico.

    Args:
        host (str): Hostname del target
        port (int): Puerto a escanear
        timeout (int): Timeout en segundos

    Returns:
        str: Estado de la conexion
    """
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(timeout)
        result = sock.connect_ex((host, port))
        sock.close()

        if result == 0:
            return "OPEN"
        else:
            return "CLOSED"

    except socket.gaierror:
        return "ERROR-DNS"
    except socket.timeout:
        return "TIMEOUT"
    except Exception:
        return "ERROR"


def main():
    """Ejecuta el escaneo y genera reporte JSON."""

    # Detectar entorno
    scan_mode = os.getenv("SCAN_MODE", "compose")
    
    # Targets según entorno
    if scan_mode == "kubernetes":
        targets = [
            ("frontend.zero-trust-lab.svc.cluster.local", 8080, "Frontend Flask"),
            ("backend.zero-trust-lab.svc.cluster.local", 5000, "Backend API"),
            ("backend.zero-trust-lab.svc.cluster.local", 5432, "Backend DB (simulado)"),
        ]
    else:
        # Targets originales para Docker Compose
        targets = [
            ("frontend", 8080, "Frontend Flask"),
            ("backend", 5000, "Backend API"),
            ("backend", 5432, "Backend DB (simulado)"),
        ]

    # Mensaje de inicio en stderr
    print("=" * 60, file=sys.stderr)
    print("Network Scanner - Zero Trust Network Sandbox", file=sys.stderr)
    print("=" * 60, file=sys.stderr)
    print(f"Fecha: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}", file=sys.stderr)
    print(f"Entorno: {scan_mode}", file=sys.stderr)
    print(f"Total de targets: {len(targets)}", file=sys.stderr)
    print("", file=sys.stderr)

    results = []
    open_count = 0
    closed_count = 0
    error_count = 0

    for host, port, description in targets:
        target_str = f"{host}:{port}"
        print(
            f"Escaneando {target_str:25} ({description})...", end=" ", file=sys.stderr
        )

        status = scan_target(host, port)

        result = {
            "target": target_str,
            "host": host,
            "port": port,
            "description": description,
            "status": status,
        }

        results.append(result)

        # Contadores
        if status == "OPEN":
            open_count += 1
            symbol = "[OK]"
        elif status in ["CLOSED", "TIMEOUT"]:
            closed_count += 1
            symbol = "[X]"
        else:
            error_count += 1
            symbol = "[!]"

        print(f"{symbol} {status}", file=sys.stderr)

    print("", file=sys.stderr)
    print("=" * 60, file=sys.stderr)
    print("RESUMEN DEL ESCANEO", file=sys.stderr)
    print("=" * 60, file=sys.stderr)
    print(f"Puertos abiertos:    {open_count}", file=sys.stderr)
    print(f"Puertos cerrados:    {closed_count}", file=sys.stderr)
    print(f"Errores:             {error_count}", file=sys.stderr)
    print("=" * 60, file=sys.stderr)

    # Generar reporte JSON
    report = {
        "scan_date": datetime.now().isoformat(),
        "scanner": "attacker",
        "environment": "docker-compose",
        "total_targets": len(targets),
        "summary": {"open": open_count, "closed": closed_count, "errors": error_count},
        "results": results,
    }

    # Output JSON a stdout
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
