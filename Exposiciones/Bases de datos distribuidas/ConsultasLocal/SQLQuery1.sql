CREATE DATABASE BDDistribuida_CR;
GO

USE BDDistribuida_CR;
GO

-- =====================================================
-- TABLA DE CLIENTES DE COSTA RICA
-- Esta sede solo guarda clientes de Costa Rica.
-- =====================================================

CREATE TABLE ClientesCR (
    IdCliente INT PRIMARY KEY,
    Nombre VARCHAR(100),
    Pais VARCHAR(50),
    Ciudad VARCHAR(100),
    CONSTRAINT CK_ClientesCR_Pais CHECK (Pais = 'Costa Rica')
);
GO

-- =====================================================
-- TABLA DE VENTAS DE COSTA RICA
-- =====================================================

CREATE TABLE VentasCR (
    IdVenta INT PRIMARY KEY,
    IdCliente INT,
    Producto VARCHAR(100),
    Monto DECIMAL(10,2),
    Fecha DATE,
    FOREIGN KEY (IdCliente) REFERENCES ClientesCR(IdCliente)
);
GO

-- =====================================================
-- TABLA PARA FRAGMENTACIÓN VERTICAL
-- =====================================================

CREATE TABLE DatosBasicosClientes (
    IdCliente INT PRIMARY KEY,
    Nombre VARCHAR(100),
    Cedula VARCHAR(20),
    Pais VARCHAR(50)
);
GO

-- =====================================================
-- TABLA REPLICADA
-- =====================================================

CREATE TABLE ProductosReplicados (
    IdProducto INT PRIMARY KEY,
    NombreProducto VARCHAR(100),
    Precio DECIMAL(10,2)
);
GO

-- =====================================================
-- INSERTAR DATOS DE CLIENTES COSTA RICA
-- =====================================================

INSERT INTO ClientesCR VALUES
(1, 'Carlos Ramírez', 'Costa Rica', 'San José'),
(2, 'María Fernández', 'Costa Rica', 'Cartago'),
(3, 'José Vargas', 'Costa Rica', 'Alajuela');
GO

-- =====================================================
-- INSERTAR VENTAS COSTA RICA
-- =====================================================

INSERT INTO VentasCR VALUES
(1, 1, 'Laptop', 450000, '2026-06-01'),
(2, 2, 'Mouse', 12000, '2026-06-02'),
(3, 3, 'Teclado', 25000, '2026-06-03');
GO

-- =====================================================
-- INSERTAR DATOS BÁSICOS DE CLIENTES
-- =====================================================

INSERT INTO DatosBasicosClientes VALUES
(1, 'Carlos Ramírez', '1-1111-1111', 'Costa Rica'),
(2, 'María Fernández', '2-2222-2222', 'Costa Rica'),
(3, 'José Vargas', '3-3333-3333', 'Costa Rica');
GO

-- =====================================================
-- INSERTAR PRODUCTOS REPLICADOS
-- =====================================================

INSERT INTO ProductosReplicados VALUES
(1, 'Laptop', 450000),
(2, 'Mouse', 12000),
(3, 'Teclado', 25000);
GO

-- =====================================================
-- CONSULTAS LOCALES DE LA COMPUTADORA
-- =====================================================

SELECT * FROM ClientesCR;
SELECT * FROM VentasCR;
SELECT * FROM DatosBasicosClientes;
SELECT * FROM ProductosReplicados;

