# Maratón de Medellín (2016–2026) — Arquitectura de Datos, Mini-Lakehouse y Optimización de Consultas

**Institución Universitaria ITM** · Tópicos Avanzados en Bases de Datos (`810304008-1`)  
**Docente:** Roberto Carlos Rahamut Suteu  
**Equipo 5:** Yenifer Foronda · Kevin Castaño · Jerónimo Casas Vanegas  
**Medellín, 2026**

---

## 1. Descripción del Proyecto

Este repositorio integra la implementación reproducible del ecosistema de datos diseñado a lo largo de los Módulos 1 a 4 para la **Maratón de Medellín (ediciones 2016–2026)**, cubriendo **165,000 participantes** y **585,000 registros de pasos RFID** a través de 6 puntos de control (`K5`, `K10`, `K15`, `K21`, `K30/KM30` y `META`).

El proyecto conecta dos planos complementarios con **PostgreSQL 16** como única fuente oficial de verdad (*Single Source of Truth*):

1. **Plano Operacional y Políglota en Vivo (M1–M2):** separación de cargas mediante **PostgreSQL 16** (OLTP, `CP`), **Apache Kafka 4.3.1 KRaft** (streaming), **Redis 7.4** (*Sorted Sets* + *Hashes* para *leaderboard* submilisegundo, `AP`) y **ClickHouse** (*MergeTree* columnar para analítica en vivo, `AP`).
2. **Plano Analítico Lakehouse y Optimización (M3–M4 — ejecutable en este repositorio):** pipeline **Medallion (Bronze / Silver / Gold)** en **Apache Parquet** orquestado con Python 3.12, esquema estrella con **SCD Tipo 2** (`K30` → `KM30`), motor analítico **DuckDB** y ciclo de diagnóstico, intervención y medición con `EXPLAIN ANALYZE`.

```text
PostgreSQL 16 (OLTP)
   └──► extract.py ──► Zona Bronze (Parquet crudo + metadatos de auditoría)
                          └──► transform_silver.py ──► Zona Silver (Limpieza + reporte_calidad.txt)
                                                          └──► transform_gold.py ──► Zona Gold (Esquema Estrella + SCD Tipo 2)
                                                                                        ├──► analyze.py (5 Consultas DuckDB + Benchmark)
                                                                                        └──► Optimización M4 (Hive Partitioning + Parquet Ordenado)
