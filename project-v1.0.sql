
-- Creación de tabla Usuario
CREATE TABLE usuario (
    usuario_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    correo_electronico VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    rol VARCHAR(20) CHECK (rol IN ('diseñador', 'cliente', 'administrador')) NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Creación tabla Perfil de Medidas
CREATE TABLE perfil_medidas (
    perfil_id SERIAL PRIMARY KEY,
    usuario_id INT REFERENCES usuario(usuario_id) ON DELETE CASCADE,
    nombre_perfil VARCHAR(100),
    altura DECIMAL(5,2),
    pecho DECIMAL(5,2),
    cintura DECIMAL(5,2),
    cadera DECIMAL(5,2),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Creación tabla Plantilla de Prenda
CREATE TABLE plantilla_prenda (
    plantilla_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100),
    descripcion TEXT,
    tipo_ropa VARCHAR(50),
    tipo_cuerpo VARCHAR(50)
);

-- Creación tabla Material
CREATE TABLE material (
    material_id SERIAL PRIMARY KEY,
    nombre VARCHAR(50),
    descripcion TEXT
);

-- Tabla intermedia Plantilla_Material
CREATE TABLE plantilla_material (
    plantilla_id INT REFERENCES plantilla_prenda(plantilla_id) ON DELETE CASCADE,
    material_id INT REFERENCES material(material_id) ON DELETE CASCADE,
    PRIMARY KEY (plantilla_id, material_id)
);

-- Creación tabla Pedido Personalizado
CREATE TABLE pedido_personalizado (
    pedido_id SERIAL PRIMARY KEY,
    usuario_id INT REFERENCES usuario(usuario_id) ON DELETE CASCADE,
    plantilla_id INT REFERENCES plantilla_prenda(plantilla_id),
    material_id INT REFERENCES material(material_id),
    color VARCHAR(50),
    ajustes TEXT,
    notas TEXT,
    estado_pedido VARCHAR(20) CHECK (estado_pedido IN ('pendiente', 'diseño', 'produccion', 'entrega', 'completado', 'cancelado')) DEFAULT 'pendiente',
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Creación tabla Visualización 3D
CREATE TABLE visualizacion_3d (
    visualizacion_id SERIAL PRIMARY KEY,
    pedido_id INT REFERENCES pedido_personalizado(pedido_id) ON DELETE CASCADE,
    url_recurso VARCHAR(255),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tiempo_generacion INT,
    estado_visualizacion VARCHAR(20) CHECK (estado_visualizacion IN ('generado', 'pendiente', 'error')) DEFAULT 'pendiente'
);

-- Tabla Historial Estado del Pedido
CREATE TABLE historial_estado (
    historial_id SERIAL PRIMARY KEY,
    pedido_id INT REFERENCES pedido_personalizado(pedido_id) ON DELETE CASCADE,
    estado VARCHAR(20),
    fecha_cambio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notas_adicionales TEXT
);

-- Tabla Mensajes sobre Pedidos
CREATE TABLE mensaje_pedido (
    mensaje_id SERIAL PRIMARY KEY,
    pedido_id INT REFERENCES pedido_personalizado(pedido_id) ON DELETE CASCADE,
    usuario_id INT REFERENCES usuario(usuario_id) ON DELETE SET NULL,
    mensaje TEXT,
    fecha_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla Archivo Adjunto para Mensajes
CREATE TABLE archivo_adjunto (
    archivo_id SERIAL PRIMARY KEY,
    mensaje_id INT REFERENCES mensaje_pedido(mensaje_id) ON DELETE CASCADE,
    url_archivo VARCHAR(255),
    tipo_archivo VARCHAR(50)
);

-- Tabla Valoraciones de Pedidos
CREATE TABLE valoracion_pedido (
    valoracion_id SERIAL PRIMARY KEY,
    pedido_id INT REFERENCES pedido_personalizado(pedido_id) ON DELETE CASCADE,
    calificacion INT CHECK (calificacion BETWEEN 1 AND 5),
    comentario TEXT,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla Transacciones de Pago
CREATE TABLE transaccion_pago (
    transaccion_id SERIAL PRIMARY KEY,
    pedido_id INT REFERENCES pedido_personalizado(pedido_id) ON DELETE CASCADE,
    monto DECIMAL(10,2),
    fecha_pago TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metodo_pago VARCHAR(50),
    numero_autorizacion VARCHAR(100),
    nit VARCHAR(15),
    nombre_cliente VARCHAR(100)
);

-- Índices recomendados para rendimiento
CREATE INDEX idx_usuario_correo ON usuario(correo_electronico);
CREATE INDEX idx_pedido_usuario ON pedido_personalizado(usuario_id);
CREATE INDEX idx_pedido_estado ON pedido_personalizado(estado_pedido);
CREATE INDEX idx_historial_pedido ON historial_estado(pedido_id);
CREATE INDEX idx_mensaje_pedido ON mensaje_pedido(pedido_id);


-- Insertar datos de prueba
-- Usuarios
INSERT INTO usuario (nombre, correo_electronico, password_hash, rol) VALUES
('Juan Pérez', 'juan@cliente.com', 'hash123', 'cliente'),
('María García', 'maria@disenador.com', 'hash456', 'diseñador'),
('Admin Sistema', 'admin@empresa.com', 'hash789', 'administrador');

-- Perfiles de Medidas
INSERT INTO perfil_medidas (usuario_id, nombre_perfil, altura, pecho, cintura, cadera) VALUES
(1, 'Mi perfil principal', 1.75, 95.5, 80.0, 98.0),
(2, 'Perfil diseñador', 1.68, 88.0, 72.5, 94.5);

-- Plantillas de Prenda
INSERT INTO plantilla_prenda (nombre, descripcion, tipo_ropa, tipo_cuerpo) VALUES
('Camisa Slim Fit', 'Camisa formal ajustada', 'camisa', 'athletic'),
('Vestido Verano', 'Vestido ligero para clima cálido', 'vestido', 'hourglass'),
('Pantalón Skinny', 'Pantalón ajustado moderno', 'pantalon', 'slim');

-- Materiales
INSERT INTO material (nombre, descripcion) VALUES
('Algodón Orgánico', 'Tejido 100% algodón certificado'),
('Seda Natural', 'Seda premium de alta calidad'),
('Poliéster Reciclado', 'Material ecológico reciclado');

-- Relación Plantilla-Material
INSERT INTO plantilla_material (plantilla_id, material_id) VALUES
(1, 1), (1, 3),  -- Camisa Slim Fit usa Algodón y Poliéster
(2, 2),           -- Vestido Verano usa Seda
(3, 1), (3, 3);   -- Pantalón Skinny usa ambos materiales

-- Pedidos Personalizados
INSERT INTO pedido_personalizado (usuario_id, plantilla_id, material_id, color, ajustes, notas, estado_pedido) VALUES
(1, 1, 1, 'azul marino', 'Ajustar mangas 2cm', 'Urgente para evento', 'produccion'),
(1, 2, 2, 'blanco', 'Reducir escote 5cm', 'Regalo de cumpleaños', 'completado'),
(2, 3, 3, 'negro', '', 'Pedido de muestra', 'pendiente');

-- Visualizaciones 3D
INSERT INTO visualizacion_3d (pedido_id, url_recurso, tiempo_generacion, estado_visualizacion) VALUES
(1, 'https://storage.com/modelos/3d/camisa-azul', 45, 'generado'),
(2, 'https://storage.com/modelos/3d/vestido-blanco', 38, 'generado'),
(3, NULL, NULL, 'pendiente');

-- Historial de Estados
INSERT INTO historial_estado (pedido_id, estado, notas_adicionales) VALUES
(1, 'pendiente', 'Pedido recibido'),
(1, 'diseño', 'En proceso de diseño'),
(1, 'produccion', 'En taller de confección'),
(2, 'pendiente', 'Pedido recibido'),
(2, 'completado', 'Entregado con éxito'),
(3, 'pendiente', 'Esperando confirmación de materiales');