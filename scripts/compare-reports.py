"""
Compare Reports - Zero Trust Network Sandbox
Compara resultados de escaneos entre Docker Compose y Kubernetes.
"""

import json
import sys
from pathlib import Path


def load_report(filepath):
    """Carga un reporte JSON desde un archivo."""
    try:
        with open(filepath, "r") as f:
            return json.load(f)
    except FileNotFoundError:
        print(f"ERROR: No se encontró el archivo {filepath}")
        return None
    except json.JSONDecodeError:
        print(f"ERROR: {filepath} no es un JSON válido")
        return None


def main():
    """Compara reportes de Compose vs Kubernetes."""

    print("")
    print("=" * 60)
    print("Comparación de Reportes - Compose vs Kubernetes")
    print("=" * 60)
    print("")

    # Rutas de los reportes
    compose_path = Path("reports/compose-connectivity.json")
    k8s_path = Path("reports/k8s-connectivity.json")

    # Cargar reportes
    print("Cargando reportes...")
    compose_report = load_report(compose_path)
    k8s_report = load_report(k8s_path)

    if not compose_report or not k8s_report:
        print("ERROR: No se pudieron cargar ambos reportes")
        sys.exit(1)

    print(f" Compose: {compose_path}")
    print(f" K8s:     {k8s_path}")
    print("")

    # Extraer métricas
    compose_open = compose_report["summary"]["open"]
    k8s_open = k8s_report["summary"]["open"]

    compose_closed = compose_report["summary"]["closed"]
    k8s_closed = k8s_report["summary"]["closed"]

    total_targets = compose_report["total_targets"]

    # Calcular reducción
    if compose_open > 0:
        reduction_percent = ((compose_open - k8s_open) / compose_open) * 100
    else:
        reduction_percent = 0

    # Mostrar comparación
    print("=" * 60)
    print("RESULTADOS")
    print("=" * 60)
    print("")
    print(f"Total de targets escaneados: {total_targets}")
    print("")
    print("Docker Compose (sin NetworkPolicies):")
    print(f"  Puertos abiertos:  {compose_open}")
    print(f"  Puertos cerrados:  {compose_closed}")
    print("")
    print("Kubernetes (con NetworkPolicies):")
    print(f"  Puertos abiertos:  {k8s_open}")
    print(f"  Puertos cerrados:  {k8s_closed}")
    print("")
    print("=" * 60)
    print(f"Reducción de superficie de ataque: {reduction_percent:.1f}%")
    print("=" * 60)
    print("")

    # Generar reporte de comparación
    comparison = {
        "comparison_date": compose_report["scan_date"],
        "compose": {
            "environment": "docker-compose",
            "open": compose_open,
            "closed": compose_closed,
            "total": total_targets,
        },
        "kubernetes": {
            "environment": "kubernetes",
            "open": k8s_open,
            "closed": k8s_closed,
            "total": total_targets,
        },
        "reduction": {
            "absolute": compose_open - k8s_open,
            "percentage": round(reduction_percent, 2),
        },
    }

    # Guardar reporte de comparación
    output_path = Path("reports/comparison.json")
    with open(output_path, "w") as f:
        json.dump(comparison, f, indent=2)

    print(f" Reporte de comparación guardado: {output_path}")
    print("")

    # Mensaje final
    if k8s_open == 0:
        print(" EXITO: Zero Trust implementado correctamente")
        print("  el attacker no puede acceder a ningún servicio")
    else:
        print(" ADVERTENCIA: Aun hay puertos accesibles")
        print(f"  {k8s_open} puertos siguen abiertos desde attacker")

    print("")


if __name__ == "__main__":
    main()
