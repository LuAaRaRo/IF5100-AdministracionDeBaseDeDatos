CREATE DATABASE BDDistribuida_MX;
GO

USE BDDistribuida_MX;
GO

-- =====================================================
-- TABLA DE CLIENTES DE MÉXICO
-- Ejemplo de fragmentación horizontal:
-- Esta sede solo guarda clientes de México.
-- =====================================================

CREATE TABLE ClientesMX (
    IdCliente INT PRIMARY KEY,
    Nombre VARCHAR(100),
    Pais VARCHAR(50),
    Ciudad VARCHAR(100),
    CONSTRAINT CK_ClientesMX_Pais CHECK (Pais = 'México')
);
GO

-- =====================================================
-- TABLA DE VENTAS DE MÉXICO
-- Cada sede guarda sus propias ventas.
-- =====================================================

CREATE TABLE VentasMX (
    IdVenta INT PRIMARY KEY,
    IdCliente INT,
    Producto VARCHAR(100),
    Monto DECIMAL(10,2),
    Fecha DATE,
    FOREIGN KEY (IdCliente) REFERENCES ClientesMX(IdCliente)
);
GO

-- =====================================================
-- TABLA PARA FRAGMENTACIÓN VERTICAL
-- Aquí se guarda solo la información de contacto.
-- Los datos básicos del cliente estarán en la computadora.
-- =====================================================

CREATE TABLE ContactoClientes (
    IdCliente INT PRIMARY KEY,
    Telefono VARCHAR(20),
    Correo VARCHAR(100),
    Direccion VARCHAR(150)
);
GO

-- =====================================================
-- TABLA REPLICADA
-- Esta misma tabla también va a existir en la computadora.
-- Sirve para explicar replicación.
-- =====================================================

CREATE TABLE ProductosReplicados (
    IdProducto INT PRIMARY KEY,
    NombreProducto VARCHAR(100),
    Precio DECIMAL(10,2)
);
GO

-- =====================================================
-- INSERTAR DATOS DE CLIENTES MÉXICO
-- =====================================================

INSERT INTO ClientesMX VALUES
(4, 'Luis Hernández', 'México', 'Ciudad de México'),
(5, 'Ana Torres', 'México', 'Guadalajara'),
(6, 'Pedro González', 'México', 'Monterrey');
GO

-- =====================================================
-- INSERTAR VENTAS MÉXICO
-- =====================================================

INSERT INTO VentasMX VALUES
(4, 4, 'Monitor', 180000, '2026-06-01'),
(5, 5, 'Impresora', 95000, '2026-06-02'),
(6, 6, 'Audífonos', 30000, '2026-06-03');
GO

-- =====================================================
-- INSERTAR DATOS DE CONTACTO
-- Estos datos se unirán con los datos básicos guardados
-- en la computadora.
-- =====================================================

INSERT INTO ContactoClientes VALUES
(1, '8888-1111', 'carlos@email.com', 'San José, Costa Rica'),
(2, '8888-2222', 'maria@email.com', 'Cartago, Costa Rica'),
(3, '8888-3333', 'jose@email.com', 'Alajuela, Costa Rica');
GO

-- =====================================================
-- INSERTAR PRODUCTOS REPLICADOS
-- Esta información también estará en la computadora.
-- =====================================================

INSERT INTO ProductosReplicados VALUES
(1, 'Laptop', 450000),
(2, 'Mouse', 12000),
(3, 'Teclado', 25000);
GO

-- =====================================================
-- CONSULTAS LOCALES DE LA VM
-- =====================================================

SELECT * FROM ClientesMX;
SELECT * FROM VentasMX;
SELECT * FROM ContactoClientes;
SELECT * FROM ProductosReplicados;