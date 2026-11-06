-- Entorno academico con datos sinteticos.
-- Se permiten nulos en tiempo y fecha para evaluar
-- la limpieza de datos en la capa Silver.
--
-- Cada ejecucion reinicia exclusivamente las tres
-- tablas del proyecto y vuelve a cargar los CSV.
-- ============================================================


-- ============================================================
-- 0. REINICIAR LAS TABLAS DEL PROYECTO
-- ============================================================

DROP TABLE IF EXISTS pasos;
DROP TABLE IF EXISTS participantes;
DROP TABLE IF EXISTS puntos_control;


-- ============================================================
-- 1. PARTICIPANTES
-- ============================================================

CREATE TABLE participantes (
    id_participante SERIAL PRIMARY KEY,
    chip_id VARCHAR(50) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    categoria VARCHAR(10) NOT NULL,
    edicion INT NOT NULL,

    CONSTRAINT uq_chip_edicion
        UNIQUE (chip_id, edicion)
);


-- ============================================================
-- 2. PUNTOS DE CONTROL
-- ============================================================

CREATE TABLE puntos_control (
    id_punto SERIAL PRIMARY KEY,
    nombre VARCHAR(20) NOT NULL UNIQUE,
    distancia_km NUMERIC(6,3) NOT NULL
);


-- ============================================================
-- 3. REGISTROS RFID
-- ============================================================

CREATE TABLE pasos (
    id_paso BIGSERIAL PRIMARY KEY,

    id_participante INT NOT NULL,
    id_punto INT NOT NULL,

    -- Permite tiempos nulos para simular datos incompletos.
    -- Tambien admite tiempos negativos o iguales a cero.
    tiempo_acumulado_segundos INT,

    -- Permite fechas nulas para simular lecturas incompletas.
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_pasos_participante
        FOREIGN KEY (id_participante)
        REFERENCES participantes(id_participante),

    CONSTRAINT fk_pasos_punto
        FOREIGN KEY (id_punto)
        REFERENCES puntos_control(id_punto),

    CONSTRAINT uq_corredor_punto
        UNIQUE (id_participante, id_punto)
);


-- ============================================================
-- 4. CATALOGO DE PUNTOS DE CONTROL
-- ============================================================

INSERT INTO puntos_control (
    id_punto,
    nombre,
    distancia_km
)
VALUES
    (1, 'K5',    5.000),
    (2, 'K10',  10.000),
    (3, 'K15',  15.000),
    (4, 'K21',  21.000),
    (5, 'K30',  30.000),
    (6, 'META', 42.195)
ON CONFLICT DO NOTHING;


-- ============================================================
-- 5. SINCRONIZAR SECUENCIA DE CHECKPOINTS
-- ============================================================

SELECT setval(
    pg_get_serial_sequence(
        'puntos_control',
        'id_punto'
    ),
    (SELECT MAX(id_punto) FROM puntos_control)
);