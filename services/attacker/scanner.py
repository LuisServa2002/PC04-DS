import json
import socket
import sys
from datetime import datetime


def scan_target(host, port, timeout=2):
    try:
        # Crear socket TCP
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(timeout)

        # Intentar conectar
        result = sock.connect_ex((host, port))
        sock.close()

        # Si result es 0, la conexión fue exitosa
        if result == 0:
            return "OPEN"
        else:
            return "CLOSED"

    except socket.gaierror:
        # Error de resolución DNS
        return "ERROR-DNS"
    except socket.timeout:
        # Timeout de conexión
        return "CLOSED"
    except Exception:
        # Cualquier otro error
        return "ERROR"


def main():
    # Lista de targets a escanear (host, puerto, descripción)
    targets = [
        ("frontend", 80, "Frontend HTTP"),
        ("frontend", 8080, "Frontend Flask"),
        ("backend", 5000, "Backend API"),
        ("backend", 5432, "Backend DB (simulado)"),
    ]

    print("Iniciando escaneo de red...", file=sys.stderr)
    print(f"Fecha: {datetime.now().isoformat()}", file=sys.stderr)
    print(f"Targets: {len(targets)}", file=sys.stderr)
    print("", file=sys.stderr)

    results = []

    for host, port, description in targets:
        target_str = f"{host}:{port}"
        print(f"Escaneando {target_str} ({description})...", file=sys.stderr)

        status = scan_target(host, port)

        result = {
            "target": target_str,
            "host": host,
            "port": port,
            "description": description,
            "status": status,
        }

        results.append(result)

        # Mostrar resultado en stderr (no interferir con JSON en stdout)
        status_symbol = "✓" if status == "OPEN" else "✗"
        print(f"  {status_symbol} {target_str}: {status}", file=sys.stderr)

    print("", file=sys.stderr)
    print("Escaneo completado", file=sys.stderr)

    # Generar reporte JSON
    report = {
        "scan_date": datetime.now().isoformat(),
        "scanner": "attacker",
        "environment": "docker-compose",
        "total_targets": len(targets),
        "results": results,
    }

    # Calcular estadísticas
    open_count = sum(1 for r in results if r["status"] == "OPEN")
    closed_count = sum(1 for r in results if r["status"] == "CLOSED")
    error_count = sum(1 for r in results if "ERROR" in r["status"])

    report["summary"] = {
        "open": open_count,
        "closed": closed_count,
        "errors": error_count,
    }

    # Imprimir JSON a stdout (esto es lo que se captura en el reporte)
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()