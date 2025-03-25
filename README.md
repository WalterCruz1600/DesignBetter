# Documentación de la Base de Datos - Design Better

## Descripción General
Este documento describe la estructura de la base de datos diseñada para la tienda de ropa, incluyendo la definición de tablas, relaciones y restricciones clave.

## Documentación - Historial Versiones

El historial de versiones del documento adjunto se encuentra en el siguiente enlace:

https://uvggt-my.sharepoint.com/:w:/g/personal/piv23574_uvg_edu_gt/EWtkRutOnO9Ouz51C8ldecQB1yIibMX0fIUvLK9rvnsYmA?e=sjwwy7

## Diseño de la Base de Datos
La base de datos sigue un modelo relacional que permite gestionar usuarios, perfiles de medidas, plantillas de prendas, materiales, pedidos personalizados, visualizaciones 3D, historial de estados, mensajes y transacciones de pago.

## Tablas y Definiciones

### **Tabla `usuario`**
Gestiona la información de los usuarios registrados.
```sql
CREATE TABLE usuario (
    usuario_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    correo_electronico VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    rol VARCHAR(20) CHECK (rol IN ('diseñador', 'cliente', 'administrador')) NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### **Tabla `perfil_medidas`**
Almacena las medidas de los clientes para personalizar los pedidos.
```sql
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
```

### **Tabla `plantilla_prenda`**
Define las plantillas de prendas disponibles.
```sql
CREATE TABLE plantilla_prenda (
    plantilla_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100),
    descripcion TEXT,
    tipo_ropa VARCHAR(50),
    tipo_cuerpo VARCHAR(50)
);
```

### **Tabla `material`**
Contiene información sobre los materiales disponibles.
```sql
CREATE TABLE material (
    material_id SERIAL PRIMARY KEY,
    nombre VARCHAR(50),
    descripcion TEXT
);
```

### **Tabla `plantilla_material`**
Relación entre plantillas de prendas y materiales utilizados.
```sql
CREATE TABLE plantilla_material (
    plantilla_id INT REFERENCES plantilla_prenda(plantilla_id) ON DELETE CASCADE,
    material_id INT REFERENCES material(material_id) ON DELETE CASCADE,
    PRIMARY KEY (plantilla_id, material_id)
);
```

### **Tabla `pedido_personalizado`**
Almacena los pedidos personalizados realizados por los clientes.
```sql
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
```

### **Tabla `visualizacion_3d`**
Almacena las visualizaciones 3D generadas para los pedidos.
```sql
CREATE TABLE visualizacion_3d (
    visualizacion_id SERIAL PRIMARY KEY,
    pedido_id INT REFERENCES pedido_personalizado(pedido_id) ON DELETE CASCADE,
    url_recurso VARCHAR(255),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tiempo_generacion INT,
    estado_visualizacion VARCHAR(20) CHECK (estado_visualizacion IN ('generado', 'pendiente', 'error')) DEFAULT 'pendiente'
);
```

### **Tabla `historial_estado`**
Registra el historial de cambios de estado de los pedidos.
```sql
CREATE TABLE historial_estado (
    historial_id SERIAL PRIMARY KEY,
    pedido_id INT REFERENCES pedido_personalizado(pedido_id) ON DELETE CASCADE,
    estado VARCHAR(20),
    fecha_cambio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notas_adicionales TEXT
);
```

### **Tabla `mensaje_pedido`**
Permite la comunicación entre clientes y diseñadores sobre un pedido.
```sql
CREATE TABLE mensaje_pedido (
    mensaje_id SERIAL PRIMARY KEY,
    pedido_id INT REFERENCES pedido_personalizado(pedido_id) ON DELETE CASCADE,
    usuario_id INT REFERENCES usuario(usuario_id) ON DELETE SET NULL,
    mensaje TEXT,
    fecha_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### **Tabla `archivo_adjunto`**
Almacena archivos adjuntos en los mensajes de pedidos.
```sql
CREATE TABLE archivo_adjunto (
    archivo_id SERIAL PRIMARY KEY,
    mensaje_id INT REFERENCES mensaje_pedido(mensaje_id) ON DELETE CASCADE,
    url_archivo VARCHAR(255),
    tipo_archivo VARCHAR(50)
);
```

### **Tabla `valoracion_pedido`**
Guarda valoraciones y comentarios sobre los pedidos completados.
```sql
CREATE TABLE valoracion_pedido (
    valoracion_id SERIAL PRIMARY KEY,
    pedido_id INT REFERENCES pedido_personalizado(pedido_id) ON DELETE CASCADE,
    calificacion INT CHECK (calificacion BETWEEN 1 AND 5),
    comentario TEXT,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### **Tabla `transaccion_pago`**
Registra las transacciones de pago realizadas.
```sql
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
```

## Optimización con Índices
Para mejorar el rendimiento, se crearon los siguientes índices:
```sql
CREATE INDEX idx_usuario_correo ON usuario(correo_electronico);
CREATE INDEX idx_pedido_usuario ON pedido_personalizado(usuario_id);
CREATE INDEX idx_pedido_estado ON pedido_personalizado(estado_pedido);
CREATE INDEX idx_historial_pedido ON historial_estado(pedido_id);
CREATE INDEX idx_mensaje_pedido ON mensaje_pedido(pedido_id);
```
